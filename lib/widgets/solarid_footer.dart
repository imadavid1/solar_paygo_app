import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'imad_id_logo.dart';

/// Add the real account URLs here when the accounts have been opened.
abstract final class SolarIDSocialLinks {
  static const youtube = '';
  static const facebook = '';
  static const instagram = '';
  static const tiktok = '';
}

class SolarIDFooterGroup {
  const SolarIDFooterGroup(this.title, this.links);
  final String title;
  final List<(String, VoidCallback)> links;
}

class SolarIDFooter extends StatelessWidget {
  const SolarIDFooter({super.key, required this.groups, this.skyBlend = false});
  final List<SolarIDFooterGroup> groups;
  final bool skyBlend;
  static const navy = Color(0xFF102F46);
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      gradient: skyBlend
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF73CDEC),
                Color(0xFFEAF9FE),
                Colors.white,
                Color(0xFFABE1F4),
                Color(0xFFF5FCFF),
              ],
              stops: [0, .28, .48, .76, 1],
            )
          : null,
    ),
    padding: const EdgeInsets.fromLTRB(24, 64, 24, 28),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 32,
              runSpacing: 34,
              alignment: WrapAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 245,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SolarIDBrand(size: 58),
                      SizedBox(height: 18),
                      SolarText(
                        'Solar energy, products and professional services in one place.',
                        style: TextStyle(
                          color: navy,
                          fontSize: 15,
                          height: 1.65,
                        ),
                      ),
                      SizedBox(height: 18),
                      SolarText(
                        '+234 906 919 0601\nNigeria',
                        style: TextStyle(
                          color: navy,
                          fontSize: 14,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final group in groups)
                  SizedBox(
                    width: 190,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SolarText(
                          group.title,
                          style: const TextStyle(
                            color: navy,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 15),
                        for (final link in group.links)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: _FooterTextLink(label: link.$1, onTap: link.$2),
                          ),
                        if (identical(group, groups.last)) ...[
                          const SizedBox(height: 18),
                          SizedBox(width: 142, height: 40,
                            child: FilledButton.icon(
                              onPressed: () => launchUrl(
                                Uri.parse('https://wa.me/2349069190601?text=Hello%20SolarID%2C%20I%20would%20like%20to%20make%20an%20enquiry.'),
                                mode: LaunchMode.externalApplication),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.resolveWith<Color>((states) =>
                                  states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)
                                    ? const Color(0xFF78CBE5) : Colors.white),
                                foregroundColor: const WidgetStatePropertyAll(SolarIDFooter.navy),
                                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                                elevation: const WidgetStatePropertyAll(0),
                                fixedSize: const WidgetStatePropertyAll(Size(142, 40)),
                                minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
                                maximumSize: const WidgetStatePropertyAll(Size(142, 40)),
                                side: const WidgetStatePropertyAll(BorderSide(color: Color(0xFF99BCCD))),
                                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
                                shape: const WidgetStatePropertyAll(StadiumBorder()),
                              ),
                              icon: const Icon(Icons.chat_rounded, size: 18),
                              label: const SolarText('WhatsApp', style: TextStyle(fontSize: 14)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 40),
            const Divider(color: Color(0xFFB3CDD9), height: 1),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 30,
              runSpacing: 18,
              children: [
                const SolarIDSocialIcons(),
                SolarText(
                  '© ${DateTime.now().year} SolarID. All rights reserved.',
                  style: const TextStyle(color: navy, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ); }
}

class SolarIDSocialIcons extends StatelessWidget {
  const SolarIDSocialIcons({super.key});
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Wrap(
    spacing: 10,
    children: [
      for (final social in const [
        ('YouTube', 'youtube', SolarIDSocialLinks.youtube),
        ('Facebook', 'facebook', SolarIDSocialLinks.facebook),
        ('Instagram', 'instagram', SolarIDSocialLinks.instagram),
        ('TikTok', 'tiktok', SolarIDSocialLinks.tiktok),
      ])
        Semantics(
          label: social.$3.isEmpty
              ? '${social.$1}, account coming soon'
              : social.$1,
          button: true,
          enabled: social.$3.isNotEmpty,
          child: Tooltip(
            message: SolarLanguage.instance.translate(social.$3.isEmpty
                ? '${social.$1} — coming soon'
                : social.$1),
            child: IconButton(
              onPressed: social.$3.isEmpty
                  ? null
                  : () async {
                      final uri = Uri.tryParse(social.$3);
                      if (uri != null && uri.scheme == 'https') {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
              icon: Image.asset(
                'assets/brand/${social.$2}.png',
                width: 24,
                height: 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFE5F5FC),
                disabledBackgroundColor: const Color(0xFFE5F5FC),
                minimumSize: const Size(44, 44),
              ),
            ),
          ),
        ),
    ],
  ); }
}

/// Footer navigation with an explicit mouse hover highlight.
class _FooterTextLink extends StatefulWidget {
  const _FooterTextLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  State<_FooterTextLink> createState() => _FooterTextLinkState();
}

class _FooterTextLinkState extends State<_FooterTextLink> {
  bool _hovered = false;
  bool _focused = false;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: Semantics(
      link: true,
      label: widget.label,
      onTap: widget.onTap,
      child: FocusableActionDetector(
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            widget.onTap();
            return null;
          }),
        },
        child: GestureDetector(
          excludeFromSemantics: true,
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: _hovered || _focused ? const Color(0xFFD8F3FB) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: _hovered || _focused ? const [
                BoxShadow(color: Color(0x2267C7EF), blurRadius: 8, offset: Offset(0, 2)),
              ] : const [],
            ),
            child: SolarText(widget.label, style: const TextStyle(
              color: SolarIDFooter.navy,
              fontSize: 14,
              height: 1.5,
            )),
          ),
        ),
      ),
    ),
  ); }
}
