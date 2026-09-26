import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'models/auth_session.dart';
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
          : const PurchasePowerScreen(),
    );
  }
}

class PurchasePowerScreen extends StatefulWidget {
  const PurchasePowerScreen({super.key});

  @override
  State<PurchasePowerScreen> createState() => _PurchasePowerScreenState();
}

class _PurchasePowerScreenState extends State<PurchasePowerScreen> {
  String _generatedToken = "";
  String _message = "";
  String? _accessToken;
  bool _isLoading = false;
  List<dynamic> _history = [];
 @override
 void initState() {
  super.initState();

  final params = Uri.base.queryParameters;
  final reference = params['reference'] ?? params['trxref'];

  if (reference != null && reference.isNotEmpty) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verifyPayment(reference);
    });
   }
  }
  Future<void> loginCustomer() async {
  final response = await http.post(
    Uri.parse('https://solar-backend-q2fo.onrender.com/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': 'securetest@example.com',
      'password': 'TestPassword123',
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    _accessToken = data['access_token'];
  }
}

  Future<void> buyPower(int amount) async {
  setState(() {
    _isLoading = true;
    _generatedToken = "";
    _message = "";
  });

  try {
    await loginCustomer();
    if (_accessToken == null || _accessToken!.isEmpty) {
      throw Exception("Login failed");
}
    final createResponse = await http.post(
  Uri.parse('https://solar-backend-q2fo.onrender.com/create-payment'),
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer $_accessToken",
  },
  body: jsonEncode({
    "device_id": "TEST-DEV-999",
    "amount_paid": amount.toString(),
  }),
);

    final createData = jsonDecode(createResponse.body);

    if (createResponse.statusCode == 200) {
      final authorizationUrl = createData['authorization_url'];

      final Uri url = Uri.parse(authorizationUrl);

      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      setState(() {
        _message = "Payment page opened. After payment, click Buy again to verify.";
      });
    } else {
      setState(() {
        _message = createData['detail'] ?? "Could not start payment";
      });
    }
  } catch (e) {
    setState(() {
      _message = "Could not connect to backend.";
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
Future<void> verifyPayment(String reference) async {
  setState(() {
    _isLoading = true;
    _message = "Verifying payment...";
  });

  try {
    await loginCustomer();

  if (_accessToken == null || _accessToken!.isEmpty) {
    throw Exception("Login failed");
  }
    final verifyResponse = await http.post(
      Uri.parse('https://solar-backend-q2fo.onrender.com/verify-payment'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
},
      body: jsonEncode({
        "reference": reference,
      }),
    );
    final verifyData = jsonDecode(verifyResponse.body);

    if (verifyResponse.statusCode == 200) {

  setState(() {
    _generatedToken = verifyData['token'];
    _message = verifyData['message'];
  });

  } else {
      setState(() {
        _message = verifyData['detail'] ?? "Payment verification failed";
      });
    }
  } catch (e) {
    setState(() {
      _message = "Could not verify payment.";
    });

  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
Future<void> loadHistory() async {
  setState(() {
    _isLoading = true;
    _message = "Loading history...";
  });

  try {
    final response = await http.get(
      Uri.parse('https://solar-backend-q2fo.onrender.com/history')
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _history = data['history'];
        _message = "History loaded";
      });
    } else {
      setState(() {
        _message = "Could not load history";
      });
    }
  } catch (e) {
    setState(() {
      _message = "Could not connect to backend.";
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text("Buy Solar Power"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      
          body: ListView(
           padding: const EdgeInsets.all(20),
           children: [
            const Icon(Icons.wb_sunny, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              "Nigeria Solar PAYGO",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Device ID: TEST-DEV-999",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : () => buyPower(1000),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text("Buy 1 Day (₦1,000)"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : () => buyPower(7000),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Buy 1 Week (₦7,000)"),
            ),
          const SizedBox(height: 10),
          ElevatedButton(
           onPressed: _isLoading ? null : loadHistory,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
           child: const Text("View Purchase History"),
         ),
         const SizedBox(height: 20),

         SizedBox(
  width: 320,
  child: Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.battery_charging_full,
            size: 50,
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          const Text(
            "Battery Health",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          const Text("Battery: 82%", style: TextStyle(fontSize: 16)),
          const Text("Current Usage: 120W", style: TextStyle(fontSize: 16)),
          const Text(
            "Status: Good",
            style: TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  ),
),

            const SizedBox(height: 40),
            if (_isLoading) const CircularProgressIndicator(),
            if (_history.isNotEmpty) ...[
  const SizedBox(height: 20),
  const Text(
    "PURCHASE HISTORY",
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.grey,
    ),
  ),
  const SizedBox(height: 10),
  ..._history.map((item) {
    return Card(
      child: ListTile(
        title: Text("Token: ${item['token']}"),
        subtitle: Text(
          "Amount: ${item['amount_paid']} | Days: ${item['days_added']}\nReference: ${item['reference']}",
        ),
      ),
    );
  }),
],
            if (_message.isNotEmpty)
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                fontSize: 16,
                 color: Colors.green,
                 fontWeight: FontWeight.bold,
               ),
              ),
  
            if (_generatedToken.isNotEmpty) ...[

                 const Text(
                "YOUR TOKEN:",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                _generatedToken,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.green,
                ),
              ),
                     const SizedBox(height: 10),
        ],
      ],
    ), // ListView
  ); // Scaffold
}
}







        
      
  
