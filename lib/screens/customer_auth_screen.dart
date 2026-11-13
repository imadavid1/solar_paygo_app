import 'package:solar_paygo_app/l10n/solar_language.dart';
import '../widgets/imad_id_logo.dart';
import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../services/auth_service.dart';

const ink = Color(0xFF102F46);
const surface = Color(0xFFFFFFFF);
const gold = Color(0xFF78CBE5);
const goldLight = Color(0xFF102F46);
const text = Color(0xFF102F46);
const muted = Color(0xFF626262);

class CustomerAuthScreen extends StatefulWidget {
  const CustomerAuthScreen({
    super.key,
    required this.onAuthenticated,
    this.onBack,
  });
  final ValueChanged<AuthSession> onAuthenticated;
  final VoidCallback? onBack;

  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  bool registering = false, busy = false, hidePassword = true;
  String error = '';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    if (registering && (value == null || value.trim().length < 2)) {
      return 'Enter your full name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value?.trim() ?? '')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < 8) return 'Use at least 8 characters';
    if (registering &&
        (!RegExp(r'[A-Z]').hasMatch(password) ||
            !RegExp(r'[a-z]').hasMatch(password) ||
            !RegExp(r'\d').hasMatch(password))) {
      return 'Include uppercase, lowercase and a number';
    }
    return null;
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = '';
    });
    try {
      if (registering) {
        await authService.register(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
        );
      }
      final session = await authService.login(
        email: emailController.text,
        password: passwordController.text,
      );
      if (!session.isCustomer) {
        throw Exception('Please use the provider portal for this account');
      }
      widget.onAuthenticated(session);
    } catch (caught) {
      if (mounted) {
        setState(
          () => error = caught.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void switchMode() {
    setState(() {
      registering = !registering;
      error = '';
      formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FD),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 940;
            final form = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 470),
              child: _AuthCard(child: buildForm()),
            );
            if (!wide) {
              return Stack(
                children: [
                  const Positioned.fill(child: _SolarBackdrop()),
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.white.withValues(alpha: .78),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: form,
                    ),
                  ),
                ],
              );
            }
            return Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  const Expanded(flex: 12, child: _AuthHero()),
                  const SizedBox(width: 22),
                  Expanded(
                    flex: 8,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 20,
                        ),
                        child: form,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.onBack != null) ...[
            TextButton.icon(
              onPressed: busy ? null : widget.onBack,
              style: TextButton.styleFrom(
                foregroundColor: ink,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const SolarText(
                'Back to website',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 20),
          ],
          const _Brand(),
          const SizedBox(height: 34),
          SolarText(
            registering ? 'Create your account' : 'Welcome back',
            style: const TextStyle(
              color: text,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -.8,
            ),
          ),
          const SizedBox(height: 10),
          SolarText(
            registering
                ? 'Join SolarID and take control of your energy.'
                : 'Access your device, energy credit and secure tokens.',
            style: const TextStyle(color: muted, fontSize: 14, height: 1.55),
          ),
          const SizedBox(height: 27),
          if (registering) ...[
            const _FieldLabel('Full name'),
            darkField(
              nameController,
              validateName,
              'Your full name',
              Icons.person_outline,
            ),
            const SizedBox(height: 16),
          ],
          const _FieldLabel('Email address'),
          darkField(
            emailController,
            validateEmail,
            'name@example.com',
            Icons.alternate_email_rounded,
            type: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Password'),
          TextFormField(
            controller: passwordController,
            validator: SolarLanguage.validation<String>(validatePassword),
            obscureText: hidePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!busy) submit();
            },
            style: const TextStyle(color: text),
            decoration: decoration(
              registering ? 'Minimum 8 characters' : 'Your password',
              Icons.lock_outline_rounded,
              suffix: IconButton(
                onPressed: () => setState(() => hidePassword = !hidePassword),
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: muted,
                ),
              ),
            ),
          ),
          if (error.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECE8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9A69B)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFB83927)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SolarText(
                      error,
                      style: const TextStyle(
                        color: Color(0xFF8A2A1D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 23),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: busy ? null : submit,
              style: FilledButton.styleFrom(
                foregroundColor: ink,
                backgroundColor: gold,
                disabledBackgroundColor: const Color(0xFF506777),
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              child: busy
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: ink,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SolarText(registering ? 'Create secure account' : 'Sign in'),
                        const SizedBox(width: 9),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: busy ? null : switchMode,
              child: SolarText(
                registering
                    ? 'Already registered? Sign in'
                    : 'New customer? Create an account',
                style: const TextStyle(
                  color: goldLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 16, color: gold),
              SizedBox(width: 7),
              Flexible(
                child: SolarText(
                  'Protected account  •  Encrypted connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget darkField(
    TextEditingController controller,
    String? Function(String?) validator,
    String hint,
    IconData icon, {
    TextInputType? type,
  }) {
    return TextFormField(
      controller: controller,
      validator: SolarLanguage.validation<String>(validator),
      keyboardType: type,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: text),
      decoration: decoration(hint, icon),
    );
  }

  InputDecoration decoration(String hint, IconData icon, {Widget? suffix}) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: color, width: width),
        );
    return SolarInputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF777777)),
      prefixIcon: Icon(icon, color: muted, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF0F8FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      enabledBorder: border(const Color(0xFFC9DFEB)),
      focusedBorder: border(gold, 1.5),
      errorBorder: border(const Color(0xFFFF7865)),
      focusedErrorBorder: border(const Color(0xFFFF7865), 1.5),
      errorStyle: const TextStyle(color: Color(0xFFB83927)),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    padding: const EdgeInsets.fromLTRB(42, 38, 42, 34),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFFC9DFEB)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x16000000),
          blurRadius: 28,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: child,
  ); }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Row(
    children: [
      const ImadIdLogo(size: 45),
      const SizedBox(width: 12),
      const Expanded(
        child: SolarText(
          'SolarID',
          style: TextStyle(
            color: text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ],
  ); }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: SolarText(
      label,
      style: const TextStyle(
        color: ink,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
  ); }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero();
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: Stack(
      fit: StackFit.expand,
      children: [
        const _SolarBackdrop(),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                ink.withValues(alpha: .10),
                ink.withValues(alpha: .78),
              ],
              stops: const [0, .50, 1],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, color: gold, size: 19),
                  SizedBox(width: 8),
                  SolarText(
                    'POWERING EVERYDAY POSSIBILITY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: .14),
                  border: Border.all(color: gold.withValues(alpha: .42)),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const SolarText(
                  'SMART SOLAR ACCESS',
                  style: TextStyle(
                    color: goldLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 21),
              const SolarText(
                'Power your home.\nLive without limits.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 54,
                  height: .98,
                  letterSpacing: -2.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              const SizedBox(
                width: 510,
                child: SolarText(
                  'Purchase power, receive secure activation tokens and monitor your solar device from one beautifully simple account.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.48,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 29),
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _HeroPoint(Icons.verified_user_outlined, 'Secure payments'),
                  _HeroPoint(Icons.bolt_rounded, 'Instant tokens'),
                  _HeroPoint(Icons.insights_rounded, 'Clear history'),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ); }
}

class _HeroPoint extends StatelessWidget {
  const _HeroPoint(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.white),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: gold),
        const SizedBox(width: 7),
        SolarText(
          label,
          style: const TextStyle(
            color: ink,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  ); }
}

class _SolarBackdrop extends StatelessWidget {
  const _SolarBackdrop();
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Image.asset(
    'assets/images/solar_home_hero.png',
    fit: BoxFit.cover,
    alignment: Alignment.center,
  ); }
}
