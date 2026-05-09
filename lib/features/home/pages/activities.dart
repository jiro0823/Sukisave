import 'package:flutter/material.dart';
import 'package:sukisave/core/models/purchased_product.dart';
import 'package:sukisave/core/models/vendor_order_request.dart';
import 'package:sukisave/core/services/order_history_service.dart';
import 'package:sukisave/core/state/vendor_order_store.dart';
import 'package:sukisave/core/widgets/app_image.dart';
import 'package:sukisave/core/widgets/app_bottom_nav.dart';
import 'package:sukisave/features/home/pages/payment.dart';

const Color _brandGreen = Color(0xFF0F5513);
const Color _panelWhite = Color(0xFFF3F3F3);

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  late Future<List<PurchasedProduct>> _ordersFuture;
  final VendorOrderStore _vendorOrderStore = VendorOrderStore.instance;

  @override
  void initState() {
    super.initState();
    _ordersFuture = OrderHistoryService.instance.fetchCurrentUserOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: _brandGreen,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Container(color: _brandGreen),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Past orders',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Geist',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _ordersFuture = OrderHistoryService.instance
                                .fetchCurrentUserOrders();
                          });
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: _panelWhite,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _vendorOrderStore,
                      builder: (context, _) {
                        return FutureBuilder<List<PurchasedProduct>>(
                          future: _ordersFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: _brandGreen,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const _ActivityMessage(
                                icon: Icons.error_outline,
                                title: 'Unable to load orders',
                                message: 'Please try again later.',
                              );
                            }

                            final List<PurchasedProduct> orders =
                                snapshot.data ?? const <PurchasedProduct>[];
                            final List<VendorOrderRequest> vendorOrders =
                                List<VendorOrderRequest>.from(
                                  _vendorOrderStore.requests,
                                )..sort(
                                  (a, b) => b.createdAt.compareTo(a.createdAt),
                                );

                            if (orders.isEmpty && vendorOrders.isEmpty) {
                              return const _ActivityMessage(
                                icon: Icons.receipt_long_outlined,
                                title: 'No past orders yet',
                                message: 'Your paid products will appear here.',
                              );
                            }

                            return ListView(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                20,
                                16,
                                140,
                              ),
                              children: [
                                ...vendorOrders.map(
                                  (order) => _VendorOrderCard(
                                    order: order,
                                    onProceedToPayment: () =>
                                        _openPayment(order),
                                  ),
                                ),
                                ...orders.map(
                                  (order) => _PastOrderCard(item: order),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 2, onTap: (_) {}),
    );
  }

  void _openPayment(VendorOrderRequest order) {
    if (!order.isAccepted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          items: [order.toPaymentItem()],
          pendingRequestIds: {order.requestId},
        ),
      ),
    );
  }
}

class _VendorOrderCard extends StatelessWidget {
  final VendorOrderRequest order;
  final VoidCallback onProceedToPayment;

  const _VendorOrderCard({
    required this.order,
    required this.onProceedToPayment,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActionEnabled = order.isAccepted;
    final String buttonText = order.isPending
        ? 'Wait for vendor action'
        : order.isDenied
        ? 'Denied by vendor'
        : 'Proceed to payment';
    final Color buttonColor = order.isDenied
        ? const Color(0xFFD64545)
        : _brandGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage(
                path: order.imagePath,
                width: 70,
                height: 70,
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
                              color: _brandGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'P ${order.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _brandGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${order.quantity} pcs. ${order.name} - ${order.description}',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    if (order.isDenied &&
                        order.declineReason != null &&
                        order.declineReason!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Reason: ${order.declineReason!}',
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 11,
                            color: Color(0xFFD64545),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: isActionEnabled ? onProceedToPayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                disabledBackgroundColor: buttonColor.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PastOrderCard extends StatelessWidget {
  final PurchasedProduct item;

  const _PastOrderCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage(
                path: item.imagePath,
                width: 70,
                height: 70,
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
                            item.name,
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _brandGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'P ${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bought on ${_formatDate(item.purchasedAt)}',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity} pcs. ${item.name} - ${item.category}',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Select items to reorder',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _ActivityMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _ActivityMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _brandGreen, size: 42),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _brandGreen,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
