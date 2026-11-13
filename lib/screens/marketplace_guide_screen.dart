import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_theme.dart';
import '../marketplace/marketplace_widgets.dart';
import '../marketplace/marketplace_examples.dart';
import 'marketplace_screen.dart';

const marketplaceGuideTitles = ['Solar Appliances', 'Portable Solar Products', 'Complete Solar System'];

class MarketplaceGuideScreen extends StatefulWidget {
  const MarketplaceGuideScreen({super.key, required this.onCustomerAccess, this.initialCategory = 'Solar Appliances'});
  final VoidCallback onCustomerAccess;
  final String initialCategory;
  @override
  State<MarketplaceGuideScreen> createState() => _MarketplaceGuideScreenState();
}
class _MarketplaceGuideScreenState extends State<MarketplaceGuideScreen> {
  final _keys = List.generate(3, (_) => GlobalKey());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!mounted) return;
      final i = marketplaceGuideTitles.indexOf(widget.initialCategory);
      final target = _keys[i < 0 ? 0 : i].currentContext;
      if(target != null) Scrollable.ensureVisible(target, alignment: 0);
    });
  }
  void _browse() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MarketplaceScreen(onCustomerAccess: widget.onCustomerAccess)));
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MarketplaceShell(activeSection: 'Marketplace', 
    onCustomerAccess: widget.onCustomerAccess, title: 'Explore more possibilities', subtitle: '', hero: const SizedBox.shrink(),
    child: Container(color: Colors.white, padding: const EdgeInsets.symmetric(vertical: 36), child: Column(children: [
      _GuideFeature(key: _keys[0], title: 'Solar Appliances', heading: 'Make everyday energy\nwork for you.', image: 'marketplace-family-warm.png',
        introduction: 'Bring light, comfort and productivity into everyday spaces. Explore efficient fans, compatible televisions, lanterns, outdoor lighting and water pumps for solar-powered living.',
        explanation: 'Start with the appliance you need, then compare its voltage, power draw and daily running time. Match it with the right panel and storage so the complete setup suits your routine.',
        onBrowse: _browse, examples: [marketExamples[8], marketExamples[13], marketExamples[5], marketExamples[9], imadGapProducts[0], imadGapProducts[1]],
        more: const [('Light where it matters', 'Choose task lighting for reading, portable lanterns for movement, and outdoor lights for shared spaces. Compare brightness and runtime at the setting you actually use.'), ('Comfort and entertainment', 'Efficient DC fans and televisions can work with matched solar home systems. Confirm the connector, voltage and included accessories before selecting an appliance.'), ('Water and productive work', 'Solar pumps need to be sized for water volume and lift height. Explain your application to SolarID so the pump, controller and panel array can be considered together.')]),
      _GuideFeature(key: _keys[1], title: 'Portable Solar Products', heading: 'Take useful power\nwith you.', image: 'portable.png',
        introduction: 'Discover portable power stations, compact lighting and flexible solar options for travel, mobile work and backup at home.',
        explanation: 'Compare stored energy, supported output power and solar input compatibility. A compact setup can be easy to move, while the right capacity helps keep essential devices running.',
        onBrowse: _browse, examples: [marketExamples[12], marketExamples[5], marketExamples[4]],
        more: const [('Understand stored energy', 'Capacity in watt-hours describes stored energy. Runtime depends on the connected devices, conversion losses and operating conditions; it is different from maximum output power.'), ('Match your devices', 'Check socket types, USB output and appliance starting loads. A portable station must support the power your devices need, including any short startup surge.'), ('Charge from daylight', 'Use compatible solar panels within the station’s input limits. Solar charging speed changes with panel rating, weather, shade and orientation.')]),
      _GuideFeature(key: _keys[2], title: 'Complete Solar System', heading: 'Bring the whole\nsolution together.', image: 'assets/images/home_industrial.png', landscape: true,
        introduction: 'Build a connected energy solution around your home, shop or business. Panels, storage, inverters and the right installation components each have a role to play.',
        explanation: 'Choose a coordinated home kit for essential lighting and charging, or plan a larger system from your daily energy needs. SolarID can help you compare the equipment and request a suitable quotation.',
        onBrowse: _browse, examples: [marketExamples[7], marketExamples[0], marketExamples[1], marketExamples[2], imadGapProducts[2], imadGapProducts[3]],
        more: const [('Start with the loads', 'List the equipment you want to power, how long it runs and which loads operate together. This helps establish energy use, peak output and the backup capacity required.'), ('Choose compatible components', 'Panel strings, inverter inputs, battery voltage and communications must work together. Include mounting, cabling, isolation and the correct protection components in the plan.'), ('Confirm the complete package', 'Ask what is included in the quotation: equipment, delivery, installation and support. The displayed catalogue prices are samples, and PAYGO eligibility and payment terms need confirmation.')]),
    ])),
  ); }
}

class _GuideFeature extends StatelessWidget {
  const _GuideFeature({super.key, required this.title, required this.heading, required this.image,
    required this.introduction, required this.explanation, required this.onBrowse,
    required this.examples, required this.more, this.landscape = false});
  final String title, heading, image, introduction, explanation;
  final VoidCallback onBrowse;
  final List<MarketExample> examples;
  final List<(String,String)> more;
  final bool landscape;
  void _readMore(BuildContext context) => showDialog<void>(context: context, builder: (ctx) => Dialog(insetPadding: const EdgeInsets.all(20), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 850), child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
    Row(children: [Expanded(child: SolarText(title, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w800))), IconButton(onPressed: () => Navigator.pop(ctx), tooltip: SolarLanguage.instance.translate('Close'), icon: const Icon(Icons.close))]),
    for(final point in more) ...[const SizedBox(height: 26), SolarText(point.$1, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: Color(0xFF087AA4))), const SizedBox(height: 10), SolarText(point.$2, style: const TextStyle(fontSize: 17, height: 1.65))],
    const SizedBox(height: 28), FilledButton(onPressed: () { Navigator.pop(ctx); onBrowse(); }, child: const SolarText('Browse the Marketplace →')),
  ]))))));
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Padding(padding: const EdgeInsets.fromLTRB(24, 18, 24, 60), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1500), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth >= 1000;
      final photo = Image.asset(landscape ? image : 'assets/images/catalogue/$image', fit: landscape ? BoxFit.cover : BoxFit.contain);
      final copy = Padding(padding: EdgeInsets.fromLTRB(wide ? 55 : 24, wide ? 45 : 30, wide ? 100 : 24, wide ? 45 : 30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        SolarText(title.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w800, color: Color(0xFF087AA4))),
        const SizedBox(height: 20), SolarText(heading, style: TextStyle(fontSize: wide ? 42 : 32, height: 1.12, fontWeight: FontWeight.w800, color: MarketColors.ink)),
        const SizedBox(height: 24), SolarText(introduction, style: const TextStyle(fontSize: 17, height: 1.6, color: MarketColors.muted)),
        const SizedBox(height: 20), SolarText(explanation, style: const TextStyle(fontSize: 16, height: 1.6, color: MarketColors.muted)),
        const SizedBox(height: 28), FilledButton(onPressed: () => _readMore(context), style: imadBlueButtonStyle(backgroundColor: MarketColors.skyStrong, foregroundColor: MarketColors.ink, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))), child: const SolarText('Read more →', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
      ]));
      if(!wide) return Column(children: [Container(color: MarketColors.sky, height: 320, width: double.infinity, padding: landscape ? EdgeInsets.zero : const EdgeInsets.all(20), child: photo), Container(color: Colors.white, child: copy)]);
      return SizedBox(height: 640, child: Stack(fit: StackFit.expand, children: [
        Container(color: MarketColors.sky, child: landscape ? photo : Align(alignment: Alignment.centerRight, child: SizedBox(width: box.maxWidth * .53, height: 540, child: Padding(padding: const EdgeInsets.all(30), child: photo)))),
        Align(alignment: Alignment.centerLeft, child: SizedBox(width: box.maxWidth * .61, child: ClipPath(clipper: const _SlantedPanel(), child: Container(color: Colors.white, child: copy)))),
      ]));
    }),
    const SizedBox(height: 32),
    SolarText('Explore $title', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
    const SizedBox(height: 18),
    LayoutBuilder(builder: (context, box) {
      final columns = box.maxWidth >= 950 ? 3 : box.maxWidth >= 600 ? 2 : 1;
      final width = (box.maxWidth - (columns-1)*22)/columns;
      return Wrap(spacing: 22, runSpacing: 22, children: [for(final p in examples) SizedBox(width: width, child: Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: MarketColors.sky, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 195, width: double.infinity, child: MarketExampleImage(product: p)), const SizedBox(height: 18), SolarText(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 10), SolarText(p.description, style: const TextStyle(height: 1.5)), const SizedBox(height: 12), SolarText('${formatNaira(p.price)} · sample', style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 14), SizedBox(width: 170, child: FilledButton.icon(onPressed: () => showMarketExample(context, p, ordering: true), style: imadBlueButtonStyle(backgroundColor: MarketColors.green, foregroundColor: MarketColors.ink, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), iconAlignment: IconAlignment.end, icon: const Icon(Icons.arrow_forward_rounded), label: const SolarText('Order Now'))),
      ])))]);
    }),
  ])))); }
}
class _SlantedPanel extends CustomClipper<Path> {
  const _SlantedPanel();
  @override
  Path getClip(Size size) => Path()..moveTo(0,0)..lineTo(size.width,0)..lineTo(size.width-115,size.height)..lineTo(0,size.height)..close();
  @override
  bool shouldReclip(_SlantedPanel oldClipper) => false;
}
