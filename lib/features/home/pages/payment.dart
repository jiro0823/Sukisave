import 'package:flutter/material.dart';
import 'package:sukisave/core/models/purchased_product.dart';
import 'package:sukisave/core/widgets/payment_confirmation.dart';

class PaymentPage extends StatefulWidget {
  final List<dynamic> items; // accept passed items
  final Set<int> pendingRequestIds;

  const PaymentPage({
    super.key,
    required this.items,
    this.pendingRequestIds = const <int>{},
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const Color _brandGreen = Color(0xFF0F5513);
  static const Color _panelWhite = Color(0xFFF3F3F3);
  static const double _deliveryFee = 30.00;

  int _selectedPayment = 0;
  int _selectedDelivery = 0;

  List<_PaymentMethod> get _methods => const [
    _PaymentMethod(label: 'Visa', assetPath: 'assets/images/payment/Visa.png'),
    _PaymentMethod(
      label: 'PayPal',
      assetPath: 'assets/images/payment/paypal.png',
    ),
    _PaymentMethod(
      label: 'GCash',
      assetPath: 'assets/images/payment/gcash.png',
    ),
  ];

  double get _subtotal =>
      widget.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double get _total => _subtotal + _deliveryFee;

  Set<int> get _paidProductIds {
    return widget.items.map<int>((item) => item.id as int).toSet();
  }

  List<PurchasedProduct> get _paidItems {
    final DateTime purchasedAt = DateTime.now();

    return widget.items.map<PurchasedProduct>((item) {
      return PurchasedProduct(
        userId: 0,
        productId: item.id as int,
        name: item.name as String,
        category: item.description as String,
        price: item.price as int,
        quantity: item.quantity as int,
        imagePath: item.imagePath as String,
        purchasedAt: purchasedAt,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items; // ✅ FIXED SOURCE

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              decoration: const BoxDecoration(
                color: _brandGreen,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(22),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: _brandGreen,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: List.generate(_methods.length, (index) {
                        final method = _methods[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _methodTile(
                            method: method,
                            selected: _selectedPayment == index,
                            onTap: () {
                              setState(() {
                                _selectedPayment = index;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    const Divider(color: Color(0xFFE5E5E5)),
                    const SizedBox(height: 10),
                    const Text(
                      'Delievery Method',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _brandGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _choiceChip(
                          label: 'Delievery',
                          selected: _selectedDelivery == 0,
                          onTap: () {
                            setState(() {
                              _selectedDelivery = 0;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        _choiceChip(
                          label: 'Pick Up',
                          selected: _selectedDelivery == 1,
                          onTap: () {
                            setState(() {
                              _selectedDelivery = 1;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE5E5E5)),
                    const SizedBox(height: 10),
                    const Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ✅ USE PASSED ITEMS HERE
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.name, // FIX: use name not title
                              style: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '₱ ${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 6),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delievery fee',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '₱ 30.00',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFE5E5E5)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '₱ ${_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _brandGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: SizedBox(
                        width: 180,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: items.isEmpty
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PaymentConfirmationPage(
                                        paidProductIds: _paidProductIds,
                                        paidItems: _paidItems,
                                        pendingRequestIds:
                                            widget.pendingRequestIds,
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brandGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _brandGreen : _panelWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _methodTile({
    required _PaymentMethod method,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _panelWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(method.assetPath, height: 18),
            _radioDot(selected: selected),
          ],
        ),
      ),
    );
  }

  Widget _radioDot({required bool selected}) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _brandGreen, width: 1.4),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: _brandGreen,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _PaymentMethod {
  final String label;
  final String assetPath;

  const _PaymentMethod({required this.label, required this.assetPath});
}
