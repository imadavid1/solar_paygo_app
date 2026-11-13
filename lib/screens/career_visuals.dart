import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
// Careers introduction controls use bounded, wrapping text.

const _navy = Color(0xFF173A51);
const _sky = Color(0xFF098AB8);
const _grey = Color(0xFF5C686D);

class CareerIntroduction extends StatelessWidget {
  const CareerIntroduction({super.key, required this.onExplore});
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    color: const Color(0xFF162C3B),
    child: Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1440),
          child: LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 1000;
            final introduction = _SlantedIntroduction(onExplore: onExplore, slanted: !compact);
            const illustration = _CareerIllustration();
            if (compact) return Column(children: [introduction,
              const AspectRatio(aspectRatio: 1.6, child: illustration)]);
            return SizedBox(width: double.infinity, child: Stack(children: [
              Positioned.fill(child: Align(alignment: Alignment.centerRight,
                child: FractionallySizedBox(widthFactor: .53, heightFactor: 1, child: illustration))),
              SizedBox(width: constraints.maxWidth * .60, child: introduction),
            ]));
          }),
        )),
      ),
    ]),
  ); }
}

class _CareerIllustration extends StatelessWidget {
  const _CareerIllustration();
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Stack(fit: StackFit.expand, children: [
    Image.asset('assets/images/career_connected_future.png', fit: BoxFit.cover,
      alignment: Alignment.centerRight,
      semanticLabel: 'Concept illustration of a solar-powered community connected with digital services'),
    const ColoredBox(color: Color(0xB3B47A24)),
  ]); }
}

class _SlantedIntroduction extends StatelessWidget {
  const _SlantedIntroduction({required this.onExplore, required this.slanted});
  final VoidCallback onExplore;
  final bool slanted;
  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final panel = Container(width: double.infinity, color: Colors.white,
      padding: EdgeInsets.fromLTRB(slanted ? 44 : 24, 44, slanted ? 120 : 24, 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        const SolarText('CAREERS AT THE CROSSROADS', style: TextStyle(color: _sky, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        const SolarText('Your Contribution.\nA More Connected Future.', style: TextStyle(color: _navy, fontSize: 34, height: 1.15, fontWeight: FontWeight.w700, letterSpacing: -.6)),
        const SizedBox(height: 24),
        const SolarText('SolarID brings solar energy, commerce and practical expertise together. Our solar products and flexible power purchases help people make useful choices for their homes, businesses and communities.\n\nOur marketplace connects customers with seller services, while our professional directory and learning pathways connect people with practical skills.\n\nDiscover how your technical knowledge, craftsmanship or service experience could contribute to this connected future.',
          style: TextStyle(color: _grey, fontSize: 16, height: 1.55)),
        const SizedBox(height: 28),
        _CareerIntroButton(onPressed: onExplore),
      ]),
    );
    return slanted ? ClipPath(clipper: const _CareerSlantClipper(), child: panel) : panel;
  }
}

class _CareerSlantClipper extends CustomClipper<Path> {
  const _CareerSlantClipper();
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width * .88, size.height)
    ..lineTo(0, size.height)
    ..close();
  @override
  bool shouldReclip(covariant _CareerSlantClipper oldClipper) => false;
}

class _CareerIntroButton extends StatelessWidget {
  const _CareerIntroButton({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 190),
    child: OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(999))),
        side: const WidgetStatePropertyAll(BorderSide(color: _sky, width: 1.2)),
        backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.hovered) ? _sky : Colors.white),
        foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.hovered) ? Colors.white : _sky),
      ),
      child: const SolarText('Discover pathways', softWrap: true, textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w700)),
    ),
  ); }
}

// These are original project graphics, not affiliation or certification badges.
class CareerGraphicPanel extends StatelessWidget {
  const CareerGraphicPanel({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    const titles = ['SOLAR\nEXPERTISE', 'PRACTICAL\nCRAFTSMANSHIP', 'CONNECTED\nSERVICES'];
    const icons = [Icons.solar_power_outlined, Icons.handyman_outlined, Icons.hub_outlined];
    const details = [
      ['PLAN', 'INSTALL', 'MAINTAIN'],
      ['PRECISION', 'CARE', 'CRAFT'],
      ['PRODUCTS', 'PEOPLE', 'SUPPORT'],
    ];
    const captions = ['KNOWLEDGE THAT SUPPORTS EVERYDAY POWER', 'PRACTICAL SKILLS. PURPOSEFUL WORK.', 'ENERGY AND EXPERTISE, BROUGHT TOGETHER'];
    return Container(width: double.infinity, constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: const LinearGradient(
        colors: [Color(0xFF112735), Color(0xFF18455E), Color(0xFF098AB8)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      padding: const EdgeInsets.all(28),
      child: LayoutBuilder(builder: (context, constraints) {
        final symbol = Container(width: 88, height: 88,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white70, width: 1.4)),
          child: Icon(icons[index], size: 44, color: Colors.white));
        final wordmark = SolarText(titles[index], style: const TextStyle(color: Colors.white, fontSize: 27, height: 1.15, letterSpacing: .6, fontWeight: FontWeight.w400));
        final topics = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final detail in details[index])
          Padding(padding: const EdgeInsets.only(bottom: 9), child: SolarText(detail, style: const TextStyle(color: Colors.white, fontSize: 17, letterSpacing: .8, fontWeight: FontWeight.w700)))]);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          const SolarText('SolarID / CAREER PATHWAYS', style: TextStyle(color: Color(0xFFBDEBFA), fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w600)),
          const SizedBox(height: 30),
          if (constraints.maxWidth < 420) ...[
            symbol, const SizedBox(height: 20), wordmark, const SizedBox(height: 22),
            Wrap(spacing: 18, runSpacing: 10, children: [for (final detail in details[index]) SolarText(detail, style: const TextStyle(color: Colors.white, fontSize: 13, letterSpacing: .7, fontWeight: FontWeight.w700))]),
          ] else Wrap(spacing: 24, runSpacing: 24, crossAxisAlignment: WrapCrossAlignment.center, children: [
            symbol,
            SizedBox(width: 190, child: wordmark),
            ConstrainedBox(constraints: BoxConstraints(maxWidth: constraints.maxWidth), child: topics),
          ]),
          const SizedBox(height: 30),
          SolarText(captions[index], style: const TextStyle(color: Colors.white70, fontSize: 10, height: 1.6, letterSpacing: .7)),
        ]);
      }),
    );
  }
}
