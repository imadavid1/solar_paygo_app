import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';

import '../marketplace/marketplace_data.dart';
import '../marketplace/marketplace_theme.dart';
import '../marketplace/marketplace_widgets.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product, required this.onCustomerAccess});
  final SolarProduct product;
  final VoidCallback onCustomerAccess;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final related = solarProducts.where((item) => item.category == product.category && item.id != product.id).take(4).toList();
    return MarketplaceShell(activeSection: 'Marketplace', 
      onCustomerAccess: onCustomerAccess,
      title: product.name,
      subtitle: product.description,
      child: Column(children: [
        PageSection(
          color: MarketColors.white,
          child: LayoutBuilder(builder: (context, constraints) {
            final image = ClipRRect(borderRadius: BorderRadius.circular(20), child: AspectRatio(aspectRatio: 1.25, child: ProductImage(product: product)));
            final copy = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              SolarText(product.category.toUpperCase(), style: const TextStyle(color: MarketColors.greenDark, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              SolarText(product.name, style: const TextStyle(color: MarketColors.ink, fontSize: 39, fontWeight: FontWeight.w900, height: 1.05)),
              const SizedBox(height: 18),
              SolarText(product.description, style: const TextStyle(color: MarketColors.muted, fontSize: 17, height: 1.5)),
              const SizedBox(height: 22),
              Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: MarketColors.sky, borderRadius: BorderRadius.circular(13)), child: Row(children: [const Icon(Icons.tune_rounded, color: MarketColors.greenDark), const SizedBox(width: 12), Expanded(child: SolarText(product.specification, style: const TextStyle(color: MarketColors.ink, fontWeight: FontWeight.w700, height: 1.4)))])),
              const SizedBox(height: 25),
              SolarText(formatNaira(product.price), style: const TextStyle(color: MarketColors.ink, fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(height: 22),
              HoverButton(label: 'Order on WhatsApp', icon: Icons.chat_rounded, onPressed: () => openImadWhatsApp('Hello SolarID, I would like to order ${product.name} (${formatNaira(product.price)}).')),
            ]);
            if (constraints.maxWidth >= 850) return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: image), const SizedBox(width: 54), Expanded(child: copy)]);
            return Column(children: [image, const SizedBox(height: 32), copy]);
          }),
        ),
        if (related.isNotEmpty)
          PageSection(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionTitle(title: 'More in this category', subtitle: 'Compare related products before making your decision.'),
            const SizedBox(height: 28),
            ProductGrid(products: related, onProduct: (item) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: item, onCustomerAccess: onCustomerAccess))), onOrder: (item) => openImadWhatsApp('Hello SolarID, I would like to order ${item.name} (${formatNaira(item.price)}).')),
          ])),
      ]),
    );
  }
}
