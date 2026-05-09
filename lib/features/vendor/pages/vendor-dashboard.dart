import 'package:flutter/material.dart';
import 'package:sukisave/core/services/auth_service.dart';
import 'package:sukisave/core/services/vendor_dashboard_service.dart';
import 'package:sukisave/core/state/vendor_order_store.dart';
import 'package:sukisave/features/vendor/pages/target-orders.dart';
import 'package:sukisave/features/vendor/widgets/bar_chart.dart';
import 'package:sukisave/features/vendor/widgets/dashboard_card.dart';
import 'package:sukisave/features/vendor/widgets/filter_tabs.dart';
import 'package:sukisave/features/vendor/widgets/sales_graph_widget.dart';
import 'package:sukisave/features/vendor/widgets/vendor_bottom_navbar.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  int selectedFilter = 1;
  final VendorDashboardService _service = VendorDashboardService();
  VendorDashboardData _data = VendorDashboardData.empty();
  bool _isLoading = true;
  String? _statusMessage;
  int _vendorId = 0;

  @override
  void initState() {
    super.initState();
    VendorOrderStore.instance.addListener(_refreshAfterOrderChange);
    _bootstrap();
  }

  @override
  void dispose() {
    VendorOrderStore.instance.removeListener(_refreshAfterOrderChange);
    super.dispose();
  }

  void _refreshAfterOrderChange() {
    if (_vendorId > 0) {
      _loadData(_vendorId);
    }
  }

  Future<void> _bootstrap() async {
    final user =
        AuthService.instance.currentUser ??
        await AuthService.instance.restoreSession();
    final vendorId = user?.id ?? 0;
    _vendorId = vendorId;

    if (vendorId == 0) {
      setState(() {
        _data = VendorDashboardData.empty();
        _isLoading = false;
        _statusMessage = "Please sign in as a vendor to view dashboard data.";
      });
      return;
    }

    try {
      await _loadData(vendorId);
    } catch (e) {
      setState(() {
        _data = VendorDashboardData.empty();
        _isLoading = false;
        _statusMessage = "Unable to load dashboard data.";
      });
    }
  }

  Future<void> _loadData(int vendorId) async {
    try {
      final result = await _service.fetch(vendorId);
      if (!mounted) return;
      setState(() {
        _data = result;
        _isLoading = false;
        _statusMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _data = VendorDashboardData.empty();
        _isLoading = false;
        _statusMessage = "Unable to load dashboard data.";
      });
    }
  }

  void _openTargetOrders() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TargetOrdersPage()));
  }

  List<double> get _series {
    switch (selectedFilter) {
      case 0:
        return _data.todaySeries;
      case 1:
        return _data.weeklySeries;
      case 2:
        return _data.monthlySeries;
      default:
        return _data.weeklySeries;
    }
  }

  List<String> get _labels {
    switch (selectedFilter) {
      case 0:
        return _data.todayLabels;
      case 1:
        return _data.weeklyLabels;
      case 2:
        return _data.monthlyLabels;
      default:
        return _data.weeklyLabels;
    }
  }

  String _formatNumber(num value) {
    final text = value.round().toString();
    return text.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  String _formatPercent(double value) {
    return "${value.toStringAsFixed(1)}%";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: VendorBottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _statusMessage != null
            ? Center(child: Text(_statusMessage!))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Dashboard",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: _openTargetOrders,
                          child: const Text(
                            "Target Orders",
                            style: TextStyle(
                              color: Color(0xFF0F5513),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: DashboardCard(
                            icon: Icons.people,
                            value: _formatNumber(_data.totalVisitors),
                            label: "Total Visitors",
                            percent: "",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DashboardCard(
                            icon: Icons.shopping_cart,
                            value: _formatNumber(_data.totalOrders),
                            label: "Total Orders",
                            percent: "",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: DashboardCard(
                            icon: Icons.attach_money,
                            value: _formatNumber(_data.totalSales),
                            label: "Total Sales",
                            percent: "",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DashboardCard(
                            icon: Icons.message,
                            value: _formatPercent(_data.conversionRate),
                            label: "Conversation",
                            percent: "",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Overview",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        FilterTabs(
                          selectedIndex: selectedFilter,
                          onChanged: (i) => setState(() => selectedFilter = i),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    BarChartWidget(data: _series, labels: _labels),

                    const SizedBox(height: 20),

                    SalesGraphWidget(data: _data.monthlySeries),
                  ],
                ),
              ),
      ),
    );
  }
}
