import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'seller_process_strip.dart';
import 'package:flutter/material.dart';

import '../marketplace/marketplace_theme.dart';
import '../marketplace/marketplace_widgets.dart';

class SellWithUsScreen extends StatefulWidget {
  const SellWithUsScreen({super.key, required this.onCustomerAccess});
  final VoidCallback onCustomerAccess;
  @override
  State<SellWithUsScreen> createState() => _SellWithUsScreenState();
}

class _SellWithUsScreenState extends State<SellWithUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _contactName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  String _businessType = 'Solar retailer';
  bool _accepted = false;

  @override
  void dispose() {
    for (final controller in [_businessName, _contactName, _email, _phone, _description]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: SolarText('Please confirm the marketplace terms before submitting.')));
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded, color: MarketColors.green, size: 52),
        title: const SolarText('Application received', style: TextStyle(fontWeight: FontWeight.w900)),
        content: SolarText('Thank you, ${_contactName.text}. The SolarID team will review ${_businessName.text} and contact you using the details supplied.'),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const SolarText('Done'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MarketplaceShell(activeSection: 'Sell with us', 
        onCustomerAccess: widget.onCustomerAccess,
        hero: const SellerProcessStrip(),
        title: 'Grow your business with SolarID',
        subtitle: 'Join a trusted solar marketplace, reach customers across Nigeria and manage your products through a clear seller onboarding process.',
        child: Column(children: [
          PageSection(
            child: LayoutBuilder(builder: (context, constraints) {
              final benefits = const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SectionTitle(title: 'Become an approved seller', subtitle: 'Complete the form accurately. This demonstration stores no submission until it is connected to the approved backend seller service.'),
                SizedBox(height: 28),
                _Benefit(icon: Icons.people_alt_outlined, title: 'Reach more customers', body: 'Show your products to customers searching for dependable solar equipment.'),
                _Benefit(icon: Icons.security_rounded, title: 'Trusted environment', body: 'Seller checks, clear product records and controlled account access.'),
                _Benefit(icon: Icons.analytics_outlined, title: 'Clear performance', body: 'A future seller dashboard can show orders, commission and product activity.'),
              ]);
              final form = Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: MarketColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: MarketColors.line), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 18, offset: const Offset(0, 8))]),
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SolarText('Seller application', style: TextStyle(color: MarketColors.ink, fontSize: 25, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 22),
                    _field(_businessName, 'Business name'),
                    const SizedBox(height: 14),
                    _field(_contactName, 'Contact person'),
                    const SizedBox(height: 14),
                    _field(_email, 'Business email', email: true),
                    const SizedBox(height: 14),
                    _field(_phone, 'Phone number'),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(initialValue: _businessType, decoration: const SolarInputDecoration(labelText: 'Business type'), items: const ['Solar retailer', 'Equipment distributor', 'Installer', 'Manufacturer', 'Professional service provider'].map((value) => DropdownMenuItem(value: value, child: SolarText(value))).toList(), onChanged: (value) => setState(() => _businessType = value ?? _businessType)),
                    const SizedBox(height: 14),
                    TextFormField(controller: _description, maxLines: 4, decoration: const SolarInputDecoration(labelText: 'Products or services'), validator: SolarLanguage.validation<String>((value) => value == null || value.trim().length < 15 ? 'Provide a short description (at least 15 characters).' : null)),
                    const SizedBox(height: 10),
                    CheckboxListTile(value: _accepted, contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, activeColor: MarketColors.green, title: const SolarText('I confirm that the information supplied is accurate.'), onChanged: (value) => setState(() => _accepted = value ?? false)),
                    const SizedBox(height: 8),
                    HoverButton(label: 'Submit seller application', icon: Icons.arrow_forward_rounded, onPressed: _submit, expanded: true),
                  ]),
                ),
              );
              return constraints.maxWidth >= 900 ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: benefits), const SizedBox(width: 54), Expanded(child: form)]) : Column(children: [benefits, const SizedBox(height: 34), form]);
            }),
          ),
        ]),
      ); }

  Widget _field(TextEditingController controller, String label, {bool email = false}) => TextFormField(
        controller: controller,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        decoration: SolarInputDecoration(labelText: label),
        validator: SolarLanguage.validation<String>((value) {
          if (value == null || value.trim().isEmpty) return '$label is required.';
          if (email && (!value.contains('@') || !value.contains('.'))) return 'Enter a valid email address.';
          return null;
        }),
      );
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title, body;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: MarketColors.sky, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: MarketColors.greenDark)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SolarText(title, style: const TextStyle(color: MarketColors.ink, fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 5), SolarText(body, style: const TextStyle(color: MarketColors.muted, height: 1.45))]))]),
      ); }
}
