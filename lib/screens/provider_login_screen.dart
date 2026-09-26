import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../services/auth_service.dart';

class ProviderLoginScreen extends StatefulWidget {
  final ValueChanged<AuthSession> onLoginSuccess;
  const ProviderLoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<ProviderLoginScreen> createState() => _ProviderLoginScreenState();
}

class _ProviderLoginScreenState extends State<ProviderLoginScreen> {
  static const navy = Color(0xFF071D2B);
  static const green = Color(0xFF0B7A55);
  static const lime = Color(0xFFA8D94F);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final session = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!session.isProvider) {
        throw Exception('This account does not have provider access.');
      }
      widget.onLoginSuccess(session);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F4),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return Row(
            children: [
              if (wide) const Expanded(flex: 11, child: _BrandPanel()),
              Expanded(flex: wide ? 9 : 1, child: _buildForm(wide)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm(bool wide) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: wide ? 64 : 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!wide) ...[
                    const _CompactBrand(),
                    const SizedBox(height: 46),
                  ],
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      color: navy,
                      fontSize: 34,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sign in to manage customers, solar devices and payments.',
                    style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 34),
                  const _FieldLabel('Email address'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      hintText: 'provider@example.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return 'Enter your email address';
                      if (!email.contains('@')) return 'Enter a valid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const _FieldLabel('Password'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _hidePassword ? 'Show password' : 'Hide password',
                        onPressed: () => setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Enter your password' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF7C7C7)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFB42318), size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFF8A1C13)))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Sign in securely', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 17, color: Colors.blueGrey.shade500),
                      const SizedBox(width: 7),
                      Text('Protected provider access', style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF061A27), Color(0xFF0B463C), Color(0xFF0B7A55)],
          stops: [0, .62, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -100, right: -80, child: _glow(310, const Color(0x22A8D94F))),
          Positioned(bottom: -140, left: -100, child: _glow(380, const Color(0x1800D9A3))),
          const Padding(
            padding: EdgeInsets.all(64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _LogoMark(size: 48),
                    SizedBox(width: 14),
                    Text('Nigeria Solar PAYGO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19)),
                  ],
                ),
                Spacer(),
                _PanelLabel(),
                SizedBox(height: 22),
                Text(
                  'Powering access.\nManaging impact.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 48, height: 1.08, letterSpacing: -1.6),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 470,
                  child: Text(
                    'A secure, real-time view of your customers, connected solar systems and PAYGO operations.',
                    style: TextStyle(color: Color(0xFFBCD0C9), fontSize: 17, height: 1.55),
                  ),
                ),
                SizedBox(height: 42),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _FeaturePill(icon: Icons.bolt_rounded, label: 'Live operations'),
                    _FeaturePill(icon: Icons.verified_user_outlined, label: 'Secure access'),
                    _FeaturePill(icon: Icons.insights_rounded, label: 'Clear insights'),
                  ],
                ),
                Spacer(),
                Text('Reliable energy management for a brighter Nigeria.', style: TextStyle(color: Color(0xFF9CB5AD), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _glow(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _PanelLabel extends StatelessWidget {
  const _PanelLabel();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0x22FFFFFF),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: const Text(
          'PROVIDER COMMAND CENTRE',
          style: TextStyle(color: _ProviderLoginScreenState.lime, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.4),
        ),
      );
}

class _CompactBrand extends StatelessWidget {
  const _CompactBrand();
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LogoMark(size: 44),
        SizedBox(width: 12),
        Text('Nigeria Solar PAYGO', style: TextStyle(color: _ProviderLoginScreenState.navy, fontSize: 17, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  final double size;
  const _LogoMark({required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: _ProviderLoginScreenState.lime, borderRadius: BorderRadius.circular(size * .28)),
      child: Icon(Icons.solar_power_rounded, color: _ProviderLoginScreenState.navy, size: size * .58),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _ProviderLoginScreenState.lime),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(color: _ProviderLoginScreenState.navy, fontWeight: FontWeight.w700, fontSize: 13),
      );
}
