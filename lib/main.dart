import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const SolarApp());

class SolarApp extends StatelessWidget {
  const SolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PurchasePowerScreen(),
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
  String _paymentReference = "";
  bool _isLoading = false;
  List<dynamic> _history = [];
  @override
void initState() {
  super.initState();

  final reference = Uri.base.queryParameters['reference'];

  if (reference != null && reference.isNotEmpty) {
    verifyPayment(reference);
  }
}

  Future<void> buyPower(int amount) async {
  setState(() {
    _isLoading = true;
    _generatedToken = "";
    _message = "";
    _paymentReference = "";
  });

  try {
    final createResponse = await http.post(
      Uri.parse('https://solar-backend-q2fo.onrender.com/create-payment'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "device_id": "DEV001",
        "amount_paid": amount,
      }),
    );

    final createData = jsonDecode(createResponse.body);

    if (createResponse.statusCode == 200) {
      final authorizationUrl = createData['authorization_url'];
      final reference = createData['reference'];

      _paymentReference = reference;

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
    final verifyResponse = await http.post(
      Uri.parse('https://solar-backend-q2fo.onrender.com/verify-payment'),
      headers: {"Content-Type": "application/json"},
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
              "Device ID: DEV001",
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







        
      
  
