import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

const commerceStates = ['Abia','Adamawa','Akwa Ibom','Anambra','Bauchi','Bayelsa','Benue','Borno','Cross River','Delta','Ebonyi','Edo','Ekiti','Enugu','Gombe','Imo','Jigawa','Kaduna','Kano','Katsina','Kebbi','Kogi','Kwara','Lagos','Nasarawa','Niger','Ogun','Ondo','Osun','Oyo','Plateau','Rivers','Sokoto','Taraba','Yobe','Zamfara','FCT'];

int? nairaToKobo(String text) {
  final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(text.trim());
  if (match == null) return null;
  final whole = int.tryParse(match.group(1)!);
  if (whole == null || whole > 1000000000) return null;
  return whole * 100 + int.parse((match.group(2) ?? '').padRight(2, '0'));
}

String commerceMoney(int kobo) {
  final naira = (kobo ~/ 100).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  return '₦$naira.${(kobo % 100).toString().padLeft(2, '0')}';
}

class CommerceProduct {
  const CommerceProduct({required this.id, required this.name, required this.description, required this.category, required this.imageUrl, required this.priceKobo, required this.stock, this.sellerId});
  final int id, priceKobo, stock;
  final int? sellerId;
  final String name, description, category, imageUrl;
  factory CommerceProduct.fromJson(Map<String,dynamic> j) => CommerceProduct(id:(j['id'] as num).toInt(), name:j['name'] as String, description:j['description'] as String, category:j['category'] as String, imageUrl:j['image_url'] as String, priceKobo:(j['price_kobo'] as num).toInt(), stock:(j['stock'] as num).toInt(), sellerId:(j['seller_id'] as num?)?.toInt());
}

class CommerceApiException implements Exception {
  const CommerceApiException(this.status, this.message);
  final int status;
  final String message;
  @override
  String toString() => message;
}

class CommerceApi {
  CommerceApi({http.Client? client, String? baseUrl}) : _client = client ?? http.Client(), baseUrl = baseUrl ?? const String.fromEnvironment('COMMERCE_API_BASE_URL', defaultValue: String.fromEnvironment('SELLER_API_BASE_URL', defaultValue: ApiConfig.baseUrl));
  final http.Client _client;
  final String baseUrl;
  void close() => _client.close();
  Future<dynamic> call(String method, String path, {Map<String,dynamic>? body, String? token}) async {
    final request = http.Request(method, Uri.parse('${baseUrl.replaceFirst(RegExp(r'/$'), '')}/$path'));
    request.headers['Content-Type'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) request.body = jsonEncode(body);
    final response = await http.Response.fromStream(await _client.send(request).timeout(const Duration(seconds:30))).timeout(const Duration(seconds:30));
    dynamic data;
    try { data = jsonDecode(response.body); } catch (_) { throw Exception('The service is unavailable. Please try again.'); }
    if (response.statusCode >= 400) {
      if (response.statusCode == 401) throw const CommerceApiException(401, 'Sign in to product services to continue.');
      final detail = data is Map ? data['detail'] : null;
      throw CommerceApiException(response.statusCode, detail is String ? detail : 'Please check the information entered and try again.');
    }
    return data;
  }
  Future<List<CommerceProduct>> catalogue() async => (await call('GET','commerce/catalogue') as List).map((j) {
    final data = Map<String,dynamic>.from(j as Map);
    final image = data['image_url'] as String;
    if (RegExp(r'^/seller/photos/[0-9a-f]{32}$').hasMatch(image)) {
      data['image_url'] = '${baseUrl.replaceFirst(RegExp(r'/$'), '')}$image';
    }
    SolarLanguage.instance.registerPublicText([data['name'] as String, data['description'] as String, data['category'] as String]);
    return CommerceProduct.fromJson(data);
  }).toList();
}

class CommerceBasket extends ChangeNotifier {
  static final instance = CommerceBasket();
  static const storageKey = 'imad_product_basket_v1';
  final Map<int,int> _items = {};
  Future<void>? _loading;
  Future<void> _writes = Future.value();
  Future<void> flush() => _writes;
  Map<int,int> get items => Map.unmodifiable(_items);
  int get count => _items.values.fold(0, (a,b) => a+b);
  int get revision => _revision;
  int _revision = 0;
  Future<void> init() => _loading ??= _load();
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    try {
      final data = jsonDecode(p.getString(storageKey) ?? '{}') as Map;
      for (final entry in data.entries) {
        final id = int.tryParse(entry.key.toString()); final quantity = entry.value;
        if (id != null && id > 0 && quantity is int && quantity > 0 && quantity <= 100) _items[id] = quantity;
      }
    } catch (_) { _items.clear(); }
    notifyListeners();
  }
  void setQuantity(int id, int quantity) {
    if (id <= 0 || quantity < 0 || quantity > 100) throw ArgumentError('Invalid basket quantity');
    if (quantity == 0) { _items.remove(id); } else { _items[id] = quantity; }
    _revision++; notifyListeners();
    final encoded = jsonEncode({for (final e in _items.entries) e.key.toString():e.value});
    _writes = _writes.catchError((Object _) {}).then((_) async {
      final p = await SharedPreferences.getInstance(); await p.setString(storageKey, encoded);
    }).catchError((Object _) {});
  }
  void add(CommerceProduct p) {
    final quantity = (_items[p.id] ?? 0)+1;
    if (quantity > p.stock || quantity > 100) throw StateError('No more available stock for this product.');
    setQuantity(p.id,quantity);
  }
  List<Map<String,int>> requestItems() => [for(final e in _items.entries) {'product_id':e.key,'quantity':e.value}];
}
