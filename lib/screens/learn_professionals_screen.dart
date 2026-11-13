import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_widgets.dart';
import 'learn_professionals_faq.dart';

class LearnProfessionalsScreen extends StatefulWidget {
  const LearnProfessionalsScreen({super.key, required this.onCustomerAccess});
  final VoidCallback onCustomerAccess;
  @override
  State<LearnProfessionalsScreen> createState() => _LearnProfessionalsScreenState();
}

class _LearnProfessionalsScreenState extends State<LearnProfessionalsScreen> {
  final _solarKey = GlobalKey();
  final _tradesKey = GlobalKey();
  final _faqKey = GlobalKey();

  void _enquire(String topic) => openImadWhatsApp(
    'Hello SolarID, I would like to learn about $topic. Please confirm available professionals, requirements, location, schedule and fees.');

  void _jump(GlobalKey key) {
    final target = key.currentContext;
    if (target != null) Scrollable.ensureVisible(target,
      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 550),
      curve: Curves.easeInOut, alignment: .05);
  }

  void _paygoInfo() => showDialog<void>(context: context, builder: (context) => AlertDialog(
    title: const SolarText('Understand PAYGO'),
    content: const SingleChildScrollView(child: SolarText(
      'PAYGO lets customers purchase power using the available daily, weekly or monthly options. After payment is confirmed, an activation token is issued through the existing customer flow.\n\nLearning about PAYGO can include understanding payment plans, keeping transaction records, activation tokens and monitoring energy use. Training fees are a separate enquiry; this information button does not start a payment.',
      style: TextStyle(height: 1.6))),
    actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const SolarText('Close'))],
  ));

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MarketplaceShell(activeSection: 'Find a professional', 
    onCustomerAccess: widget.onCustomerAccess,
    title: 'Learn from Professionals',
    subtitle: 'Build practical skills with SolarID.',
    hero: const _LearningHero(),
    child: Column(children: [
      PageSection(color: Colors.white, child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Column(children: [
          const SolarText('Why Learn with SolarID?', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 36, height: 1.15, fontWeight: FontWeight.w800,
              color: Color(0xFF172126), letterSpacing: -.8)),
          const SizedBox(height: 24),
          const SolarText('Practical knowledge grows through clear guidance and hands-on experience. SolarID brings professional enquiries, useful solar information and a choice of skilled trades into one place, helping you take a more informed next step.\n\nTell us what you want to learn, where you are based and what experience you already have. Discuss the professional’s relevant skills, qualifications and previous work, then agree a learning plan that suits your goals.\n\nFrom solar installation to electrical work, carpentry and other everyday trades, our aim is to make finding practical guidance simpler for people in Nigeria.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 18, height: 1.65, color: Color(0xFF5C686D))),
          const SizedBox(height: 30),
          HoverButton(label: 'Enquire now', onPressed: () => _enquire('practical skills')),
        ]),
      ))),
      _LearningPathways(
        onSolar: () => _jump(_solarKey), onPaygo: _paygoInfo,
        onTrades: () => _jump(_tradesKey),
      ),
      _LearningRow(
        key: _solarKey, imageFirst: false,
        image: 'assets/images/learn_rooftop_installation.png',
        imageLabel: 'Solar installer using tools on a rooftop panel installation',
        eyebrow: 'SOLAR INSTALLATION',
        title: 'Skills for homes, shops\nand bigger ambitions',
        body: 'Explore how an experienced installer approaches a solar project: understanding energy needs, planning the layout, choosing compatible equipment and maintaining the finished system.\n\nDiscuss the skills required for a home, shop, office or larger commercial site. Industrial work needs the right qualifications, design experience and project-specific checks; ask SolarID to confirm a suitable professional for the scale of work you have in mind.',
        points: const ['Energy needs and system planning', 'Panels, batteries and inverter compatibility', 'Supervised installation and maintenance'],
        button: 'Ask about solar', onPressed: () => _enquire('solar installation'),
      ),
      _LearningRow(
        key: _tradesKey, imageFirst: true,
        image: 'assets/images/learn_inverter_engineer.png',
        imageLabel: 'Electrical engineer checking an inverter and battery installation',
        eyebrow: 'EXPLORE SKILLED TRADES',
        title: 'One platform.\nTwenty paths to explore.',
        body: 'Our directory covers 20 professional categories, from solar installers and electricians to plumbers, painters, carpenters, welders and repair technicians. Choose the field that interests you and ask about the practical learning options in your area.\n\nAn enquiry can help you clarify what a professional can teach, how sessions would work and what preparation you need. Current availability and any learning arrangement are confirmed directly through SolarID.',
        points: const ['Choose a trade and Nigerian location', 'Discuss your learning goals and starting level', 'Confirm experience, availability and arrangements'],
        button: 'Explore learning', onPressed: () => _jump(_faqKey),
      ),
      LearnProfessionalsFaq(key: _faqKey),
    ]),
  ); }
}

class _LearningHero extends StatelessWidget {
  const _LearningHero();
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  LayoutBuilder(builder: (context, constraints) {
    final compact = constraints.maxWidth < 760;
    return SizedBox(height: compact ? 430 : 500, width: double.infinity,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/learn_professionals_hero.png', fit: BoxFit.cover,
          semanticLabel: 'Instructor and trainee in a technical learning workshop'),
        const ColoredBox(color: Color(0x9E193A57)),
        Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1020),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SolarText('Learn from\nProfessionals', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: compact ? 42 : 62,
                  height: 1.08, fontWeight: FontWeight.w800, letterSpacing: -1.4)),
              const SizedBox(height: 24),
              const SolarText('Build practical skills. Understand your options.\nTake the next step with SolarID.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, height: 1.5, fontWeight: FontWeight.w500)),
            ]),
          ),
        )),
      ]),
    );
  }); }
}

class _LearningPathways extends StatelessWidget {
  const _LearningPathways({required this.onSolar, required this.onPaygo, required this.onTrades});
  final VoidCallback onSolar, onPaygo, onTrades;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(color: Colors.white,
    child: Stack(children: [
      Positioned(top: 0, left: 0, right: 0, height: 320,
        child: Image.asset('assets/images/learn_coastal_background.png', fit: BoxFit.cover,
          excludeFromSemantics: true)),
      Padding(padding: const EdgeInsets.fromLTRB(24, 245, 24, 60),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(builder: (context, constraints) {
            final cards = [
              _PathCard(title: 'Solar Installation', subtitle: 'Solar Energy for All',
                copy: 'Explore the practical skills behind planning, installation and care of solar systems.',
                icon: Icons.solar_power_outlined, action: 'Explore solar', onPressed: onSolar),
              _PathCard(title: 'PAYGO & Energy', subtitle: 'Understand flexible power',
                copy: 'Learn how power purchases, activation tokens and everyday energy use fit together.',
                icon: Icons.bolt_outlined, action: 'Understand PAYGO', onPressed: onPaygo),
              _PathCard(title: 'Skilled Trades', subtitle: 'Find your next direction',
                copy: 'Explore electrical work, plumbing, painting, carpentry, welding and more.',
                icon: Icons.handyman_outlined, action: 'Explore trades', onPressed: onTrades),
            ];
            if (constraints.maxWidth < 900) return Column(children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 20), cards[i],
              ],
            ]);
            return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 24), Expanded(child: cards[i]),
              ],
            ]));
          }),
        )),
      ),
    ]),
  ); }
}

class _PathCard extends StatelessWidget {
  const _PathCard({required this.title, required this.subtitle, required this.copy,
    required this.icon, required this.action, required this.onPressed});
  final String title, subtitle, copy, action;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22),
      boxShadow: const [BoxShadow(color: Color(0x100B344C), blurRadius: 18, offset: Offset(0, 6))]),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: const Color(0xFF098AB8), size: 30),
      const SizedBox(height: 15),
      SolarText(title, textAlign: TextAlign.center, style: const TextStyle(
        color: Color(0xFF098AB8), fontSize: 25, height: 1.2, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      SolarText(subtitle, textAlign: TextAlign.center, style: const TextStyle(
        color: Color(0xFF172126), fontSize: 15, height: 1.4, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      SolarText(copy, textAlign: TextAlign.center, style: const TextStyle(
        color: Color(0xFF5C686D), fontSize: 15, height: 1.6)),
      const SizedBox(height: 16),
      TextButton(onPressed: onPressed, style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF098AB8)), child: SolarText('$action →')),
    ]),
  ); }
}

class _LearningRow extends StatelessWidget {
  const _LearningRow({super.key, required this.imageFirst, required this.image,
    required this.imageLabel, required this.eyebrow, required this.title,
    required this.body, required this.points, required this.button, required this.onPressed});
  final bool imageFirst;
  final String image, imageLabel, eyebrow, title, body, button;
  final List<String> points;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  PageSection(color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120),
      child: LayoutBuilder(builder: (context, constraints) {
        final photo = ClipRRect(borderRadius: BorderRadius.circular(22),
          child: AspectRatio(aspectRatio: 1.25,
            child: Image.asset(image, fit: BoxFit.cover, semanticLabel: imageLabel)));
        final copy = Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, children: [
            SolarText(eyebrow, style: const TextStyle(color: Color(0xFF098AB8),
              fontSize: 12, letterSpacing: 1.3, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SolarText(title, style: const TextStyle(color: Color(0xFF172126), fontSize: 33,
              height: 1.15, letterSpacing: -.8, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            SolarText(body, style: const TextStyle(color: Color(0xFF5C686D), fontSize: 16, height: 1.65)),
            const SizedBox(height: 18),
            for (final point in points) Padding(padding: const EdgeInsets.only(bottom: 9),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_rounded, size: 19, color: Color(0xFF098AB8)),
                const SizedBox(width: 9), Expanded(child: SolarText(point,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF5C686D)))),
              ])),
            const SizedBox(height: 18),
            HoverButton(label: button, onPressed: onPressed),
          ]);
        if (constraints.maxWidth < 850) return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [photo, const SizedBox(height: 28), copy]);
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: imageFirst
          ? [Expanded(child: photo), const SizedBox(width: 60), Expanded(child: copy)]
          : [Expanded(child: copy), const SizedBox(width: 60), Expanded(child: photo)]);
      }),
    ),
  ); }
}
