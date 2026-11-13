import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_theme.dart';
import 'commerce_service.dart';
import 'commerce_order_screen.dart' show commerceSecret;

class CommercePayoutCalendarSection extends StatefulWidget{
 const CommercePayoutCalendarSection({super.key,required this.api,required this.token,required this.provider,
  required this.data,required this.onChanged,required this.disabled});
 final CommerceApi api;
 final String token;
 final bool provider,disabled;
 final Map<String,dynamic> data;
 final Future<void> Function() onChanged;
 @override
 State<CommercePayoutCalendarSection> createState()=>_CommercePayoutCalendarSectionState();
}
class _CommercePayoutCalendarSectionState extends State<CommercePayoutCalendarSection>{
 bool _busy=false;
 String? _error;
 Map<String,dynamic>? _pending;
 String _date(dynamic value){
  final d=DateTime.tryParse(value?.toString()??'')?.toLocal();
  return d==null?'Not scheduled':'${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
 }
 Future<void> _start()async{
  final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
   title:const SolarText('Start the TEST payout calendar?'),
   content:const SolarText('The first projected cutoff will be 14 days from now, then every 14 days. This calendar is saved once and cannot be reset here. Only eligible test settlements are projected after their seven-day hold. No balance is released, no payout is approved and no bank transfer occurs.'),
   actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const SolarText('Cancel')),
    FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const SolarText('Start test calendar'))]));
  if(yes!=true||!mounted)return;
  _pending={'request_key':commerceSecret(),'simulation':true};await _send();
 }
 Future<void> _send()async{
  if(_pending==null||_busy)return;
  setState((){_busy=true;_error=null;});
  try{
   await widget.api.call('POST','commerce/management/test-payout-calendar',token:widget.token,body:_pending);
   _pending=null;
  }catch(e){if(mounted)setState(()=>_error='${e.toString().replaceFirst('Exception: ','')} Refresh to check the saved calendar.');}
  finally{if(mounted){await widget.onChanged();if(mounted){
   if(widget.data['configured']==true){_pending=null;_error=null;}
   setState(()=>_busy=false);
  }}}
 }
 @override
 Widget build(BuildContext context){ SolarLanguage.watch(context); return Container(width:double.infinity,padding:const EdgeInsets.all(22),
  margin:const EdgeInsets.symmetric(vertical:16),decoration:BoxDecoration(color:MarketColors.sky,borderRadius:BorderRadius.circular(16)),
  child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const SolarText('Test payout schedule',style:TextStyle(fontSize:22,fontWeight:FontWeight.w800,color:Color(0xFF162C3B))),
   const SizedBox(height:12),const SolarText('Seven-day hold, then a projected fourteen-day calendar. Forecast only — no available balance or payout approval.'),
   if(widget.data['configured']==true)...[
    SolarText('First calendar cutoff: ${_date(widget.data['first_cutoff_at'])}'),
    SolarText('Cycle: every ${widget.data['cycle_days']} days'),
    SolarText('Projected net from this order: ${commerceMoney((widget.data['projected_total_kobo'] as num).toInt())}'),
   ] else const SolarText('The test calendar has not been started.'),
   for(final raw in (widget.data['items'] as List? ?? []))Padding(padding:const EdgeInsets.only(top:14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    SolarText(raw['name'].toString(),style:const TextStyle(fontWeight:FontWeight.w700)),
    SolarText(raw['eligibility_label'].toString()),
    if(raw['excluded']==true)const SolarText('Excluded from payout projections.')
    else if(raw['projected_cutoff_at']!=null)...[
     SolarText('Projected cutoff: ${_date(raw['projected_cutoff_at'])}'),
     SolarText('Projected seller net: ${commerceMoney((raw['projected_net_kobo'] as num).toInt())}'),
    ] else const SolarText('No projection until the test calendar is started.'),
   ])),
   const SizedBox(height:12),SolarText(widget.data['notice'].toString()),
   if(_busy)const LinearProgressIndicator(),
   if(_error!=null)SolarText(_error!,style:const TextStyle(color:Colors.red)),
   if(widget.provider&&widget.data['can_start']==true&&_pending==null)OutlinedButton(
    onPressed:_busy||widget.disabled?null:_start,child:const SolarText('Set up test payout calendar')),
   if(widget.provider&&_pending!=null&&widget.data['configured']!=true)OutlinedButton(
    onPressed:_busy||widget.disabled?null:_send,child:const SolarText('Retry same calendar request')),
  ])); }
}
