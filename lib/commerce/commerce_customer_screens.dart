import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_theme.dart';
import 'commerce_service.dart';
import 'commerce_checkout_screen.dart';
import 'commerce_order_screen.dart';

const _navy = Color(0xFF162C3B);

class CommerceToolbar extends StatefulWidget {
  const CommerceToolbar({super.key, required this.section});
  final String section;
  @override
  State<CommerceToolbar> createState()=>_CommerceToolbarState();
}
class _CommerceToolbarState extends State<CommerceToolbar> {
  @override
  void initState(){super.initState();CommerceBasket.instance.init().catchError((Object _) {});}
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(color:Colors.white, padding:const EdgeInsets.symmetric(horizontal:24,vertical:14), child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:1340),child:Wrap(alignment:WrapAlignment.end,spacing:12,runSpacing:10,children:[
    OutlinedButton.icon(onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>CommerceCatalogueScreen(section:widget.section))), icon:const Icon(Icons.storefront_outlined),label:const SolarText('Shop available products')),
    ListenableBuilder(listenable:CommerceBasket.instance,builder:(context,_)=>FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:_navy,foregroundColor:Colors.white),onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const CommerceBasketScreen())),icon:const Icon(Icons.shopping_bag_outlined),label:SolarText('Basket (${CommerceBasket.instance.count})'))),
  ])))); }
}

class CommerceCatalogueScreen extends StatefulWidget {
  const CommerceCatalogueScreen({super.key,this.section='Marketplace',this.api,this.basket});
  final String section;
  final CommerceApi? api;
  final CommerceBasket? basket;
  @override
  State<CommerceCatalogueScreen> createState()=>_CommerceCatalogueScreenState();
}
class _CommerceCatalogueScreenState extends State<CommerceCatalogueScreen> {
  late final CommerceApi _api;
  late final CommerceBasket _basket;
  List<CommerceProduct> _products=[];
  bool _loading=true;
  String? _error;
  @override
  void initState(){super.initState();_api=widget.api??CommerceApi();_basket=widget.basket??CommerceBasket.instance;_load();}
  @override
  void dispose(){if(widget.api==null)_api.close();super.dispose();}
  Future<void> _load() async {
    setState((){_loading=true;_error=null;});
    try {await _basket.init();final products=await _api.catalogue();if(mounted)setState(()=>_products=products.where((p)=>widget.section!='Shopping'||const ['Solar panels','Batteries','Inverters'].contains(p.category)).toList());}
    catch(e){if(mounted)setState(()=>_error=e.toString().replaceFirst('Exception: ',''));}
    finally{if(mounted)setState(()=>_loading=false);}
  }
  @override
  Widget build(BuildContext context){ SolarLanguage.watch(context); return Scaffold(backgroundColor:MarketColors.sky,appBar:AppBar(backgroundColor:Colors.white,foregroundColor:_navy,title:const SolarText('Available products'),actions:[ListenableBuilder(listenable:_basket,builder:(ctx,_)=>TextButton.icon(onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>CommerceBasketScreen(basket:_basket,api:_api))),icon:const Icon(Icons.shopping_bag_outlined),label:SolarText('Basket (${_basket.count})'))),IconButton(tooltip: SolarLanguage.instance.translate('Refresh products'),onPressed:_loading?null:_load,icon:const Icon(Icons.refresh))]),body:_loading?const Center(child:CircularProgressIndicator()):_error!=null?Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[SolarText(_error!,textAlign:TextAlign.center),const SizedBox(height:16),FilledButton(onPressed:_load,child:const SolarText('Try again'))]))):_products.isEmpty?const Center(child:Padding(padding:EdgeInsets.all(28),child:SolarText('No products are available for online ordering yet.\nPlease check again soon.',textAlign:TextAlign.center))):SingleChildScrollView(padding:const EdgeInsets.all(24),child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:1300),child:LayoutBuilder(builder:(ctx,box){final columns=box.maxWidth>=950?3:box.maxWidth>=600?2:1;final width=(box.maxWidth-(columns-1)*20)/columns;return Wrap(spacing:20,runSpacing:20,children:[for(final p in _products)SizedBox(width:width,child:Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SizedBox(height:180,width:double.infinity,child:Image.network(p.imageUrl,webHtmlElementStrategy:WebHtmlElementStrategy.fallback,fit:BoxFit.contain,errorBuilder:(_,__,___)=>const Center(child:Icon(Icons.image_not_supported_outlined,size:48)))),const SizedBox(height:18),SolarText(p.name,style:const TextStyle(fontSize:23,fontWeight:FontWeight.w800,color:_navy)),const SizedBox(height:10),SolarText(p.description,maxLines:3,overflow:TextOverflow.ellipsis),const SizedBox(height:14),SolarText(commerceMoney(p.priceKobo),style:const TextStyle(fontSize:21,fontWeight:FontWeight.w800,color:_navy)),const SizedBox(height:8),SolarText('${p.stock} available · ${p.sellerId==null?'SolarID':'Marketplace seller'}'),const SizedBox(height:16),FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:_navy,foregroundColor:Colors.white),onPressed:(){try{_basket.add(p);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:SolarText('${p.name} added to basket')));}catch(e){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:SolarText(e.toString().replaceFirst('Bad state: ',''))));}},icon:const Icon(Icons.add_shopping_cart),label:const SolarText('Add to basket'))])))]);}))))); }
}

class CommerceBasketScreen extends StatefulWidget {
  const CommerceBasketScreen({super.key,this.api,this.basket});
  final CommerceApi? api;
  final CommerceBasket? basket;
  @override
  State<CommerceBasketScreen> createState()=>_CommerceBasketScreenState();
}
class _CommerceBasketScreenState extends State<CommerceBasketScreen> {
  late final CommerceApi _api;
  late final CommerceBasket _basket;
  final _form=GlobalKey<FormState>();
  final _city=TextEditingController();
  String _state='Lagos';
  Map<int,CommerceProduct> _products={};
  Map<String,dynamic>? _quote;
  String? _error;
  bool _loading=true,_quoting=false;
  int _requestVersion=0;
  @override
  void initState(){super.initState();_api=widget.api??CommerceApi();_basket=widget.basket??CommerceBasket.instance;_basket.addListener(_changed);_city.addListener(_changed);_load();}
  void _changed(){_requestVersion++;if(mounted)setState(()=>_quote=null);}
  @override
  void dispose(){_basket.removeListener(_changed);_city.removeListener(_changed);_city.dispose();if(widget.api==null)_api.close();super.dispose();}
  Future<void> _load() async {
    try{await _basket.init();final products=await _api.catalogue();if(mounted)setState(()=>_products={for(final p in products)p.id:p});}
    catch(e){if(mounted)setState(()=>_error=e.toString().replaceFirst('Exception: ',''));}
    finally{if(mounted)setState(()=>_loading=false);}
  }
  Future<void> _calculate() async {
    if(!_form.currentState!.validate()||_basket.items.isEmpty)return;
    final version=++_requestVersion;
    setState((){_quoting=true;_error=null;_quote=null;});
    try{final result=Map<String,dynamic>.from(await _api.call('POST','commerce/basket/quote',body:{'country':'NG','state':_state,'city':_city.text.trim(),'items':_basket.requestItems()}) as Map);if(mounted&&version==_requestVersion)setState(()=>_quote=result);}
    catch(e){if(mounted&&version==_requestVersion)setState(()=>_error=e.toString().replaceFirst('Exception: ',''));}
    finally{if(mounted)setState(()=>_quoting=false);}
  }
  @override
  Widget build(BuildContext context){ SolarLanguage.watch(context); return Scaffold(backgroundColor:Colors.white,appBar:AppBar(backgroundColor:MarketColors.sky,foregroundColor:_navy,title:const SolarText('Your basket')),body:_loading?const Center(child:CircularProgressIndicator()):SingleChildScrollView(padding:const EdgeInsets.all(24),child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:1000),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    TextButton.icon(onPressed:()=>CommerceOrderScreen.openLatest(context,_api),icon:const Icon(Icons.receipt_long_outlined),label:const SolarText('View last saved order on this device')),
    const SolarText('Review your items',style:TextStyle(fontSize:30,fontWeight:FontWeight.w800,color:_navy)),const SizedBox(height:20),
    if(_basket.items.isEmpty)const SolarText('Your basket is empty. Browse available products to add an item.'),
    for(final entry in _basket.items.entries)...[
      Container(margin:const EdgeInsets.only(bottom:14),padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:MarketColors.sky,borderRadius:BorderRadius.circular(14)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SolarText(_products[entry.key]?.name??'Product no longer available',style:const TextStyle(fontSize:19,fontWeight:FontWeight.w700)),const SizedBox(height:10),if(_products[entry.key]!=null)SolarText('${commerceMoney(_products[entry.key]!.priceKobo)} each'),Wrap(spacing:10,crossAxisAlignment:WrapCrossAlignment.center,children:[IconButton(tooltip: SolarLanguage.instance.translate('Decrease quantity'),onPressed:_quoting?null:()=>_basket.setQuantity(entry.key,entry.value-1),icon:const Icon(Icons.remove)),SolarText('${entry.value}'),IconButton(tooltip: SolarLanguage.instance.translate('Increase quantity'),onPressed:_quoting||_products[entry.key]==null||entry.value>=_products[entry.key]!.stock||entry.value>=100?null:()=>_basket.setQuantity(entry.key,entry.value+1),icon:const Icon(Icons.add)),TextButton(onPressed:_quoting?null:()=>_basket.setQuantity(entry.key,0),child:const SolarText('Remove'))])])),
    ],
    if(_basket.items.isNotEmpty)...[
      const SizedBox(height:22),const SolarText('Where should we deliver?',style:TextStyle(fontSize:23,fontWeight:FontWeight.w800,color:_navy)),const SizedBox(height:16),
      Form(key:_form,child:Column(children:[DropdownButtonFormField<String>(initialValue:_state,isExpanded:true,decoration:const SolarInputDecoration(labelText:'State / FCT',border:OutlineInputBorder()),items:[for(final s in commerceStates)DropdownMenuItem(value:s,child:SolarText(s))],onChanged:_quoting?null:(v){if(v!=null){_state=v;_changed();}}),const SizedBox(height:16),TextFormField(controller:_city,enabled:!_quoting,decoration:const SolarInputDecoration(labelText:'City / town',border:OutlineInputBorder()),validator: SolarLanguage.validation<String>((v)=>(v??'').trim().length<2?'Enter your city or town':null))])),
      const SizedBox(height:20),FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:_navy,foregroundColor:Colors.white),onPressed:_quoting?null:_calculate,icon:const Icon(Icons.local_shipping_outlined),label:SolarText(_quoting?'Calculating…':'Calculate delivery and total')),
    ],
    if(_error!=null)Padding(padding:const EdgeInsets.symmetric(vertical:20),child:SolarText(_error!,style:const TextStyle(color:Colors.red))),
    if(_quote!=null)...[
      const SizedBox(height:26),Container(width:double.infinity,padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:MarketColors.sky,borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SolarText('Products: ${commerceMoney((_quote!['subtotal_kobo'] as num).toInt())}'),const SizedBox(height:10),SolarText('Delivery: ${commerceMoney((_quote!['delivery_kobo'] as num).toInt())}'),const SizedBox(height:14),SolarText('Total: ${commerceMoney((_quote!['total_kobo'] as num).toInt())}',style:const TextStyle(fontSize:26,fontWeight:FontWeight.w800,color:_navy)),const SizedBox(height:16),for(final shipment in _quote!['shipments'] as List)Padding(padding:const EdgeInsets.only(bottom:10),child:SolarText('${shipment['service_name']} · ${shipment['min_days']}–${shipment['max_days']} days · ${commerceMoney((shipment['delivery_kobo'] as num).toInt())}'))])),
    ],
    if(_quote!=null&&!_quoting)Padding(padding:const EdgeInsets.only(top:20),child:FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:_navy,foregroundColor:Colors.white),onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>CommerceCheckoutScreen(api:_api,basket:_basket,state:_state,city:_city.text.trim()))),icon:const Icon(Icons.fact_check_outlined),label:const SolarText('Continue to delivery details'))),
    const SizedBox(height:24),const SolarText('You can review your delivery details next. Product payment is not available yet.'),
  ]))))); }
}
