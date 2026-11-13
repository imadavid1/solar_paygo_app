import 'package:solar_paygo_app/l10n/solar_language.dart';
import '../commerce/commerce_management_screen.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth_session.dart';

import '../marketplace/marketplace_widgets.dart';
import '../marketplace/marketplace_theme.dart';

// Seller sign-in is deliberately separate from the customer purchase session.
class SellerCentreScreen extends StatefulWidget {
  const SellerCentreScreen({super.key, required this.section, required this.onCustomerAccess});
  final String section;
  final VoidCallback onCustomerAccess;
  @override
  State<SellerCentreScreen> createState() => _SellerCentreScreenState();
}

class _SellerCentreScreenState extends State<SellerCentreScreen> {
  static AuthSession? _session;
  final _form = GlobalKey<FormState>();
  final _fields = <String, TextEditingController>{};
  Map<String, dynamic>? _profile;
  List<dynamic> _products = [], _tickets = [];
  bool _busy = false, _register = false, _accepted = false;
  bool _loaded = false;
  Uint8List? _selectedPhoto;
  String? _selectedPhotoName;
  String _category = 'Solar panels', _topic = 'Registration';
  int? _editing;
  String? _error;
  TextEditingController c(String key) => _fields.putIfAbsent(key, TextEditingController.new);
  bool get application => widget.section == 'Become a Seller';
  bool get listing => widget.section == 'List Your Products';
  @override
  void initState() { super.initState(); if (_session != null) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _run(_refresh); }); }
  @override
  void dispose() { for (final field in _fields.values) { field.dispose(); } super.dispose(); }

  Future<dynamic> _api(String method, String path, [Map<String, dynamic>? body]) async {
    const sellerApi = String.fromEnvironment('SELLER_API_BASE_URL', defaultValue: ApiConfig.baseUrl);
    final suffix = path.startsWith('account:') ? path.substring(8) : 'seller/$path';
    final uri = Uri.parse('$sellerApi/$suffix');
    final headers = {'Content-Type': 'application/json', if (_session != null) 'Authorization': 'Bearer ${_session!.accessToken}'};
    final response = await (method == 'GET' ? http.get(uri, headers: headers)
      : method == 'PUT' ? http.put(uri, headers: headers, body: jsonEncode(body))
      : http.post(uri, headers: headers, body: jsonEncode(body))).timeout(const Duration(seconds: 30));
    if (response.statusCode == 401 || response.statusCode == 403 && response.body.contains('Not authenticated')) {
      _session = null;
      throw Exception('Your session expired. Please sign in again.');
    }
    dynamic data;
    try { data = jsonDecode(response.body); } catch (_) {
      throw Exception('Seller services are unavailable. Check that the backend seller update has been installed.');
    }
    if (response.statusCode >= 400) {
      final detail = data is Map ? data['detail'] : null;
      if (response.statusCode == 404) throw Exception('Seller services are not installed on this backend yet.');
      throw Exception(detail is String ? detail : 'Please check the information entered and try again.');
    }
    return data;
  }

  String _photoUrl(String value) {
    if (!RegExp(r'^/seller/photos/[0-9a-f]{32}$').hasMatch(value)) return value;
    const base = String.fromEnvironment('SELLER_API_BASE_URL', defaultValue: ApiConfig.baseUrl);
    return '${base.replaceFirst(RegExp(r'/$'), '')}$value';
  }

  Future<void> _choosePhoto(ImageSource source) async {
    await _run(() async {
      final file = await ImagePicker().pickImage(source: source);
      if (file == null || !mounted) return;
      if (await file.length() > 8 * 1024 * 1024) throw Exception('Choose a photo no larger than 8 MB.');
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() { _selectedPhoto = bytes; _selectedPhotoName = file.name; });
    });
  }

  Future<void> _uploadPhoto() async {
    await _run(() async {
      final bytes = _selectedPhoto;
      final token = _session?.accessToken;
      if (bytes == null) return;
      if (token == null) throw Exception('Sign in before uploading a photo.');
      const base = String.fromEnvironment('SELLER_API_BASE_URL', defaultValue: ApiConfig.baseUrl);
      final response = await http.post(Uri.parse('${base.replaceFirst(RegExp(r'/$'), '')}/seller/photos'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/octet-stream'}, body: bytes).timeout(const Duration(seconds: 60));
      if (response.statusCode == 401) { _session = null; throw Exception('Your session expired. Please sign in again.'); }
      dynamic data;
      try { data = jsonDecode(response.body); } catch (_) { throw Exception('Photo upload is unavailable. Check that the backend update is installed.'); }
      if (response.statusCode >= 400) throw Exception(data is Map && data['detail'] is String ? data['detail'] : 'Photo upload failed. Please try again.');
      final path = data['image_url'] as String;
      if (!RegExp(r'^/seller/photos/[0-9a-f]{32}$').hasMatch(path)) throw Exception('The upload returned an invalid photo address.');
      if (!mounted) return;
      setState(() { c('image').text = path; _selectedPhoto = null; _selectedPhotoName = null; });
      _notice('Photo uploaded. Save your draft to attach it to this product.');
    });
  }

  Widget _photoInput() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Wrap(spacing: 12, runSpacing: 12, children: [
      _button('Choose photo', () => _choosePhoto(ImageSource.gallery)),
      if (kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS))
        _button('Take photo', () => _choosePhoto(ImageSource.camera)),
    ]),
    const SizedBox(height: 12),
    const SolarText('JPG, PNG or WebP, up to 8 MB. Use a photo you own or have permission to display.', style: TextStyle(fontSize: 12, color: MarketColors.muted)),
    if (_selectedPhoto != null) ...[
      const SizedBox(height: 16),
      Image.memory(_selectedPhoto!, width: 180, height: 140, fit: BoxFit.contain,
        errorBuilder: (_, error, stack) => const SolarText('Photo preview unavailable. Choose a JPG, PNG or WebP file.')),
      const SizedBox(height: 8), SolarText(_selectedPhotoName ?? 'Selected photo'),
      const SizedBox(height: 12),
      Wrap(spacing: 12, children: [
        _button('Upload photo', _uploadPhoto, solid: true),
        _button('Cancel selection', () => setState(() { _selectedPhoto = null; _selectedPhotoName = null; })),
      ]),
      const SizedBox(height: 12), const SolarText('Upload this photo before saving the draft.'),
    ],
    const SizedBox(height: 16),
    _field('image', 'Photo address (uploaded automatically, or paste HTTPS URL)', optional: true),
    if (c('image').text.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 16), child:
      Image.network(_photoUrl(c('image').text.trim()), width: 180, height: 140, fit: BoxFit.contain,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        errorBuilder: (_, error, stack) => const SolarText('Photo could not load. Check the photo address.'))),
  ]);

  Future<void> _refresh() async {
    _profile = await _api('GET', 'profile') as Map<String, dynamic>?;
    if (listing && _profile != null) _products = await _api('GET', 'products') as List<dynamic>;
    if (!application && !listing) _tickets = await _api('GET', 'tickets') as List<dynamic>;
    _loaded = true;
    if (mounted) setState(() {});
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() { _busy = true; _error = null; });
    try { await action(); } catch (e) { if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', '')); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  void _notice(String text) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: SolarText(text))); }
  void _navigate(String title) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SellerCentreScreen(section: title, onCustomerAccess: widget.onCustomerAccess)));

  Widget _field(String key, String label, {int lines = 1, bool optional = false, bool password = false, TextInputType? keyboard}) => Padding(
    padding: const EdgeInsets.only(bottom: 16), child: TextFormField(controller: c(key), obscureText: password,
    minLines: lines, maxLines: lines, keyboardType: keyboard,
    decoration: SolarInputDecoration(labelText: label, filled: true, fillColor: const Color(0xFFF6FBFD),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MarketColors.line))),
    validator: SolarLanguage.validation<String>((value) {
      final text = (value ?? '').trim();
      if (!optional && text.isEmpty) return 'Please enter $label';
      if (key == 'email' && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) return 'Enter a valid email address';
      if (password && _register && text.length < 8) return 'Use at least 8 characters';
      if (key == 'price' && (double.tryParse(text) == null || double.parse(text) <= 0 || !double.parse(text).isFinite)) return 'Enter a valid positive price';
      if (key == 'stock' && (int.tryParse(text) == null || int.parse(text) < 0)) return 'Enter a whole number, zero or more';
      if ((key == 'description' || key == 'businessDescription' || key == 'message') && text.length < 20) return 'Please enter at least 20 characters';
      if (key == 'image' && text.isNotEmpty && !RegExp(r'^/seller/photos/[0-9a-f]{32}$').hasMatch(text) && (Uri.tryParse(text)?.scheme != 'https' || (Uri.tryParse(text)?.host.isEmpty ?? true))) return 'Use a public HTTPS image URL';
      return null;
    })));

  Widget _button(String label, VoidCallback action, {bool solid = false}) => solid
    ? FilledButton(onPressed: _busy ? null : action, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF087AA4), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18)), child: SolarText(label))
    : OutlinedButton(onPressed: _busy ? null : action, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF087AA4), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18)), child: SolarText(label));
  Widget _box(Widget child) => Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white,
    border: Border.all(color: MarketColors.line), borderRadius: BorderRadius.circular(20)), child: child);
  Widget _title(String title, String copy) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SolarText(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: MarketColors.ink)),
    const SizedBox(height: 10), SolarText(copy, style: const TextStyle(height: 1.6, color: MarketColors.muted)), const SizedBox(height: 24)]);

  Widget _hero() {
    final copy = application ? 'Build your solar business with SolarID. Introduce your store, share your expertise and prepare for a clear seller review.'
      : listing ? 'Your products. Your workspace. Prepare accurate listings, manage your catalogue and track review progress in one place.'
      : 'Clear answers. Practical guidance. Get help with your seller account, product listings and everyday marketplace questions.';
    return Container(decoration: BoxDecoration(color: listing ? const Color(0xFF162C3B) : null, gradient: listing ? null : const LinearGradient(colors: [Color(0xFFE8F8FE), Color(0xFFB8E9F8)])),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1280),
      child: LayoutBuilder(builder: (context, size) {
        final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SolarText('SolarID / SELLER CENTRE', style: TextStyle(fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w700, color: listing ? MarketColors.skyStrong : const Color(0xFF087AA4))),
          const SizedBox(height: 16), SolarText(widget.section, style: TextStyle(fontSize: size.maxWidth < 600 ? 34 : 48, fontWeight: FontWeight.w900, height: 1.12, color: listing ? Colors.white : MarketColors.ink)),
          const SizedBox(height: 18), SolarText(copy, style: TextStyle(fontSize: 17, height: 1.6, color: listing ? Colors.white70 : MarketColors.muted)),
          const SizedBox(height: 24), Wrap(spacing: 12, runSpacing: 12, children: [for (final title in ['Become a Seller', 'List Your Products', 'Seller Support']) if (title != widget.section) _button(title, () => _navigate(title))])]);
        final visual = _box(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(application ? Icons.storefront_outlined : listing ? Icons.inventory_2_outlined : Icons.support_agent, size: 64, color: const Color(0xFF087AA4)),
          const SizedBox(height: 22), SolarText(application ? 'Start with a strong foundation' : listing ? 'A catalogue built for confidence' : 'Support at every step', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18), for (final line in application ? ['Create or sign in to your account', 'Tell us about your business', 'Track your application status'] : listing ? ['Accurate specifications and photos', 'Naira pricing and stock availability', 'Draft, review and approval status'] : ['Registration and account guidance', 'Product and delivery help', 'Your support request history']) Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [const Icon(Icons.check_circle_outline, color: Color(0xFF087AA4), size: 20), const SizedBox(width: 10), Expanded(child: SolarText(line))]))]));
        return size.maxWidth < 850 ? Column(children: [text, const SizedBox(height: 28), visual]) : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: 6, child: text), const SizedBox(width: 64), Expanded(flex: 4, child: visual)]);
      }))));
  }

  Widget _auth() => _box(Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _title(_register ? 'Create your SolarID account' : 'Sign in to your seller workspace', 'Use your existing SolarID account, or create one to begin. Seller approval is a separate review; it does not grant provider access.'),
    if (_register) _field('name', 'Full name'), _field('email', 'Email address', keyboard: TextInputType.emailAddress),
    _field('password', 'Password', password: true),
    Wrap(spacing: 16, runSpacing: 12, children: [_button(_register ? 'Create account' : 'Sign in', () => _run(() async {
      if (!_form.currentState!.validate()) return;
      if (_register) await _api('POST', 'account:users', {'name': c('name').text, 'email': c('email').text.trim().toLowerCase(), 'password': c('password').text});
      _session = AuthSession.fromJson(Map<String, dynamic>.from(await _api('POST', 'account:login', {'email': c('email').text.trim().toLowerCase(), 'password': c('password').text})));
      c('password').clear();
      await _refresh();
    }), solid: true), TextButton(onPressed: _busy ? null : () => setState(() { _register = !_register; _error = null; }), child: SolarText(_register ? 'Already have an account? Sign in' : 'New to SolarID? Create an account'))])])));

  Widget _application() {
    if (_profile != null) return _box(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title('Your application', '${_profile!['business_name']} • ${_profile!['location']}'),
      Chip(label: SolarText('Status: ${_profile!['status']}')),
      const SizedBox(height: 16), SolarText(_profile!['review_note']?.toString().isNotEmpty == true ? _profile!['review_note'] : 'You can prepare product drafts while your business details are reviewed. Approval is required before submitting products.'),
      const SizedBox(height: 24), _button('Prepare your products', () => _navigate('List Your Products'))]));
    return _box(Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title('Tell us about your business', 'Provide accurate information. Your application starts as pending and is reviewed by an SolarID provider.'),
      _field('business', 'Business / store name'), _field('phone', 'Business phone', keyboard: TextInputType.phone),
      _field('location', 'State and city'), _field('type', 'Business type (retailer, installer, distributor...)'),
      _field('registration', 'Business registration number, if applicable', optional: true),
      _field('businessDescription', 'Products and services you offer', lines: 4),
      CheckboxListTile(contentPadding: EdgeInsets.zero, value: _accepted, onChanged: _busy ? null : (value) => setState(() => _accepted = value ?? false), title: const SolarText('I confirm that these details are accurate and that I am authorised to represent this business.')),
      const SizedBox(height: 18), _button('Submit application', () => _run(() async {
        if (!_form.currentState!.validate()) return;
        if (!_accepted) throw Exception('Please confirm the business information.');
        await _api('POST', 'application', {'business_name': c('business').text, 'phone': c('phone').text, 'location': c('location').text,
          'business_type': c('type').text, 'registration_number': c('registration').text, 'description': c('businessDescription').text, 'accepted': true});
        await _refresh(); _notice('Application received. Your status is pending review.');
      }), solid: true)])));
  }

  Map<String, dynamic> _productBody() => {'name': c('product').text, 'category': _category, 'description': c('description').text,
    'specifications': c('specifications').text, 'price': double.parse(c('price').text), 'stock': int.parse(c('stock').text),
    'image_url': c('image').text, 'warranty': c('warranty').text, 'delivery': c('delivery').text};
  void _edit(Map<String, dynamic> p) { setState(() {
    _selectedPhoto = null; _selectedPhotoName = null; _editing = p['id'] as int; _category = p['category'];
    for (final pair in {'product': 'name', 'description': 'description', 'specifications': 'specifications', 'price': 'price', 'stock': 'stock', 'image': 'image_url', 'warranty': 'warranty', 'delivery': 'delivery'}.entries) { c(pair.key).text = '${p[pair.value]}'; }
  }); _notice('Product loaded into the editor above.'); }
  void _reset() { _selectedPhoto = null; _selectedPhotoName = null; _editing = null; for (final key in ['product','description','specifications','price','stock','image','warranty','delivery']) { c(key).clear(); } }

  Widget _listings() {
    if (_profile == null) return _box(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title('Set up your seller profile first', 'Submit your business application, then return here to prepare your product catalogue.'),
      _button('Become a Seller', () => _navigate('Become a Seller'), solid: true)]));
    final editor = _box(Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title(_editing == null ? 'Add a product' : 'Edit product #$_editing', 'Save a draft first. Add a clear product photo before requesting review. Editing a submitted product returns it to draft.'),
      _field('product', 'Product name'), DropdownButtonFormField<String>(initialValue: _category, isExpanded: true,
        decoration: const SolarInputDecoration(labelText: 'Category'), items: ['Solar panels','Batteries','Inverters','Solar appliances','Portable solar','Complete systems','Accessories'].map((x) => DropdownMenuItem(value: x, child: SolarText(x))).toList(), onChanged: (x) => setState(() => _category = x!)),
      const SizedBox(height: 20), _field('description', 'Product description', lines: 4), _field('specifications', 'Capacity, dimensions and compatibility', lines: 3),
      _field('price', 'Price (₦)', keyboard: const TextInputType.numberWithOptions(decimal: true)), _field('stock', 'Stock quantity', keyboard: TextInputType.number),
      _photoInput(),
      const SizedBox(height: 18), _field('warranty', 'Warranty details'), _field('delivery', 'Delivery coverage and estimated timing'),
      Wrap(spacing: 12, runSpacing: 12, children: [_button('Preview listing', () { if (!_form.currentState!.validate()) return; showDialog<void>(context: context, builder: (ctx) => AlertDialog(title: SolarText(c('product').text), content: SizedBox(width: 450, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (c('image').text.isNotEmpty) Image.network(_photoUrl(c('image').text.trim()), webHtmlElementStrategy: WebHtmlElementStrategy.fallback, height: 170, errorBuilder: (_, error, stack) => const SolarText('Photo could not load. Check the URL.')),
        const SizedBox(height: 16), SolarText('₦${double.parse(c('price').text).toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), SolarText(c('description').text), const SizedBox(height: 12), SolarText(c('specifications').text), SolarText('Warranty: ${c('warranty').text}'), SolarText('Delivery: ${c('delivery').text}')]))), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const SolarText('Back to editor'))])); }),
      _button('Save draft', () => _run(() async {
        if (_selectedPhoto != null) throw Exception('Upload your selected photo, or cancel the selection, before saving.'); if (!_form.currentState!.validate()) return;
        await _api(_editing == null ? 'POST' : 'PUT', _editing == null ? 'products' : 'products/$_editing', _productBody());
        _reset(); await _refresh(); _notice('Product draft saved.');
      }), solid: true), if (_editing != null) _button('New product', () => setState(_reset))])])));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 12, runSpacing: 12, children: [Chip(label: SolarText('Seller: ${_profile!['status']}')), Chip(label: SolarText('${_products.length} products')), Chip(label: SolarText('${_products.where((p) => p['status'] == 'draft').length} drafts'))]),
      const SizedBox(height: 20), editor, const SizedBox(height: 36), _title('Your product catalogue', 'Only your own products appear here. Approved listings are stored in the seller catalogue; the existing public shopping catalogue is not automatically replaced.'),
      if (_products.isEmpty) const SolarText('No products yet. Add your first draft above.'),
      for (final p in _products) Padding(padding: const EdgeInsets.only(bottom: 16), child: _box(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if ('${p['image_url']}'.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 16), child: Image.network(_photoUrl(p['image_url'] as String), webHtmlElementStrategy: WebHtmlElementStrategy.fallback, width: 150, height: 110, fit: BoxFit.contain, errorBuilder: (_, error, stack) => const Icon(Icons.image_not_supported_outlined, size: 40))),
        SolarText(p['name'], style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 8), SolarText('${p['category']} · ₦${p['price']} · Stock ${p['stock']}'),
        const SizedBox(height: 12), Chip(label: SolarText(p['status'])), if ('${p['review_note']}'.isNotEmpty) SolarText(p['review_note']),
        const SizedBox(height: 16), Wrap(spacing: 12, runSpacing: 12, children: [_button('Edit', () => _edit(Map<String, dynamic>.from(p))),
          if (p['status'] == 'draft' || p['status'] == 'rejected') _button('Submit for review', () => _run(() async {
            await _api('POST', 'products/${p['id']}/submit'); await _refresh(); _notice('Product submitted for review.');
          }))])])))]);
  }

  static const _help = <String, String>{
    'How do I become a seller?': 'Create or sign in to an SolarID account, then complete the Become a Seller application. Your business information is reviewed separately from customer registration.',
    'Can I list products before approval?': 'You can save product drafts after submitting your seller application. Your business must be approved before you can submit products for review.',
    'What should a product listing include?': 'Use a clear title, category, accurate specifications, a naira price, available stock, warranty information and delivery coverage. Include a photo you have permission to use.',
    'How do I add a product photo?': 'Paste a public HTTPS URL into the product photo field and check it using Preview listing. This update does not upload photo files.',
    'What happens when I edit a listing?': 'Editing returns the listing to draft so the revised details can be reviewed again. Saving a draft does not publish it.',
    'Where do I ask about delivery or payments?': 'Open a support request with the relevant topic and provide your product or order reference. Do not include passwords, card details or secret keys.',
  };
  Widget _support() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _title('How can we help?', 'Find practical guidance or contact SolarID about your seller workspace.'),
    TextField(controller: c('search'), decoration: const SolarInputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search seller help', border: OutlineInputBorder()), onChanged: (_) => setState(() {})),
    const SizedBox(height: 20), for (final item in _help.entries.where((x) => '${x.key} ${x.value}'.toLowerCase().contains(c('search').text.toLowerCase()))) ExpansionTile(title: SolarText(item.key, style: const TextStyle(fontWeight: FontWeight.w700)), children: [Padding(padding: const EdgeInsets.all(20), child: SolarText(item.value, style: const TextStyle(height: 1.6)))]),
    const SizedBox(height: 28), _button('Contact SolarID on WhatsApp', () => _run(() async { await openImadWhatsApp('Hello SolarID, I need seller support.'); })),
    const SizedBox(height: 32), if (_session == null) _auth() else _box(Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title('Open a support request', 'Your request will be saved in the backend. You can also contact SolarID on WhatsApp; no response time is promised.'),
      DropdownButtonFormField<String>(initialValue: _topic, items: ['Registration','Product listings','Orders and delivery','Payments','Other'].map((x) => DropdownMenuItem(value: x, child: SolarText(x))).toList(), onChanged: (x) => setState(() => _topic = x!), decoration: const SolarInputDecoration(labelText: 'Topic')),
      const SizedBox(height: 20), _field('subject', 'Subject'), _field('message', 'How can we help?', lines: 5),
      _button('Send support request', () => _run(() async { if (!_form.currentState!.validate()) return;
        final ticket = await _api('POST', 'tickets', {'topic': _topic, 'subject': c('subject').text, 'message': c('message').text});
        c('subject').clear(); c('message').clear(); await _refresh(); _notice('Support request #${ticket['id']} saved.');
      }), solid: true)]))),
    if (_session != null && _tickets.isNotEmpty) ...[const SizedBox(height: 28), _title('Your requests', 'A record of your submitted enquiries.'), for (final t in _tickets) ListTile(title: SolarText('#${t['id']} · ${t['subject']}'), subtitle: SolarText('${t['topic']}${t['reply']?.toString().isNotEmpty == true ? '\nSolarID: ${t['reply']}' : ''}'), trailing: SolarText(t['status']))]]);

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MarketplaceShell(activeSection: 'Sell with us', title: widget.section, subtitle: '', onCustomerAccess: widget.onCustomerAccess,
    hero: _hero(), child: PageSection(color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_busy) const LinearProgressIndicator(),
      if (_error != null) Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(18), color: const Color(0xFFFFF0EC), child: SolarText(_error!, style: const TextStyle(color: Color(0xFF8A301B)))),
      if (_session != null) Padding(padding: const EdgeInsets.only(bottom: 24), child: Wrap(spacing: 16, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [SolarText('Signed in as ${_session!.name}'), if (_profile?['status'] == 'approved' || _session!.isProvider) _button(_session!.isProvider ? 'Product management' : 'Delivery settings', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CommerceManagementScreen(session: _session!)))), _button('Refresh', () => _run(_refresh)), _button('Sign out', () => setState(() { _session = null; _profile = null; _loaded = false; _products = []; _tickets = []; }))])),
      if (!application && !listing) _support()
      else if (_session == null) _auth()
      else if (!_loaded) _box(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_title('Connect to your seller workspace', 'Load your application and catalogue from the backend.'), _button('Load workspace', () => _run(_refresh))]))
      else if (application) _application() else _listings(),
    ]))); }
}
