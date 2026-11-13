import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'imad_id_logo.dart';
import '../screens/seller_centre_screen.dart';
import '../screens/careers_screen.dart';
import '../screens/learn_professionals_screen.dart';
import '../screens/hire_workers_screen.dart';
// Careers, hiring and learning each have their own screen.
import '../screens/marketplace_guide_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_theme.dart';

class ImadSiteHeader extends StatefulWidget implements PreferredSizeWidget {
  const ImadSiteHeader({
    super.key,
    required this.onHome,
    required this.onShopping,
    required this.onMarketplace,
    required this.onSellWithUs,
    required this.onProfessionals,
    required this.onCustomerAccess,
    required this.onGuide,
    this.actions = const [],
    this.height = 82,
    this.activeSection = 'Home',
  });
  final VoidCallback onHome,
      onShopping,
      onMarketplace,
      onSellWithUs,
      onProfessionals,
      onCustomerAccess;
  final ValueChanged<String> onGuide;
  final List<Widget> actions;
  final double height;
  final String activeSection;
  @override
  Size get preferredSize => Size.fromHeight(height);
  @override
  State<ImadSiteHeader> createState() => _ImadSiteHeaderState();
}

class _ImadSiteHeaderState extends State<ImadSiteHeader> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  Timer? _closeTimer;
  String? _active;
  List<String> get _categories => _active == 'Sell with us'
      ? const ['Become a Seller', 'List Your Products', 'Seller Support']
      : _active == 'Find a professional'
      ? const ['Hire Skilled Workers', 'Learn from Professionals', 'Careers']
      : _active == 'Marketplace'
      ? marketplaceGuideTitles
      : const ['Solar panels', 'Batteries', 'Inverters'];
  void _guide(String category) {
    if (const [
      'Become a Seller',
      'List Your Products',
      'Seller Support',
    ].contains(category)) {
      _run(
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SellerCentreScreen(
              section: category,
              onCustomerAccess: widget.onCustomerAccess,
            ),
          ),
        ),
      );
      return;
    }
    if (const [
      'Hire Skilled Workers',
      'Learn from Professionals',
      'Careers',
    ].contains(category)) {
      _run(
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => category == 'Hire Skilled Workers'
                ? HireWorkersScreen(onCustomerAccess: widget.onCustomerAccess)
                : category == 'Learn from Professionals'
                ? LearnProfessionalsScreen(
                    onCustomerAccess: widget.onCustomerAccess,
                  )
                : CareersScreen(onCustomerAccess: widget.onCustomerAccess),
          ),
        ),
      );
      return;
    }
    if (marketplaceGuideTitles.contains(category)) {
      _run(
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MarketplaceGuideScreen(
              onCustomerAccess: widget.onCustomerAccess,
              initialCategory: category,
            ),
          ),
        ),
      );
    } else {
      _run(() => widget.onGuide(category));
    }
  }

  List<(String, VoidCallback)> get _navigation => [
    ('Home', widget.onHome),
    ('Shopping', widget.onShopping),
    ('Marketplace', widget.onMarketplace),
    ('Sell with us', widget.onSellWithUs),
    ('Find a professional', widget.onProfessionals),
  ];
  String _description(String category) {
    if (marketplaceGuideTitles.contains(category))
      return switch (category) {
        'Solar Appliances' =>
          'Discover lighting, fans, televisions and pumps for solar-powered living.',
        'Portable Solar Products' =>
          'Explore portable power stations, compact lighting and energy on the move.',
        _ =>
          'Bring generation, storage and compatible equipment together in one solution.',
      };
    if (_active == 'Sell with us')
      return switch (category) {
        'Become a Seller' =>
          'Explore the application process and business verification steps.',
        'List Your Products' =>
          'Prepare clear descriptions, prices, stock details and product photos.',
        _ =>
          'Connect with SolarID for guidance on selling and product enquiries.',
      };
    if (const [
      'Hire Skilled Workers',
      'Learn from Professionals',
      'Careers',
    ].contains(category))
      return switch (category) {
        'Hire Skilled Workers' =>
          'Find practical support for your home, workplace or next project.',
        'Learn from Professionals' =>
          'Explore hands-on guidance and practical learning in your chosen trade.',
        _ =>
          'Explore career enquiries and opportunities to develop your skills.',
      };
    return switch (category) {
      'Solar panels' =>
        'Discover panel types, power ratings and options for different spaces.',
      'Batteries' =>
        'Explore energy storage, capacity and choosing compatible equipment.',
      _ =>
        'Understand hybrid systems, output power and single or three-phase options.',
    };
  }

  void _open(String label) {
    _closeTimer?.cancel();
    if (_active != label) setState(() => _active = label);
    _portal.show();
  }

  void _keepOpen() => _closeTimer?.cancel();
  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 180), _close);
  }

  void _close() {
    _closeTimer?.cancel();
    _portal.hide();
    if (mounted && _active != null) setState(() => _active = null);
  }

  void _run(VoidCallback callback) {
    _close();
    callback();
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1120;
    if (!desktop && _active != null)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _close();
      });
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) => Positioned(
        left: 0,
        top: 0,
        width: width,
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          child: MouseRegion(
            onEnter: (_) => _keepOpen(),
            onExit: (_) => _scheduleClose(),
            child: Material(
              color: Colors.white,
              elevation: 5,
              shadowColor: const Color(0x18000000),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(_active),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 180),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -6 * (1 - value)),
                    child: child,
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1320),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 2,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final category in _categories)
                            Expanded(
                              child: Focus(
                                onFocusChange: (focused) {
                                  if (focused)
                                    _keepOpen();
                                  else
                                    _scheduleClose();
                                },
                                child: InkWell(
                                  onTap: () => _guide(category),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SolarText(
                                          category,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: MarketColors.ink,
                                            decoration:
                                                _active == 'Find a professional'
                                                ? TextDecoration.underline
                                                : null,
                                            decorationColor:
                                                MarketColors.skyStrong,
                                            decorationThickness: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        SolarText(
                                          _description(category),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.15,
                                            color: MarketColors.muted,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        SolarText(
                                          _active == 'Marketplace'
                                              ? 'Read more →'
                                              : 'Learn more →',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF087AA4),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      child: CompositedTransformTarget(
        link: _link,
        child: MouseRegion(
          onEnter: (_) => _keepOpen(),
          onExit: (_) => _scheduleClose(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: widget.height,
            decoration: BoxDecoration(
              gradient: _active == null
                  ? const LinearGradient(
                      colors: [
                        Color(0xFFD8F3FB),
                        Color(0xFFF7FDFF),
                        Color(0xFFD8F3FB),
                        Color(0xFFE9F9FF),
                        Color(0xFFD8F3FB),
                      ],
                      stops: [0, .28, .52, .78, 1],
                    )
                  : null,
              color: MarketColors.sky,
              border: const Border(
                bottom: BorderSide(color: MarketColors.line),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: desktop ? 24 : 14),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _run(widget.onHome),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ImadIdLogo(size: 42),
                      const SizedBox(width: 10),
                      SolarText(
                        'SolarID',
                        style: TextStyle(
                          color: MarketColors.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: width < 420 ? 16 : 19,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!desktop) const Spacer(),
                if (desktop)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final item in _navigation)
                              MouseRegion(
                                onEnter: (_) {
                                  if (item.$1 == 'Home')
                                    _close();
                                  else
                                    _open(item.$1);
                                },
                                child: TextButton(
                                  onFocusChange: (focused) {
                                    if (focused && item.$1 != 'Home')
                                      _open(item.$1);
                                    else if (!focused)
                                      _scheduleClose();
                                  },
                                  onPressed: () => _run(item.$2),
                                  style: TextButton.styleFrom(
                                    foregroundColor: MarketColors.ink,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 20,
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color:
                                              widget.activeSection == item.$1 ||
                                                  _active == item.$1
                                              ? const Color(0xFF162C3B)
                                              : Colors.transparent,
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                    child: SolarText(
                                      item.$1,
                                      key: ValueKey('site-nav-${item.$1}'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 10),
                            FilledButton.icon(
                              onPressed: () => _run(widget.onCustomerAccess),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    ModalRoute.of(context)?.isFirst == true
                                    ? const Color(0xFF162C3B)
                                    : MarketColors.ink,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 18,
                                ),
                              ),
                              icon: const Icon(
                                Icons.person_outline_rounded,
                                size: 19,
                              ),
                              label: const SolarText('My account'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  PopupMenuButton<String>(
                    tooltip: SolarLanguage.instance.translate('Open navigation'),
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: MarketColors.ink,
                    ),
                    onSelected: (value) {
                      if (value.startsWith('guide:')) {
                        _guide(value.substring(6));
                        return;
                      }
                      if (value == 'account') {
                        _run(widget.onCustomerAccess);
                        return;
                      }
                      _run(
                        _navigation.firstWhere((item) => item.$1 == value).$2,
                      );
                    },
                    itemBuilder: (_) => [
                      for (final item in _navigation)
                        PopupMenuItem(
                          value: item.$1,
                          child: SolarText(
                            item.$1,
                            key: ValueKey('site-nav-${item.$1}'),
                            style: TextStyle(
                              decoration: widget.activeSection == item.$1
                                  ? TextDecoration.underline
                                  : null,
                              decorationColor: Colors.white,
                              decorationThickness: 4.0,
                              fontWeight: widget.activeSection == item.$1
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      const PopupMenuDivider(),
                      for (final category in const [
                        'Solar panels',
                        'Batteries',
                        'Inverters',
                      ])
                        PopupMenuItem(
                          value: 'guide:$category',
                          child: SolarText('Learn about ${category.toLowerCase()}'),
                        ),
                      const PopupMenuDivider(),
                      for (final category in const [
                        'Hire Skilled Workers',
                        'Learn from Professionals',
                        'Careers',
                      ])
                        PopupMenuItem(
                          value: 'guide:$category',
                          child: SolarText(category),
                        ),
                      for (final category in marketplaceGuideTitles)
                        PopupMenuItem(
                          value: 'guide:$category',
                          child: SolarText(category),
                        ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'account',
                        child: SolarText('My account'),
                      ),
                    ],
                  ),
                ...widget.actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
