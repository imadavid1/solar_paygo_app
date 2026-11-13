import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'dart:convert';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../marketplace/marketplace_theme.dart';
import 'commerce_service.dart';
import 'commerce_cases_section.dart';
import 'commerce_refund_section.dart';

String commerceSecret() {
  final random=Random.secure();
  return List.generate(32,(_)=>random.nextInt(256).toRadixString(16).padLeft(2,'0')).join();
}

// Only the order reference and its access credential are saved on this device.
// Addresses, emails and other contact fields are not saved to browser storage.
class CommerceOrderStore {
  static const key='imad_last_unpaid_order_v1';
  static Future<void> save(String number,String token) async {
    final prefs=await SharedPreferences.getInstance();
    if(!await prefs.setString(key,jsonEncode({'number':number,'token':token}))) {
      throw Exception('Order saved, but this device could not remember it. Keep this page open.');
    }
  }
  static Future<Map<String,String>?> load() async {
    final prefs=await SharedPreferences.getInstance();
    try {
      final data=jsonDecode(prefs.getString(key)??'null');
      if(data is! Map || data['number'] is! String || data['token'] is! String) return null;
      return {'number':data['number'] as String,'token':data['token'] as String};
    } catch(_){return null;}
  }
}

class CommerceOrderScreen extends StatefulWidget {
  const CommerceOrderScreen({super.key,required this.api,required this.number,
    required this.token,this.initialOrder});
  final CommerceApi api;
  final String number,token;
  final Map<String,dynamic>? initialOrder;
  static Future<void> openLatest(BuildContext context,CommerceApi api) async {
    final saved=await CommerceOrderStore.load();
    if(!context.mounted)return;
    if(saved==null){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:SolarText('No saved order was found on this device.')));return;
    }
    await Navigator.of(context).push(MaterialPageRoute(builder:(_)=>CommerceOrderScreen(
      api:api,number:saved['number']!,token:saved['token']!)));
  }
  @override
  State<CommerceOrderScreen> createState()=>_CommerceOrderScreenState();
}
class _CommerceOrderScreenState extends State<CommerceOrderScreen> {
  static const _navy=Color(0xFF162C3B);
  Map<String,dynamic>? _order;
  bool _busy=false;
  String? _error;
  Uri? _checkoutUrl;
  Map<String,dynamic>? _pendingReceipt;
  String? _pendingShipment;
  @override
  void initState(){super.initState();_order=widget.initialOrder;_update();}
  Future<void> _update({bool cancel=false}) async {
    setState((){_busy=true;_error=null;});
    try {
      final data=Map<String,dynamic>.from(await widget.api.call('POST',
        'commerce/orders/${widget.number}/${cancel?'cancel':'status'}',
        body:{'access_token':widget.token}) as Map);
      if(mounted)setState(()=>_order=data);
    }catch(e){if(mounted)setState(()=>_error=e.toString().replaceFirst('Exception: ',''));}
    finally{if(mounted)setState(()=>_busy=false);}
  }
  Future<void> _payment({bool verify=false}) async {
    setState((){_busy=true;_error=null;});
    try {
      final data=Map<String,dynamic>.from(await widget.api.call('POST',
        'commerce/orders/${widget.number}/payment/${verify?'verify':'initialize'}',
        body:{'access_token':widget.token}) as Map);
      if(verify) {
        await _update();
      } else {
        final uri=Uri.parse(data['authorization_url'] as String);
        if(uri.scheme!='https'||uri.host!='checkout.paystack.com'||uri.userInfo.isNotEmpty) {
          throw Exception('Unexpected checkout address. Payment was not opened.');
        }
        if(mounted)setState(()=>_checkoutUrl=uri);
        if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:SolarText('Checkout is ready. Select Open Paystack test checkout, then return here and select Check payment.')));
        await _update();
      }
    }catch(e){if(mounted)setState(()=>_error=e.toString().replaceFirst('Exception: ',''));}
    finally{if(mounted)setState(()=>_busy=false);}
  }
  Future<void> _confirmReceipt(Map shipment) async {
    final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      title:const SolarText('Simulate receiving this shipment?'),
      content:SolarText('Shipment: ${shipment['label']}. TEST ONLY: this records a buyer receipt acknowledgement. No real delivery is proved and no seller money is released.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const SolarText('Cancel')),
        FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const SolarText('Confirm test receipt'))]));
    if(yes!=true||!mounted)return;
    _pendingShipment=shipment['shipment_key'] as String;
    _pendingReceipt={'access_token':widget.token,'request_key':commerceSecret(),
      'expected_status':'dispatched','simulation':true,'receipt_confirmed':true};
    await _sendReceipt();
  }
  Future<void> _sendReceipt() async {
    final body=_pendingReceipt;
    final shipment=_pendingShipment;
    if(body==null||shipment==null||_busy)return;
    setState((){_busy=true;_error=null;});
    try {
      await widget.api.call('POST',
        'commerce/orders/${Uri.encodeComponent(widget.number)}/fulfilments/${Uri.encodeComponent(shipment)}/confirm-delivery',body:body);
      _pendingReceipt=null;_pendingShipment=null;
      if(mounted)await _update();
    } catch(e) {
      if(e is CommerceApiException && e.status>=400 && e.status<500){_pendingReceipt=null;_pendingShipment=null;}
      if(mounted)setState(()=>_error='${e.toString().replaceFirst('Exception: ','')} Refresh the order, or retry the same receipt request.');
    } finally {if(mounted)setState(()=>_busy=false);}
  }
  String _title() {
    if(_order?['status']=='refunded')return 'Test refund confirmed';
    if(_order?['refund']?['recorded']==true&&_order?['status']=='refund_pending')return 'Test refund awaiting confirmation';
    if(_order?['status']=='delivered')return 'Test order — receipt confirmed';
    if(_order?['status']=='processing')return 'Test order — preparation in progress';
    if(_order?['status']=='dispatched')return 'Test order — dispatch simulated';
    if(_order?['status']=='paid')return 'Test payment verified — order paid';
    if(_order?['status']=='refund_pending')return 'Payment needs provider review — do not dispatch';
    if(_order?['payment_status']!=null)return 'Payment started — check payment status';
    if(_order?['status']=='cancelled')return 'Order cancelled — no payment taken';
    return 'Order saved — awaiting payment';
  }
  Future<void> _cancel() async {
    final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      title:const SolarText('Cancel this unpaid order?'),
      content:const SolarText('This releases the reserved items. No payment has been taken.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const SolarText('Keep order')),
        FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const SolarText('Cancel order'))]));
    if(yes==true&&mounted)await _update(cancel:true);
  }
  @override
  Widget build(BuildContext context){ SolarLanguage.watch(context); return Scaffold(backgroundColor:Colors.white,
    appBar:AppBar(backgroundColor:MarketColors.sky,foregroundColor:_navy,title:const SolarText('Your product order')),
    body:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Center(child:ConstrainedBox(
      constraints:const BoxConstraints(maxWidth:900),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        SolarText(widget.number,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w800,color:_navy)),
        const SizedBox(height:14),
        if(_busy)const LinearProgressIndicator(),
        if(_error!=null)Padding(padding:const EdgeInsets.symmetric(vertical:16),child:SolarText(_error!,style:const TextStyle(color:Colors.red))),
        if(_order!=null)...[
          const SizedBox(height:18),
          SolarText(_title(),
            style:const TextStyle(fontSize:23,fontWeight:FontWeight.w700,color:_navy)),
          const SizedBox(height:10),
          if(_order!['reservation_status']=='active')SolarText('Stock reserved until ${DateTime.parse(_order!['reservation_expires_at'] as String).toLocal()}. Refresh to check the latest status.'),
          if(_order!['reservation_status']=='expired')const SolarText('The 15-minute reservation expired. The items are no longer held.'),
          if(_order!['reservation_status']=='cancelled')const SolarText('The reservation has been released.'),
          const SizedBox(height:20),
          Container(width:double.infinity,padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:MarketColors.sky,borderRadius:BorderRadius.circular(16)),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              for(final item in _order!['items'] as List)SolarText('${item['name']} × ${item['quantity']} — ${commerceMoney((item['subtotal_kobo'] as num).toInt())}'),
              const SizedBox(height:16),SolarText('Products: ${commerceMoney((_order!['subtotal_kobo'] as num).toInt())}'),
              SolarText('Delivery: ${commerceMoney((_order!['delivery_kobo'] as num).toInt())}'),
              SolarText('Total: ${commerceMoney((_order!['total_kobo'] as num).toInt())}',style:const TextStyle(fontSize:25,fontWeight:FontWeight.w800)),
              const Divider(height:30),
              SolarText('${_order!['customer']['customer_name']}'),
              SolarText('${_order!['customer']['address_line1']}'),
              if(_order!['customer']['address_line2']!='')SolarText('${_order!['customer']['address_line2']}'),
              SolarText('${_order!['city']}, ${_order!['state']}, Nigeria'),
              SolarText('${_order!['customer']['email']} · ${_order!['customer']['phone']}'),
              if(_order!['customer']['postal_code']!='')SolarText('Postal code: ${_order!['customer']['postal_code']}'),
              if(_order!['customer']['delivery_notes']!='')SolarText('Instructions: ${_order!['customer']['delivery_notes']}'),
              for(final shipment in _order!['shipments'] as List)SolarText('${shipment['service_name']} · ${shipment['min_days']}–${shipment['max_days']} days'),
            ])),
        ],
        for(final shipment in (_order?['tracking'] as List? ?? []))
          Container(width:double.infinity,margin:const EdgeInsets.only(top:18),padding:const EdgeInsets.all(20),
            decoration:BoxDecoration(color:MarketColors.sky,borderRadius:BorderRadius.circular(16)),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              SolarText('Tracking · ${shipment['label']}',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w700)),
              if(shipment['simulation']==true)const SolarText('TEST SIMULATION — no real courier or delivery'),
              SolarText('Status: ${shipment['status']}'),
              if(shipment['delivered_at']!=null)SolarText('Buyer receipt simulated: ${DateTime.parse(shipment['delivered_at'] as String).toLocal()}'),
              if(shipment['receipt_source']=='buyer_test')const SolarText('Acknowledged on the buyer order page. Seller payouts remain disabled.'),
              if(shipment['can_confirm_receipt']==true)Padding(padding:const EdgeInsets.only(top:12),
                child:OutlinedButton(onPressed:_busy||_pendingReceipt!=null?null:()=>_confirmReceipt(shipment as Map),
                  child:const SolarText('Simulate receipt confirmation'))),
              if(shipment['courier']!='')SolarText('Courier: ${shipment['courier']}'),
              if(shipment['tracking_number']!='')SelectableText(SolarLanguage.instance.translate('Tracking number: ${shipment['tracking_number']}')),
            ])),
        if(_pendingReceipt!=null)Padding(padding:const EdgeInsets.only(top:16),child:OutlinedButton(
          onPressed:_busy?null:_sendReceipt,child:const SolarText('Retry same receipt confirmation'))),
        if(_order!=null)CommerceCasesSection(api:widget.api,number:widget.number,token:widget.token,
          buyer:true,provider:false,cases:(_order!['cases'] as List? ?? []),
          shipments:(_order!['tracking'] as List? ?? []),disabled:_busy||_pendingReceipt!=null,onChanged:()=>_update()),
        if(_order?['refund'] is Map)CommerceRefundSection(api:widget.api,number:widget.number,token:widget.token,
          provider:false,data:Map<String,dynamic>.from(_order!['refund'] as Map),disabled:_busy,onChanged:()=>_update()),
        const SizedBox(height:22),Wrap(spacing:12,runSpacing:12,children:[
          OutlinedButton.icon(onPressed:_busy?null:()=>_update(),icon:const Icon(Icons.refresh),label:const SolarText('Refresh order')),
          if(_order?['status']=='awaiting_payment'&&_order?['payment_status']==null)OutlinedButton(onPressed:_busy?null:_cancel,child:const SolarText('Cancel unpaid order')),
        ]),
        const SizedBox(height:16),
        if(_order?['payment_enabled']==true)...[
          Wrap(spacing:12,runSpacing:12,children:[
            if(_order?['status']=='awaiting_payment'&&_order?['reservation_status']=='active')
              FilledButton(onPressed:_busy?null:()=>_payment(),child:const SolarText('Pay securely — TEST MODE')),
            if(_checkoutUrl!=null&&_order?['status']=='awaiting_payment')
              OutlinedButton(onPressed:_busy?null:()async {
                final opened=await launchUrl(_checkoutUrl!,mode:LaunchMode.externalApplication);
                if(!opened&&mounted)setState(()=>_error='Allow the Paystack tab in your browser, then try again.');
              },child:const SolarText('Open Paystack test checkout')),
            OutlinedButton(onPressed:_busy?null:()=>_payment(verify:true),child:const SolarText('Check payment')),
          ]),
          const SizedBox(height:12),
          const SolarText('Test mode only. Paystack handles payment details. Return to this tab and select Check payment after checkout. No real money, dispatch or seller payout. Your basket remains unchanged.'),
        ] else const SolarText('Product payment is not configured. Your basket remains unchanged. No dispatch or seller payout.'),
      ]))))); }
}
