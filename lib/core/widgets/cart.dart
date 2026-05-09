import 'package:flutter/material.dart';
import 'package:sukisave/core/state/cart_store.dart';
import 'package:sukisave/core/state/vendor_order_store.dart';
import 'package:sukisave/core/widgets/app_image.dart';
import 'package:sukisave/features/home/pages/activities.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Color _brandGreen = Color(0xFF0F5513);
  static const Color _mutedGray = Color(0xFF8E8E8E);
  static const Color _softGray = Color(0xFFF4F4F4);

  late List<_CartItem> _items;

  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadCartItems();
    CartStore.instance.addListener(_onCartUpdated);
  }

  void _loadCartItems() {
    final items = CartStore.instance.items;

    _items = items.map((cartItem) {
      return _CartItem(
        id: cartItem.product.id,
        name: cartItem.product.title,
        date: 'Added just now',
        description: cartItem.product.category,
        price: cartItem.product.price,
        quantity: cartItem.quantity, // 🔥 IMPORTANT FIX
        quantityLeft: cartItem.product.quantityLeft,
        imagePath: cartItem.product.imagePath,
      );
    }).toList();
  }

  void _onCartUpdated() {
    setState(() {
      _loadCartItems();
    });
  }

  @override
  void dispose() {
    CartStore.instance.removeListener(_onCartUpdated);
    super.dispose();
  }

  bool get _isAllSelected =>
      _items.isNotEmpty && _selectedIds.length == _items.length;

  Iterable<_CartItem> get _activeItems =>
      _items.where((item) => _selectedIds.contains(item.id));

  int get _activeTotalPrice =>
      _activeItems.fold(0, (sum, item) => sum + item.price * item.quantity);

  int get _activeCount =>
      _activeItems.fold(0, (sum, item) => sum + item.quantity);

  Future<void> _adjustActiveQuantities(int delta) async {
    if (_items.isEmpty) return;

    for (final item in _activeItems.toList()) {
      if (delta > 0) {
        final result = await CartStore.instance.increase(item.id);
        if (!mounted) return;
        if (result.isSoldOut) {
          await _showSoldOutDialog(item.name);
        }
      } else {
        await CartStore.instance.decrease(item.id);
        if (!mounted) return;
        final stillInCart = CartStore.instance.items.any(
          (cartItem) => cartItem.product.id == item.id,
        );
        if (!stillInCart) {
          _selectedIds.remove(item.id);
        }
      }
    }
  }

  Future<void> _showSoldOutDialog(String productName) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Sold out'),
        content: Text('$productName is currently sold out.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _toggleAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds
          ..clear()
          ..addAll(_items.map((item) => item.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleItem(int id, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  TextStyle get _geistBase => const TextStyle(fontFamily: 'Geist');

  Future<void> _startVendorApprovalFlow() async {
    final activeItems = _activeItems.toList();
    if (activeItems.isEmpty) return;

    final VendorOrderStore store = VendorOrderStore.instance;
    final requests = activeItems.map((item) {
      return store.createRequest(
        productId: item.id,
        name: item.name,
        description: item.description,
        price: item.price,
        quantity: item.quantity,
        imagePath: item.imagePath,
      );
    }).toList();

    store.addRequests(requests);
    await CartStore.instance.removeAll(
      activeItems.map((item) => item.id).toSet(),
      restoreStock: false,
    );
    setState(() {
      _selectedIds.clear();
      _loadCartItems();
    });

    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Waiting for vendor confirmation',
            style: TextStyle(
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          content: const Text(
            'Please wait while the vendor accepts or declines your order.',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 12,
              color: _mutedGray,
            ),
          ),
        );
      },
    );

    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ReceiptPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softGray,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: _brandGreen,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 62,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'SukiCart',
                      style: _geistBase.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      child: SizedBox(
                        width: 38,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _brandGreen,
                            padding: EdgeInsets.zero,
                            shape: const CircleBorder(),
                            elevation: 0,
                          ),
                          child: const Icon(Icons.arrow_back, size: 18),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      child: Text(
                        'edit',
                        style: _geistBase.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _items[index];
                return _CartCard(
                  item: item,
                  isSelected: _selectedIds.contains(item.id),
                  onChanged: (value) => _toggleItem(item.id, value),
                  textStyle: _geistBase,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: _brandGreen,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleAll(!_isAllSelected),
                  child: _CheckBoxSquare(
                    checked: _isAllSelected,
                    checkedColor: Colors.white,
                    borderColor: Colors.white,
                    iconColor: _brandGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'All',
                  style: _geistBase.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                _QuantityStepper(
                  value: _activeCount,
                  onDecrement: _activeCount == 0
                      ? null
                      : () => _adjustActiveQuantities(-1),
                  onIncrement: _activeCount == 0
                      ? null
                      : () => _adjustActiveQuantities(1),
                ),
                const Spacer(),
                Text(
                  'P $_activeTotalPrice',
                  style: _geistBase.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _activeCount == 0
                        ? null
                        : _startVendorApprovalFlow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white70,
                      foregroundColor: _brandGreen,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'CheckOut ($_activeCount)',
                      style: _geistBase.copyWith(
                        color: _brandGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
}

class _CartCard extends StatelessWidget {
  final _CartItem item;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;
  final TextStyle textStyle;

  const _CartCard({
    required this.item,
    required this.isSelected,
    required this.onChanged,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => onChanged(!isSelected),
                child: _CheckBoxSquare(
                  checked: isSelected,
                  checkedColor: const Color(0xFF0F5513),
                  borderColor: const Color(0xFFBDBDBD),
                  iconColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              AppImage(
                path: item.imagePath,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: textStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F5513),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.date,
                      style: textStyle.copyWith(
                        fontSize: 10,
                        color: const Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: textStyle.copyWith(
                        fontSize: 10,
                        color: const Color(0xFF777777),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'P ${item.price}.00',
                      style: textStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${item.quantity}',
                      style: textStyle.copyWith(
                        fontSize: 10,
                        color: const Color(0xFF777777),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    '${item.quantityLeft} serving left',
                    style: textStyle.copyWith(
                      fontSize: 10,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                size: 16,
                color: Color(0xFF9E9E9E),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Add shop voucher code',
                  style: textStyle.copyWith(
                    fontSize: 11,
                    color: _CartPageState._mutedGray,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: Color(0xFF9E9E9E),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckBoxSquare extends StatelessWidget {
  final bool checked;
  final Color checkedColor;
  final Color borderColor;
  final Color iconColor;

  const _CheckBoxSquare({
    this.checked = false,
    required this.checkedColor,
    required this.borderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: checked ? checkedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: checked ? Icon(Icons.check, size: 12, color: iconColor) : null,
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _QuantityStepper({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove, size: 16),
            color: const Color(0xFF0F5513),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F5513),
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add, size: 16),
            color: const Color(0xFF0F5513),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}

class _CartItem {
  final int id;
  final String name;
  final String date;
  final String description;
  final int price;
  int quantity;
  final int quantityLeft;
  final String imagePath;

  _CartItem({
    required this.id,
    required this.name,
    required this.date,
    required this.description,
    required this.price,
    required this.quantity,
    required this.quantityLeft,
    required this.imagePath,
  });
}
