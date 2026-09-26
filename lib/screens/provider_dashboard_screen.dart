import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/provider_models.dart';
import '../services/provider_service.dart';

class ProviderDashboardScreen extends StatefulWidget {
  final AuthSession session;
  final VoidCallback onLogout;
  const ProviderDashboardScreen({super.key, required this.session, required this.onLogout});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  static const _navy = Color(0xFF071D2B);
  static const _green = Color(0xFF0B7A55);
  static const _lime = Color(0xFFA8D94F);
  static const _canvas = Color(0xFFF3F6F5);

  late final ProviderService _service;
  final _searchController = TextEditingController();
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error;
  String _query = '';
  ProviderSummary? _summary;
  List<Customer> _customers = [];
  List<SolarDevice> _devices = [];
  List<PaymentRecord> _payments = [];

  @override
  void initState() {
    super.initState();
    _service = ProviderService(widget.session.accessToken);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getSummary(),
        _service.getCustomers(),
        _service.getDevices(),
        _service.getPayments(),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = results[0] as ProviderSummary;
        _customers = results[1] as List<Customer>;
        _devices = results[2] as List<SolarDevice>;
        _payments = results[3] as List<PaymentRecord>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _pageTitle => const ['Overview', 'Customers', 'Solar devices', 'Payments'][_selectedIndex];

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
      _query = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 1000;
          return Row(
            children: [
              if (desktop) _Sidebar(selected: _selectedIndex, onSelect: _selectPage, onLogout: _confirmLogout),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(
                      title: _pageTitle,
                      providerName: widget.session.name,
                      onRefresh: _loadData,
                      onLogout: _confirmLogout,
                      showMenu: !desktop,
                    ),
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width < 1000
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectPage,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFDDF1E7),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Overview'),
                NavigationDestination(icon: Icon(Icons.people_alt_outlined), label: 'Customers'),
                NavigationDestination(icon: Icon(Icons.solar_power_outlined), label: 'Devices'),
                NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Payments'),
              ],
            )
          : null,
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _green));
    }
    if (_error != null) return _ErrorState(message: _error!, retry: _loadData);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: switch (_selectedIndex) {
        1 => _customersPage(),
        2 => _devicesPage(),
        3 => _paymentsPage(),
        _ => _overviewPage(),
      },
    );
  }

  Widget _overviewPage() {
    final summary = _summary;
    if (summary == null) return const _EmptyState(icon: Icons.analytics_outlined, title: 'No summary available');
    final successRate = _payments.isEmpty
        ? 0
        : ((_payments.where((p) => p.status.toLowerCase() == 'success').length / _payments.length) * 100).round();
    final activeRate = summary.totalDevices == 0 ? 0 : ((summary.activeDevices / summary.totalDevices) * 100).round();

    return SingleChildScrollView(
      key: const ValueKey('overview'),
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeBanner(name: widget.session.name, customers: summary.totalCustomers, devices: summary.totalDevices),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1200 ? 4 : constraints.maxWidth >= 650 ? 2 : 1;
                  final width = (constraints.maxWidth - ((columns - 1) * 16)) / columns;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(width: width, child: _MetricCard(label: 'Total customers', value: '${summary.totalCustomers}', icon: Icons.people_alt_rounded, color: const Color(0xFF3973E6), note: 'Registered accounts')),
                      SizedBox(width: width, child: _MetricCard(label: 'Solar devices', value: '${summary.totalDevices}', icon: Icons.solar_power_rounded, color: const Color(0xFFF4A226), note: '$activeRate% currently active')),
                      SizedBox(width: width, child: _MetricCard(label: 'Active devices', value: '${summary.activeDevices}', icon: Icons.bolt_rounded, color: _green, note: '${summary.lockedDevices} locked devices')),
                      SizedBox(width: width, child: _MetricCard(label: 'Successful payments', value: '${summary.successfulPayments}', icon: Icons.verified_rounded, color: const Color(0xFF7656D6), note: '$successRate% success rate')),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 950;
                  final activity = _RecentActivity(payments: _payments.take(5).toList());
                  final status = _SystemStatus(
                    active: summary.activeDevices,
                    locked: summary.lockedDevices,
                    total: summary.totalDevices,
                    paymentSuccess: successRate,
                  );
                  return wide
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: activity), const SizedBox(width: 20), Expanded(flex: 2, child: status)])
                      : Column(children: [activity, const SizedBox(height: 20), status]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customersPage() {
    final filtered = _customers.where((item) {
      final q = _query.toLowerCase();
      return item.name.toLowerCase().contains(q) || item.email.toLowerCase().contains(q) || item.id.toString().contains(q);
    }).toList();
    return _DataPage(
      key: const ValueKey('customers'),
      title: 'Customer directory',
      subtitle: '${_customers.length} registered customer${_customers.length == 1 ? '' : 's'}',
      searchController: _searchController,
      searchHint: 'Search customers by name, email or ID',
      onSearch: (value) => setState(() => _query = value),
      child: filtered.isEmpty
          ? const _EmptyState(icon: Icons.person_search_outlined, title: 'No matching customers')
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 84, endIndent: 20),
              itemBuilder: (context, index) {
                final customer = filtered[index];
                final devices = _devices.where((d) => d.customerId == customer.id).length;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                  leading: _InitialAvatar(name: customer.name),
                  title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w700, color: _navy)),
                  subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(customer.email)),
                  trailing: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 18,
                    children: [
                      _SmallInfo(icon: Icons.solar_power_outlined, text: '$devices device${devices == 1 ? '' : 's'}'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFF0F3F2), borderRadius: BorderRadius.circular(8)),
                        child: Text('ID ${customer.id}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF60716C))),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _devicesPage() {
    final filtered = _devices.where((item) {
      final q = _query.toLowerCase();
      return item.deviceCode.toLowerCase().contains(q) || item.deviceName.toLowerCase().contains(q) || item.status.toLowerCase().contains(q);
    }).toList();
    return _DataPage(
      key: const ValueKey('devices'),
      title: 'Solar device fleet',
      subtitle: '${_devices.length} registered device${_devices.length == 1 ? '' : 's'}',
      searchController: _searchController,
      searchHint: 'Search devices by code, name or status',
      onSearch: (value) => setState(() => _query = value),
      child: filtered.isEmpty
          ? const _EmptyState(icon: Icons.solar_power_outlined, title: 'No matching devices')
          : _table(
              columns: const ['Device', 'Customer', 'Status', 'Credit balance'],
              rows: filtered.map((device) {
                final active = device.status.toLowerCase() == 'active';
                return [
                  _PrimaryCell(title: device.deviceName, subtitle: device.deviceCode, icon: Icons.solar_power_rounded, color: const Color(0xFFF4A226)),
                  Text('Customer ${device.customerId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  _StatusBadge(label: device.status, success: active),
                  Text('${device.remainingCredit.toStringAsFixed(0)} day${device.remainingCredit == 1 ? '' : 's'}', style: const TextStyle(fontWeight: FontWeight.w700, color: _navy)),
                ];
              }).toList(),
            ),
    );
  }

  Widget _paymentsPage() {
    final filtered = _payments.where((item) {
      final q = _query.toLowerCase();
      return item.reference.toLowerCase().contains(q) || item.status.toLowerCase().contains(q) || item.customerId.toString().contains(q);
    }).toList();
    return _DataPage(
      key: const ValueKey('payments'),
      title: 'Payment transactions',
      subtitle: '${_payments.length} transaction${_payments.length == 1 ? '' : 's'} recorded',
      searchController: _searchController,
      searchHint: 'Search by reference, status or customer ID',
      onSearch: (value) => setState(() => _query = value),
      child: filtered.isEmpty
          ? const _EmptyState(icon: Icons.manage_search_rounded, title: 'No matching payments')
          : _table(
              columns: const ['Reference', 'Customer / device', 'Amount', 'Status', 'Fulfilment', 'Created'],
              rows: filtered.map((payment) {
                final success = payment.status.toLowerCase() == 'success';
                return [
                  _PrimaryCell(title: payment.reference, subtitle: 'Transaction #${payment.id}', icon: Icons.receipt_long_rounded, color: const Color(0xFF7656D6)),
                  Text('Customer ${payment.customerId}  •  Device ${payment.deviceId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('₦${payment.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, color: _navy)),
                  _StatusBadge(label: payment.status, success: success),
                  _StatusBadge(label: payment.fulfilled ? 'Fulfilled' : 'Pending', success: payment.fulfilled),
                  Text(_formatDate(payment.createdAt), style: const TextStyle(color: Color(0xFF52655F))),
                ];
              }).toList(),
            ),
    );
  }

  Widget _table({required List<String> columns, required List<List<Widget>> rows}) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F8F7)),
            headingTextStyle: const TextStyle(color: Color(0xFF60716C), fontWeight: FontWeight.w700, fontSize: 12),
            dataRowMinHeight: 68,
            dataRowMaxHeight: 76,
            horizontalMargin: 22,
            columnSpacing: 38,
            dividerThickness: .6,
            columns: columns.map((column) => DataColumn(label: Text(column.toUpperCase()))).toList(),
            rows: rows.map((cells) => DataRow(cells: cells.map(DataCell.new).toList())).toList(),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';
    final local = date.toLocal();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to enter your provider credentials again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed == true) widget.onLogout();
  }
}

class _Sidebar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  const _Sidebar({required this.selected, required this.onSelect, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.grid_view_rounded, 'Overview'),
      (Icons.people_alt_outlined, 'Customers'),
      (Icons.solar_power_outlined, 'Solar devices'),
      (Icons.receipt_long_outlined, 'Payments'),
    ];
    return Container(
      width: 260,
      color: _ProviderDashboardScreenState._navy,
      padding: const EdgeInsets.fromLTRB(18, 26, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(children: [
              _DashboardLogo(),
              SizedBox(width: 12),
              Expanded(child: Text('Nigeria Solar\nPAYGO', style: TextStyle(color: Colors.white, fontSize: 16, height: 1.18, fontWeight: FontWeight.w800))),
            ]),
          ),
          const SizedBox(height: 42),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('WORKSPACE', style: TextStyle(color: Color(0xFF6F8981), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 12),
          ...List.generate(items.length, (index) {
            final active = selected == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Material(
                color: active ? const Color(0xFF123C3A) : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => onSelect(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: active ? BoxDecoration(border: Border.all(color: const Color(0x2239D998)), borderRadius: BorderRadius.circular(11)) : null,
                    child: Row(children: [
                      Icon(items[index].$1, color: active ? _ProviderDashboardScreenState._lime : const Color(0xFF91A69F), size: 21),
                      const SizedBox(width: 13),
                      Text(items[index].$2, style: TextStyle(color: active ? Colors.white : const Color(0xFFACC0B9), fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
                    ]),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF0C2934), borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.cloud_done_outlined, color: _ProviderDashboardScreenState._lime, size: 20),
              SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('System online', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                SizedBox(height: 2),
                Text('All services connected', style: TextStyle(color: Color(0xFF8DA69E), fontSize: 10)),
              ])),
            ]),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, size: 19),
            label: const Text('Sign out'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF9BB0A9)),
          ),
        ],
      ),
    );
  }
}

class _DashboardLogo extends StatelessWidget {
  const _DashboardLogo();
  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: _ProviderDashboardScreenState._lime, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.solar_power_rounded, color: _ProviderDashboardScreenState._navy, size: 26),
      );
}

class _TopBar extends StatelessWidget {
  final String title;
  final String providerName;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;
  final bool showMenu;
  const _TopBar({required this.title, required this.providerName, required this.onRefresh, required this.onLogout, required this.showMenu});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE4EAE7)))),
      child: Row(children: [
        Expanded(child: Text(title, style: const TextStyle(color: _ProviderDashboardScreenState._navy, fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -.3))),
        IconButton.filledTonal(tooltip: 'Refresh data', onPressed: onRefresh, icon: const Icon(Icons.refresh_rounded), style: IconButton.styleFrom(backgroundColor: const Color(0xFFF0F5F3), foregroundColor: _ProviderDashboardScreenState._green)),
        const SizedBox(width: 14),
        Container(width: 1, height: 32, color: const Color(0xFFE0E7E4)),
        const SizedBox(width: 14),
        CircleAvatar(backgroundColor: const Color(0xFFDDF1E7), foregroundColor: _ProviderDashboardScreenState._green, child: Text(providerName.isEmpty ? 'P' : providerName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800))),
        const SizedBox(width: 10),
        if (MediaQuery.sizeOf(context).width >= 620)
          Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(providerName, style: const TextStyle(color: _ProviderDashboardScreenState._navy, fontSize: 13, fontWeight: FontWeight.w700)),
            const Text('Provider administrator', style: TextStyle(color: Color(0xFF758780), fontSize: 11)),
          ]),
        if (showMenu) PopupMenuButton<String>(onSelected: (value) { if (value == 'logout') onLogout(); }, itemBuilder: (context) => const [PopupMenuItem(value: 'logout', child: Text('Sign out'))]),
      ]),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final String name;
  final int customers;
  final int devices;
  const _WelcomeBanner({required this.name, required this.customers, required this.devices});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0A3C3B), Color(0xFF0B7A55)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x220B7A55), blurRadius: 24, offset: Offset(0, 10))],
        ),
        child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 22, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Good day, ${name.split(' ').first}', style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.6)),
            const SizedBox(height: 8),
            const Text('Here is the latest view of your PAYGO network.', style: TextStyle(color: Color(0xFFC5DDD5), fontSize: 14)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(color: const Color(0x18FFFFFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x22FFFFFF))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.public_rounded, color: _ProviderDashboardScreenState._lime, size: 23),
              const SizedBox(width: 10),
              Text('$devices systems serving $customers customers', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      );
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String note;
  const _MetricCard({required this.label, required this.value, required this.icon, required this.color, required this.note});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE3EAE7)), boxShadow: const [BoxShadow(color: Color(0x09071D2B), blurRadius: 14, offset: Offset(0, 5))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(width: 43, height: 43, decoration: BoxDecoration(color: color.withValues(alpha: .11), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 23)),
            const Icon(Icons.more_horiz_rounded, color: Color(0xFF9DABA6)),
          ]),
          const SizedBox(height: 20),
          Text(value, style: const TextStyle(color: _ProviderDashboardScreenState._navy, fontSize: 31, height: 1, fontWeight: FontWeight.w800, letterSpacing: -1)),
          const SizedBox(height: 7),
          Text(label, style: const TextStyle(color: Color(0xFF40544E), fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 12),
          Text(note, style: const TextStyle(color: Color(0xFF82918C), fontSize: 11)),
        ]),
      );
}

class _RecentActivity extends StatelessWidget {
  final List<PaymentRecord> payments;
  const _RecentActivity({required this.payments});
  @override
  Widget build(BuildContext context) => _Panel(
        title: 'Recent payment activity',
        subtitle: 'Latest transactions across the network',
        child: payments.isEmpty
            ? const SizedBox(height: 210, child: _EmptyState(icon: Icons.receipt_long_outlined, title: 'No recent transactions'))
            : Column(children: payments.map((payment) {
                final success = payment.status.toLowerCase() == 'success';
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE9EEEC)))),
                  child: Row(children: [
                    Container(width: 38, height: 38, decoration: BoxDecoration(color: success ? const Color(0xFFE4F5ED) : const Color(0xFFFFF2D9), borderRadius: BorderRadius.circular(10)), child: Icon(success ? Icons.check_rounded : Icons.schedule_rounded, color: success ? _ProviderDashboardScreenState._green : const Color(0xFFC67C09), size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(payment.reference, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ProviderDashboardScreenState._navy, fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 3),
                      Text('Customer ${payment.customerId} • Device ${payment.deviceId}', style: const TextStyle(color: Color(0xFF84938E), fontSize: 11)),
                    ])),
                    const SizedBox(width: 12),
                    Text('₦${payment.amount.toStringAsFixed(0)}', style: const TextStyle(color: _ProviderDashboardScreenState._navy, fontWeight: FontWeight.w800)),
                  ]),
                );
              }).toList()),
      );
}

class _SystemStatus extends StatelessWidget {
  final int active;
  final int locked;
  final int total;
  final int paymentSuccess;
  const _SystemStatus({required this.active, required this.locked, required this.total, required this.paymentSuccess});
  @override
  Widget build(BuildContext context) => _Panel(
        title: 'Network health',
        subtitle: 'Current operational status',
        child: Column(children: [
          _ProgressLine(label: 'Active devices', value: total == 0 ? 0 : active / total, valueLabel: '$active of $total', color: _ProviderDashboardScreenState._green),
          const SizedBox(height: 25),
          _ProgressLine(label: 'Payment success', value: paymentSuccess / 100, valueLabel: '$paymentSuccess%', color: const Color(0xFF7656D6)),
          const SizedBox(height: 25),
          _ProgressLine(label: 'Devices requiring attention', value: total == 0 ? 0 : locked / total, valueLabel: '$locked', color: const Color(0xFFE25B4B)),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF4F8F6), borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.security_rounded, color: _ProviderDashboardScreenState._green, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('Provider connection is secure and operational.', style: TextStyle(color: Color(0xFF456159), fontSize: 12, fontWeight: FontWeight.w600))),
            ]),
          ),
        ]),
      );
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final double value;
  final String valueLabel;
  final Color color;
  const _ProgressLine({required this.label, required this.value, required this.valueLabel, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: Color(0xFF40544E), fontWeight: FontWeight.w600, fontSize: 12)),
          Text(valueLabel, style: const TextStyle(color: _ProviderDashboardScreenState._navy, fontWeight: FontWeight.w800, fontSize: 12)),
        ]),
        const SizedBox(height: 9),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: value.clamp(0.0, 1.0).toDouble(), minHeight: 7, backgroundColor: const Color(0xFFE8EEEB), valueColor: AlwaysStoppedAnimation(color))),
      ]);
}

class _Panel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _Panel({required this.title, required this.subtitle, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE3EAE7))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: _ProviderDashboardScreenState._navy, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFF82918C), fontSize: 12)),
          const SizedBox(height: 18),
          child,
        ]),
      );
}

class _DataPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String> onSearch;
  final Widget child;
  const _DataPage({super.key, required this.title, required this.subtitle, required this.searchController, required this.searchHint, required this.onSearch, required this.child});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.end, runSpacing: 18, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(color: _ProviderDashboardScreenState._navy, fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF74867F), fontSize: 13)),
                ]),
                SizedBox(
                  width: 340,
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearch,
                    decoration: InputDecoration(
                      hintText: searchHint,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      isDense: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 22),
              Expanded(child: Container(width: double.infinity, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E9E6))), child: child)),
            ]),
          ),
        ),
      );
}

class _PrimaryCell extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _PrimaryCell({required this.title, required this.subtitle, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: .11), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 11),
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: _ProviderDashboardScreenState._navy, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: Color(0xFF82918C), fontSize: 11)),
        ]),
      ]);
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool success;
  const _StatusBadge({required this.label, required this.success});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: success ? const Color(0xFFE4F5ED) : const Color(0xFFFFEEE9), borderRadius: BorderRadius.circular(30)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: success ? _ProviderDashboardScreenState._green : const Color(0xFFE25B4B), shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text(label.toUpperCase(), style: TextStyle(color: success ? const Color(0xFF08714E) : const Color(0xFFA23A2F), fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: .4)),
        ]),
      );
}

class _InitialAvatar extends StatelessWidget {
  final String name;
  const _InitialAvatar({required this.name});
  @override
  Widget build(BuildContext context) => Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0B7A55), Color(0xFF39A878)]), borderRadius: BorderRadius.circular(13)),
        child: Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
      );
}

class _SmallInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SmallInfo({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 17, color: const Color(0xFF74867F)), const SizedBox(width: 6), Text(text, style: const TextStyle(color: Color(0xFF52655F), fontSize: 12, fontWeight: FontWeight.w600))]);
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  const _EmptyState({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 42, color: const Color(0xFF9BAAA5)), const SizedBox(height: 12), Text(title, style: const TextStyle(color: Color(0xFF60716C), fontWeight: FontWeight.w700))])));
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback retry;
  const _ErrorState({required this.message, required this.retry});
  @override
  Widget build(BuildContext context) => Center(child: Container(margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(28), constraints: const BoxConstraints(maxWidth: 480), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0D1CC))), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_rounded, size: 46, color: Color(0xFFE25B4B)), const SizedBox(height: 16), const Text('Unable to load dashboard', style: TextStyle(color: _ProviderDashboardScreenState._navy, fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF71827C))), const SizedBox(height: 20), FilledButton.icon(onPressed: retry, icon: const Icon(Icons.refresh_rounded), label: const Text('Try again'))])));
}
