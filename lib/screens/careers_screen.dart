import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_widgets.dart';
import 'career_interest_form.dart';
import 'career_visuals.dart';

const _blue = Color(0xFF098AB8);
const _ink = Color(0xFF172E40);
const _muted = Color(0xFF5C686D);
const _careerImages = ['career_solar.png', 'career_trades.png', 'career_marketplace.png', 'career_support.png'];
const _careerDescriptions = [
  'Installation, electrical work and system maintenance.',
  'Practical trades for homes, workplaces and projects.',
  'Product enquiries, seller support and customer advice.',
  'Communication, coordination and everyday service.',
];
const _careerRoles = [
  ['Solar installer', 'Electrical technician', 'Inverter and battery technician'],
  ['Carpenter', 'Painter', 'Plumber', 'Bricklayer', 'Welder'],
  ['Solar product sales', 'Marketplace support', 'Seller coordination'],
  ['Customer enquiries', 'Field coordination', 'PAYGO support'],
];

class CareersScreen extends StatefulWidget {
  const CareersScreen({super.key, required this.onCustomerAccess});
  final VoidCallback onCustomerAccess;
  @override
  State<CareersScreen> createState() => _CareersScreenState();
}
class _CareersScreenState extends State<CareersScreen> {
  final _paths = GlobalKey();
  void _interest([String? field]) => showDialog<void>(context: context,
    builder: (_) => CareerInterestForm(initialField: field, onSend: openImadWhatsApp));
  void _explore(int index) => showDialog<void>(context: context, builder: (context) => AlertDialog(
    title: SolarText(careerFields[index]),
    content: SizedBox(width: 490, child: SingleChildScrollView(child: Column(
      mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SolarText('Roles to explore', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        for (final role in _careerRoles[index]) Padding(padding: const EdgeInsets.only(bottom: 10), child: SolarText('• $role')),
        const SizedBox(height: 12),
        const SolarText('Share your relevant experience, location and preferred role. Technical work may require trade qualifications, evidence of previous work and suitable safety training.\n\nThese are career paths, not advertised vacancies. SolarID will confirm any available opening, its requirements, terms and application process.', style: TextStyle(height: 1.6)),
      ]))),
    actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const SolarText('Close')),
      FilledButton(onPressed: () { Navigator.of(context).pop(); _interest(careerFields[index]); }, child: const SolarText('Register interest'))],
  ));
  void _jump() { final target = _paths.currentContext; if (target != null) Scrollable.ensureVisible(target,
    alignment: .05, duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 500), curve: Curves.easeInOut); }
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MarketplaceShell(activeSection: 'Find a professional', 
    title: 'Careers', subtitle: 'Build your future with SolarID.', onCustomerAccess: widget.onCustomerAccess,
    hero: CareerIntroduction(onExplore: _jump),
    child: Column(children: [
      _CareerReveal(child: PageSection(key: _paths, color: const Color(0xFFF5F8FA), child: Column(children: [
        const _CareerHeading(title: 'Find Your Direction', subtitle: 'Four pathways. A world of practical possibilities.'),
        const SizedBox(height: 38),
        Wrap(alignment: WrapAlignment.center, spacing: 28, runSpacing: 32, children: [
          for (var i = 0; i < careerFields.length; i++) SizedBox(width: 240,
            child: Column(children: [
              Semantics(label: careerFields[i], button: true, child: Material(color: Colors.transparent, shape: const CircleBorder(), clipBehavior: Clip.antiAlias,
                child: Ink.image(image: AssetImage('assets/images/${_careerImages[i]}'), width: 150, height: 150, fit: BoxFit.cover,
                  child: InkWell(onTap: () => _explore(i), customBorder: const CircleBorder())))),
              const SizedBox(height: 18),
              SolarText(careerFields[i], textAlign: TextAlign.center, style: const TextStyle(color: _ink, fontSize: 20, height: 1.25, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              SolarText(_careerDescriptions[i], textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 15, height: 1.55)),
              TextButton(onPressed: () => _explore(i), child: const SolarText('Explore roles →')),
            ])),
        ]),
        const SizedBox(height: 44),
        const _CareerSteps(),
      ]))),
      _CareerReveal(child: _CareerRow(imageFirst: true, graphicIndex: 0, eyebrow: 'SOLAR & ELECTRICAL',
        title: 'Technical Insight.\nEveryday Impact.',
        copy: 'A well-planned solar solution begins with an understanding of demand, compatible equipment and the conditions on site. Installation and ongoing care turn that knowledge into practical value for homes and businesses.\n\nIf your background includes solar systems, electrical work or inverter and battery maintenance, explore how your experience could support these needs through SolarID.',
        onPressed: () => _explore(0))),
      _CareerReveal(child: _CareerRow(imageFirst: false, graphicIndex: 1, eyebrow: 'CONSTRUCTION & SKILLED TRADES',
        title: 'Craft That Makes\na Difference.',
        copy: 'From careful preparation to a dependable finish, skilled trades shape the places where people live and work. Painting, carpentry, plumbing, bricklaying and welding each bring a different kind of expertise.\n\nSolarID brings these service enquiries into one platform. Introduce your craft, your experience and the areas you can serve to begin a career conversation.',
        onPressed: () => _explore(1))),
      _CareerReveal(child: _CareerRow(imageFirst: true, graphicIndex: 2, eyebrow: 'SALES, SUPPORT & OPERATIONS',
        title: 'Make Every Connection\nCount.',
        copy: 'Clear product information and thoughtful follow-up help people navigate energy choices. Marketplace coordination, customer enquiries and PAYGO assistance connect different parts of the SolarID experience.\n\nExplore a service role where communication, organisation and attention to detail matter. Tell us how your strengths could help people move from a question to an informed next step.',
        onPressed: () => _explore(3), extraAction: TextButton(onPressed: () => _explore(2), child: const SolarText('Explore sales & marketplace →')))),
      _CareerReveal(child: Container(width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFBCEBFA), Color(0xFF72CCE9)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 820), child: Column(children: [
          const SolarText('Ready for Your Next Step?', textAlign: TextAlign.center, style: TextStyle(color: _ink, fontSize: 36, height: 1.2, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          const SolarText('Tell us your field, location and experience. Start a conversation about what could come next.', textAlign: TextAlign.center, style: TextStyle(color: _ink, fontSize: 18, height: 1.6)),
          const SizedBox(height: 28),
          HoverButton(label: 'Register interest', onPressed: () => _interest()),
          const SizedBox(height: 15),
          const SolarText('Current opportunities and requirements are confirmed directly with SolarID.', textAlign: TextAlign.center, style: TextStyle(color: _ink, fontSize: 13, height: 1.5)),
        ]))))),
    ]),
  ); }
}

class _CareerHeading extends StatelessWidget {
  const _CareerHeading({required this.title, required this.subtitle});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Column(children: [
    SolarText(title, textAlign: TextAlign.center, style: const TextStyle(color: _ink, fontSize: 34, height: 1.2, fontWeight: FontWeight.w800)),
    const SizedBox(height: 13), SolarText(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 17, height: 1.6)),
  ]); }
}
class _CareerSteps extends StatelessWidget {
  const _CareerSteps();
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  LayoutBuilder(builder: (context, constraints) {
    const labels = ['Choose Your Field', 'Share Your Experience', 'Submit Your Interest', 'Discuss Opportunities', 'Get Started'];
    const icons = [Icons.explore_outlined, Icons.handyman_outlined, Icons.edit_note_outlined, Icons.forum_outlined, Icons.flag_outlined];
    Widget step(int i) => SizedBox(width: 150, child: Column(children: [
      Container(width: 64, height: 64, decoration: const BoxDecoration(color: _blue, shape: BoxShape.circle), child: Icon(icons[i], color: Colors.white, size: 28)),
      const SizedBox(height: 12), SolarText(labels[i], textAlign: TextAlign.center, style: const TextStyle(color: _ink, fontSize: 14, height: 1.4, fontWeight: FontWeight.w600)),
    ]));
    if (constraints.maxWidth < 1000) return Column(children: [
      for (var i = 0; i < labels.length; i++) ...[if (i > 0) const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Icon(Icons.arrow_downward_rounded, color: Color(0xFFC5D6DF))), step(i)],
    ]);
    return Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var i = 0; i < labels.length; i++) ...[if (i > 0) const Padding(padding: EdgeInsets.fromLTRB(10, 20, 10, 0), child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFC5D6DF))), step(i)],
    ]);
  }); }
}
class _CareerRow extends StatelessWidget {
  const _CareerRow({required this.imageFirst, required this.graphicIndex, required this.eyebrow, required this.title, required this.copy, required this.onPressed, this.extraAction});
  final bool imageFirst;
  final int graphicIndex;
  final String eyebrow, title, copy;
  final VoidCallback onPressed;
  final Widget? extraAction;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  PageSection(color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120), child: LayoutBuilder(builder: (context, constraints) {
      final photo = CareerGraphicPanel(index: graphicIndex);
      final text = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        SolarText(eyebrow, style: const TextStyle(color: _blue, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
        const SizedBox(height: 15), SolarText(title, style: const TextStyle(color: _ink, fontSize: 34, height: 1.15, fontWeight: FontWeight.w800, letterSpacing: -.6)),
        const SizedBox(height: 20), SolarText(copy, style: const TextStyle(color: _muted, fontSize: 17, height: 1.65)),
        const SizedBox(height: 23), HoverButton(label: 'Explore roles', onPressed: onPressed),
        if (extraAction != null) Padding(padding: const EdgeInsets.only(top: 8), child: extraAction!),
      ]);
      if (constraints.maxWidth < 800) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [photo, const SizedBox(height: 28), text]);
      return Row(children: [Expanded(child: imageFirst ? photo : text), const SizedBox(width: 64), Expanded(child: imageFirst ? text : photo)]);
    })),
  ); }
}

// Reveal once when a strip enters the viewport; keep its layout space while hidden.
class _CareerReveal extends StatefulWidget {
  const _CareerReveal({required this.child});
  final Widget child;
  @override
  State<_CareerReveal> createState() => _CareerRevealState();
}
class _CareerRevealState extends State<_CareerReveal> {
  ScrollPosition? _position;
  bool _visible = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (_position != next) { _position?.removeListener(_check); _position = next; _position?.addListener(_check); }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }
  void _check() {
    if (!mounted || _visible) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    if (MediaQuery.disableAnimationsOf(context) || top < MediaQuery.sizeOf(context).height - 24) setState(() => _visible = true);
  }
  @override
  void dispose() { _position?.removeListener(_check); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final shown = _visible || reduced;
    final duration = reduced ? Duration.zero : const Duration(milliseconds: 480);
    return ExcludeSemantics(excluding: !shown, child: IgnorePointer(ignoring: !shown,
      child: AnimatedOpacity(opacity: shown ? 1 : 0, duration: duration,
        child: AnimatedSlide(offset: shown ? Offset.zero : const Offset(0, .035), duration: duration, curve: Curves.easeOut, child: widget.child))));
  }
}
