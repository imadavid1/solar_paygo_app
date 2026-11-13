import 'package:solar_paygo_app/l10n/solar_language.dart';
import '../screens/hire_workers_screen.dart';
import '../screens/learn_professionals_screen.dart';
import '../screens/careers_screen.dart';
import '../screens/seller_centre_screen.dart';
import '../widgets/solarid_footer.dart';
import '../commerce/commerce_customer_screens.dart';
import '../screens/product_guide_screen.dart';
import '../widgets/site_header.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'marketplace_data.dart';
import 'marketplace_theme.dart';
import '../screens/marketplace_screen.dart';
import '../screens/professionals_screen.dart';
import '../screens/sell_with_us_screen.dart';
import '../screens/shopping_screen.dart';

const imadWhatsAppNumber = '2349069190601';

Future<void> openImadWhatsApp(String message) async {
  final uri = Uri.parse(
    'https://wa.me/$imadWhatsAppNumber?text=${Uri.encodeComponent(message)}',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class MarketplaceShell extends StatelessWidget {
  const MarketplaceShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onCustomerAccess,
    this.actions = const [],
    this.hero,
    this.activeSection = 'Marketplace',
  });

  final Widget? hero;
  final String activeSection;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onCustomerAccess;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    void open(Widget page) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => page));
    }

    return Scaffold(
      backgroundColor: MarketColors.mist,
      appBar: ImadSiteHeader(
        activeSection: activeSection,
        onHome: () => Navigator.of(context).popUntil((route) => route.isFirst),
        onShopping: () =>
            open(ShoppingScreen(onCustomerAccess: onCustomerAccess)),
        onMarketplace: () =>
            open(MarketplaceScreen(onCustomerAccess: onCustomerAccess)),
        onSellWithUs: () =>
            open(SellWithUsScreen(onCustomerAccess: onCustomerAccess)),
        onProfessionals: () =>
            open(ProfessionalsScreen(onCustomerAccess: onCustomerAccess)),
        onCustomerAccess: onCustomerAccess,
        actions: actions,
        onGuide: (category) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductGuideScreen(
              onCustomerAccess: onCustomerAccess,
              initialCategory: category,
            ),
          ),
        ),
      ),
      body: ImadButtonArea(
        child: ListView(
          children: [
            if (const ['Shopping', 'Marketplace'].contains(activeSection))
              CommerceToolbar(section: activeSection),
            hero ??
                Container(
                  color: MarketColors.sky,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 62,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          SolarText(
                            title,
                            style: const TextStyle(
                              color: MarketColors.ink,
                              fontWeight: FontWeight.w900,
                              fontSize: 46,
                              height: 1.05,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 780),
                            child: SolarText(
                              subtitle,
                              style: const TextStyle(
                                color: MarketColors.muted,
                                fontSize: 18,
                                height: 1.55,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            child,
            MarketplaceFooter(
              onCustomerAccess: onCustomerAccess,
              shoppingSkyBlend: title == 'Popular products',
              backgroundColor:
                  const [
                    'Find a Professional',
                    'Find a professional',
                    'Hire Skilled Workers',
                    'Learn from Professionals',
                    'Careers',
                  ].contains(title)
                  ? Colors.white
                  : MarketColors.mist,
            ),
          ],
        ),
      ),
    );
  }
}

class PageSection extends StatelessWidget {
  const PageSection({
    super.key,
    required this.child,
    this.color = MarketColors.mist,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 68),
  });
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    width: double.infinity,
    color: color,
    padding: padding,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: child,
      ),
    ),
  ); }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });
  final String title;
  final String subtitle;
  final IconData? icon;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (icon != null) ...[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: MarketColors.sky,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: MarketColors.greenDark),
        ),
        const SizedBox(width: 15),
      ],
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SolarText(
              title,
              style: const TextStyle(
                color: MarketColors.ink,
                fontSize: 31,
                fontWeight: FontWeight.w900,
                letterSpacing: -.8,
              ),
            ),
            const SizedBox(height: 7),
            SolarText(
              subtitle,
              style: const TextStyle(
                color: MarketColors.muted,
                height: 1.5,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ],
  ); }
}

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.onProduct,
    required this.onOrder,
  });
  final List<SolarProduct> products;
  final ValueChanged<SolarProduct> onProduct;
  final ValueChanged<SolarProduct> onOrder;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1120
          ? 4
          : constraints.maxWidth >= 760
          ? 3
          : constraints.maxWidth >= 500
          ? 2
          : 1;
      final width = (constraints.maxWidth - (columns - 1) * 20) / columns;
      return Wrap(
        spacing: 20,
        runSpacing: 20,
        children: products
            .map(
              (product) => SizedBox(
                width: width,
                child: ProductCard(
                  product: product,
                  onTap: () => onProduct(product),
                  onOrder: () => onOrder(product),
                ),
              ),
            )
            .toList(),
      );
    },
  ); }
}

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onOrder,
  });
  final SolarProduct product;
  final VoidCallback onTap;
  final VoidCallback onOrder;
  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    cursor: SystemMouseCursors.click,
    child: AnimatedScale(
      scale: _hovered ? 1.018 : 1,
      duration: const Duration(milliseconds: 180),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -7 : 0, 0),
        decoration: BoxDecoration(
          color: MarketColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered ? MarketColors.skyStrong : MarketColors.line,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? .15 : .06),
              blurRadius: _hovered ? 26 : 12,
              offset: Offset(0, _hovered ? 12 : 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.35,
                    child: ProductImage(product: widget.product),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 19),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SolarText(
                          widget.product.category.toUpperCase(),
                          style: const TextStyle(
                            color: MarketColors.greenDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SolarText(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: MarketColors.ink,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 9),
                        SolarText(
                          widget.product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: MarketColors.muted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 13),
                        SolarText(
                          formatNaira(widget.product.price),
                          style: const TextStyle(
                            color: MarketColors.ink,
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(height: 14),
                        HoverButton(
                          label: 'Order Now',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: widget.onOrder,
                          expanded: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ); }
}

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product});
  final SolarProduct product;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Stack(
    fit: StackFit.expand,
    children: [
      Container(color: MarketColors.sky),
      Image.network(
        product.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(product.icon, color: MarketColors.greenDark, size: 72),
        ),
      ),
      Positioned(
        top: 12,
        left: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: MarketColors.white.withValues(alpha: .92),
            borderRadius: BorderRadius.circular(20),
          ),
          child: SolarText(
            product.useCase,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: MarketColors.ink,
              fontSize: 11,
            ),
          ),
        ),
      ),
    ],
  ); }
}

class HoverButton extends StatefulWidget {
  const HoverButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
    this.secondary = false,
  });
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool expanded;
  final bool secondary;
  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    const blue = Color(0xFF009BDF);
    final button = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: OutlinedButton(
        onPressed: widget.onPressed,
        style:
            imadBlueButtonStyle(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
            ).copyWith(
              backgroundColor: WidgetStatePropertyAll<Color>(
                _hovered ? blue : Colors.white,
              ),
              foregroundColor: WidgetStatePropertyAll<Color>(
                _hovered ? Colors.white : blue,
              ),
            ),
        child: Row(
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SolarText(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            if (widget.icon != null) ...[
              const SizedBox(width: 8),
              Icon(widget.icon, size: 18),
            ],
          ],
        ),
      ),
    );
    return widget.expanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

class MarketplaceFooter extends StatelessWidget {
  const MarketplaceFooter({
    super.key,
    this.backgroundColor = MarketColors.mist,
    this.shoppingSkyBlend = false,
    this.onCustomerAccess,
  });
  final Color backgroundColor;
  final bool shoppingSkyBlend;
  final VoidCallback? onCustomerAccess;
  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    void customer() => onCustomerAccess?.call();
    void open(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    return SolarIDFooter(
      skyBlend: shoppingSkyBlend,
      groups: [
        SolarIDFooterGroup('Explore', [
          (
            'Home',
            () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          ('Shopping', () => open(ShoppingScreen(onCustomerAccess: customer))),
          (
            'Marketplace',
            () => open(MarketplaceScreen(onCustomerAccess: customer)),
          ),
          (
            'Sell with us',
            () => open(SellWithUsScreen(onCustomerAccess: customer)),
          ),
        ]),
        SolarIDFooterGroup('Solar energy', [
          for (final category in ['Solar panels', 'Batteries', 'Inverters'])
            (
              category,
              () => open(
                ProductGuideScreen(
                  onCustomerAccess: customer,
                  initialCategory: category,
                ),
              ),
            ),
          ('Customer access', customer),
        ]),
        SolarIDFooterGroup('Professionals', [
          (
            'Find a professional',
            () => open(ProfessionalsScreen(onCustomerAccess: customer)),
          ),
          (
            'Hire skilled workers',
            () => open(HireWorkersScreen(onCustomerAccess: customer)),
          ),
          (
            'Learn from professionals',
            () => open(LearnProfessionalsScreen(onCustomerAccess: customer)),
          ),
          ('Careers', () => open(CareersScreen(onCustomerAccess: customer))),
        ]),
        SolarIDFooterGroup('Support', [
          (
            'WhatsApp enquiry',
            () => openImadWhatsApp(
              'Hello SolarID, I would like to make an enquiry.',
            ),
          ),
          (
            'Seller support',
            () => open(
              SellerCentreScreen(
                onCustomerAccess: customer,
                section: 'Seller Support',
              ),
            ),
          ),
        ]),
      ],
    );
  }
}

String formatNaira(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final position = digits.length - i;
    buffer.write(digits[i]);
    if (position > 1 && position % 3 == 1) buffer.write(',');
  }
  return '₦$buffer';
}

// Blue outline buttons for public shopping pages.
ButtonStyle imadBlueButtonStyle({
  Color? backgroundColor,
  Color? foregroundColor,
  EdgeInsetsGeometry? padding,
  OutlinedBorder? shape,
  BorderSide? side,
}) {
  const blue = Color(0xFF009BDF);

  bool active(Set<WidgetState> states) =>
      states.contains(WidgetState.hovered) ||
      states.contains(WidgetState.pressed);

  return ButtonStyle(
    fixedSize: const WidgetStatePropertyAll<Size>(Size(170, 48)),
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (states) => active(states) ? blue : Colors.white,
    ),
    foregroundColor: WidgetStateProperty.resolveWith<Color>(
      (states) => states.contains(WidgetState.disabled)
          ? Colors.grey
          : active(states)
          ? Colors.white
          : blue,
    ),
    side: const WidgetStatePropertyAll<BorderSide>(
      BorderSide(color: blue, width: 1.5),
    ),
    shape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
    padding: padding == null
        ? null
        : WidgetStatePropertyAll<EdgeInsetsGeometry>(padding),
    elevation: const WidgetStatePropertyAll<double>(0),
    overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    animationDuration: const Duration(milliseconds: 200),
  );
}

class ImadButtonArea extends StatelessWidget {
  const ImadButtonArea({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final style = imadBlueButtonStyle();
    return Theme(
      data: Theme.of(context).copyWith(
        filledButtonTheme: FilledButtonThemeData(style: style),
        outlinedButtonTheme: OutlinedButtonThemeData(style: style),
        elevatedButtonTheme: ElevatedButtonThemeData(style: style),
        textButtonTheme: TextButtonThemeData(style: style),
      ),
      child: SelectionArea(child: child),
    );
  }
}
