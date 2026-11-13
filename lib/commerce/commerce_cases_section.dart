import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_theme.dart';
import 'commerce_service.dart';
import 'commerce_order_screen.dart' show commerceSecret;

class CommerceCasesSection extends StatefulWidget {
 const CommerceCasesSection({super.key,required this.api,required this.number,required this.token,
  required this.buyer,required this.provider,required this.cases,required this.onChanged,this.shipments=const [],this.disabled=false});
 final CommerceApi api;
 final String number,token;
 final bool buyer,provider,disabled;
 final List cases,shipments;
 final Future<void> Function() onChanged;
 @override
 State<CommerceCasesSection> createState()=>_CommerceCasesSectionState();
}

class _CommerceCasesSectionState extends State<CommerceCasesSection> {
 bool _busy=false;
 String? _error,_pendingPath;
 Map<String,dynamic>? _pending;
 String _date(dynamic value){
  final date=DateTime.tryParse(value?.toString()??'')?.toLocal();
  return date==null?'Not recorded':'${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
 }
 String _label(dynamic value)=>switch(value){
  'open'=>'Open — awaiting SolarID review',
  'refund_required'=>'Refund required — not refunded; settlement blocked',
  'closed_no_refund'=>'Closed after review — no refund',
  'refund_request'=>'Refund request','delivery_issue'=>'Delivery issue','product_issue'=>'Product issue',
  'refund_confirmed'=>'Full test refund confirmed — no real money moved',
  _=>value.toString().replaceAll('_',' '),
 };
 Future<void> _dialog({Map? shipment,Map? issue})async{
  final report=shipment!=null;
  var kind='product_issue',reason='not_working',decision='refund_required',note='';
  String? validation;
  final yes=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,local)=>AlertDialog(
   title:SolarText(report?'Report a test order problem':'Review test case #${issue!['id']}'),
   content:SizedBox(width:460,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
    const SolarText('TEST ONLY. No refund is sent and no seller money is released. Do not enter card details or passwords.'),
    const SizedBox(height:16),
    if(report)...[
     DropdownButtonFormField<String>(initialValue:kind,decoration:const SolarInputDecoration(labelText:'Case type'),
      items:const [DropdownMenuItem(value:'product_issue',child:SolarText('Product issue')),
       DropdownMenuItem(value:'delivery_issue',child:SolarText('Delivery issue')),
       DropdownMenuItem(value:'refund_request',child:SolarText('Refund request'))],onChanged:(v){if(v!=null)kind=v;}),
     const SizedBox(height:12),DropdownButtonFormField<String>(initialValue:reason,decoration:const SolarInputDecoration(labelText:'Reason'),
      items:const [DropdownMenuItem(value:'not_received',child:SolarText('Not received')),
       DropdownMenuItem(value:'damaged',child:SolarText('Damaged')),
       DropdownMenuItem(value:'wrong_item',child:SolarText('Wrong item')),
       DropdownMenuItem(value:'not_working',child:SolarText('Not working')),
       DropdownMenuItem(value:'other',child:SolarText('Other'))],onChanged:(v){if(v!=null)reason=v;}),
    ] else ...[
     const SolarText('Only close without a refund after reviewing the evidence. Refund required keeps settlement blocked; it does not send a refund.'),
     const SizedBox(height:12),DropdownButtonFormField<String>(initialValue:decision,decoration:const SolarInputDecoration(labelText:'Decision'),
      isExpanded:true,items:const [DropdownMenuItem(value:'refund_required',child:SolarText('Refund required — keep blocked')),
       DropdownMenuItem(value:'closed_no_refund',child:SolarText('Close — no refund needed'))],onChanged:(v){if(v!=null)decision=v;}),
    ],
    const SizedBox(height:12),TextField(maxLength:1500,maxLines:4,onChanged:(v)=>note=v,
     decoration:SolarInputDecoration(labelText:report?'Describe the problem':'Review explanation',errorText:validation)),
   ]))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const SolarText('Cancel')),
    FilledButton(onPressed:(){
     if(note.trim().length<10){local(()=>validation='Enter at least 10 characters.');return;}
     Navigator.pop(ctx,true);
    },child:SolarText(report?'Submit test case':'Save test review'))],
  )));
  if(yes!=true||!mounted)return;
  final number=Uri.encodeComponent(widget.number);
  _pendingPath=report?'commerce/orders/$number/fulfilments/${Uri.encodeComponent(shipment['shipment_key'] as String)}/cases'
   :'commerce/management/orders/$number/cases/${issue!['id']}/review';
  _pending={'request_key':commerceSecret(),'simulation':true,
   if(report)...{'access_token':widget.token,'kind':kind,'reason':reason,'details':note.trim()}
   else ...{'expected_status':'open','decision':decision,'note':note.trim()}};
  await _send();
 }
 Future<void> _send()async{
  if(_pending==null||_pendingPath==null||_busy)return;
  setState((){_busy=true;_error=null;});
  try{
   await widget.api.call('POST',_pendingPath!,token:widget.buyer?null:widget.token,body:_pending);
   _pending=null;_pendingPath=null;
   await widget.onChanged();
  }catch(e){
   if(e is CommerceApiException&&e.status>=400&&e.status<500){_pending=null;_pendingPath=null;}
   if(mounted)setState(()=>_error=e.toString().replaceFirst('Exception: ',''));
  }finally{if(mounted)setState(()=>_busy=false);}
 }
 @override
 Widget build(BuildContext context){
    SolarLanguage.watch(context);
  final disabled=_busy||widget.disabled||_pending!=null;
  return Padding(padding:const EdgeInsets.symmetric(vertical:20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const SolarText('Problems and refund requests',style:TextStyle(fontSize:22,fontWeight:FontWeight.w800,color:Color(0xFF162C3B))),
   const SizedBox(height:10),const SolarText('TEST case review only. Open cases and refund-required decisions block settlement eligibility and new preparation/dispatch. No automatic refunds or payouts.'),
   if(!widget.buyer&&!widget.provider)const SolarText('Only your shipment’s case status is shown. Buyer messages and review notes remain private.'),
   if(_busy)const LinearProgressIndicator(),
   if(_error!=null)SolarText(_error!,style:const TextStyle(color:Colors.red)),
   if(_pending!=null)OutlinedButton(onPressed:_busy||widget.disabled?null:_send,child:const SolarText('Retry same case request')),
   if(widget.cases.isEmpty)const Padding(padding:EdgeInsets.symmetric(vertical:12),child:SolarText('No cases reported.')),
   for(final raw in widget.cases)Container(width:double.infinity,margin:const EdgeInsets.only(top:12),padding:const EdgeInsets.all(20),
    decoration:BoxDecoration(color:MarketColors.sky,borderRadius:BorderRadius.circular(16)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     SolarText('Case #${raw['id']} · ${_label(raw['kind'])}',style:const TextStyle(fontWeight:FontWeight.w700)),
     SolarText(_label(raw['status'])),SolarText('Reported: ${_date(raw['created_at'])}'),
     if(raw['reason']!=null)SolarText('Reason: ${_label(raw['reason'])}'),
     if(raw['details']!=null)SolarText(raw['details'].toString()),
     for(final event in (raw['events'] as List? ?? []))...[
      const SizedBox(height:8),SolarText('${_label(event['to_status'])} · ${_date(event['created_at'])}'),SolarText(event['note'].toString()),
     ],
     if(widget.provider&&raw['status']=='open')Padding(padding:const EdgeInsets.only(top:12),child:OutlinedButton(
      onPressed:disabled?null:()=>_dialog(issue:Map.from(raw as Map)),child:const SolarText('Review test case'))),
    ])),
   if(widget.buyer)for(final raw in widget.shipments)if(raw['can_report_issue']==true)
    Padding(padding:const EdgeInsets.only(top:12),child:OutlinedButton(onPressed:disabled?null:()=>_dialog(shipment:Map.from(raw as Map)),
     child:SolarText('Report a problem · ${raw['label']}'))),
  ]));
 }
}
