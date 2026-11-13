import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import '../models/auth_session.dart';
import '../marketplace/marketplace_theme.dart';
import 'commerce_service.dart';
import 'commerce_paid_orders_screen.dart';

class CommerceManagementScreen extends StatefulWidget {
  const CommerceManagementScreen({super.key,required this.session,this.api});
  final AuthSession session;
  final CommerceApi? api;
  @override
  State<CommerceManagementScreen> createState()=>_CommerceManagementScreenState();
}

class _CommerceManagementScreenState extends State<CommerceManagementScreen> {
  static const navy=Color(0xFF162C3B);
  late final CommerceApi _api;
  late AuthSession _session;
  bool _needsLogin=false;
  final _loginForm=GlobalKey<FormState>();
  final _rateForm=GlobalKey<FormState>(),_productForm=GlobalKey<FormState>();
  final _fields=<String,TextEditingController>{};
  List<Map<String,dynamic>> _rates=[],_products=[],_sellers=[],_listings=[],_pendingApplications=[],_pendingProducts=[];
  String? _error;
  bool _busy=true,_confirmed=false,_productActive=true,_rateActive=true;
  int _tab=0,_formVersion=0;
  int? _ownerId,_overrideId,_editingProduct;
  String _state='Lagos',_category='Solar panels';
  bool get _provider=>_session.isProvider;
  String get _token=>_session.accessToken;
  TextEditingController c(String key)=>_fields.putIfAbsent(key,TextEditingController.new);
  @override
  void initState(){super.initState();_session=widget.session;_api=widget.api??CommerceApi();_ownerId=_provider?null:_session.userId;_refresh();}
  @override
  void dispose(){for(final field in _fields.values){field.dispose();}if(widget.api==null)_api.close();super.dispose();}
  List<Map<String,dynamic>> rows(dynamic data)=>(data as List).map((r)=>Map<String,dynamic>.from(r as Map)).toList();
  Future<void> _refresh() async {
    setState((){_busy=true;_error=null;});
    try{
      final rates=rows(await _api.call('GET','commerce/delivery-rates',token:_token));
      if(_provider){
        final data=Map<String,dynamic>.from(await _api.call('GET','commerce/catalogue/management',token:_token) as Map);
        final queue=Map<String,dynamic>.from(await _api.call('GET','seller/review-queue',token:_token) as Map);
        if(mounted)setState((){_rates=rates;_products=rows(data['products']);_sellers=rows(data['sellers']);_listings=rows(data['approved_listings']);_pendingApplications=rows(queue['applications']);_pendingProducts=rows(queue['products']);});
      }else{
        final products=await _api.catalogue();
        if(mounted)setState((){_rates=rates;_products=[for(final p in products.where((p)=>p.sellerId==_session.userId)){'id':p.id,'name':p.name,'seller_id':p.sellerId}];});
      }
    }catch(e){if(mounted)setState((){_error=e.toString().replaceFirst('Exception: ','');if(e is CommerceApiException && e.status==401)_needsLogin=true;});}
    finally{if(mounted)setState(()=>_busy=false);}
  }
  Future<void> _run(Future<void> Function() action) async {
    setState((){_busy=true;_error=null;});
    try{await action();if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:SolarText('Saved successfully.')));await _refresh();}}
    catch(e){if(mounted)setState((){_error=e.toString().replaceFirst('Exception: ','');if(e is CommerceApiException && e.status==401)_needsLogin=true;});}
    finally{if(mounted)setState(()=>_busy=false);}
  }
  Future<bool> _confirm(String title,String message) async=>await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:SolarText(title),content:SolarText(message),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const SolarText('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const SolarText('Confirm'))]))??false;
  Widget _field(String key,String label,{int lines=1,bool optional=false,bool money=false,bool whole=false,bool password=false})=>Padding(padding:const EdgeInsets.only(bottom:16),child:TextFormField(controller:c(key),enabled:!_busy,obscureText:password,minLines:lines,maxLines:lines,keyboardType:money||whole?const TextInputType.numberWithOptions(decimal:true):TextInputType.text,decoration:SolarInputDecoration(labelText:label,border:const OutlineInputBorder(),filled:true,fillColor:Colors.white),validator: SolarLanguage.validation<String>((value){final text=(value??'').trim();if(optional&&text.isEmpty)return null;if(text.isEmpty)return 'Enter $label';if(money&&nairaToKobo(text)==null)return 'Enter a naira amount with at most two decimal places';if(whole&&(int.tryParse(text)==null||int.parse(text)<0))return 'Enter a whole number, zero or greater';if(key=='description'&&text.length<20)return 'Enter at least 20 characters';if(key=='sku'&&!RegExp(r'^[A-Za-z0-9_.-]{3,100}$').hasMatch(text))return 'Use 3–100 letters, numbers, dots, hyphens or underscores';if(key=='image'&&(Uri.tryParse(text)?.scheme!='https'||(Uri.tryParse(text)?.host.isEmpty??true)))return 'Enter a public HTTPS image URL';return null;})));
  Widget _box(Widget child)=>Container(width:double.infinity,padding:const EdgeInsets.all(22),margin:const EdgeInsets.only(bottom:22),decoration:BoxDecoration(color:MarketColors.sky,borderRadius:BorderRadius.circular(16)),child:child);
  Widget _heading(String text)=>Padding(padding:const EdgeInsets.only(bottom:18),child:SolarText(text,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800,color:navy)));
  Widget _button(String label,VoidCallback action)=>FilledButton(style:FilledButton.styleFrom(backgroundColor:navy,foregroundColor:Colors.white),onPressed:_busy?null:action,child:SolarText(label));
  void _clearRate(){c('city').text='';c('service').clear();c('base').clear();c('additional').clear();c('min').clear();c('max').clear();_overrideId=null;_rateActive=true;_formVersion++;setState((){});}
  void _editRate(Map<String,dynamic> r){_ownerId=(r['seller_id'] as num?)?.toInt();_overrideId=(r['product_id'] as num?)?.toInt();_state=r['state'] as String;c('city').text=r['city']=='*'?'':r['city'].toString();c('service').text=r['service_name'].toString();c('base').text=((r['base_kobo'] as num)/100).toStringAsFixed(2);c('additional').text=((r['additional_item_kobo'] as num)/100).toStringAsFixed(2);c('min').text=r['min_days'].toString();c('max').text=r['max_days'].toString();_rateActive=r['active']==true;_formVersion++;setState(()=>_tab=0);}
  Widget _delivery(){
    final ownerProducts=_products.where((p)=>(p['seller_id'] as num?)?.toInt()==_ownerId).toList();
    final ids=ownerProducts.map((p)=>(p['id'] as num).toInt()).toSet();
    if(_overrideId!=null&&!ids.contains(_overrideId))_overrideId=null;
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _box(Form(key:_rateForm,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        _heading('Set delivery charges'),const SolarText('Use the actual charges and delivery estimates agreed with your courier. Leave city blank for a state-wide rate. Product-specific rates can cover bulky items.'),const SizedBox(height:20),
        if(_provider)...[DropdownButtonFormField<String>(key:ValueKey('owner-$_formVersion'),initialValue:_ownerId==null?'imad':'$_ownerId',isExpanded:true,decoration:const SolarInputDecoration(labelText:'Fulfilled by',border:OutlineInputBorder()),items:[const DropdownMenuItem(value:'imad',child:SolarText('SolarID')),for(final s in _sellers)DropdownMenuItem(value:'${s['user_id']}',child:SolarText(s['business_name']?.toString()??'Seller ${s['user_id']}')),if(_ownerId!=null&&!_sellers.any((s)=>(s['user_id'] as num).toInt()==_ownerId))DropdownMenuItem(value:'$_ownerId',child:SolarText('Unavailable seller #$_ownerId'))],onChanged:_busy?null:(v){_ownerId=v=='imad'?null:int.tryParse(v??'');_clearRate();}),const SizedBox(height:16)],
        DropdownButtonFormField<String>(key:ValueKey('state-$_formVersion'),initialValue:_state,isExpanded:true,decoration:const SolarInputDecoration(labelText:'State / FCT',border:OutlineInputBorder()),items:[for(final s in commerceStates)DropdownMenuItem(value:s,child:SolarText(s))],onChanged:_busy?null:(v){if(v!=null)setState(()=>_state=v);}),const SizedBox(height:16),
        _field('city','City / town (blank means state-wide)',optional:true),
        DropdownButtonFormField<String>(key:ValueKey('product-$_formVersion'),initialValue:_overrideId?.toString()??'all',isExpanded:true,decoration:const SolarInputDecoration(labelText:'Products covered',border:OutlineInputBorder()),items:[const DropdownMenuItem(value:'all',child:SolarText('All products from this seller')),for(final p in ownerProducts)DropdownMenuItem(value:'${p['id']}',child:SolarText(p['name'].toString(),overflow:TextOverflow.ellipsis))],onChanged:_busy?null:(v)=>setState(()=>_overrideId=v=='all'?null:int.tryParse(v??''))),const SizedBox(height:16),
        _field('service','Courier / delivery service'),_field('base','First-item delivery charge (₦)',money:true),_field('additional','Each additional item (₦)',money:true),_field('min','Minimum delivery days',whole:true),_field('max','Maximum delivery days',whole:true),
        SwitchListTile(contentPadding:EdgeInsets.zero,title:const SolarText('Delivery rate enabled'),value:_rateActive,onChanged:_busy?null:(v)=>setState(()=>_rateActive=v)),const SizedBox(height:14),
        Wrap(spacing:12,runSpacing:12,children:[_button('Save delivery rate',(){if(!_rateForm.currentState!.validate())return;final min=int.parse(c('min').text),max=int.parse(c('max').text);if(min<1||max<min||max>90){setState(()=>_error='Delivery estimates must be between 1 and 90 days, with maximum at least minimum.');return;}_run(()async{await _api.call('PUT','commerce/delivery-rates',token:_token,body:{'seller_id':_ownerId,'state':_state,'city':c('city').text.trim().isEmpty?'*':c('city').text.trim(),'product_id':_overrideId,'service_name':c('service').text.trim(),'base_kobo':nairaToKobo(c('base').text),'additional_item_kobo':nairaToKobo(c('additional').text),'min_days':min,'max_days':max,'active':_rateActive});});}),OutlinedButton(onPressed:_busy?null:_clearRate,child:const SolarText('Clear form'))]),
      ]))),
      _heading('Saved delivery rates'),if(_rates.isEmpty)const SolarText('No delivery rates have been configured.'),
      for(final r in _rates)_box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SolarText('${r['state']} · ${r['city']=='*'?'All cities':r['city']}',style:const TextStyle(fontSize:19,fontWeight:FontWeight.w700)),SolarText('${r['service_name']} · ${r['seller_id']==null?'SolarID':'Seller ${r['seller_id']}'}'),const SizedBox(height:10),SolarText('First item ${commerceMoney((r['base_kobo'] as num).toInt())} · Additional item ${commerceMoney((r['additional_item_kobo'] as num).toInt())}'),SolarText('${r['min_days']}–${r['max_days']} days · ${r['active']==true?'Enabled':'Disabled'}${r['product_id']==null?'':' · Product #${r['product_id']}'}'),const SizedBox(height:12),_button('Edit rate',()=>_editRate(r))])),
    ]);
  }
  void _editProduct(Map<String,dynamic> p){_editingProduct=(p['id'] as num).toInt();c('sku').text=p['sku'].toString();c('name').text=p['name'].toString();c('description').text=p['description'].toString();c('image').text=p['image_url'].toString();c('price').text=((p['price_kobo'] as num)/100).toStringAsFixed(2);c('stock').text=p['stock'].toString();_category=p['category'].toString();_productActive=p['active']==true;_confirmed=false;_formVersion++;setState(()=>_tab=1);}
  Widget _inventory()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    _box(Form(key:_productForm,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _heading(_editingProduct==null?'Publish an SolarID product':'Edit SolarID product'),
      _field('sku','Product SKU'),_field('name','Product name'),_field('description','Product description',lines:3),_field('image','Product photo HTTPS URL'),
      DropdownButtonFormField<String>(key:ValueKey('category-$_formVersion'),initialValue:_category,isExpanded:true,decoration:const SolarInputDecoration(labelText:'Category',border:OutlineInputBorder()),items:[for(final category in {'Solar panels','Batteries','Inverters','Solar appliances','Portable solar','Complete systems','Accessories',_category})DropdownMenuItem(value:category,child:SolarText(category))],onChanged:_busy?null:(v){if(v!=null)setState(()=>_category=v);}),const SizedBox(height:16),
      _field('price','Confirmed selling price (₦)',money:true),_field('stock','Available stock',whole:true),
      CheckboxListTile(contentPadding:EdgeInsets.zero,title:const SolarText('I confirm this is the actual selling price and available stock.'),value:_confirmed,onChanged:_busy?null:(v)=>setState(()=>_confirmed=v??false)),
      SwitchListTile(contentPadding:EdgeInsets.zero,title:const SolarText('Available for online ordering'),value:_productActive,onChanged:_busy?null:(v)=>setState(()=>_productActive=v)),
      const SizedBox(height:12),Wrap(spacing:12,runSpacing:12,children:[_button('Save product',(){if(!_productForm.currentState!.validate())return;if(!_confirmed||(nairaToKobo(c('price').text)??0)<=0){setState(()=>_error='Confirm a positive selling price and the available stock.');return;}_run(()async{await _api.call(_editingProduct==null?'POST':'PUT','commerce/catalogue/imad${_editingProduct==null?'':'/$_editingProduct'}',token:_token,body:{'sku':c('sku').text.trim(),'name':c('name').text.trim(),'description':c('description').text.trim(),'category':_category,'image_url':c('image').text.trim(),'price_kobo':nairaToKobo(c('price').text),'stock':int.parse(c('stock').text),'price_confirmed':true,'active':_productActive});});}),OutlinedButton(onPressed:_busy?null:(){for(final key in ['sku','name','description','image','price','stock']){c(key).clear();}setState((){_editingProduct=null;_confirmed=false;_productActive=true;});},child:const SolarText('New product'))]),
    ]))),
    _heading('Published products'),if(_products.isEmpty)const SolarText('No products have been published yet.'),
    for(final p in _products)_box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SolarText(p['name'].toString(),style:const TextStyle(fontSize:19,fontWeight:FontWeight.w700)),SolarText('${commerceMoney((p['price_kobo'] as num).toInt())} · ${p['stock']} in stock · ${p['active']==true?'Enabled':'Disabled'}'),const SizedBox(height:10),if(p['seller_id']==null)_button('Edit product',()=>_editProduct(p))else const SolarText('Seller inventory is managed through the approved seller listing.')])),
    const SizedBox(height:16),_heading('Approved seller listings'),if(_listings.isEmpty)const SolarText('No approved seller listings are ready to publish.'),
    for(final p in _listings)_box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SolarText(p['name'].toString(),style:const TextStyle(fontSize:19,fontWeight:FontWeight.w700)),SolarText('Seller ${p['user_id']} · ₦${p['price']} · ${p['stock']} in stock'),const SizedBox(height:12),_button('Publish / refresh listing',()async{if(!await _confirm('Confirm product details','Confirm the seller’s current price and available stock before publishing this product.'))return;if(!mounted)return;_run(()async{await _api.call('POST','commerce/catalogue/seller-listings/${p['id']}/publish',token:_token,body:{'price_confirmed':true});});})])),
  ]);
  Widget _reviews()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    _heading('Seller applications'),if(_pendingApplications.isEmpty)const SolarText('No applications are waiting for review.'),
    for(final p in _pendingApplications)_box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SolarText(p['business_name']?.toString()??'Seller ${p['user_id']}',style:const TextStyle(fontSize:19,fontWeight:FontWeight.w700)),SolarText('${p['location']} · ${p['phone']}'),SolarText(p['description']?.toString()??''),const SizedBox(height:12),_button('Approve seller',()async{if(!await _confirm('Approve seller','Approve this business after checking its application and identity.'))return;if(!mounted)return;_run(()async{await _api.call('PATCH','seller/review/application/${p['id']}',token:_token,body:{'status':'approved','note':'Reviewed by SolarID.'});});})])),
    const SizedBox(height:26),_heading('Product reviews'),if(_pendingProducts.isEmpty)const SolarText('No products are waiting for review.'),
    for(final p in _pendingProducts)_box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SolarText(p['name'].toString(),style:const TextStyle(fontSize:19,fontWeight:FontWeight.w700)),SolarText('${p['description']}\n${p['specifications']}'),SolarText('Seller ${p['user_id']} · ₦${p['price']} · ${p['stock']} in stock'),const SizedBox(height:12),_button('Approve product',()async{if(!await _confirm('Approve product','Check the product, photo, price, warranty and stock before approval. Publication is a separate step.'))return;if(!mounted)return;_run(()async{await _api.call('PATCH','seller/review/product/${p['id']}',token:_token,body:{'status':'approved','note':'Reviewed by SolarID.'});});})])),
  ]);
  Widget _login()=>_box(Form(key:_loginForm,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    _heading('Sign in to product services'),
    const SolarText('Use your SolarID provider or approved seller account. Your energy-purchase session will stay unchanged.'),const SizedBox(height:18),
    _field('commerceEmail','Email address'),_field('commercePassword','Password',password:true),
    _button('Sign in',()async{
      if(!_loginForm.currentState!.validate())return;
      setState((){_busy=true;_error=null;});
      try {
        final result=Map<String,dynamic>.from(await _api.call('POST','login',body:{'email':c('commerceEmail').text.trim().toLowerCase(),'password':c('commercePassword').text}) as Map);
        final session=AuthSession.fromJson(result);
        c('commercePassword').clear();
        if(!mounted)return;
        setState((){_session=session;_needsLogin=false;_tab=0;_ownerId=session.isProvider?null:session.userId;_overrideId=null;_formVersion++;});
        await _refresh();
      }catch(e){if(mounted)setState(()=>_error=e.toString().replaceFirst('Exception: ',''));}
      finally{if(mounted)setState(()=>_busy=false);}
    }),
  ])));
  @override
  Widget build(BuildContext context){ SolarLanguage.watch(context); return Scaffold(backgroundColor:Colors.white,appBar:AppBar(backgroundColor:MarketColors.sky,foregroundColor:navy,title:const SolarText('Product commerce'),actions:[IconButton(tooltip: SolarLanguage.instance.translate('Refresh'),onPressed:_busy?null:_refresh,icon:const Icon(Icons.refresh))]),body:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:1100),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    SolarText(_provider?'Manage products and delivery':'Your delivery settings',style:const TextStyle(fontSize:30,fontWeight:FontWeight.w800,color:navy)),const SizedBox(height:10),SolarText('Signed in as ${_session.name}'),const SizedBox(height:10),const SolarText('Seller commission: 5% of product subtotal. Seller funds become eligible seven days after confirmed delivery, then enter the next 14-day payout cycle.'),const SizedBox(height:20),
    if(!_needsLogin)Padding(padding:const EdgeInsets.only(bottom:20),child:OutlinedButton.icon(onPressed:_busy?null:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>CommercePaidOrdersScreen(api:_api,token:_token))),icon:const Icon(Icons.receipt_long_outlined),label:const SolarText('Paid product orders'))),
    if(_provider)Wrap(spacing:10,runSpacing:10,children:[for(final item in [(0,'Delivery rates'),(1,'Products'),(2,'Seller approvals')])ChoiceChip(label:SolarText(item.$2),selected:_tab==item.$1,selectedColor:MarketColors.sky,onSelected:_busy?null:(_)=>setState(()=>_tab=item.$1))]),const SizedBox(height:24),
    if(_busy)const LinearProgressIndicator(),if(_error!=null)Padding(padding:const EdgeInsets.symmetric(vertical:20),child:SolarText(_error!,style:const TextStyle(color:Colors.red))),
    _needsLogin?_login():_tab==1&&_provider?_inventory():_tab==2&&_provider?_reviews():_delivery(),
  ]))))); }
}
