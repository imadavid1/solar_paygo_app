import 'package:solar_paygo_app/l10n/solar_language.dart';
import '../widgets/solarid_footer.dart';
import 'product_guide_screen.dart';
import '../widgets/site_header.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'marketplace_screen.dart';
import 'professionals_screen.dart';
import 'sell_with_us_screen.dart';
import 'shopping_screen.dart';

const _ink = Color(0xFF101010);
const _gold = Color(0xFFD8F3FB);
const _green = Color(0xFF101820);
const _muted = Color(0xFF5F625F);

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key, required this.onCustomerAccess});

  final VoidCallback onCustomerAccess;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scrollController = ScrollController();
  final _homeKey = GlobalKey();
  final _howKey = GlobalKey();
  final _plansKey = GlobalKey();
  final _benefitsKey = GlobalKey();
  final _securityKey = GlobalKey();
  final _contactKey = GlobalKey();

  Future<void> _goTo(GlobalKey key) async {
    final context = key.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
      alignment: .03,
    );
  }

  void _openProvider() {
    final uri = Uri.base.replace(
      queryParameters: {...Uri.base.queryParameters, 'portal': 'provider'},
    );
    launchUrl(uri, webOnlyWindowName: '_self');
  }

  void _openPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(
              onHome: () => _goTo(_homeKey),
              onShopping: () => _openPage(
                ShoppingScreen(onCustomerAccess: widget.onCustomerAccess),
              ),
              onMarketplace: () => _openPage(
                MarketplaceScreen(onCustomerAccess: widget.onCustomerAccess),
              ),
              onSellWithUs: () => _openPage(
                SellWithUsScreen(onCustomerAccess: widget.onCustomerAccess),
              ),
              onProfessionals: () => _openPage(
                ProfessionalsScreen(onCustomerAccess: widget.onCustomerAccess),
              ),
              onCustomerAccess: widget.onCustomerAccess,
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _Hero(
                  key: _homeKey,
                  onStart: widget.onCustomerAccess,
                  onLearn: () => _goTo(_howKey),
                ),
                _TrustStrip(),
                _HowItWorks(key: _howKey, onStart: widget.onCustomerAccess),
                _Plans(key: _plansKey, onStart: widget.onCustomerAccess),
                _Benefits(key: _benefitsKey),
                _Security(key: _securityKey),
                _CallToAction(onStart: widget.onCustomerAccess),
                _Footer(
                  key: _contactKey,
                  onNavigate: _goTo,
                  homeKey: _homeKey,
                  howKey: _howKey,
                  plansKey: _plansKey,
                  benefitsKey: _benefitsKey,
                  securityKey: _securityKey,
                  onCustomerAccess: widget.onCustomerAccess,
                  onProviderAccess: _openProvider,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HeaderDelegate({
    required this.onHome,
    required this.onShopping,
    required this.onMarketplace,
    required this.onSellWithUs,
    required this.onProfessionals,
    required this.onCustomerAccess,
  });
  final VoidCallback onHome,
      onShopping,
      onMarketplace,
      onSellWithUs,
      onProfessionals,
      onCustomerAccess;
  @override
  double get minExtent => 78;
  @override
  double get maxExtent => 78;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ImadSiteHeader(
    height: 78,
    onHome: onHome,
    onShopping: onShopping,
    onMarketplace: onMarketplace,
    onSellWithUs: onSellWithUs,
    onProfessionals: onProfessionals,
    onCustomerAccess: onCustomerAccess,
    onGuide: (category) => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductGuideScreen(
          onCustomerAccess: onCustomerAccess,
          initialCategory: category,
        ),
      ),
    ),
  );
  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) => true;
}

class _Hero extends StatelessWidget {
  const _Hero({super.key, required this.onStart, required this.onLearn});
  final VoidCallback onStart, onLearn;

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  LayoutBuilder(
    builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 900;
      final padding = desktop
          ? (constraints.maxWidth * .10).clamp(48.0, 180.0).toDouble()
          : 24.0;
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: constraints.maxWidth,
          minHeight: desktop ? 620 : 600,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/home_family_bright_v2.png',
                fit: BoxFit.cover,
                alignment: desktop
                    ? Alignment.centerRight
                    : const Alignment(.35, 0),
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: desktop
                        ? const [
                            Color(0xBA102C3B),
                            Color(0x4D102C3B),
                            Color(0x00102C3B),
                          ]
                        : const [Color(0xB3102C3B), Color(0x66102C3B)],
                    stops: desktop ? const [0, .48, 1] : null,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                padding,
                desktop ? 64 : 48,
                padding,
                desktop ? 64 : 48,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SolarText(
                      desktop
                          ? 'Power your\nhome.\nPay your way.'
                          : 'Power your home.\nPay your way.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: desktop
                            ? 80
                            : (constraints.maxWidth < 380 ? 42 : 50),
                        height: .98,
                        fontWeight: FontWeight.w900,
                        letterSpacing: desktop ? -3 : -1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SolarText(
                      'Affordable solar energy with secure payments, instant activation tokens and simple control from your phone.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: desktop ? 21 : 18,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 18,
                      runSpacing: 8,
                      children: [
                        _HeroTrust(Icons.shield_outlined, 'Secure payments'),
                        _HeroTrust(Icons.bolt_rounded, 'Instant tokens'),
                        _HeroTrust(
                          Icons.phone_android_rounded,
                          'Mobile friendly',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        FilledButton.icon(
                          onPressed: onStart,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF162C3B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 22,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const SolarText(
                            'Get started',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: onLearn,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 22,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: const SolarText(
                            'How PAYGO works',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  ); }
}

class _HeroTrust extends StatelessWidget {
  const _HeroTrust(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: _gold, size: 20),
      const SizedBox(width: 7),
      SolarText(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  ); }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(
      color: _gold,
      borderRadius: BorderRadius.circular(30),
    ),
    child: SolarText(
      text,
      style: const TextStyle(
        color: _ink,
        fontWeight: FontWeight.w900,
        fontSize: 12,
        letterSpacing: 1.2,
      ),
    ),
  ); }
}

class _MiniTrust extends StatelessWidget {
  const _MiniTrust(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: _green, size: 20),
      const SizedBox(width: 7),
      SolarText(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, color: _ink),
      ),
    ],
  ); }
}

class _TrustStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    color: _gold,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
    child: const Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 45,
      runSpacing: 18,
      children: [
        _StripItem('PAY AS YOU GO', 'Flexible daily and weekly credit'),
        _StripItem('SECURE BY DESIGN', 'Protected accounts and payments'),
        _StripItem('CLEAR CONTROL', 'Tokens, history and device status'),
      ],
    ),
  ); }
}

class _StripItem extends StatelessWidget {
  const _StripItem(this.title, this.subtitle);
  final String title, subtitle;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  SizedBox(
    width: 310,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SolarText(
          title,
          style: const TextStyle(
            color: _ink,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        SolarText(
          subtitle,
          style: const TextStyle(color: _ink, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  ); }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks({super.key, required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  LayoutBuilder(
    builder: (context, outer) {
      final desktop = outer.maxWidth >= 900;
      final inset = desktop ? 40.0 : 24.0;
      return Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: desktop ? 500 : 470,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/home_solar_texture_v2.png',
                  fit: BoxFit.cover,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xD912314C),
                        Color(0xBA07507C),
                        Color(0x8C102C3B),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(inset, 72, inset, 70),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: Column(
                  children: [
                    const SolarText(
                      'SIMPLE FROM DAY ONE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _gold,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SolarText(
                      'Solar power in three clear steps',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: desktop ? 43 : 34,
                        height: 1.08,
                        letterSpacing: -1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 730),
                      child: SolarText(
                        'No complicated process. Create your account, connect your solar device and purchase the energy credit you need.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          height: 1.55,
                        ),
                      ),
                    ),
                    SizedBox(height: desktop ? 76 : 48),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = desktop
                            ? (constraints.maxWidth - 48) / 3
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          children: const [
                            _StepCard(
                              number: '01',
                              icon: Icons.person_add_alt_1_rounded,
                              title: 'Create your account',
                              body:
                                  'Register securely and sign in from your phone or computer.',
                            ),
                            _StepCard(
                              number: '02',
                              icon: Icons.solar_power_rounded,
                              title: 'Connect your device',
                              body:
                                  'Your provider assigns your registered solar system to your account.',
                            ),
                            _StepCard(
                              number: '03',
                              icon: Icons.bolt_rounded,
                              title: 'Buy power',
                              body:
                                  'Choose a plan, pay securely and receive your activation token.',
                            ),
                          ].map((card) => SizedBox(width: width, child: card)).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 38),
                    FilledButton(
                      onPressed: onStart,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF162C3B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 18,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const SolarText(
                        'Create customer account',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  ); }
}

class _StepCard extends StatefulWidget {
  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
  });
  final String number, title, body;
  final IconData icon;

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    cursor: SystemMouseCursors.click,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, hovered ? -8 : 0, 0),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: hovered ? const Color(0xFFEAF8FC) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hovered ? const Color(0xFF8BCFE2) : const Color(0xFFE0E4E4),
          width: hovered ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: hovered ? .15 : .08),
            blurRadius: hovered ? 28 : 18,
            offset: Offset(0, hovered ? 14 : 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(widget.icon, color: _ink, size: 28),
              ),
              SolarText(
                widget.number,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD0CEC6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SolarText(
            widget.title,
            style: const TextStyle(
              color: _ink,
              fontWeight: FontWeight.w900,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 12),
          SolarText(
            widget.body,
            style: const TextStyle(color: _muted, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    ),
  ); }
}

class _Plans extends StatelessWidget {
  const _Plans({super.key, required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  _Section(
    background: Colors.white,
    child: Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: _SectionHeading(
            kicker: 'FLEXIBLE CREDIT',
            title: 'Choose the plan that fits your life',
            body:
                'Straightforward payment options with no confusing charges. Your successful payment produces a device-specific activation token.',
          ),
        ),
        const SizedBox(height: 45),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth.clamp(0.0, 1120.0).toDouble();
            final width = availableWidth >= 1000
                ? (availableWidth - 48) / 3
                : availableWidth >= 650
                ? (availableWidth - 24) / 2
                : availableWidth;
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                SizedBox(
                  width: width,
                  child: _PlanCard(
                    label: 'DAILY',
                    days: '1 day access',
                    price: '\u20A61,000',
                    icon: Icons.wb_sunny_outlined,
                    description:
                        'A simple daily top-up for immediate energy access.',
                    onStart: onStart,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _PlanCard(
                    label: 'WEEKLY',
                    days: '7 days access',
                    price: '\u20A67,000',
                    icon: Icons.date_range_outlined,
                    description:
                        'One convenient payment for a full week of energy.',
                    featured: true,
                    onStart: onStart,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _PlanCard(
                    label: 'MONTHLY',
                    days: '30 days access',
                    price: '\u20A630,000',
                    icon: Icons.calendar_month_outlined,
                    description:
                        'One simple payment for 30 days of energy access.',
                    onStart: onStart,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  ); }
}

class _PlanCard extends StatefulWidget {
  const _PlanCard({
    required this.label,
    required this.days,
    required this.price,
    required this.icon,
    required this.description,
    required this.onStart,
    this.featured = false,
  });
  final String label, days, price, description;
  final IconData icon;
  final bool featured;
  final VoidCallback onStart;

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      curve: hovered ? Curves.easeOutBack : Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, hovered ? -9 : 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: hovered ? .20 : .10),
            blurRadius: hovered ? 28 : 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 380),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedScale(
                  scale: hovered ? 1.045 : 1,
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  child: Image.asset(
                    'assets/images/home_solar_texture_v2.png',
                    fit: BoxFit.cover,
                    alignment: widget.label == 'DAILY'
                        ? Alignment.centerLeft
                        : widget.featured
                        ? Alignment.center
                        : Alignment.centerRight,
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xF2162C3B),
                        Color(0xD9162C3B),
                        Color(0xF2162C3B),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _PanelLines()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(widget.icon, color: _gold, size: 27),
                        const SizedBox(width: 12),
                        SolarText(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SolarText(
                        widget.price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 46,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SolarText(
                      widget.days,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SolarText(
                      widget.description,
                      style: const TextStyle(
                        color: Color(0xFFE0E8EC),
                        height: 1.5,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),
                    FilledButton(
                      onPressed: widget.onStart,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.hovered)
                              ? const Color(0xFF53C6E7)
                              : Colors.white,
                        ),
                        foregroundColor: const WidgetStatePropertyAll(_ink),
                        side: const WidgetStatePropertyAll(
                          BorderSide(color: Colors.white),
                        ),
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                        ),
                        shape: const WidgetStatePropertyAll(StadiumBorder()),
                      ),
                      child: const SolarText(
                        'Access this plan',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ); }
}

class _PanelLines extends CustomPainter {
  const _PanelLines();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final pen = Paint()
      ..color = const Color(0x30B4D8E6)
      ..strokeWidth = .7;
    for (double x = -size.height; x < size.width; x += 12) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, size.height * .55),
        pen,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PanelLines oldDelegate) => false;
}

class _Benefits extends StatelessWidget {
  const _Benefits({super.key});

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  _Section(
    background: Colors.white,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        final copy = const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeading(
              kicker: 'BUILT AROUND YOU',
              title: 'The benefits',
              body:
                  'Practical solar access supported by technology that stays clear and easy to use.',
            ),
            SizedBox(height: 28),
            _BenefitRow(
              Icons.payments_outlined,
              'Low upfront cost',
              'Buy manageable periods of energy instead of paying everything at once.',
            ),
            _BenefitRow(
              Icons.visibility_outlined,
              'No hidden requirements',
              'Clear plans, visible history and simple account information.',
            ),
            _BenefitRow(
              Icons.phone_android_rounded,
              'Use it anywhere',
              'A responsive experience designed for phones, tablets and computers.',
            ),
            _BenefitRow(
              Icons.support_agent_rounded,
              'Provider support',
              'Your provider can monitor devices and resolve account issues quickly.',
            ),
          ],
        );
        final image = AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              const Positioned.fill(
                left: 34,
                top: 34,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFD8F3FB),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned.fill(
                right: 24,
                bottom: 24,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/benefits_family.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ],
          ),
        );
        if (desktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 6, child: copy),
              const SizedBox(width: 64),
              Expanded(flex: 5, child: image),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            copy,
            const SizedBox(height: 40),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: image,
              ),
            ),
          ],
        );
      },
    ),
  ); }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow(this.icon, this.title, this.body);
  final IconData icon;
  final String title, body;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    padding: const EdgeInsets.symmetric(vertical: 20),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFCBC9C0))),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _green, size: 27),
        const SizedBox(width: 17),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SolarText(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              SolarText(body, style: const TextStyle(color: _muted, height: 1.45)),
            ],
          ),
        ),
      ],
    ),
  ); }
}

class _Security extends StatelessWidget {
  const _Security({super.key});
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  _Section(
    background: const Color(0xFF162C3B),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 820,
          child: _SectionHeading(
            kicker: 'SECURITY AT THE CORE',
            title: 'Designed to protect every transaction',
            body:
                'Security is built into the customer, payment, token and provider workflows from the start.',
            light: true,
          ),
        ),
        const SizedBox(height: 44),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 900
                ? (constraints.maxWidth - 72) / 4
                : constraints.maxWidth >= 520
                ? (constraints.maxWidth - 24) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: const [
                _SecurityCard(
                  Icons.lock_outline_rounded,
                  'Protected accounts',
                  'Authenticated access separates customer and provider permissions.',
                ),
                _SecurityCard(
                  Icons.verified_user_outlined,
                  'Verified payments',
                  'Activation tokens are issued only after confirmed payment.',
                ),
                _SecurityCard(
                  Icons.key_rounded,
                  'Device-bound tokens',
                  'Cryptographic tokens are tied to the correct registered solar device.',
                ),
                _SecurityCard(
                  Icons.replay_outlined,
                  'Replay protection',
                  'Token counters help prevent old activation codes from being reused.',
                ),
              ].map((card) => SizedBox(width: width, child: card)).toList(),
            );
          },
        ),
      ],
    ),
  ); }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard(this.icon, this.title, this.body);
  final IconData icon;
  final String title, body;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    padding: const EdgeInsets.all(27),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF3C3C3C)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _gold, size: 31),
        const SizedBox(height: 22),
        SolarText(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 19,
          ),
        ),
        const SizedBox(height: 10),
        SolarText(
          body,
          style: const TextStyle(color: Color(0xFFBDBDBD), height: 1.5),
        ),
      ],
    ),
  ); }
}

class _CallToAction extends StatelessWidget {
  const _CallToAction({required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    width: double.infinity,
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            const SolarText(
              'Ready for reliable solar power?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ink,
                fontWeight: FontWeight.w900,
                fontSize: 48,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 18),
            const SolarText(
              'Create your secure account and manage your energy in one clear place.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 18),
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF162C3B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const SolarText(
                'Get started now',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    ),
  ); }
}

class _Footer extends StatelessWidget {
  const _Footer({
    super.key,
    required this.onNavigate,
    required this.homeKey,
    required this.howKey,
    required this.plansKey,
    required this.benefitsKey,
    required this.securityKey,
    required this.onCustomerAccess,
    required this.onProviderAccess,
  });
  final Future<void> Function(GlobalKey) onNavigate;
  final GlobalKey homeKey, howKey, plansKey, benefitsKey, securityKey;
  final VoidCallback onCustomerAccess, onProviderAccess;
  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    void open(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    return SolarIDFooter(
      skyBlend: true,
      groups: [
        SolarIDFooterGroup('Solar energy', [
          ('Home', () => onNavigate(homeKey)),
          ('How it works', () => onNavigate(howKey)),
          ('Daily, weekly and monthly plans', () => onNavigate(plansKey)),
          ('Benefits', () => onNavigate(benefitsKey)),
          ('Security', () => onNavigate(securityKey)),
        ]),
        SolarIDFooterGroup('Explore', [
          (
            'Shopping',
            () => open(ShoppingScreen(onCustomerAccess: onCustomerAccess)),
          ),
          (
            'Marketplace',
            () => open(MarketplaceScreen(onCustomerAccess: onCustomerAccess)),
          ),
          (
            'Sell with us',
            () => open(SellWithUsScreen(onCustomerAccess: onCustomerAccess)),
          ),
          (
            'Find a professional',
            () => open(ProfessionalsScreen(onCustomerAccess: onCustomerAccess)),
          ),
        ]),
        SolarIDFooterGroup('Your account', [
          ('Customer access', onCustomerAccess),
          ('Provider portal', onProviderAccess),
        ]),
        SolarIDFooterGroup('Support', [
          (
            'Contact SolarID',
            () => launchUrl(
              Uri.parse('https://wa.me/2349069190601'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ]),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.background,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 90),
  });
  final Color background;
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    width: double.infinity,
    color: background,
    padding: padding,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1300),
        child: child,
      ),
    ),
  ); }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.kicker,
    required this.title,
    required this.body,
    this.light = false,
  });
  final String kicker, title, body;
  final bool light;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 850),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SolarText(
          kicker,
          style: TextStyle(
            color: light ? _gold : _green,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 13),
        SolarText(
          title,
          style: TextStyle(
            color: light ? Colors.white : _ink,
            fontWeight: FontWeight.w900,
            fontSize: 43,
            height: 1.08,
            letterSpacing: -1.4,
          ),
        ),
        const SizedBox(height: 16),
        SolarText(
          body,
          style: TextStyle(
            color: light ? const Color(0xFFC7C7C7) : _muted,
            fontSize: 17,
            height: 1.55,
          ),
        ),
      ],
    ),
  ); }
}
