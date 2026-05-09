import 'package:flutter/material.dart';
import 'package:sukisave/core/models/purchased_product.dart';
import 'package:sukisave/core/services/order_history_service.dart';
import 'package:sukisave/core/state/cart_store.dart';
import 'package:sukisave/core/state/vendor_order_store.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final Set<int> paidProductIds;
  final List<PurchasedProduct> paidItems;
  final Set<int> pendingRequestIds;

  const PaymentConfirmationPage({
    super.key,
    required this.paidProductIds,
    required this.paidItems,
    this.pendingRequestIds = const <int>{},
  });

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  static const Color _brandGreen = Color(0xFF0F5513);
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _brandGreen, width: 5),
                  ),
                  child: const Icon(Icons.check, color: _brandGreen, size: 48),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Order Confirmed!',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Thank you for supporting our local food heroes your choice helps small vendors grow, reduce food waste, and keep our community thriving.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Get Direction',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _brandGreen,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: 200,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isCompleting ? null : _completeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandGreen,
                      disabledBackgroundColor: _brandGreen.withValues(
                        alpha: 0.65,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue Browse',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _completeOrder() async {
    setState(() {
      _isCompleting = true;
    });

    try {
      await OrderHistoryService.instance.savePaidItems(widget.paidItems);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCompleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save order history. Please try again.'),
        ),
      );
      return;
    }

    VendorOrderStore.instance.removeByRequestIds(widget.pendingRequestIds);
    await CartStore.instance.removeAll(
      widget.paidProductIds,
      restoreStock: false,
    );
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/landing');
  }
}
