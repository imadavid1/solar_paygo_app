import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';

/// Selected SolarID sunrise monogram. Class name retained for existing callers.
class ImadIdLogo extends StatelessWidget {
  const ImadIdLogo({super.key, required this.size});
  final double size;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Semantics(
    label: 'SolarID logo',
    image: true,
    child: Container(
      color: Colors.white,
      width: size,
      height: size,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: size * 1.35,
          maxHeight: size * 1.35,
          child: Image.asset(
            'assets/brand/solarid-mark.png',
            width: size * 1.35,
            height: size * 1.35,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
  ); }
}

class SolarIDBrand extends StatelessWidget {
  const SolarIDBrand({super.key, this.size = 44});
  final double size;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ImadIdLogo(size: size),
      const SizedBox(width: 10),
      const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Solar',
              style: TextStyle(color: Color(0xFF102F46)),
            ),
            TextSpan(
              text: 'ID',
              style: TextStyle(color: Color(0xFF37B6E6)),
            ),
          ],
        ),
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w900,
          letterSpacing: -.6,
        ),
      ),
    ],
  ); }
}
