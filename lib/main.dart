import 'package:flutter/material.dart';

import 'models/auth_session.dart';
import 'screens/customer_portal_screen.dart';
import 'screens/provider_dashboard_screen.dart';
import 'screens/provider_login_screen.dart';

void main() => runApp(const SolarApp());

class SolarApp extends StatefulWidget {
  const SolarApp({super.key});

  @override
  State<SolarApp> createState() => _SolarAppState();
}

class _SolarAppState extends State<SolarApp> {
  AuthSession? _providerSession;

  bool get _isProviderPortal {
    return Uri.base.queryParameters['portal'] == 'provider';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nigeria Solar PAYGO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B6E4F),
          primary: const Color(0xFF0B7A55),
          surface: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F6F5),
        fontFamily: 'Segoe UI',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD9E3DF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD9E3DF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF0B7A55),
              width: 1.5,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0B7A55),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: _isProviderPortal
          ? _providerSession == null
              ? ProviderLoginScreen(
                  onLoginSuccess: (session) {
                    setState(() {
                      _providerSession = session;
                    });
                  },
                )
              : ProviderDashboardScreen(
                  session: _providerSession!,
                  onLogout: () {
                    setState(() {
                      _providerSession = null;
                    });
                  },
                )
          : const CustomerPortalScreen(),
    );
  }
}
  
