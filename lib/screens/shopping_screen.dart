import 'package:solar_paygo_app/l10n/solar_language.dart';
import '../widgets/spacing_carousel.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../marketplace/marketplace_theme.dart';
import '../marketplace/marketplace_widgets.dart';
import '../marketplace/shopping_catalogue.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key, required this.onCustomerAccess});
  final VoidCallback onCustomerAccess;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MarketplaceShell(activeSection: 'Shopping', 
    onCustomerAccess: onCustomerAccess,
    title: 'Popular products',
    subtitle: 'Discover solar panels, batteries and inverters. Compare capacities and explore the equipment that fits your space.',
    child: Column(children: [
      for (final category in ['Solar panels', 'Batteries', 'Inverters'])
        _EquipmentSection(category: category, products: shoppingCatalogue.where((p) => p.category == category).toList()),
    ]),
  ); }
}

class _EquipmentSection extends StatefulWidget {
  const _EquipmentSection({required this.category, required this.products});
  final String category;
  final List<CatalogueProduct> products;
  @override
  State<_EquipmentSection> createState() => _EquipmentSectionState();
}
class _EquipmentSectionState extends State<_EquipmentSection> {
  String _filter = 'All';
  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final batteries = widget.category == 'Batteries';
    final products = widget.products.where((p) => _filter == 'All' || p.applications.contains(_filter)).toList();
    // Both rows contain different products, unless a filter has fewer than six results.
    final split = (products.length / 2).ceil();
    final first = products.length >= 6 ? products.sublist(0, split) : products;
    final second = products.length >= 6 ? products.sublist(split) : products.reversed.toList();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: batteries ? [Colors.white, MarketColors.sky, Colors.white] : [MarketColors.sky, Colors.white])),
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1480), child: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionTitle(title: widget.category, subtitle: batteries ? 'Store daytime energy for brighter evenings.' : widget.category == 'Inverters' ? 'Convert solar energy into dependable everyday power.' : 'From compact rooftops to larger commercial installations.',
            icon: batteries ? Icons.battery_charging_full : widget.category == 'Inverters' ? Icons.electrical_services : Icons.solar_power_outlined),
          const SizedBox(height: 22),
          Wrap(spacing: 8, runSpacing: 8, children: [for(final filter in ['All','Homes','Shops','Companies', if(widget.category == 'Solar panels') 'Vehicles', 'Latest additions'])
            ChoiceChip(label: SolarText(filter), selected: _filter == filter, selectedColor: MarketColors.sky,
              onSelected: (_) => setState(() => _filter = filter)),
          ]),
        ])),
        const SizedBox(height: 34),
        if(products.isEmpty) const Padding(padding: EdgeInsets.all(32), child: SolarText('No products in this category. Choose another application.'))
        else ...[
          _ProductCarousel(key: ValueKey('${widget.category}:$_filter:1'), products: first, vertical: batteries),
          const SizedBox(height: 48),
          _ProductCarousel(key: ValueKey('${widget.category}:$_filter:2'), products: second, vertical: batteries, reverse: true),
        ],
      ]))),
    );
  }
}

class _ProductCarousel extends StatelessWidget {
  const _ProductCarousel({super.key, required this.products, required this.vertical, this.reverse = false});
  final List<CatalogueProduct> products;
  final bool vertical, reverse;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  ShoppingProductCarousel(
    reverse: reverse, tall: vertical,
    children: [for (final product in products)
      _ProductCard(product: product, vertical: vertical, mobile: true)],
  ); }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.vertical, required this.mobile});
  final CatalogueProduct product;
  final bool vertical, mobile;
  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final picture = Padding(padding: const EdgeInsets.all(16), child: _ProductImage(product: product));
    final details = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SolarText(product.brand.toUpperCase(), style: const TextStyle(fontSize: 11, letterSpacing: 1.2, color: MarketColors.greenDark, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      SolarText(product.name, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: vertical ? 21 : 19, height: 1.15, fontWeight: FontWeight.w900, color: MarketColors.ink)),
      const SizedBox(height: 12),
      for(final spec in product.specs.take(3)) Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.check_circle_outline, size: 17, color: MarketColors.green), const SizedBox(width: 7),
        Expanded(child: SolarText(spec, style: const TextStyle(fontSize: 13, height: 1.25, color: MarketColors.muted))),
      ])),
      ]))),
      const SizedBox(height: 8),
      SolarText(product.price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: MarketColors.ink)),
      if(product.price != 'Request price') const SolarText('Sample price', style: TextStyle(fontSize: 10, color: MarketColors.muted)),
      const SizedBox(height: 12),
      SizedBox(width: 170, child: FilledButton(onPressed: () => _details(context), style: imadBlueButtonStyle(backgroundColor: MarketColors.green, foregroundColor: MarketColors.ink, padding: const EdgeInsets.symmetric(vertical: 15)), child: const SolarText('Learn more  →'))),
    ]);
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(vertical ? 22 : 5), border: Border.all(color: MarketColors.line), boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 16, offset: Offset(0,6))]),
      child: ClipRRect(borderRadius: BorderRadius.circular(vertical ? 22 : 5), child: vertical || mobile ? Column(children: [
        SizedBox(height: vertical ? 210 : 195, width: double.infinity, child: ColoredBox(color: const Color(0xFFF5FAFC), child: picture)),
        Expanded(child: Padding(padding: const EdgeInsets.all(20), child: details)),
      ]) : Padding(padding: const EdgeInsets.all(24), child: Row(children: [Expanded(flex: 3, child: details), const SizedBox(width: 12), Expanded(flex: 2, child: picture)]))),
    );
  }
  Future<void> _openLink(BuildContext context, String url) async {
    try {
      if(await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) return;
    } catch (_) { /* A failed link leaves the product details open. */ }
    if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: SolarText('Unable to open this link. Please try again.')));
  }
  void _details(BuildContext context) => showDialog<void>(context: context, builder: (dialogContext) => Dialog(
    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [Expanded(child: SolarText(product.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900))), IconButton(tooltip: SolarLanguage.instance.translate('Close'), onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close))]),
      const SizedBox(height: 18),
      Center(child: SizedBox(height: 220, child: _ProductImage(product: product))),
      const SizedBox(height: 20), SolarText(product.description, style: const TextStyle(height: 1.6)),
      const SizedBox(height: 20), for(final spec in product.specs) Padding(padding: const EdgeInsets.only(bottom: 9), child: SolarText('• $spec')),
      const SizedBox(height: 16), SolarText(product.price, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      SolarText('Suitable applications: ${product.applications.where((a) => a != "Latest additions").join(", ")}', style: const TextStyle(height: 1.5)),
      const SizedBox(height: 10),
      SolarText(product.imageNote, style: const TextStyle(fontSize: 12, color: MarketColors.muted)),
      const SizedBox(height: 10),
      SolarText(product.priceNote, style: const TextStyle(color: MarketColors.muted, height: 1.5)),
      const SizedBox(height: 24), Wrap(spacing: 12, runSpacing: 12, children: [
        FilledButton.icon(onPressed: () => openImadWhatsApp('Hello SolarID, please confirm the price and availability of ${product.brand} ${product.name}.'), icon: const Icon(Icons.chat_outlined), label: const SolarText('Enquire / order')),
        if(product.priceSource.isNotEmpty) OutlinedButton(onPressed: () => _openLink(dialogContext, product.priceSource), child: const SolarText('Supplier price reference')),
        OutlinedButton.icon(onPressed: () => _openLink(dialogContext, product.source), icon: const Icon(Icons.open_in_new), label: const SolarText('Manufacturer details')),
      ]),
    ]))),
  ));
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});
  final CatalogueProduct product;
  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final jinko = product.image.startsWith('jinko');
    final inverter = product.image.startsWith('deye-inverter');
    return FittedBox(fit: BoxFit.contain, child: ClipRect(child: Align(
      widthFactor: inverter ? .53 : jinko ? .65 : 1,
      heightFactor: jinko ? .55 : 1,
      alignment: inverter ? Alignment.centerLeft : Alignment.center,
      child: Image.asset('assets/images/catalogue/${product.image}', semanticLabel: product.name),
    )));
  }
}
