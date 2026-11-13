import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_theme.dart';
import '../marketplace/marketplace_widgets.dart';
import '../widgets/site_header.dart';
import 'shopping_screen.dart';
import 'marketplace_screen.dart';
import 'sell_with_us_screen.dart';
import 'professionals_screen.dart';

class ProductGuideScreen extends StatefulWidget {
  const ProductGuideScreen({super.key, required this.onCustomerAccess, this.initialCategory = 'Solar panels'});
  final VoidCallback onCustomerAccess;
  final String initialCategory;
  @override
  State<ProductGuideScreen> createState() => _ProductGuideScreenState();
}
class _ProductGuideScreenState extends State<ProductGuideScreen> {
  final _scroll = ScrollController();
  final _keys = {for(final category in ['Solar panels','Batteries','Inverters']) category: GlobalKey()};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _keys[widget.initialCategory]?.currentContext;
      if(mounted && target != null) Scrollable.ensureVisible(target, alignment: .02);
    });
  }
  @override
  void dispose() { _scroll.dispose(); super.dispose(); }
  void _open(Widget page) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => page));
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Scaffold(
    backgroundColor: Colors.white,
    appBar: ImadSiteHeader(activeSection: 'Shopping', 
      onHome: () => Navigator.of(context).popUntil((route) => route.isFirst),
      onShopping: () => _open(ShoppingScreen(onCustomerAccess: widget.onCustomerAccess)),
      onMarketplace: () => _open(MarketplaceScreen(onCustomerAccess: widget.onCustomerAccess)),
      onSellWithUs: () => _open(SellWithUsScreen(onCustomerAccess: widget.onCustomerAccess)),
      onProfessionals: () => _open(ProfessionalsScreen(onCustomerAccess: widget.onCustomerAccess)),
      onCustomerAccess: widget.onCustomerAccess,
      onGuide: (category) {
        final target = _keys[category]?.currentContext;
        if(target != null) Scrollable.ensureVisible(target, alignment: .02,
          duration: MediaQuery.of(context).disableAnimations ? Duration.zero : const Duration(milliseconds: 550), curve: Curves.easeInOut);
      },
    ),
    body: ImadButtonArea(child: SingleChildScrollView(controller: _scroll, child: Column(children: [
      for(var i=0; i<_guides.length; i++) _GuideStrip(key: _keys[_guides[i].category], guide: _guides[i], imageLeft: i.isOdd,
        onBrowse: () => _open(ShoppingScreen(onCustomerAccess: widget.onCustomerAccess))),
      const MarketplaceFooter(),
    ]))),
  ); }
}
class _Guide {
  const _Guide(this.category, this.title, this.image, this.summary, this.points, this.details);
  final String category, title, image, summary;
  final List<(String,String)> points, details;
}
const _guides = [
  _Guide('Solar panels', 'Turn daylight into\neveryday power', 'assets/images/home_industrial.png',
    'Solar panels are the starting point of your solar system. They capture sunlight and produce direct-current electricity, which can support daytime use and charge compatible storage through the right equipment. From a small rooftop to a larger business installation, the best choice begins with your energy needs and available space.',
    [('Power and efficiency','Compare the rated wattage, efficiency and dimensions together. Higher wattage does not automatically mean a panel will fit your roof better.'),
     ('The right panel type','Monofacial panels collect light from the front. Bifacial models can also use reflected light from the rear when the mounting and surface conditions support it.'),
     ('Built around your space','Rooftop, commercial and flexible vehicle panels serve different applications. Installation design, shade and mounting matter as much as the label.')],
    [('What the wattage means','The nameplate wattage is measured under standard test conditions. Real output changes with sunlight, temperature, shade and system losses. Daily energy production also depends on your location and orientation.'),
     ('How to compare modules','Check the exact model datasheet: dimensions, weight, voltage, current, temperature coefficient and warranty conditions. Your installer must match string voltage and current to the charge controller or inverter.'),
     ('Planning your installation','Start with an appliance and energy-use assessment, then review roof condition, mounting, wiring and protection with a qualified installer. Flexible vehicle panels are normally used for auxiliary or campervan power, rather than vehicle propulsion.')]),
  _Guide('Batteries', 'Keep energy ready\nfor when you need it', 'assets/images/catalogue/se-f16-a.jpg',
    'A solar battery stores energy for use later in the day or during an interruption, when the connected system supports backup operation. Choosing storage is about more than a large capacity number: the battery, inverter and your daily demand need to work together.',
    [('Capacity you can use','Kilowatt-hours describe stored energy. Usable capacity can be lower than nominal capacity, depending on the permitted depth of discharge and system settings.'),
     ('Match the whole system','Battery voltage, charging limits and communication requirements must match the inverter. Lithium iron phosphate models often include a battery management system.'),
     ('Room to grow','Some modular systems allow expansion. Follow the manufacturer’s rules for compatible modules, maximum quantities and installation conditions.')],
    [('Energy versus power','Capacity in kWh indicates how much energy can be stored. Charge and discharge power determine how quickly that energy can move. Backup duration depends on the actual load, available charge and conversion losses.'),
     ('Understanding battery ratings','Compare chemistry, nominal voltage, capacity, usable energy, current limits and warranty terms. Cycle-life figures rely on specific test conditions and should not be treated as a guaranteed lifetime in every installation.'),
     ('Installation and care','Use the manufacturer’s specified environment, clearances and mounting. A qualified installer should check connections, protection and BMS compatibility. Routine checks and suitable operating settings help the system perform consistently.')]),
  _Guide('Inverters', 'Connect your solar\nto everyday living', 'assets/images/catalogue/deye-inverter.png',
    'An inverter converts direct-current electricity into alternating-current electricity for compatible appliances and installations. A hybrid model can coordinate solar generation, battery storage and grid power, subject to its design and configuration. The right model should fit both your electrical supply and the equipment you want to run.',
    [('Power that fits your loads','Compare continuous output and surge capability with your appliance needs. Output power in kW is different from battery capacity in kWh.'),
     ('Choose the correct supply','Single-phase and three-phase equipment have different connection requirements. Select the inverter that matches the installation and local electrical requirements.'),
     ('Check solar and storage inputs','MPPT voltage ranges, PV current limits and battery compatibility determine which panels and storage can be connected.')],
    [('Hybrid and other inverter types','Different designs support different functions. Check whether a model supports batteries, backup output, grid interaction or off-grid use before buying. These features should not be assumed from the word inverter alone.'),
     ('Sizing and compatibility','Review continuous output, surge duration, battery voltage, charge/discharge limits and PV input specifications. A larger inverter may also require a battery bank that can safely supply higher current.'),
     ('Professional setup','Correct protection, earthing, isolation and commissioning are essential. Grid-connected equipment and export settings must meet local requirements. Ask your installer to explain the operating modes and any monitoring features.')]),
];
class _GuideStrip extends StatelessWidget {
  const _GuideStrip({super.key, required this.guide, required this.imageLeft, required this.onBrowse});
  final _Guide guide;
  final bool imageLeft;
  final VoidCallback onBrowse;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(color: Colors.white, width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 76),
    child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1560),
      child: LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 900;
        final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SolarText(guide.category.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 1.8, fontWeight: FontWeight.w700, color: Color(0xFF087AA4))),
          const SizedBox(height: 16),
          SolarText(guide.title, style: TextStyle(fontSize: wide ? 46 : 34, height: 1.15, fontWeight: FontWeight.w400, color: const Color(0xFF008BC1))),
          const SizedBox(height: 24),
          SolarText(guide.summary, style: const TextStyle(fontSize: 17, color: MarketColors.muted, height: 1.65)),
          const SizedBox(height: 20),
          for(final point in guide.points) Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SolarText(point.$1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: MarketColors.ink)),
            const SizedBox(height: 5), SolarText(point.$2, style: const TextStyle(fontSize: 15, color: MarketColors.muted, height: 1.55)),
          ])),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => _learnMore(context), style: imadBlueButtonStyle(foregroundColor: const Color(0xFF087AA4), side: const BorderSide(color: MarketColors.skyStrong, width: 1.5), padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18), shape: const StadiumBorder()), child: const SolarText('Learn more →', style: TextStyle(fontSize: 17))),
        ]);
        final image = ClipRRect(borderRadius: BorderRadius.circular(30), child: SizedBox(height: wide ? 600 : 350, width: double.infinity,
          child: guide.category == 'Solar panels' ? Image.asset(guide.image, fit: BoxFit.cover, semanticLabel: 'Solar panels on a commercial rooftop')
          : ColoredBox(color: const Color(0xFFF9FAFB), child: Padding(padding: const EdgeInsets.all(28), child: FittedBox(fit: BoxFit.contain,
            child: ClipRect(child: Align(widthFactor: guide.category == 'Inverters' ? .53 : 1, alignment: guide.category == 'Inverters' ? Alignment.centerLeft : Alignment.center,
              child: Image.asset(guide.image, semanticLabel: guide.category))))))),
        );
        if(!wide) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [text, const SizedBox(height: 30), image]);
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: imageLeft
          ? [Expanded(flex: 6, child: image), const SizedBox(width: 90), Expanded(flex: 5, child: text)]
          : [Expanded(flex: 5, child: text), const SizedBox(width: 90), Expanded(flex: 6, child: image)]);
      }),
    )),
  ); }
  void _learnMore(BuildContext context) => showDialog<void>(context: context, builder: (dialogContext) => Dialog(
    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 850), child: SingleChildScrollView(padding: const EdgeInsets.all(30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [Expanded(child: SolarText('More about ${guide.category.toLowerCase()}', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700, color: Color(0xFF008BC1)))), IconButton(tooltip: SolarLanguage.instance.translate('Close'), onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close))]),
      for(final detail in guide.details) Padding(padding: const EdgeInsets.only(top: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SolarText(detail.$1, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), const SizedBox(height: 10),
        SolarText(detail.$2, style: const TextStyle(fontSize: 16, height: 1.65, color: MarketColors.muted)),
      ])),
      const SizedBox(height: 30), FilledButton(onPressed: () { Navigator.pop(dialogContext); onBrowse(); }, child: const SolarText('Browse products')),
    ]))),
  ));
}
