import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/provider_models.dart';

class ProviderService {
  final String accessToken;

  const ProviderService(this.accessToken);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

  Future<Map<String, dynamic>> _get(String endpoint) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 30));

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['detail'] ?? 'Unable to load provider data');
    }

    return data;
  }

  Future<ProviderSummary> getSummary() async {
    final data = await _get('/provider/summary');
    return ProviderSummary.fromJson(data);
  }

  Future<List<Customer>> getCustomers() async {
    final data = await _get('/provider/customers');
    return (data['customers'] as List)
        .map((item) => Customer.fromJson(item))
        .toList();
  }

  Future<List<SolarDevice>> getDevices() async {
    final data = await _get('/provider/devices');
    return (data['devices'] as List)
        .map((item) => SolarDevice.fromJson(item))
        .toList();
  }

  Future<List<PaymentRecord>> getPayments() async {
    final data = await _get('/provider/payments');
    return (data['payments'] as List)
        .map((item) => PaymentRecord.fromJson(item))
        .toList();
  }
}