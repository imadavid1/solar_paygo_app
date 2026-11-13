import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_theme.dart';
import 'commerce_service.dart';
import 'commerce_order_screen.dart' show commerceSecret;

class CommerceRefundSection extends StatefulWidget {
 const CommerceRefundSection({super.key,required this.api,required this.number,required this.token,
  required this.provider,required this.data,required this.disabled,required this.onChanged});
 final CommerceApi api;
 final String number,token;
 final bool provider,disabled;
 final Map<String,dynamic> data;
 final Future<void> Function() onChanged;
 @override
 State<CommerceRefundSection> createState()=>_CommerceRefundSectionState();
}
class _CommerceRefundSectionState extends State<CommerceRefundSection>{
 bool _busy=false;
 String? _error;
 String? _notice;
 @override
 void didUpdateWidget(covariant CommerceRefundSection oldWidget){
  super.didUpdateWidget(oldWidget);
  if(widget.data['status']=='processed'){_error=null;_notice=null;}
 }
 Future<void> _create()async{
  final amount=commerceMoney((widget.data['amount_kobo'] as num).toInt());
  final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
   title:const SolarText('Request a full Paystack TEST refund?'),
   content:SolarText('Refund the full order total of $amount, INCLUDING delivery. Single-seller test orders only. No real money moves. Seller settlement stays blocked. This creates one refund attempt; uncertain results must be checked, never resubmitted.'),
   actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const SolarText('Cancel')),
    FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const SolarText('Request full TEST refund'))]));
  if(yes==true&&mounted)await _send(false);
 }
 Future<void> _send(bool check)async{
  if(_busy)return;
  setState((){_busy=true;_error=null;_notice=null;});
  try{
   await widget.api.call('POST','commerce/management/orders/${Uri.encodeComponent(widget.number)}/refund${check?'/check':''}',
    token:widget.token,body:{'request_key':commerceSecret(),'simulation':true,if(!check)'full_refund_confirmed':true});
  }catch(e){if(mounted)setState((){
   if(e is TimeoutException){
    _notice='The request is taking longer than expected. Refresh this order to see the saved result. Do not request another refund.';
   }else{_error='${e.toString().replaceFirst('Exception: ','')} Refresh this order and use Check test refund.';}
  });}
  finally{
   if(mounted){await widget.onChanged();if(mounted)setState((){
    _busy=false;
    if(widget.data['status']=='processed'){_error=null;_notice=null;}
   });}
  }
 }
 @override
 Widget build(BuildContext context){ SolarLanguage.watch(context); return Container(width:double.infinity,margin:const EdgeInsets.symmetric(vertical:16),padding:const EdgeInsets.all(22),
  decoration:BoxDecoration(color:MarketColors.sky,borderRadius:BorderRadius.circular(16)),
  child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const SolarText('Test refund processing',style:TextStyle(fontSize:22,fontWeight:FontWeight.w800,color:Color(0xFF162C3B))),
   const SizedBox(height:10),SolarText(widget.data['label'].toString()),
   if(widget.data['recorded']==true)...[
    if(widget.data['amount_kobo'] is num)SolarText('Full order refund (including delivery): ${commerceMoney((widget.data['amount_kobo'] as num).toInt())}'),
    if(widget.data['confirmed_at']!=null)SolarText('Confirmed check: ${DateTime.parse(widget.data['confirmed_at'] as String).toLocal()}'),
   ],
   const SizedBox(height:10),SolarText(widget.data['notice'].toString()),
   if(_busy)const LinearProgressIndicator(),
   if(_error!=null)SolarText(_error!,style:const TextStyle(color:Colors.red)),
   if(_notice!=null)SolarText(_notice!,style:const TextStyle(color:Color(0xFF162C3B))),
   if(widget.provider&&widget.data['can_start']==true)OutlinedButton(onPressed:_busy||widget.disabled?null:_create,
    child:const SolarText('Request full test refund')),
   if(widget.provider&&widget.data['can_check']==true)OutlinedButton(onPressed:_busy||widget.disabled?null:()=>_send(true),
    child:const SolarText('Check test refund')),
  ])); }
}
