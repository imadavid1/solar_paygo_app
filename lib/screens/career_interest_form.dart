import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';
import '../marketplace/marketplace_data.dart';

const careerFields = ['Solar & Electrical', 'Construction & Skilled Trades', 'Sales & Marketplace', 'Customer Support & Operations'];

class CareerInterestForm extends StatefulWidget {
  const CareerInterestForm({super.key, required this.onSend, this.initialField});
  final Future<void> Function(String) onSend;
  final String? initialField;
  @override
  State<CareerInterestForm> createState() => _CareerInterestFormState();
}

class _CareerInterestFormState extends State<CareerInterestForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _experience = TextEditingController();
  String? _field, _location;
  bool _consent = false, _sending = false;
  String? _error;
  @override
  void initState() { super.initState(); _field = widget.initialField; }
  @override
  void dispose() { _name.dispose(); _contact.dispose(); _experience.dispose(); super.dispose(); }
  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Please complete this field.' : null;
  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    if (!_consent) { setState(() => _error = 'Please agree to share your details with SolarID.'); return; }
    setState(() { _sending = true; _error = null; });
    try {
      await widget.onSend('Hello SolarID, I would like to register my career interest.\nName: ${_name.text.trim()}\nField: $_field\nLocation: $_location\nContact: ${_contact.text.trim()}\nExperience and preferred role: ${_experience.text.trim()}\nPlease confirm current opportunities, requirements and next steps.');
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = 'WhatsApp could not open. Please try again.');
    } finally { if (mounted) setState(() => _sending = false); }
  }
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  AlertDialog(
    title: const SolarText('Register Your Interest'),
    content: SizedBox(width: 520, child: SingleChildScrollView(child: Form(key: _form,
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SolarText('Tell SolarID about your skills and the work you want to explore. This opens a prepared WhatsApp message; review it and press Send there. Registering interest is not a job offer.', style: TextStyle(height: 1.5)),
        const SizedBox(height: 20),
        TextFormField(controller: _name, decoration: const SolarInputDecoration(labelText: 'Full name'), validator: SolarLanguage.validation<String>(_required), textInputAction: TextInputAction.next, maxLength: 100),
        DropdownButtonFormField<String>(initialValue: _field, isExpanded: true, decoration: const SolarInputDecoration(labelText: 'Career field'),
          items: [for (final field in careerFields) DropdownMenuItem(value: field, child: SolarText(field, overflow: TextOverflow.ellipsis))],
          onChanged: _sending ? null : (value) => setState(() => _field = value), validator: SolarLanguage.validation<String>(_required)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(initialValue: _location, isExpanded: true, decoration: const SolarInputDecoration(labelText: 'State / FCT'),
          items: [for (final place in nigeriaLocations) DropdownMenuItem(value: place, child: SolarText(place))],
          onChanged: _sending ? null : (value) => setState(() => _location = value), validator: SolarLanguage.validation<String>(_required)),
        const SizedBox(height: 16),
        TextFormField(controller: _contact, decoration: const SolarInputDecoration(labelText: 'Email or phone number'), validator: SolarLanguage.validation<String>(_required), maxLength: 150),
        TextFormField(controller: _experience, decoration: const SolarInputDecoration(labelText: 'Experience and preferred role', hintText: 'Your trade, relevant experience and work interests'), minLines: 3, maxLines: 5, validator: SolarLanguage.validation<String>(_required), maxLength: 1000),
        CheckboxListTile(contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading,
          title: const SolarText('I agree to share these details with SolarID through WhatsApp.'), value: _consent,
          onChanged: _sending ? null : (value) => setState(() => _consent = value ?? false)),
        if (_error != null) SolarText(_error!, style: const TextStyle(color: Colors.red)),
      ])))),
    actions: [TextButton(onPressed: _sending ? null : () => Navigator.of(context).pop(), child: const SolarText('Cancel')),
      FilledButton(onPressed: _sending ? null : _send, child: SolarText(_sending ? 'Opening…' : 'Open WhatsApp'))],
  ); }
}
