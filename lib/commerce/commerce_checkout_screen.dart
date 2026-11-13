import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_theme.dart';
import 'commerce_service.dart';
import 'commerce_order_screen.dart';

/// Delivery details stay in this screen's memory, never browser storage.
class CommerceCheckoutScreen extends StatefulWidget {
  const CommerceCheckoutScreen({super.key, required this.api, required this.basket,
    required this.state, required this.city});
  final CommerceApi api;
  final CommerceBasket basket;
  final String state, city;
  @override
  State<CommerceCheckoutScreen> createState() => _CommerceCheckoutScreenState();
}

class _CommerceCheckoutScreenState extends State<CommerceCheckoutScreen> {
  static const _navy = Color(0xFF162C3B);
  final _form = GlobalKey<FormState>();
  final _fields = <String, TextEditingController>{
    for (final name in ['customer_name','email','phone','address_line1',
      'address_line2','postal_code','delivery_notes']) name: TextEditingController(),
  };
  Map<String,dynamic>? _review;
  String? _error;
  bool _busy = false;
  int _version = 0;
  String? _checkoutKey, _accessToken;
  Map<String,dynamic>? _attempt;
  @override
  void initState() {
    super.initState();
    widget.basket.addListener(_invalidate);
    for (final c in _fields.values) { c.addListener(_invalidate); }
  }
  void _invalidate() {
    _version++;
    if (mounted) setState(() { _review = null; _error = null; });
  }
  @override
  void dispose() {
    widget.basket.removeListener(_invalidate);
    for (final c in _fields.values) { c.removeListener(_invalidate); c.dispose(); }
    super.dispose();
  }
  Future<void> _check() async {
    if (!_form.currentState!.validate() || widget.basket.items.isEmpty) return;
    final version = ++_version;
    setState(() { _busy = true; _error = null; _review = null; });
    try {
      final result = Map<String,dynamic>.from(await widget.api.call(
        'POST','commerce/checkout/review',body:{
          'country':'NG','state':widget.state,'city':widget.city,
          'items':widget.basket.requestItems(),
          'customer':{for (final e in _fields.entries) e.key:e.value.text.trim()},
        }) as Map);
      if (mounted && version == _version) setState(() => _review = result);
    } catch (e) {
      if (mounted && version == _version) {
        setState(() => _error = e.toString().replaceFirst('Exception: ',''));
      }
    } finally { if (mounted) setState(() => _busy = false); }
  }
  Future<void> _saveOrder() async {
    if (_busy || (_review == null && _attempt == null)) return;
    if (_attempt == null) {
      _checkoutKey = commerceSecret(); _accessToken = commerceSecret();
      _attempt = {
        'country':'NG','state':widget.state,'city':widget.city,
        'items':widget.basket.requestItems(),
        'customer':{for(final e in _fields.entries)e.key:e.value.text.trim()},
        'expected_total_kobo':_review!['total_kobo'],
        'checkout_key':_checkoutKey,'access_token':_accessToken,
      };
    }
    setState((){_busy=true;_error=null;});
    try {
      final order=Map<String,dynamic>.from(await widget.api.call('POST','commerce/orders',body:_attempt!) as Map);
      final number=order['order_number'] as String;
      try { await CommerceOrderStore.save(number,_accessToken!); }
      catch(e) { if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:SolarText(e.toString()))); }
      if(!mounted)return;
      // Use the caller-owned API: the basket route remains mounted behind this page.
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=>CommerceOrderScreen(
        api:widget.api,number:number,token:_accessToken!,initialOrder:order)));
    } catch(e) {
      if(mounted)setState(() {
        _error=e.toString().replaceFirst('Exception: ','');
        if(e is CommerceApiException && (e.status==409 || e.status==422)) {
          _attempt=null;_checkoutKey=null;_accessToken=null;_review=null;
        }
      });
    } finally { if(mounted)setState(()=>_busy=false); }
  }
  Widget _field(String key, String label, int min, int max,
      {TextInputType? keyboard, int lines = 1}) => Padding(
    padding:const EdgeInsets.only(bottom:16),
    child:TextFormField(controller:_fields[key],enabled:!_busy && _attempt==null,
      maxLength:max,maxLines:lines,keyboardType:keyboard,
      decoration:SolarInputDecoration(labelText:label,border:const OutlineInputBorder(),counterText:''),
      validator: SolarLanguage.validation<String>((raw) {
        final value = (raw ?? '').trim();
        if (value.length < min) return 'Enter $label';
        if (value.length > max || value.codeUnits.any((c) => c < 32 || c == 127)) {
          return 'Use plain text, up to $max characters';
        }
        if (key == 'email' && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
          return 'Enter a valid email address';
        }
        if (key == 'phone') {
          final count = value.replaceAll(RegExp(r'\D'),'').length;
          if (!RegExp(r'^\+?[0-9 ()-]+$').hasMatch(value) || count < 7 || count > 15) {
            return 'Enter a phone number with 7 to 15 digits';
          }
        }
        return null;
      }),
    ),
  );
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Scaffold(
    backgroundColor:Colors.white,
    appBar:AppBar(backgroundColor:MarketColors.sky,foregroundColor:_navy,
      title:const SolarText('Delivery details')),
    body:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Center(
      child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:900),child:Column(
        crossAxisAlignment:CrossAxisAlignment.start,children:[
          const SolarText('Where should your order go?',style:TextStyle(
            fontSize:30,fontWeight:FontWeight.w800,color:_navy)),
          const SizedBox(height:12),
          SolarText('${widget.city}, ${widget.state}, Nigeria'),
          TextButton(onPressed:_busy||_attempt!=null?null:()=>Navigator.of(context).pop(),
            child:const SolarText('Change city or state')),
          const SizedBox(height:16),
          if(widget.basket.items.isEmpty)const SolarText('Your basket is empty. Return to the catalogue to add products.')
          else Form(key:_form,child:Column(children:[
            _field('customer_name','Full name',2,150,keyboard:TextInputType.name),
            _field('email','Email address',5,254,keyboard:TextInputType.emailAddress),
            _field('phone','Phone number',7,30,keyboard:TextInputType.phone),
            _field('address_line1','Street address and house number',5,250,keyboard:TextInputType.streetAddress),
            _field('address_line2','Apartment or landmark (optional)',0,250),
            _field('postal_code','Postal code (optional)',0,30),
            _field('delivery_notes','Delivery instructions (optional)',0,1000),
          ])),
          if(widget.basket.items.isNotEmpty)FilledButton.icon(
            style:FilledButton.styleFrom(backgroundColor:_navy,foregroundColor:Colors.white),
            onPressed:_busy||_attempt!=null?null:_check,icon:const Icon(Icons.fact_check_outlined),
            label:SolarText(_busy?'Checking prices and delivery…':'Review order details')),
          if(_error!=null)Padding(padding:const EdgeInsets.symmetric(vertical:20),
            child:SolarText(_error!,style:const TextStyle(color:Colors.red))),
          if(_review!=null)_summary(_review!),
          const SizedBox(height:24),
          if(_review!=null || _attempt!=null)FilledButton.icon(
            style:FilledButton.styleFrom(backgroundColor:_navy,foregroundColor:Colors.white),
            onPressed:_busy?null:_saveOrder,icon:const Icon(Icons.receipt_long_outlined),
            label:SolarText(_attempt!=null?'Retry saving the same order':'Save unpaid order and reserve stock')),
          if(_attempt!=null)const Padding(padding:EdgeInsets.only(top:12),child:SolarText('A save attempt has started. Retry the same order if the connection fails; avoid starting another order.')),
          const SizedBox(height:16),
          const SolarText('Saving creates an unpaid order and reserves stock for 15 minutes. No payment is taken and no goods are dispatched. Do not enter card details here.'),
        ],
      )),
    )),
  ); }
  Widget _summary(Map<String,dynamic> data) {
    final contact = Map<String,dynamic>.from(data['customer'] as Map);
    return Container(width:double.infinity,margin:const EdgeInsets.only(top:24),
      padding:const EdgeInsets.all(24),decoration:BoxDecoration(
        color:MarketColors.sky,borderRadius:BorderRadius.circular(18)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const SolarText('Review your order details',style:TextStyle(fontSize:25,
          fontWeight:FontWeight.w800,color:_navy)),const SizedBox(height:16),
        SolarText('${contact['customer_name']}', translate: false),SolarText('${contact['email']} · ${contact['phone']}', translate: false),
        SolarText('${contact['address_line1']}', translate: false),
        if(contact['address_line2']!='')SolarText('${contact['address_line2']}', translate: false),
        SolarText('${data['city']}, ${data['state']}, Nigeria'),
        if(contact['postal_code']!='')SolarText('Postal code: ${contact['postal_code']}'),
        if(contact['delivery_notes']!='')SolarText('Instructions: ${contact['delivery_notes']}'),
        const Divider(height:32),
        for(final item in data['items'] as List)Padding(
          padding:const EdgeInsets.only(bottom:10),child:SolarText(
            '${item['name']} × ${item['quantity']} — ${commerceMoney((item['subtotal_kobo'] as num).toInt())}')),
        const SizedBox(height:8),
        SolarText('Products: ${commerceMoney((data['subtotal_kobo'] as num).toInt())}'),
        SolarText('Delivery: ${commerceMoney((data['delivery_kobo'] as num).toInt())}'),
        const SizedBox(height:12),
        SolarText('Total: ${commerceMoney((data['total_kobo'] as num).toInt())}',
          style:const TextStyle(fontSize:26,fontWeight:FontWeight.w800,color:_navy)),
        const SizedBox(height:12),
        for(final shipment in data['shipments'] as List)SolarText(
          '${shipment['service_name']} · ${shipment['min_days']}–${shipment['max_days']} days'),
      ]));
  }
}
