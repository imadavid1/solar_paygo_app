import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';

const _navy = Color(0xFF062433);
const _green = Color(0xFF0B7A55);
const _lime = Color(0xFFA8E64B);
const _muted = Color(0xFF6B7F78);
const _surface = Color(0xFFF3F7F5);

class CustomerPortalScreen extends StatefulWidget {
  const CustomerPortalScreen({super.key});

  @override
  State<CustomerPortalScreen> createState() => _CustomerPortalScreenState();
}

class _CustomerPortalScreenState extends State<CustomerPortalScreen> {
  String _generatedToken = '';
  String _message = '';
  String? _accessToken;
  bool _isLoading = false;
  bool _showHistory = false;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    final params = Uri.base.queryParameters;
    final reference = params['reference'] ?? params['trxref'];
    if (reference != null && reference.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => verifyPayment(reference));
    }
  }

  Future<void> _loginCustomer() async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'securetest@example.com',
        'password': 'TestPassword123',
      }),
    );
    if (response.statusCode == 200) {
      _accessToken = jsonDecode(response.body)['access_token'];
    }
  }

  Future<void> _buyPower(int amount) async {
    setState(() {
      _isLoading = true;
      _generatedToken = '';
      _message = '';
    });
    try {
      await _loginCustomer();
      if (_accessToken == null || _accessToken!.isEmpty) {
        throw Exception('Login failed');
      }
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/create-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'device_id': 'TEST-DEV-999',
          'amount_paid': amount.toString(),
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await launchUrl(
          Uri.parse(data['authorization_url']),
          mode: LaunchMode.externalApplication,
        );
        if (mounted) {
          setState(() => _message =
              'Secure payment opened in a new window. Complete it to receive your token.');
        }
      } else {
        setState(() => _message = data['detail'] ?? 'Could not start payment');
      }
    } catch (_) {
      if (mounted) setState(() => _message = 'Could not connect to the payment service.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> verifyPayment(String reference) async {
    setState(() {
      _isLoading = true;
      _message = 'Verifying your payment securely…';
    });
    try {
      await _loginCustomer();
      if (_accessToken == null || _accessToken!.isEmpty) {
        throw Exception('Login failed');
      }
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/verify-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({'reference': reference}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _generatedToken = '${data['token']}';
          _message = data['message'] ?? 'Payment verified successfully';
        });
      } else {
        setState(() => _message = data['detail'] ?? 'Payment verification failed');
      }
    } catch (_) {
      if (mounted) setState(() => _message = 'Could not verify payment.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _message = 'Loading your purchases…';
    });
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/history'));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _history = data['history'] ?? [];
          _showHistory = true;
          _message = _history.isEmpty ? 'No purchases found.' : '';
        });
      } else {
        setState(() => _message = 'Could not load purchase history.');
      }
    } catch (_) {
      if (mounted) setState(() => _message = 'Could not connect to the service.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _Header(onHistory: _isLoading ? null : _loadHistory),
          if (_isLoading) const LinearProgressIndicator(minHeight: 3, color: _lime),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _WelcomeBanner(),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 850;
                          final plans = _PlansCard(
                            loading: _isLoading,
                            onBuy: _buyPower,
                          );
                          const device = _DeviceCard();
                          return wide
                              ? const SizedBox.shrink()
                              : Column(children: [device, const SizedBox(height: 20), plans]);
                        },
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 850) return const SizedBox.shrink();
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(flex: 4, child: _DeviceCard()),
                              const SizedBox(width: 22),
                              Expanded(
                                flex: 6,
                                child: _PlansCard(loading: _isLoading, onBuy: _buyPower),
                              ),
                            ],
                          );
                        },
                      ),
                      if (_message.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _Notice(message: _message),
                      ],
                      if (_generatedToken.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _TokenCard(token: _generatedToken),
                      ],
                      if (_showHistory) ...[
                        const SizedBox(height: 28),
                        _HistoryCard(items: _history),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onHistory});
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      color: _navy,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              return Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: _lime, borderRadius: BorderRadius.circular(13)),
                    child: const Icon(Icons.solar_power, color: _navy),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Nigeria Solar PAYGO',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                  ),
                  if (compact)
                    IconButton(
                      onPressed: onHistory,
                      tooltip: 'Purchase history',
                      color: Colors.white,
                      icon: const Icon(Icons.receipt_long_outlined),
                    )
                  else
                    TextButton.icon(
                      onPressed: onHistory,
                      icon: const Icon(Icons.receipt_long_outlined, size: 20),
                      label: const Text('Purchase history'),
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0A4A43), Color(0xFF0B7A55)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x220B7A55), blurRadius: 28, offset: Offset(0, 12))],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 22,
        children: [
          const SizedBox(
            width: 620,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Power your day with confidence',
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                SizedBox(height: 9),
                Text('Buy secure solar credit and receive your activation token instantly.',
                    style: TextStyle(color: Color(0xFFD7E9E3), fontSize: 16, height: 1.5)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: const Color(0x22FFFFFF), borderRadius: BorderRadius.circular(14)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_outlined, color: _lime),
                SizedBox(width: 9),
                Text('Secure PAYGO service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.solar_power_outlined, title: 'My solar device', subtitle: 'Live system summary'),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFFF3F7F5), borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Expanded(child: _Metric(label: 'DEVICE ID', value: 'TEST-DEV-999')),
                _StatusPill(),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Row(
            children: [
              Expanded(child: _Metric(label: 'BATTERY HEALTH', value: '82%', icon: Icons.battery_charging_full)),
              Expanded(child: _Metric(label: 'CURRENT USAGE', value: '120W', icon: Icons.bolt)),
            ],
          ),
          const SizedBox(height: 20),
          const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: LinearProgressIndicator(value: .82, minHeight: 9, color: _green, backgroundColor: Color(0xFFE6EEEB)),
          ),
          const SizedBox(height: 10),
          const Text('Battery operating within a healthy range', style: TextStyle(color: _muted, fontSize: 13)),
        ],
      ),
    );
  }
}

class _PlansCard extends StatelessWidget {
  const _PlansCard({required this.loading, required this.onBuy});
  final bool loading;
  final ValueChanged<int> onBuy;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.flash_on_outlined, title: 'Choose a power plan', subtitle: 'Simple, transparent pricing'),
          const SizedBox(height: 22),
          LayoutBuilder(builder: (context, constraints) {
            final stack = constraints.maxWidth < 510;
            final day = _PlanTile(
              title: 'Daily power',
              period: '1 day access',
              price: '₦1,000',
              icon: Icons.wb_sunny_outlined,
              onPressed: loading ? null : () => onBuy(1000),
            );
            final week = _PlanTile(
              title: 'Weekly power',
              period: '7 days access',
              price: '₦7,000',
              icon: Icons.calendar_month_outlined,
              featured: true,
              onPressed: loading ? null : () => onBuy(7000),
            );
            return stack
                ? Column(children: [day, const SizedBox(height: 14), week])
                : Row(children: [Expanded(child: day), const SizedBox(width: 14), Expanded(child: week)]);
          }),
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(Icons.lock_outline, size: 17, color: _green),
              SizedBox(width: 8),
              Expanded(child: Text('Payments are securely processed by Paystack.', style: TextStyle(color: _muted, fontSize: 13))),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.title, required this.period, required this.price, required this.icon, required this.onPressed, this.featured = false});
  final String title;
  final String period;
  final String price;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: featured ? const Color(0xFFF1FBE6) : const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: featured ? const Color(0xFFCBEAA1) : const Color(0xFFE1E9E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: featured ? _green : const Color(0xFFE59B24)),
            const Spacer(),
            if (featured)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(color: _lime, borderRadius: BorderRadius.circular(20)),
                child: const Text('BEST VALUE', style: TextStyle(color: _navy, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
          ]),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(color: _navy, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(period, style: const TextStyle(color: _muted, fontSize: 13)),
          const SizedBox(height: 16),
          Text(price, style: const TextStyle(color: _navy, fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Buy power securely'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFE7F5EF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBFE3D4))),
        child: Row(children: [const Icon(Icons.info_outline, color: _green), const SizedBox(width: 12), Expanded(child: Text(message, style: const TextStyle(color: _navy, fontWeight: FontWeight.w600)))]),
      );
}

class _TokenCard extends StatelessWidget {
  const _TokenCard({required this.token});
  final String token;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(22)),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 18,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('YOUR ACTIVATION TOKEN', style: TextStyle(color: Color(0xFF9DB4AD), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
              const SizedBox(height: 10),
              Text(token, style: const TextStyle(color: _lime, fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: 4)),
              const SizedBox(height: 7),
              const Text('Enter this code on your solar device.', style: TextStyle(color: Colors.white70)),
            ]),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: token));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token copied')));
              },
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy token'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
            ),
          ],
        ),
      );
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.items});
  final List<dynamic> items;
  @override
  Widget build(BuildContext context) => _Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SectionTitle(icon: Icons.receipt_long_outlined, title: 'Purchase history', subtitle: '${items.length} transaction${items.length == 1 ? '' : 's'}'),
          const SizedBox(height: 18),
          if (items.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('No purchases to display.', style: TextStyle(color: _muted))))
          else
            ...items.map((item) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE7ECEA)))),
                  child: Row(children: [
                    Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFE7F5EF), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.check, color: _green)),
                    const SizedBox(width: 13),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Token ${item['token'] ?? '—'}', overflow: TextOverflow.ellipsis, style: const TextStyle(color: _navy, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('${item['days_added'] ?? '—'} day(s) • ${item['reference'] ?? 'No reference'}', overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 13)),
                    ])),
                    const SizedBox(width: 10),
                    Text('₦${item['amount_paid'] ?? '—'}', style: const TextStyle(color: _navy, fontWeight: FontWeight.w800)),
                  ]),
                )),
        ]),
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE1E8E5)), boxShadow: const [BoxShadow(color: Color(0x0D062433), blurRadius: 20, offset: Offset(0, 8))]),
        child: child,
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFE7F5EF), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: _green)),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _navy, fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 13))])),
      ]);
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.icon});
  final String label;
  final String value;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: .7)),
        const SizedBox(height: 7),
        Row(children: [if (icon != null) ...[Icon(icon, size: 20, color: _green), const SizedBox(width: 7)], Flexible(child: Text(value, style: const TextStyle(color: _navy, fontSize: 17, fontWeight: FontWeight.w800)))]),
      ]);
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(color: const Color(0xFFE2F5EC), borderRadius: BorderRadius.circular(20)),
        child: const Row(children: [Icon(Icons.circle, size: 8, color: _green), SizedBox(width: 7), Text('SYSTEM ONLINE', style: TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w800))]),
      );
}
