import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_widgets.dart';

class HireWorkersScreen extends StatelessWidget {
  const HireWorkersScreen({super.key, required this.onCustomerAccess});
  final VoidCallback onCustomerAccess;

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MarketplaceShell(activeSection: 'Find a professional', 
    onCustomerAccess: onCustomerAccess,
    title: 'Hire Skilled Workers',
    subtitle: 'Practical skills for the work that matters.',
    hero: const _WorkersHero(),
    child: Column(children: [
      Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF9BDBF7), Color(0xFFEFFAFF), Colors.white, Colors.white],
          stops: [0, .28, .62, 1],
        )),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 66),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Column(children: [
            const SolarText('Good work starts with the right people', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 34, height: 1.15, fontWeight: FontWeight.w700,
                color: Color(0xFF098AB8), letterSpacing: -.7)),
            const SizedBox(height: 22),
            const SolarText('Find practical support for your home, workplace or next project. SolarID helps you explore skilled workers by trade and location, discuss the job clearly and request someone suited to your needs.\n\nBuild confidence before work begins: ask about experience, check credentials and previous work, and agree the scope, timing and price. Our goal is a clearer, more personal route from your first enquiry to the right introduction.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, height: 1.65, color: Color(0xFF5C686D))),
            const SizedBox(height: 28),
            HoverButton(label: 'Enquire now', onPressed: () => openImadWhatsApp(
              'Hello SolarID, I would like to hire a skilled worker. Please help me confirm availability, experience and references.')),
          ]),
        )),
      ),
      const PageSection(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(24, 14, 24, 22),
        child: SolarText('Illustrative profiles; names, experience and photos are examples. All enquiries connect to SolarID.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF5C686D))),
      ),
      for (var index = 0; index < _workers.length; index++)
        _WorkerSection(worker: _workers[index], index: index),
    ]),
  ); }
}

class _WorkersHero extends StatelessWidget {
  const _WorkersHero();
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  LayoutBuilder(builder: (context, constraints) {
    final compact = constraints.maxWidth < 760;
    return SizedBox(height: compact ? 460 : 530, width: double.infinity,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/hire_workers_group.png', fit: BoxFit.cover,
          alignment: const Alignment(.35, 0),
          semanticLabel: 'Skilled workers standing together with tools from different trades'),
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          colors: [Color(0xD9182D43), Color(0x99182D43), Color(0x4D182D43)],
          stops: [0, .5, 1], begin: Alignment.centerLeft, end: Alignment.centerRight,
        ))),
        Align(alignment: Alignment.center, child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 48),
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1280),
            child: Align(alignment: Alignment.centerLeft,
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620),
                child: Column(mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SolarText('Hire Skilled\nWorkers', style: TextStyle(color: Colors.white,
                      fontSize: compact ? 43 : 66, height: 1.06, letterSpacing: -1.7,
                      fontWeight: FontWeight.w800)),
                    const SizedBox(height: 23),
                    const SolarText('The right skills. A clearer way to get the job done.',
                      style: TextStyle(color: Colors.white, fontSize: 20, height: 1.5)),
                  ]),
              ),
            ),
          ),
        )),
      ]),
    );
  }); }
}

class _Worker {
  const _Worker(this.name, this.trade, this.years, this.location, this.intro,
    this.projects, this.strengths);
  final String name, trade, location, intro, projects, strengths;
  final int years;
}

const _workers = [
  _Worker('James Wilson', 'Bricklayer', 8, 'Lagos',
    'Careful preparation, straight lines and a tidy finish make a difference on every building project. James represents the practical masonry skills you can discuss when planning your job.',
    'Residential walling, boundary walls and small shop renovations.',
    'Setting out, brick bonding, mortar preparation and neat finishing.'),
  _Worker('Emily Carter', 'Painter', 6, 'FCT Abuja',
    'A good finish begins before the first coat. Emily represents the attention to surface preparation and detail that helps refresh a home or business space.',
    'Home interiors, office refreshes and retail repainting.',
    'Surface preparation, colour coordination and clean, even coats.'),
  _Worker('Daniel Thompson', 'Carpenter', 9, 'Rivers',
    'From accurate measurements to a useful final fit, thoughtful woodwork brings a space together. Daniel represents the hands-on skills to discuss for repairs and custom joinery.',
    'Door fitting, shelving, household repairs and workshop joinery.',
    'Measuring, cutting, assembling and careful finishing.'),
];

class _WorkerSection extends StatelessWidget {
  const _WorkerSection({required this.worker, required this.index});
  final _Worker worker;
  final int index;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    width: double.infinity, color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
    child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1080),
      child: LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final photo = ClipRRect(borderRadius: BorderRadius.circular(20),
          child: AspectRatio(aspectRatio: 1.4,
            child: ClipRect(child: FittedBox(fit: BoxFit.cover,
              child: ClipRect(child: Align(
                alignment: Alignment(0, index.toDouble() - 1), heightFactor: 1 / 3,
                child: Image.asset('assets/images/hire_workers_profiles.png',
                  width: 1024, height: 1536, fit: BoxFit.fill,
                  semanticLabel: '${worker.trade} holding the tools of their trade'),
              )),
            )),
          ),
        );
        final copy = Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, children: [
            SolarText(worker.trade.toUpperCase(), style: const TextStyle(fontSize: 12,
              color: Color(0xFF098AB8), letterSpacing: 1.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 9),
            SolarText(worker.name, translate: false, style: const TextStyle(fontSize: 32, height: 1.12,
              fontWeight: FontWeight.w800, color: Color(0xFF172126), letterSpacing: -.6)),
            const SizedBox(height: 12),
            SolarText('${worker.years} years of experience  ·  ${worker.location}',
              style: const TextStyle(fontSize: 15, color: Color(0xFF098AB8), height: 1.5)),
            const SizedBox(height: 16),
            SolarText(worker.intro, style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF5C686D))),
            const SizedBox(height: 16),
            _Detail(label: 'Project experience', text: worker.projects),
            const SizedBox(height: 12),
            _Detail(label: 'Skills & workmanship', text: worker.strengths),
            const SizedBox(height: 12),
            const _Detail(label: 'Credentials & references', text: 'Ask SolarID to confirm training, relevant qualifications and previous-work references before hiring.'),
            const SizedBox(height: 22),
            HoverButton(label: 'Enquire now', onPressed: () => openImadWhatsApp(
              'Hello SolarID, I need a ${worker.trade.toLowerCase()} in ${worker.location}. Please confirm an available worker, credentials, previous work and a quotation.')),
          ]);
        if (compact) return Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [photo, const SizedBox(height: 26), copy]);
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: index.isEven
          ? [Expanded(child: copy), const SizedBox(width: 54), Expanded(child: photo)]
          : [Expanded(child: photo), const SizedBox(width: 54), Expanded(child: copy)]);
      }),
    )),
  ); }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.text});
  final String label, text;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Text.rich(SolarTextSpan(children: [
    SolarTextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF172126))),
    SolarTextSpan(text: text),
  ]), style: const TextStyle(fontSize: 14, height: 1.55, color: Color(0xFF5C686D))); }
}
