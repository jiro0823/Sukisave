import 'package:flutter/material.dart';
import 'package:sukisave/core/models/sales_model.dart';
import 'package:sukisave/core/services/sales_service.dart';
import 'package:sukisave/core/services/auth_service.dart';
import 'package:sukisave/core/state/vendor_order_store.dart';

class TargetOrdersPage extends StatefulWidget {
  const TargetOrdersPage({super.key});

  @override
  State<TargetOrdersPage> createState() => _TargetOrdersPageState();
}

class _TargetOrdersPageState extends State<TargetOrdersPage> {
  final SalesService _service = SalesService();

  List<SalesModel> sales = [];
  double progress = 0.0;
  bool isLoading = true;
  int _vendorId = 0;

  String selectedFilter = "Weekly";

  /// 🔹 CHANGE THIS BASED ON YOUR BUSINESS TARGET
  final int weeklyTarget = 2000;

  @override
  void initState() {
    super.initState();
    VendorOrderStore.instance.addListener(_reloadFromOrderStore);
    _bootstrap();
  }

  @override
  void dispose() {
    VendorOrderStore.instance.removeListener(_reloadFromOrderStore);
    super.dispose();
  }

  void _reloadFromOrderStore() {
    if (_vendorId > 0) {
      loadData();
    }
  }

  Future<void> _bootstrap() async {
    final user =
        AuthService.instance.currentUser ??
        await AuthService.instance.restoreSession();
    _vendorId = user?.id ?? 0;
    await loadData();
  }

  Future<void> loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final result = await _service.getSales(selectedFilter, _vendorId);
      final prog = await _service.calculateProgress(
        weeklyTarget,
        selectedFilter,
        _vendorId,
      );

      if (!mounted) return;
      setState(() {
        sales = result;
        progress = prog.clamp(0.0, 1.0);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      //bottomNavigationBar: VendorBottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),

                            /// 🔹 TITLE
                            const Text(
                              "Target Orders",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 24),

                            /// 🔹 PROGRESS GRAPH
                            Center(
                              child: SizedBox(
                                height: 180,
                                width: 180,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      height: 160,
                                      width: 160,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 18,
                                        backgroundColor: Colors.grey.shade300,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              Color(0xFF0F5513),
                                            ),
                                      ),
                                    ),
                                    Text(
                                      "$percentage%",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// 🔹 DESCRIPTION
                            Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    const TextSpan(text: "You Completed "),
                                    TextSpan(
                                      text: "$percentage%",
                                      style: const TextStyle(
                                        color: Color(0xFF0F5513),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          " of your target orders this week than last week",
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 12),

                            /// 🔹 SALES REPORT HEADER
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Sales Report",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                /// 🔹 FILTER
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedFilter,
                                    underline: const SizedBox(),
                                    items: ["Today", "Weekly", "Monthly"]
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedFilter = value!;
                                      });
                                      loadData();
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            /// 🔹 TABLE HEADER
                            _buildHeaderRow(),

                            const SizedBox(height: 8),

                            /// 🔹 DATA LIST
                            sales.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.only(top: 40),
                                    child: Center(
                                      child: Text(
                                        "No sales data available",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: sales.length,
                                    separatorBuilder: (_, __) =>
                                        Divider(color: Colors.grey.shade300),
                                    itemBuilder: (context, index) {
                                      final item = sales[index];
                                      return _buildRow(index, item);
                                    },
                                  ),

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 🔹 HEADER ROW
  Widget _buildHeaderRow() {
    return Row(
      children: const [
        Expanded(
          flex: 1,
          child: Text(
            "No.",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            "Product Name",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            "Quantity",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            "Sold",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ],
    );
  }

  /// 🔹 DATA ROW
  Widget _buildRow(int index, SalesModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("${index + 1}")),
          Expanded(flex: 3, child: Text(item.productName)),
          Expanded(flex: 2, child: Text("${item.quantity}")),
          Expanded(flex: 2, child: Text("₱ ${item.sold}")),
        ],
      ),
    );
  }
}
