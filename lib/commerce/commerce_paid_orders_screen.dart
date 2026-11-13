import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_theme.dart';
import 'commerce_service.dart';
import 'commerce_cases_section.dart';
import 'commerce_refund_section.dart';
import 'commerce_payout_calendar_section.dart';
import 'commerce_order_screen.dart' show commerceSecret;

const _navy=Color(0xFF162C3B);
String _money(dynamic value)=>commerceMoney((value as num).toInt());
String _date(dynamic value){
  final parsed=DateTime.tryParse(value?.toString()??'');
  if(parsed==null)return 'Not recorded';
  final date=parsed.toLocal();
  return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
}
Widget _box(Widget child)=>Container(width:double.infinity,padding:const EdgeInsets.all(22),
 margin:const EdgeInsets.only(bottom:18),decoration:BoxDecoration(color:MarketColors.sky,borderRadius:BorderRadius.circular(16)),child:child);
Widget _title(String value)=>SolarText(value,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800,color:_navy));
Widget _testBadge(bool test)=>Padding(padding:const EdgeInsets.symmetric(vertical:10),child:SolarText(
 test?'TEST ORDER — no real payment or dispatch':'Verified product order',style:const TextStyle(fontWeight:FontWeight.w700,color:_navy)));

class CommercePaidOrdersScreen extends StatefulWidget {
 const CommercePaidOrdersScreen({super.key,required this.api,required this.token});
 final CommerceApi api;
 final String token;
 @override
 State<CommercePaidOrdersScreen> createState()=>_CommercePaidOrdersScreenState();
}
class _CommercePaidOrdersScreenState extends State<CommercePaidOrdersScreen> {
 List<Map<String,dynamic>> _orders=[];
 bool _busy=true,_provider=false;
 int _offset=0,_total=0;
 String? _error;
 @override
 void initState(){super.initState();_load(0);}
 Future<void> _load(int offset)async{
  setState((){_busy=true;_error=null;});
  try{
   final result=Map<String,dynamic>.from(await widget.api.call('GET',
    'commerce/management/orders?limit=20&offset=$offset',token:widget.token) as Map);
   if(mounted)setState((){
    _orders=(result['orders'] as List).map((x)=>Map<String,dynamic>.from(x as Map)).toList();
    _provider=result['view']=='provider';_offset=offset;_total=(result['total'] as num).toInt();
   });
  }catch(e){if(mounted)setState(()=>_error=e.toString().replaceFirst('Exception: ',''));}
  finally{if(mounted)setState(()=>_busy=false);}
 }
 @override
 Widget build(BuildContext context){ SolarLanguage.watch(context); return Scaffold(backgroundColor:Colors.white,
  appBar:AppBar(backgroundColor:MarketColors.sky,foregroundColor:_navy,title:const SolarText('Paid product orders'),
   actions:[IconButton(tooltip: SolarLanguage.instance.translate('Refresh orders'),onPressed:_busy?null:()=>_load(_offset),icon:const Icon(Icons.refresh))]),
  body:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Center(child:ConstrainedBox(
   constraints:const BoxConstraints(maxWidth:1000),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    _title('Verified orders'),const SizedBox(height:12),
    SolarText(_provider?'View paid orders across SolarID and marketplace sellers.':'View the items sold by your business. Other sellers’ items and buyer contact details are private.'),
    const SizedBox(height:10),const SolarText('Seller commission is 5% of product subtotal, excluding delivery. Amounts shown are records, not available payouts.'),
    const SizedBox(height:22),if(_busy)const LinearProgressIndicator(),
    if(_error!=null)Padding(padding:const EdgeInsets.symmetric(vertical:20),child:SolarText(_error!,style:const TextStyle(color:Colors.red))),
    if(!_busy&&_error==null&&_orders.isEmpty)const SolarText('No verified paid product orders found.'),
    for(final order in _orders)_box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     SelectableText(order['order_number'].toString(),style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800,color:_navy)),
     _testBadge(order['test_mode']==true),SolarText('Status: ${order['status']} · Paid: ${_date(order['paid_at'])}'),
     SolarText('${order['city']}, ${order['state']} · ${order['quantity']} item(s)'),const SizedBox(height:12),
     SolarText('Product subtotal: ${_money(order['product_subtotal_kobo'])}'),
     SolarText('Commission: ${_money(order['commission_kobo'])}'),
     SolarText('Net product proceeds: ${_money(order['seller_net_kobo'])}'),
     if(_provider)...[SolarText('Delivery: ${_money(order['delivery_kobo'])}'),SolarText('Order total: ${_money(order['total_kobo'])}',style:const TextStyle(fontWeight:FontWeight.w700))],
     const SizedBox(height:16),OutlinedButton(onPressed:_busy?null:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>CommercePaidOrderDetailScreen(
      api:widget.api,token:widget.token,number:order['order_number'] as String))),child:const SolarText('View order')),
    ])),
    if(_total>0)...[SolarText('Showing ${_offset+1}–${_offset+_orders.length} of $_total'),const SizedBox(height:12),
     Wrap(spacing:12,children:[OutlinedButton(onPressed:_busy||_offset==0?null:()=>_load(_offset-20),child:const SolarText('Previous')),
      OutlinedButton(onPressed:_busy||_offset+20>=_total?null:()=>_load(_offset+20),child:const SolarText('Next'))])],
   ]))))); }
}

class CommercePaidOrderDetailScreen extends StatefulWidget {
 const CommercePaidOrderDetailScreen({super.key,required this.api,required this.token,required this.number});
 final CommerceApi api;
 final String token,number;
 @override
 State<CommercePaidOrderDetailScreen> createState()=>_CommercePaidOrderDetailScreenState();
}
class _CommercePaidOrderDetailScreenState extends State<CommercePaidOrderDetailScreen> {
 Map<String,dynamic>? _order;
 bool _busy=true,_provider=false;
 String? _error;
 Map<String,dynamic>? _pendingChange;
 String? _pendingSeller;
 Map<String,dynamic>? _pendingSettlement;
 int _loadSequence=0;
 @override
 void initState(){super.initState();_load();}
 Future<void> _load()async{
  final sequence=++_loadSequence;
  setState((){_busy=true;_error=null;});
  try{
   final result=Map<String,dynamic>.from(await widget.api.call('GET',
    'commerce/management/orders/${Uri.encodeComponent(widget.number)}',token:widget.token) as Map);
   if(mounted&&sequence==_loadSequence)setState((){_order=Map<String,dynamic>.from(result['order'] as Map);_provider=result['view']=='provider';});
  }catch(e){if(mounted&&sequence==_loadSequence)setState(()=>_error=e.toString().replaceFirst('Exception: ',''));}
  finally{if(mounted&&sequence==_loadSequence)setState(()=>_busy=false);}
 }
 Future<void> _sendChange()async{
  final body=_pendingChange;
  final seller=_pendingSeller;
  if(body==null||seller==null)return;
  setState((){_busy=true;_error=null;});
  try{
   await widget.api.call('POST','commerce/management/orders/${Uri.encodeComponent(widget.number)}/fulfilments/${Uri.encodeComponent(seller)}',
    token:widget.token,body:body);
   _pendingChange=null;_pendingSeller=null;
   if(mounted)await _load();
  }catch(e){
   if(e is CommerceApiException && e.status>=400 && e.status<500){_pendingChange=null;_pendingSeller=null;}
   if(mounted)setState(()=>_error='${e.toString().replaceFirst('Exception: ','')} Refresh to check the latest status.');
  }
  finally{if(mounted)setState(()=>_busy=false);}
 }
 Future<void> _recordSettlement()async{
  final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
   title:const SolarText('Record held test settlements?'),
   content:const SolarText('This copies the seller amounts already saved with this order into a held test ledger. The seven-day clock uses buyer receipt confirmation. No funds are released or transferred.'),
   actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const SolarText('Cancel')),
    FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const SolarText('Record test ledger'))]));
  if(yes!=true||!mounted)return;
  _pendingSettlement={'request_key':commerceSecret(),'simulation':true};
  await _sendSettlement();
 }
 Future<void> _sendSettlement()async{
  final body=_pendingSettlement;
  if(body==null||_busy)return;
  setState((){_busy=true;_error=null;});
  try{
   await widget.api.call('POST','commerce/management/orders/${Uri.encodeComponent(widget.number)}/settlements',
    token:widget.token,body:body);
   _pendingSettlement=null;
   if(mounted)await _load();
  }catch(e){
   if(e is CommerceApiException && e.status>=400 && e.status<500){_pendingSettlement=null;}
   if(mounted)setState(()=>_error='${e.toString().replaceFirst('Exception: ','')} Refresh, or retry the same settlement request.');
  }finally{if(mounted)setState(()=>_busy=false);}
 }
 Future<void> _change(Map<String,dynamic> shipment,bool dispatch)async{
  var courierValue=dispatch?'Test courier':'';
  var trackingValue='';
  final confirmed=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
   title:SolarText(dispatch?'Simulate dispatch?':'Simulate preparation?'),
   content:SizedBox(width:420,child:Column(mainAxisSize:MainAxisSize.min,children:[
    const SolarText('TEST ONLY. This records a simulation. It does not book a courier, confirm delivery or release money.'),
    if(dispatch)...[
     TextFormField(initialValue:courierValue,onChanged:(value)=>courierValue=value,maxLength:100,decoration:const SolarInputDecoration(labelText:'Test courier')),
     TextFormField(onChanged:(value)=>trackingValue=value,maxLength:150,decoration:const SolarInputDecoration(labelText:'Test tracking number')),
    ],
   ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const SolarText('Cancel')),
    FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const SolarText('Confirm simulation'))]));
  courierValue=courierValue.trim();trackingValue=trackingValue.trim();
  if(confirmed!=true||!mounted)return;
  if(dispatch&&(courierValue.isEmpty||trackingValue.isEmpty)){
   setState(()=>_error='Enter both a test courier and a test tracking number.');return;
  }
  _pendingSeller=shipment['seller_key'] as String;
  _pendingChange={'request_key':commerceSecret(),'action':dispatch?'dispatch':'prepare',
   'expected_status':shipment['status'],'simulation':true,
   'courier':courierValue,'tracking_number':trackingValue};
  await _sendChange();
 }
 @override
 Widget build(BuildContext context){ SolarLanguage.watch(context); return Scaffold(backgroundColor:Colors.white,
  appBar:AppBar(backgroundColor:MarketColors.sky,foregroundColor:_navy,title:const SolarText('Product order details'),
   actions:[IconButton(tooltip: SolarLanguage.instance.translate('Refresh order details'),onPressed:_busy?null:_load,icon:const Icon(Icons.refresh))]),
  body:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Center(child:ConstrainedBox(
   constraints:const BoxConstraints(maxWidth:1000),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    SelectableText(widget.number,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800,color:_navy)),
    const SizedBox(height:18),if(_busy)const LinearProgressIndicator(),
    if(_error!=null)SolarText(_error!,style:const TextStyle(color:Colors.red)),
    if(_order!=null)...[
     _testBadge(_order!['test_mode']==true),SolarText('Status: ${_order!['status']} · Paid: ${_date(_order!['paid_at'])}'),
     const SizedBox(height:20),_title('Preparation and tracking'),const SizedBox(height:14),
     if(_pendingChange!=null)Padding(padding:const EdgeInsets.only(bottom:12),child:OutlinedButton(
      onPressed:_busy?null:_sendChange,child:const SolarText('Retry same simulation update'))),
     for(final raw in (_order!['fulfilments'] as List? ?? []))
      _box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
       _title(raw['label'].toString()),
       if(raw['simulation']==true)const SolarText('TEST SIMULATION — no real courier or delivery'),
       SolarText('Status: ${raw['status']}'),
       if(raw['courier']!='')SolarText('Courier: ${raw['courier']}'),
       if(raw['tracking_number']!='')SelectableText(SolarLanguage.instance.translate('Tracking number: ${raw['tracking_number']}')),
       if(raw['delivered_at']!=null)SolarText('Buyer receipt simulated: ${_date(raw['delivered_at'])}'),
       if(raw['receipt_source']=='buyer_test')const SolarText('Receipt acknowledged on the buyer order page. No seller payout released.'),
       if(raw['dispatched_at']!=null)SolarText('Simulated dispatch: ${_date(raw['dispatched_at'])}'),
       const SizedBox(height:12),Wrap(spacing:12,runSpacing:12,children:[
        if(raw['can_prepare']==true)OutlinedButton(onPressed:_busy||_pendingChange!=null||_pendingSettlement!=null?null:()=>_change(Map<String,dynamic>.from(raw as Map),false),child:const SolarText('Simulate preparation')),
        if(raw['can_dispatch']==true)OutlinedButton(onPressed:_busy||_pendingChange!=null||_pendingSettlement!=null?null:()=>_change(Map<String,dynamic>.from(raw as Map),true),child:const SolarText('Simulate dispatch')),
       ]),
       for(final event in raw['events'] as List)SolarText('TEST · ${event['from_status']} → ${event['to_status']} · ${_date(event['created_at'])}'),
      ])),
     const SizedBox(height:20),_title(_provider?'Purchased items':'Your purchased items'),const SizedBox(height:14),
     for(final item in _order!['items'] as List)_box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _title(item['name'].toString()),SolarText('SKU: ${item['sku']}'),
      if(_provider)SolarText(item['seller_id']==null?'SolarID stock':'Seller #${item['seller_id']}'),
      const SizedBox(height:10),SolarText('${item['quantity']} × ${_money(item['unit_price_kobo'])}'),
      SolarText('Subtotal: ${_money(item['subtotal_kobo'])}'),
      SolarText('Commission (${(item['commission_bps'] as num)/100}%): ${_money(item['commission_kobo'])}'),
      SolarText('Net product proceeds: ${_money(item['seller_net_kobo'])}'),
     ])),
     _box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _title('Amounts'),SolarText('Product subtotal: ${_money(_order!['product_subtotal_kobo'])}'),
      SolarText('Commission: ${_money(_order!['commission_kobo'])}'),SolarText('Net product proceeds: ${_money(_order!['seller_net_kobo'])}'),
      if(_provider)...[SolarText('Delivery: ${_money(_order!['delivery_kobo'])}'),SolarText('Total: ${_money(_order!['total_kobo'])}')],
      const SizedBox(height:12),const SolarText('Seller funds have not been released. Delivery confirmation and payout eligibility are separate steps.'),
     ])),
     if(_order!['settlements'] is Map)...[
      _title('Seller settlements'),const SizedBox(height:14),
      if(_order!['settlements']['simulation']==true)const SolarText('TEST LEDGER — no real funds or transfers'),
      const SolarText('Seven days after buyer receipt confirmation. Timing alone does not approve a payout.'),
      const SizedBox(height:12),
      if(_pendingSettlement!=null)OutlinedButton(onPressed:_busy?null:_sendSettlement,
       child:const SolarText('Retry same settlement record')),
      if(_provider&&_order!['settlements']['can_record']==true)OutlinedButton(
       onPressed:_busy||_pendingChange!=null||_pendingSettlement!=null?null:_recordSettlement,
       child:const SolarText('Record held test settlements')),
      const SizedBox(height:12),
      if((_order!['settlements']['items'] as List).isEmpty)const SolarText('No third-party seller items in this order.'),
      for(final entry in _order!['settlements']['items'] as List)_box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
       _title(entry['name'].toString()),
       if(_provider)SolarText('Seller #${entry['seller_id']}'),
       SolarText('Ledger: ${entry['ledger_status']}'),
       SolarText('Product subtotal: ${_money(entry['gross_kobo'])}'),
       SolarText('Commission: ${_money(entry['commission_kobo'])}'),
       SolarText('Seller net: ${_money(entry['net_kobo'])}'),
       const SizedBox(height:10),SolarText(entry['eligibility_label'].toString(),style:const TextStyle(fontWeight:FontWeight.w700)),
       if(entry['recorded_at']!=null)SolarText('Ledger recorded: ${_date(entry['recorded_at'])}'),
       if(entry['receipt_confirmed_at']!=null)SolarText('Buyer receipt simulated: ${_date(entry['receipt_confirmed_at'])}'),
       if(entry['time_eligible_at']!=null)SolarText('Seven-day hold ends: ${_date(entry['time_eligible_at'])}'),
       const SolarText('Payout disabled — no money released.'),
      ])),
      SolarText(_order!['settlements']['notice'].toString()),const SizedBox(height:18),
     ],
     if(_order!['payout_calendar'] is Map)CommercePayoutCalendarSection(api:widget.api,token:widget.token,provider:_provider,
      data:Map<String,dynamic>.from(_order!['payout_calendar'] as Map),onChanged:_load,
      disabled:_busy||_pendingChange!=null||_pendingSettlement!=null),
     CommerceCasesSection(api:widget.api,number:widget.number,token:widget.token,buyer:false,provider:_provider,
      cases:(_order!['cases'] as List? ?? []),disabled:_busy||_pendingChange!=null||_pendingSettlement!=null,onChanged:_load),
     if(_order!['refund'] is Map)CommerceRefundSection(api:widget.api,number:widget.number,token:widget.token,
      provider:_provider,data:Map<String,dynamic>.from(_order!['refund'] as Map),
      disabled:_busy||_pendingChange!=null||_pendingSettlement!=null,onChanged:_load),
     if(_provider)...[
      _box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
       _title('Customer and delivery address'),
       for(final field in ['name','email','phone','address_line1','address_line2'])
        if((_order!['customer'][field]?.toString()??'').isNotEmpty)SelectableText(_order!['customer'][field].toString()),
       SolarText('${_order!['city']}, ${_order!['state']}, ${_order!['customer']['country']}'),
       if(_order!['customer']['postal_code']!='')SolarText('Postal code: ${_order!['customer']['postal_code']}'),
       if(_order!['customer']['delivery_notes']!='')SolarText('Delivery notes: ${_order!['customer']['delivery_notes']}'),
      ])),
      _title('Verified payments'),const SizedBox(height:14),
      for(final payment in _order!['payments'] as List)_box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
       SelectableText(SolarLanguage.instance.translate('Reference: ${payment['reference']}')),SolarText('Status: ${payment['status']}'),
       SolarText('Amount: ${_money(payment['amount_kobo'])} ${payment['currency']}'),SolarText('Verified: ${_date(payment['verified_at'])}'),
      ])),
     ] else _box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _title('Delivery area'),SolarText('${_order!['city']}, ${_order!['state']}'),
      const SolarText('SolarID coordinates delivery. Buyer contact details and other sellers’ items are not shared here.'),
     ])),
     SolarText(_order!['notice'].toString()),
    ],
   ]))))); }
}
