import 'package:flutter/material.dart';
import 'package:sukisave/core/models/vendor_order_request.dart';
import 'package:sukisave/core/state/vendor_order_store.dart';
import 'package:sukisave/core/widgets/app_image.dart';
import 'package:sukisave/features/vendor/pages/cancel_order.dart';
import 'package:sukisave/features/vendor/pages/confirm_order.dart';
import 'package:sukisave/features/vendor/widgets/vendor_bottom_navbar.dart';

class VendorOrderPage extends StatefulWidget {
  const VendorOrderPage({super.key});

  @override
  State<VendorOrderPage> createState() => _VendorOrderPageState();
}

class _VendorOrderPageState extends State<VendorOrderPage> {
  final VendorOrderStore _orderStore = VendorOrderStore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const VendorBottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Orders',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedBuilder(
                  animation: _orderStore,
                  builder: (context, _) {
                    final orders = List<VendorOrderRequest>.from(
                      _orderStore.requests,
                    )..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    if (orders.isEmpty) {
                      return const Center(
                        child: Text(
                          'No vendor orders yet.',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _VendorOrderPanel(order: orders[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorOrderPanel extends StatelessWidget {
  final VendorOrderRequest order;

  const _VendorOrderPanel({required this.order});

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF0F5513);
    const Color panelGray = Color(0xFFF2F2F2);
    const Color declineRed = Color(0xFFD64545);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: panelGray,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage(
                path: order.imagePath,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            order.name,
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: brandGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'P ${order.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: brandGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Qty: ${order.quantity}',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.description,
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (order.isPending)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () {
                        VendorOrderStore.instance.updateStatus(
                          order.requestId,
                          VendorOrderStatus.accepted,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ConfirmOrderPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                CancelOrderPage(requestId: order.requestId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: declineRed,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                order.isAccepted ? 'Accepted' : 'Denied by vendor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: order.isAccepted ? brandGreen : declineRed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
