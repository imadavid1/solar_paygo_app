import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';

/// Wide editorial rows for the SolarID story, separate from workforce services.
class ImadAboutSection extends StatelessWidget {
  const ImadAboutSection({super.key});

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 800;
          return Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 22 : 48,
              vertical: compact ? 52 : 82,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SolarText('About Us', style: TextStyle(
                      color: const Color(0xFF172126),
                      fontSize: compact ? 34 : 44,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                      letterSpacing: -1,
                    )),
                    SizedBox(height: compact ? 34 : 52),
                    const _AboutRow(
                      title: 'A brighter everyday life',
                      body: 'At SolarID, our purpose is simple: make solar energy easier to understand, access and use. We bring solar products, flexible PAYGO options and professional connections together, helping households and businesses take the next step towards dependable everyday power.\n\nOur focus begins with Nigeria and the practical needs of African communities: lighting a home, keeping a shop running and making room for work, learning and family life.',
                      image: 'assets/images/about_imad_centre.png',
                      imageLabel: 'Concept visual of an SolarID solar service centre in Nigeria',
                      imageFirst: true,
                    ),
                    SizedBox(height: compact ? 52 : 96),
                    const _AboutRow(
                      title: 'Solar that fits your world',
                      body: 'Every home, shop and workspace has different energy needs. Our platform helps you explore panels, batteries, inverters and solar appliances, with clear product information to guide your choices.\n\nDaily, weekly and monthly PAYGO options give customers a flexible way to purchase power. From essential lighting to a growing business, our aim is to make the journey towards solar simpler and more practical.',
                      image: 'assets/images/about_solar_community.png',
                      imageLabel: 'Nigerian shop owner discussing rooftop solar with a technician',
                      imageFirst: false,
                    ),
                    SizedBox(height: compact ? 52 : 96),
                    const _AboutRow(
                      title: 'People behind the power',
                      body: 'Good energy solutions need the right people. SolarID brings product discovery and professional enquiries into one place, helping you explore services by trade and location and discuss what your project needs.\n\nWe believe a clearer conversation is the beginning of better support. Whether you are planning an installation, looking for a skilled worker or exploring solar for the first time, our goal is to help you move forward with confidence.',
                      image: 'assets/images/about_solar_installation.png',
                      imageLabel: 'Solar technician working on a rooftop installation',
                      imageFirst: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ); }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.title, required this.body, required this.image,
    required this.imageLabel, required this.imageFirst});

  final String title;
  final String body;
  final String image;
  final String imageLabel;
  final bool imageFirst;

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 800;
          final photo = ClipRRect(
            borderRadius: BorderRadius.circular(compact ? 20 : 28),
            child: AspectRatio(
              aspectRatio: compact ? 1.45 : 1.35,
              child: Image.asset(image, fit: BoxFit.cover,
                semanticLabel: imageLabel,
                errorBuilder: (_, error, stack) => const ColoredBox(
                  color: Color(0xFFDDF3FA),
                  child: Center(child: Icon(Icons.solar_power_outlined,
                    size: 64, color: Color(0xFF1688B2))),
                ),
              ),
            ),
          );
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SolarText(title, style: TextStyle(
                color: const Color(0xFF1688B2),
                fontSize: compact ? 29 : 38,
                fontWeight: FontWeight.w700,
                letterSpacing: -.7,
                height: 1.16,
              )),
              const SizedBox(height: 22),
              SolarText(body, style: TextStyle(
                color: const Color(0xFF5C686D),
                fontSize: compact ? 16 : 17,
                height: 1.65,
              )),
            ],
          );
          if (compact) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [photo, const SizedBox(height: 28), copy]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.center,
            children: imageFirst
              ? [Expanded(flex: 11, child: photo), const SizedBox(width: 70), Expanded(flex: 10, child: copy)]
              : [Expanded(flex: 10, child: copy), const SizedBox(width: 70), Expanded(flex: 11, child: photo)],
          );
        },
      ); }
}
