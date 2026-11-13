import 'package:solar_paygo_app/l10n/solar_language.dart';
import '../widgets/imad_id_logo.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../models/auth_session.dart';

const _navy = Color(0xFF101010);
const _green = Color(0xFF101820);
const _lime = Color(0xFFD8F3FB);
const _muted = Color(0xFF5F625F);
const _surface = Color(0xFFF3F5F5);

class CustomerPortalScreen extends StatefulWidget {
  const CustomerPortalScreen({
    super.key,
    required this.session,
    required this.onLogout,
  });

  final AuthSession session;
  final VoidCallback onLogout;

  @override
  State<CustomerPortalScreen> createState() => _CustomerPortalScreenState();
}

class _CustomerPortalScreenState extends State<CustomerPortalScreen> {
  String _generatedToken = '';
  String? _paymentReference;
  String _message = '';
  bool _isLoading = false;
  int? _buyingAmount;
  bool _showHistory = false;
  List<dynamic> _history = [];
  List<dynamic> _devices = [];
  int _selectedDeviceIndex = 0;

  Map<String, dynamic>? get _selectedDevice {
    if (_devices.isEmpty || _selectedDeviceIndex >= _devices.length) {
      return null;
    }
    return Map<String, dynamic>.from(_devices[_selectedDeviceIndex] as Map);
  }

  String get _cachePrefix => 'customer_${widget.session.userId}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialisePortal());
  }

  Map<String, String> get _authorisedHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${widget.session.accessToken}',
  };

  Future<void> _initialisePortal() async {
    await _restoreOfflineData();
    await _loadDevices();
    final params = Uri.base.queryParameters;
    final reference = params['reference'] ?? params['trxref'];
    if (reference != null && reference.isNotEmpty) {
      await verifyPayment(reference);
    }
  }

  Future<void> _restoreOfflineData() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    try {
      final devices = preferences.getString('${_cachePrefix}_devices');
      final history = preferences.getString('${_cachePrefix}_history');
      setState(() {
        _generatedToken =
            preferences.getString('${_cachePrefix}_last_token') ?? '';
        if (devices != null) {
          _devices = jsonDecode(devices) as List<dynamic>;
        }
        if (history != null) {
          _history = jsonDecode(history) as List<dynamic>;
        }
      });
    } catch (_) {
      // Ignore damaged cached data; fresh data will be requested below.
    }
  }

  Future<void> _cacheJson(String key, Object value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('${_cachePrefix}_$key', jsonEncode(value));
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/users/${widget.session.userId}/devices',
        ),
        headers: _authorisedHeaders,
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        final devices = data['devices'] as List<dynamic>? ?? [];
        setState(() {
          _devices = devices;
          _selectedDeviceIndex = 0;
          if (_devices.isEmpty) {
            _message =
                'Your account is ready. A provider must assign a solar device before you can purchase power.';
          }
        });
        await _cacheJson('devices', devices);
      } else {
        setState(
          () => _message = data['detail'] ?? 'Could not load your devices.',
        );
      }
    } catch (_) {
      if (mounted)
        setState(() => _message = 'Could not connect to the service.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _buyPower(int amount) async {
    setState(() {
      _isLoading = true;
      _buyingAmount = amount;
      _generatedToken = '';
      _message = '';
    });
    try {
      final device = _selectedDevice;
      if (device == null) throw Exception('No device assigned');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/create-payment'),
        headers: _authorisedHeaders,
        body: jsonEncode({
          'device_id': device['device_code'],
          'amount_paid': amount.toString(),
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final reference = data['reference'] as String;
        setState(() => _paymentReference = reference);
        await launchUrl(
          Uri.parse(data['authorization_url']),
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_self',
        );
        if (mounted) {
          setState(
            () => _message =
                'Opening secure checkout. After payment, you will return here for verification.',
          );
        }
      } else {
        setState(() => _message = data['detail'] ?? 'Could not start payment');
      }
    } catch (_) {
      if (mounted)
        setState(() => _message = 'Could not connect to the payment service.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _buyingAmount = null;
        });
      }
    }
  }

  Future<void> verifyPayment(String reference) async {
    setState(() {
      _isLoading = true;
      _message = 'Verifying your payment securely…';
    });
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/verify-payment'),
        headers: _authorisedHeaders,
        body: jsonEncode({'reference': reference}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final token = '${data['token']}';
        setState(() {
          _generatedToken = token;
          _message = data['message'] ?? 'Payment verified successfully';
        });
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString('${_cachePrefix}_last_token', token);
      } else {
        setState(
          () => _message = data['detail'] ?? 'Payment verification failed',
        );
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
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/history'),
        headers: _authorisedHeaders,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final history = data['history'] as List<dynamic>? ?? [];
        setState(() {
          _history = history;
          _showHistory = true;
          _message = _history.isEmpty ? 'No purchases found.' : '';
        });
        await _cacheJson('history', history);
      } else {
        setState(() => _message = 'Could not load purchase history.');
      }
    } catch (_) {
      if (mounted)
        setState(() => _message = 'Could not connect to the service.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _Header(
            customerName: widget.session.name,
            onHistory: _isLoading ? null : _loadHistory,
            onLogout: widget.onLogout,
          ),
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 3, color: _lime),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WelcomeBanner(customerName: widget.session.name),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 850;
                          final plans = _PlansCard(
                            buyingAmount: _buyingAmount,
                            enabled: _selectedDevice != null,
                            onBuy: _buyPower,
                          );
                          final device = _DeviceCard(
                            devices: _devices,
                            selectedIndex: _selectedDeviceIndex,
                            onSelected: (index) {
                              setState(() => _selectedDeviceIndex = index);
                            },
                          );
                          return wide
                              ? const SizedBox.shrink()
                              : Column(
                                  children: [
                                    device,
                                    const SizedBox(height: 20),
                                    plans,
                                  ],
                                );
                        },
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 850)
                            return const SizedBox.shrink();
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: _DeviceCard(
                                  devices: _devices,
                                  selectedIndex: _selectedDeviceIndex,
                                  onSelected: (index) {
                                    setState(
                                      () => _selectedDeviceIndex = index,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 22),
                              Expanded(
                                flex: 6,
                                child: _PlansCard(
                                  buyingAmount: _buyingAmount,
                                  enabled: _selectedDevice != null,
                                  onBuy: _buyPower,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (_message.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _Notice(message: _message),
                      ],
                      if (_paymentReference != null) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => verifyPayment(_paymentReference!),
                            icon: const Icon(Icons.verified_user_outlined),
                            label: const SolarText(
                              'I have completed payment — verify now',
                            ),
                          ),
                        ),
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
  const _Header({
    required this.customerName,
    required this.onHistory,
    required this.onLogout,
  });

  final String customerName;
  final VoidCallback? onHistory;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    return Container(
      height: 78,
      color: _lime,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              return Row(
                children: [
                  const ImadIdLogo(size: 44),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: SolarText(
                      'SolarID',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (compact)
                    PopupMenuButton<String>(
                      tooltip: SolarLanguage.instance.translate('Account menu'),
                      color: Colors.white,
                      iconColor: _navy,
                      onSelected: (value) {
                        if (value == 'history') onHistory?.call();
                        if (value == 'logout') onLogout();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'history',
                          child: SolarText('Purchase history'),
                        ),
                        PopupMenuItem(value: 'logout', child: SolarText('Sign out')),
                      ],
                    )
                  else ...[
                    TextButton.icon(
                      onPressed: onHistory,
                      icon: const Icon(Icons.receipt_long_outlined, size: 20),
                      label: const SolarText('Purchase history'),
                      style: TextButton.styleFrom(foregroundColor: _navy),
                    ),
                    const SizedBox(width: 10),
                    Container(width: 1, height: 28, color: Colors.black26),
                    const SizedBox(width: 12),
                    SolarText(
                      customerName.split(' ').first,
                      style: const TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: onLogout,
                      tooltip: SolarLanguage.instance.translate('Sign out'),
                      color: _navy,
                      icon: const Icon(Icons.logout),
                    ),
                  ],
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
  const _WelcomeBanner({required this.customerName});

  final String customerName;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF101010), Color(0xFF292929)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 22,
        children: [
          SizedBox(
            width: 620,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SolarText(
                  'Welcome, ${customerName.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                const SolarText(
                  'Manage your solar device, buy secure credit and receive your activation token instantly.',
                  style: TextStyle(
                    color: Color(0xFFD8D8D8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _lime,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_outlined, color: _navy),
                SizedBox(width: 9),
                SolarText(
                  'Secure PAYGO service',
                  style: TextStyle(color: _navy, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.devices,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<dynamic> devices;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    if (devices.isEmpty) {
      return const _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.solar_power_outlined,
              title: 'My solar device',
              subtitle: 'Device assignment',
            ),
            SizedBox(height: 28),
            Icon(Icons.add_link, size: 38, color: _green),
            SizedBox(height: 14),
            SolarText(
              'No device assigned yet',
              style: TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 7),
            SolarText(
              'Your provider will link your registered solar device to this account.',
              style: TextStyle(color: _muted, height: 1.5),
            ),
          ],
        ),
      );
    }

    final device = Map<String, dynamic>.from(devices[selectedIndex] as Map);
    final status = '${device['status'] ?? 'locked'}'.toLowerCase();
    final active = status == 'active';
    final credit = (device['remaining_credit'] as num?)?.toDouble() ?? 0;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.solar_power_outlined,
            title: 'My solar device',
            subtitle: devices.length == 1
                ? 'Account-linked system'
                : '${devices.length} linked systems',
          ),
          if (devices.length > 1) ...[
            const SizedBox(height: 18),
            DropdownButtonFormField<int>(
              initialValue: selectedIndex,
              decoration: const SolarInputDecoration(labelText: 'Selected device'),
              items: [
                for (var index = 0; index < devices.length; index++)
                  DropdownMenuItem(
                    value: index,
                    child: SolarText(
                      '${devices[index]['device_name']} · ${devices[index]['device_code']}',
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onSelected(value);
              },
            ),
          ],
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'DEVICE ID',
                    value: '${device['device_code']}',
                  ),
                ),
                _StatusPill(active: active),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'DEVICE NAME',
                  value: '${device['device_name'] ?? 'Solar Device'}',
                  icon: Icons.home_outlined,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'REMAINING CREDIT',
                  value: '${credit.toStringAsFixed(0)} day(s)',
                  icon: Icons.bolt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SolarText(
            active
                ? 'Your solar device is active and ready to use.'
                : 'Purchase credit and enter the token to activate this device.',
            style: const TextStyle(color: _muted, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _PlansCard extends StatelessWidget {
  const _PlansCard({
    required this.buyingAmount,
    required this.enabled,
    required this.onBuy,
  });
  final int? buyingAmount;
  final bool enabled;
  final ValueChanged<int> onBuy;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.flash_on_outlined,
            title: 'Choose a power plan',
            subtitle: 'Simple, transparent pricing',
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 850
                  ? 3
                  : constraints.maxWidth >= 510
                  ? 2
                  : 1;
              final width =
                  (constraints.maxWidth - 14 * (columns - 1)) / columns;
              final day = _PlanTile(
                title: 'Daily power',
                period: '1 day access',
                price: '₦1,000',
                icon: Icons.wb_sunny_outlined,
                onPressed: !enabled || buyingAmount == 1000
                    ? null
                    : () => onBuy(1000),
              );
              final week = _PlanTile(
                title: 'Weekly power',
                period: '7 days access',
                price: '₦7,000',
                icon: Icons.date_range_outlined,
                featured: true,
                onPressed: !enabled || buyingAmount == 7000
                    ? null
                    : () => onBuy(7000),
              );
              final month = _PlanTile(
                title: 'Monthly power',
                period: '30 days access',
                price: '\u20A630,000',
                icon: Icons.calendar_month_outlined,
                onPressed: !enabled || buyingAmount == 30000
                    ? null
                    : () => onBuy(30000),
              );
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(width: width, child: day),
                  SizedBox(width: width, child: week),
                  SizedBox(width: width, child: month),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(Icons.lock_outline, size: 17, color: _green),
              SizedBox(width: 8),
              Expanded(
                child: SolarText(
                  'Payments are securely processed by Paystack.',
                  style: TextStyle(color: _muted, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatefulWidget {
  const _PlanTile({
    required this.title,
    required this.period,
    required this.price,
    required this.icon,
    required this.onPressed,
    this.featured = false,
  });
  final String title;
  final String period;
  final String price;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool featured;

  @override
  State<_PlanTile> createState() => _PlanTileState();
}

class _PlanTileState extends State<_PlanTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        transform: Matrix4.translationValues(0, hovered ? -7 : 0, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: hovered || widget.featured ? _lime : const Color(0xFFF3F5F5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hovered || widget.featured ? _navy : const Color(0xFFD1DDE1),
            width: widget.featured ? 2 : 1,
          ),
          boxShadow: hovered
              ? const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: _navy),
                const Spacer(),
                if (widget.featured)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _navy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const SolarText(
                      'BEST VALUE',
                      style: TextStyle(
                        color: _lime,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            SolarText(
              widget.title,
              style: const TextStyle(
                color: _navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            SolarText(
              widget.period,
              style: const TextStyle(color: _muted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SolarText(
              widget.price,
              style: const TextStyle(
                color: _navy,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onPressed,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const SolarText('Buy power securely'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F6FA),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF9FD6E5)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: _green),
        const SizedBox(width: 12),
        Expanded(
          child: SolarText(
            message,
            style: const TextStyle(color: _navy, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  ); }
}

class _TokenCard extends StatelessWidget {
  const _TokenCard({required this.token});
  final String token;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      color: _navy,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 18,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SolarText(
              'YOUR ACTIVATION TOKEN',
              style: TextStyle(
                color: Color(0xFFB8DDE7),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            SolarText(
              token, translate: false,
              style: const TextStyle(
                color: _lime,
                fontSize: 29,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 7),
            const SolarText(
              'Enter this code on your solar device.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: token));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: SolarText('Token copied')));
          },
          icon: const Icon(Icons.copy_outlined),
          label: const SolarText('Copy token'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white38),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
      ],
    ),
  ); }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.items});
  final List<dynamic> items;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.receipt_long_outlined,
          title: 'Purchase history',
          subtitle:
              '${items.length} transaction${items.length == 1 ? '' : 's'}',
        ),
        const SizedBox(height: 18),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SolarText(
                'No purchases to display.',
                style: TextStyle(color: _muted),
              ),
            ),
          )
        else
          ...items.map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE7ECEA))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F3F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      (item['token'] ?? '').toString().trim().isNotEmpty
                          ? Icons.check
                          : Icons.pending_outlined,
                      color: (item['token'] ?? '').toString().trim().isNotEmpty
                          ? _green
                          : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SolarText(
                          (item['token'] ?? '').toString().trim().isNotEmpty
    ?                         'Token ${item['token']}'
    :                         'No activation token issued',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SolarText(
                          '${item['days_added'] ?? '—'} day(s) • ${item['reference'] ?? 'No reference'}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SolarText(
                    '₦${item['amount_paid'] ?? '—'}',
                    style: const TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  ); }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFE1E8E5)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D062433),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: child,
  ); }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE1F3F8),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: _green),
      ),
      const SizedBox(width: 13),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SolarText(
              title,
              style: const TextStyle(
                color: _navy,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            SolarText(subtitle, style: const TextStyle(color: _muted, fontSize: 13)),
          ],
        ),
      ),
    ],
  ); }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.icon});
  final String label;
  final String value;
  final IconData? icon;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SolarText(
        label,
        style: const TextStyle(
          color: _muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: .7,
        ),
      ),
      const SizedBox(height: 7),
      Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: _green),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: SolarText(
              value,
              style: const TextStyle(
                color: _navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    ],
  ); }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final color = active ? _green : const Color(0xFF52656D);
    final background = active
        ? const Color(0xFFE1F3F8)
        : const Color(0xFFE9EEF0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 7),
          SolarText(
            active ? 'ACTIVE' : 'LOCKED',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
