import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';

import '../marketplace/marketplace_theme.dart';

class SellerProcessStrip extends StatelessWidget {
  const SellerProcessStrip({super.key});

  static const _items = [
    (Icons.app_registration_rounded, '1. Apply', 'Submit your business and contact information.'),
    (Icons.verified_user_outlined, '2. Verification', 'We review identity, business and product information.'),
    (Icons.inventory_2_outlined, '3. List products', 'Add clear descriptions, prices, stock and images.'),
    (Icons.trending_up_rounded, '4. Start selling', 'Receive orders and grow through the marketplace.'),
  ];

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  ColoredBox(
    color: Colors.white,
    child: LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth >= 900;
      return Column(children: [
        Stack(children: [
          Positioned.fill(child: Image.asset(
            'assets/images/catalogue/seller_sky_coast.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            semanticLabel: 'A clear sky-blue coastal horizon with calm water',
            cacheWidth: 1920,
          )),
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withValues(alpha: .72), Colors.white.withValues(alpha: .22)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ))),
          Padding(
            padding: EdgeInsets.fromLTRB(24, wide ? 66 : 42, 24, 104),
            child: Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: SizedBox(width: double.infinity, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SolarText('', style: TextStyle(
                    color: Color(0xFF087AA4), fontWeight: FontWeight.w900,
                    letterSpacing: 1.4, fontSize: 12,
                  )),
                  const SizedBox(height: 12),
                  SolarText('Grow your business with SolarID', style: TextStyle(
                    color: MarketColors.ink, fontWeight: FontWeight.w900,
                    fontSize: wide ? 46 : 34, height: 1.08, letterSpacing: -1.2,
                  )),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 780),
                    child: const SolarText(
                      'Join a trusted solar marketplace, reach customers across Nigeria and manage your products through a clear seller onboarding process.',
                      style: TextStyle(color: Color(0xFF344C59), fontSize: 18, height: 1.55, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const SolarText('How selling with us works', style: TextStyle(
                    color: MarketColors.ink, fontSize: 24, fontWeight: FontWeight.w800,
                  )),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 780),
                    child: const SolarText(
                      'A transparent process designed for genuine solar dealers, installers and service providers.',
                      style: TextStyle(color: Color(0xFF344C59), fontSize: 16, height: 1.5),
                    ),
                  ),
                ],
              )),
            )),
          ),
        ]),
        Transform.translate(
          offset: const Offset(0, -64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: LayoutBuilder(builder: (context, cardsBox) {
                final columns = cardsBox.maxWidth >= 1000 ? 4 : cardsBox.maxWidth >= 560 ? 2 : 1;
                final width = (cardsBox.maxWidth - (columns - 1) * 22) / columns;
                return Wrap(spacing: 22, runSpacing: 24, children: [
                  for (final item in _items)
                    SizedBox(width: width, child: _SellerProcessCard(
                      icon: item.$1, title: item.$2, body: item.$3,
                    )),
                ]);
              }),
            )),
          ),
        ),
      ]);
    }),
  ); }
}

class _SellerProcessCard extends StatefulWidget {
  const _SellerProcessCard({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title, body;
  @override
  State<_SellerProcessCard> createState() => _SellerProcessCardState();
}

class _SellerProcessCardState extends State<_SellerProcessCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : const Duration(milliseconds: 220);
    const blue = Color(0xFF009BDF);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered && !reduceMotion ? 1.025 : 1,
        duration: duration,
        curve: Curves.easeOutCubic,
        child: AnimatedSlide(
          offset: _hovered && !reduceMotion ? const Offset(0, -.025) : Offset.zero,
          duration: duration,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 210),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _hovered ? const Color(0xFFBDEBFA) : const Color(0xFFF0F3F5)),
              boxShadow: [
                BoxShadow(
                  color: _hovered ? const Color(0x44009BDF) : const Color(0x0D172126),
                  blurRadius: _hovered ? 16 : 10,
                  spreadRadius: _hovered ? 1 : 0,
                  offset: _hovered ? const Offset(3, 5) : const Offset(0, 3),
                ),
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(widget.icon, color: blue, size: 28),
              const SizedBox(height: 16),
              SolarText(widget.title, textAlign: TextAlign.center,
                style: const TextStyle(color: blue, fontSize: 19, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SolarText(widget.body, textAlign: TextAlign.center,
                style: const TextStyle(color: MarketColors.muted, fontSize: 15, height: 1.5)),
            ]),
          ),
        ),
      ),
    );
  }
}
