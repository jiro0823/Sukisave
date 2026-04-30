import 'package:flutter/material.dart';
import 'package:sukisave/core/state/cart_store.dart';
import 'package:sukisave/core/widgets/cart.dart';
import 'package:sukisave/core/widgets/cart_icon_button.dart';
import 'package:sukisave/core/widgets/product_card.dart';
import 'package:sukisave/core/widgets/product_detail_bottom_bar.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductCardData product;
  final List<ProductCardData> relatedProducts;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.relatedProducts,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

enum _DeliveryMode { rider, walk }

class _ProductDetailPageState extends State<ProductDetailPage> {
  static const Color _brandGreen = Color(0xFF0F5513);
  static const Color _softPanel = Color(0xFFF6F6F0);
  static const Map<String, int> _sizeAddOns = {
    'Solo': 0,
    'Family': 40,
    'Fiesta': 70,
  };
  static const int _toppingAddOn = 10;

  late String _selectedSize;
  final Set<String> _selectedToppings = {};
  _DeliveryMode _deliveryMode = _DeliveryMode.rider;

  @override
  void initState() {
    super.initState();
    _selectedSize = _sizes.first;
  }

  bool get _isFood {
    return widget.product.category.toLowerCase() == 'food';
  }

  List<String> get _sizes {
    return const ['Solo', 'Family', 'Fiesta'];
  }

  List<String> get _toppings {
    return const ['Egg + tempura', 'Bagnit + atay', 'Chicharon', 'Overload'];
  }

  String _formatRemaining(DateTime expiresAt) {
    final Duration remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) {
      return 'Expired';
    }

    final int hours = remaining.inHours;
    final int minutes = remaining.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m left';
    }
    return '${minutes}m left';
  }

  String get _deliveryTimeText {
    return _deliveryMode == _DeliveryMode.rider
        ? 'Delivery 10-30 mins'
        : 'Delivery 20-40 mins';
  }

  String get _deliveryPriceText {
    return _deliveryMode == _DeliveryMode.rider
        ? 'P 49.00 Delivery'
        : 'P 39.00 with Server';
  }

  int get _computedPrice {
    final int sizeAddOn = _sizeAddOns[_selectedSize] ?? 0;
    final int toppingAddOn = _isFood
        ? _selectedToppings.length * _toppingAddOn
        : 0;
    return widget.product.price + sizeAddOn + toppingAddOn;
  }

  List<ProductCardData> get _recommended {
    return widget.relatedProducts
        .where(
          (item) =>
              item.category == widget.product.category &&
              item.title != widget.product.title,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    const double bottomBarHeight = ProductDetailBottomBar.height;
    const double headerHeight = 248;

    return Scaffold(
      backgroundColor: _brandGreen,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: ColoredBox(color: _brandGreen),
            ),
            const Positioned.fill(
              top: 180,
              bottom: bottomBarHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(36),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              top: 180,
              bottom: bottomBarHeight,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 24),
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.title,
                                style: const TextStyle(
                                  color: _brandGreen,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${widget.product.quantityLeft} serving left',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatRemaining(widget.product.expiresAt),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'P $_computedPrice.00',
                                  style: const TextStyle(
                                    color: _brandGreen,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Size',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _sizes
                              .map(
                                (size) => _ChoicePill(
                                  label: size,
                                  selected: _selectedSize == size,
                                  onTap: () {
                                    setState(() {
                                      _selectedSize = size;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        if (_isFood) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'Toppings',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _toppings
                                .map(
                                  (topping) => _ChoicePill(
                                    label: topping,
                                    selected: _selectedToppings.contains(
                                      topping,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (_selectedToppings.contains(
                                          topping,
                                        )) {
                                          _selectedToppings.remove(topping);
                                        } else {
                                          _selectedToppings.add(topping);
                                        }
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _softPanel,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _brandGreen, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _DeliveryToggle(
                                    icon: Icons.motorcycle,
                                    selected:
                                        _deliveryMode == _DeliveryMode.rider,
                                    onTap: () {
                                      setState(() {
                                        _deliveryMode = _DeliveryMode.rider;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  _DeliveryToggle(
                                    icon: Icons.directions_walk,
                                    selected:
                                        _deliveryMode == _DeliveryMode.walk,
                                    onTap: () {
                                      setState(() {
                                        _deliveryMode = _DeliveryMode.walk;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _deliveryTimeText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _deliveryPriceText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Min. order P 109.00',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _addSelectedProductToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brandGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: const Text(
                              'Add to cart',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Recommended for you',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                SizedBox(
                                  width: 120,
                                  height: 2,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Text(
                              'Product Info',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _recommended.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final product = _recommended[index];
                              return SizedBox(
                                width: 170,
                                child: ProductCard(
                                  data: product,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailPage(
                                          product: product,
                                          relatedProducts:
                                              widget.relatedProducts,
                                        ),
                                      ),
                                    );
                                  },
                                  onAddToCart: () => _addProductToCart(
                                    product.copy(),
                                    resetSelectedOptions: false,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottomBarHeight,
              child: ProductDetailBottomBar(
                backgroundColor: _brandGreen,
                foregroundColor: Colors.white,
                priceText: 'P $_computedPrice.00',
                onChatTap: () {},
                onCallTap: () {},
                onBuyTap: _addSelectedProductToCart,
              ),
            ),
            Positioned(
              top: 6,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  const Text(
                    'Product Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  CartIconButton(
                    onTap: _openCart,
                    backgroundColor: Colors.white,
                    iconColor: _brandGreen,
                    badgeColor: _brandGreen,
                    badgeTextColor: Colors.white,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 48,
              left: 0,
              right: 0,
              child: Center(
                child: RepaintBoundary(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: ClipOval(
                      child: Image.asset(
                        widget.product.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSelectedProductToCart() {
    _addProductToCart(widget.product, resetSelectedOptions: true);
  }

  void _addProductToCart(
    ProductCardData product, {
    required bool resetSelectedOptions,
  }) {
    CartStore.instance.add(product);

    if (resetSelectedOptions) {
      setState(() {
        _selectedToppings.clear();
        _selectedSize = _sizes.first;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} added to cart'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _ProductDetailPageState._brandGreen : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _ProductDetailPageState._brandGreen),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : _ProductDetailPageState._brandGreen,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DeliveryToggle extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DeliveryToggle({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: selected ? _ProductDetailPageState._brandGreen : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _ProductDetailPageState._brandGreen),
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? Colors.white : _ProductDetailPageState._brandGreen,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _ProductDetailPageState._brandGreen),
      ),
    );
  }
}


