import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../marketplace/marketplace_theme.dart';
import '../marketplace/marketplace_widgets.dart';
import '../marketplace/marketplace_examples.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key, required this.onCustomerAccess});
  final VoidCallback onCustomerAccess;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MarketplaceShell(activeSection: 'Marketplace', 
    onCustomerAccess: onCustomerAccess, title: 'The complete solar marketplace', subtitle: '',
    hero: const _MarketBanner(),
    child: Column(children: [
      const PageSection(color: Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SolarText('Everything starts with the right equipment.', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, height: 1.15, color: MarketColors.ink)),
        SizedBox(height: 22),
        SolarText('From the first panel to the final connection, explore equipment for a brighter home, a productive business and power wherever life takes you. Discover solar generation, storage, lighting, appliances and the small components that bring a complete system together.', style: TextStyle(fontSize: 18, height: 1.65, color: MarketColors.muted)),
        SizedBox(height: 15),
        SolarText('Compare the product examples below, open their details and contact SolarID to find the right option for your needs.', style: TextStyle(fontSize: 17, height: 1.6, color: MarketColors.muted)),
      ])),
      Container(width: double.infinity, color: MarketColors.sky,
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1340),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 65),
            child: Column(children: [
              const SolarText('Explore the solar marketplace', textAlign: TextAlign.center, style: TextStyle(fontSize: 38, height: 1.1, fontWeight: FontWeight.w800, color: MarketColors.ink)),
              const SizedBox(height: 16),
              const SolarText('Generation. Storage. Everyday possibilities.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: MarketColors.muted)),
              const SizedBox(height: 12),
              const SolarText('Preview catalogue: prices and “more” counts are sample values. Confirm availability and your final quote with SolarID.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.5, color: MarketColors.muted)),
              const SizedBox(height: 56),
              for(var i=0; i<marketExamples.length; i++) _TimelineEntry(product: marketExamples[i], index: i),
            ])))),
      ),
    ]),
  ); }
}

class _MarketBanner extends StatelessWidget {
  const _MarketBanner();
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  LayoutBuilder(builder: (context, box) => SizedBox(
    height: box.maxWidth >= 850 ? 510 : 410,
    child: Stack(fit: StackFit.expand, children: [
      Image.asset('assets/images/home_industrial.png', fit: BoxFit.cover),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x18001D30), Color(0xA0001D30)]))),
      Center(child: Padding(padding: const EdgeInsets.all(28), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 850), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SolarText('MORE POSSIBILITIES. ONE MARKETPLACE.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2)),
        const SizedBox(height: 20),
        SolarText('Find your next\nsolar solution.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: box.maxWidth >= 850 ? 62 : 40, height: 1.06, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        const SolarText('Equipment for everyday energy, from essentials to complete systems.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, height: 1.5)),
      ])))),
    ]),
  )); }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.product, required this.index});
  final MarketExample product;
  final int index;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  LayoutBuilder(builder: (context, box) {
    final wide = box.maxWidth >= 850;
    final left = index.isEven;
    final card = _ScrollReveal(fromLeft: left, child: _ExampleCard(product: product));
    final line = SizedBox(width: wide ? 78 : 32, child: Stack(fit: StackFit.expand, children: [
      Center(child: Container(width: 2, color: const Color(0xFF73BDD7))),
      Positioned(top: 54, left: wide ? 31 : 8, child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Color(0xFF0786B3), shape: BoxShape.circle), child: Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))))),
    ]));
    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: wide ? [
      Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 56), child: left ? card : const SizedBox.shrink())),
      line,
      Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 56), child: left ? const SizedBox.shrink() : card)),
    ] : [line, Expanded(child: Padding(padding: const EdgeInsets.only(left: 12, bottom: 38), child: card))]));
  }); }
}

class _ExampleCardContent extends StatelessWidget {
  const _ExampleCardContent({required this.product});
  final MarketExample product;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .73), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white), boxShadow: const [BoxShadow(color: Color(0x0A06384F), blurRadius: 25, offset: Offset(0, 10))]),
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SolarText(product.category.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: Color(0xFF087AA4))),
      const SizedBox(height: 18),
      SizedBox(height: 230, width: double.infinity, child: MarketExampleImage(product: product)),
      const SizedBox(height: 20),
      SolarText(product.name, style: const TextStyle(fontSize: 26, height: 1.15, fontWeight: FontWeight.w800, color: MarketColors.ink)),
      const SizedBox(height: 12),
      SolarText(product.description, style: const TextStyle(fontSize: 16, height: 1.55, color: MarketColors.muted)),
      const SizedBox(height: 12),
      SolarText(product.specification, style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: MarketColors.ink)),
      const SizedBox(height: 20),
      SolarText(formatNaira(product.price), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: MarketColors.ink)),
      const SolarText('Sample price', style: TextStyle(fontSize: 12, color: MarketColors.muted)),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: SolarText('${product.more.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => '${m[1]},')}+ more', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF087AA4)))), TextButton(onPressed: () => showMarketExample(context, product), child: const SolarText('Explore more →'))]),
      const SolarText('Sample range count', style: TextStyle(fontSize: 11, color: MarketColors.muted)),
      const SizedBox(height: 18),
      SizedBox(width: 170, child: FilledButton.icon(onPressed: () => showMarketExample(context, product, ordering: true),
        style: imadBlueButtonStyle(backgroundColor: MarketColors.green, foregroundColor: MarketColors.ink, padding: const EdgeInsets.symmetric(vertical: 21), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        label: const SolarText('Order Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), icon: const Icon(Icons.arrow_forward_rounded, size: 21), iconAlignment: IconAlignment.end)),
    ]),
  ); }
}

class MarketExampleImage extends StatelessWidget {
  const MarketExampleImage({super.key, required this.product});
  final MarketExample product;
  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final image = Image.asset('assets/images/catalogue/${product.image}', cacheWidth: 1000, fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.solar_power_outlined, size: 64)));
    if(product.image == 'deye-inverter.png') return ClipRect(child: FittedBox(fit: BoxFit.contain, child: ClipRect(child: Align(alignment: Alignment.centerLeft, widthFactor: .53, child: image))));
    if(product.image == 'jinko-mono.jpg') return ClipRect(child: FittedBox(fit: BoxFit.contain, child: ClipRect(child: Align(widthFactor: .65, heightFactor: .55, child: image))));
    return image;
  }
}

void showMarketExample(BuildContext context, MarketExample product, {bool ordering = false}) {
  showDialog<void>(context: context, builder: (dialogContext) => Dialog(
    insetPadding: const EdgeInsets.all(20), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 750),
      child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [Expanded(child: SolarText(ordering ? 'Order enquiry' : product.category, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))), IconButton(tooltip: SolarLanguage.instance.translate('Close'), onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close))]),
        SizedBox(height: 240, width: double.infinity, child: MarketExampleImage(product: product)),
        const SizedBox(height: 20), SolarText(product.name, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14), SolarText(product.description, style: const TextStyle(fontSize: 17, height: 1.5)),
        const SizedBox(height: 14), SolarText(product.specification, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.6)),
        const SizedBox(height: 14), SolarText(product.detail, style: const TextStyle(fontSize: 16, height: 1.6)),
        const SizedBox(height: 20), SolarText('${formatNaira(product.price)} · sample price', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
        const SizedBox(height: 12), const SolarText('The displayed range counts and prices are demonstration values. Ask SolarID for available alternatives, the confirmed price, delivery and installation.', style: TextStyle(height: 1.5, color: MarketColors.muted)),
        const SizedBox(height: 22), Wrap(spacing: 12, runSpacing: 12, children: [
          FilledButton.icon(onPressed: () => openImadWhatsApp('Hello SolarID, I would like to enquire about ${product.name}. Please confirm availability, price and other options in ${product.category}. The website sample price is ${formatNaira(product.price)}.'), icon: const Icon(Icons.chat_outlined), label: const SolarText('Confirm order on WhatsApp')),
          OutlinedButton(onPressed: () => launchUrl(Uri.parse(product.source), mode: LaunchMode.externalApplication), child: const SolarText('Manufacturer details ↗')),
        ]),
      ])))),
  ));
}

class _ScrollReveal extends StatefulWidget {
  const _ScrollReveal({required this.child, required this.fromLeft});
  final Widget child;
  final bool fromLeft;
  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}
class _ScrollRevealState extends State<_ScrollReveal> {
  ScrollPosition? _position;
  bool _visible = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if(next != _position) { _position?.removeListener(_check); _position = next; _position?.addListener(_check); }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }
  void _check() {
    if(!mounted || _visible) return;
    final render = context.findRenderObject();
    if(render is! RenderBox || !render.hasSize) return;
    final y = render.localToGlobal(Offset.zero).dy;
    if(MediaQuery.disableAnimationsOf(context) || (y < MediaQuery.sizeOf(context).height - 25 && y + render.size.height > 0)) setState(() => _visible = true);
  }
  @override
  void dispose() { _position?.removeListener(_check); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedOpacity(opacity: _visible || reduced ? 1 : 0, duration: Duration(milliseconds: reduced ? 0 : 500),
      child: AnimatedSlide(offset: _visible || reduced ? Offset.zero : Offset(widget.fromLeft ? -.06 : .06, .035), duration: Duration(milliseconds: reduced ? 0 : 550), curve: Curves.easeOutCubic, child: widget.child));
  }
}


class _ExampleCard extends StatefulWidget {
  const _ExampleCard({required this.product});
  final MarketExample product;

  @override
  State<_ExampleCard> createState() => _ExampleCardState();
}

class _ExampleCardState extends State<_ExampleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final duration = Duration(milliseconds: reduced ? 0 : 220);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered && !reduced ? 1.02 : 1.0,
        duration: duration,
        curve: Curves.easeOutCubic,
        child: AnimatedSlide(
          offset: _hovered && !reduced
              ? const Offset(0, -.006)
              : Offset.zero,
          duration: duration,
          curve: Curves.easeOutCubic,
          child: _ExampleCardContent(product: widget.product),
        ),
      ),
    );
  }
}