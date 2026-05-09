import 'package:flutter/material.dart';
import 'package:sukisave/core/state/cart_store.dart';
import 'package:sukisave/core/widgets/product_card.dart';

class CartFeedback {
  CartFeedback._();

  static Future<CartMutationResult> addProduct(
    BuildContext context,
    ProductCardData product,
  ) async {
    final result = await CartStore.instance.add(product);
    if (!context.mounted) return result;

    if (result.isSoldOut) {
      await showSoldOutDialog(context, product);
      return result;
    }

    _showAddedOverlay(context, product);
    return result;
  }

  static Future<void> showSoldOutDialog(
    BuildContext context,
    ProductCardData product,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Sold out'),
          content: Text('${product.title} is currently sold out.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void _showAddedOverlay(BuildContext context, ProductCardData product) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) {
        return _CartAddedOverlay(
          productName: product.title,
          onFinished: () => entry.remove(),
        );
      },
    );

    overlay.insert(entry);
  }
}

class _CartAddedOverlay extends StatefulWidget {
  final String productName;
  final VoidCallback onFinished;

  const _CartAddedOverlay({
    required this.productName,
    required this.onFinished,
  });

  @override
  State<_CartAddedOverlay> createState() => _CartAddedOverlayState();
}

class _CartAddedOverlayState extends State<_CartAddedOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 18),
      TweenSequenceItem(tween: ConstantTween(1), weight: 52),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 30),
    ]).animate(_controller);

    _controller
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onFinished();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value,
            child: Center(
              child: Transform.scale(
                scale: 0.74 + (_scale.value * 0.26),
                child: child,
              ),
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F5513),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 46,
                    ),
                    Positioned(
                      top: 3,
                      right: 2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Color(0xFF0F5513),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.productName} added',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
