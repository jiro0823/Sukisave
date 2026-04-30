import 'package:flutter/material.dart';
import 'package:sukisave/core/state/cart_store.dart';

class CartIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final double size;
  final double iconSize;
  final BorderRadius? borderRadius;

  const CartIconButton({
    super.key,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
    required this.badgeColor,
    required this.badgeTextColor,
    this.size = 40,
    this.iconSize = 20,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius effectiveRadius =
        borderRadius ?? BorderRadius.circular(size / 2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: effectiveRadius,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.shopping_cart,
                color: iconColor,
                size: iconSize,
              ),
              Positioned(
                top: size <= 32 ? -6 : 4,
                right: size <= 32 ? -8 : 3,
                child: AnimatedBuilder(
                  animation: CartStore.instance,
                  builder: (context, _) {
                    final int totalItems = CartStore.instance.totalItems;

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                          child: child,
                        );
                      },
                      child: totalItems == 0
                          ? const SizedBox.shrink(key: ValueKey('empty-cart'))
                          : _CartBadge(
                              key: ValueKey(totalItems),
                              count: totalItems,
                              backgroundColor: badgeColor,
                              textColor: badgeTextColor,
                            ),
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

class _CartBadge extends StatelessWidget {
  final int count;
  final Color backgroundColor;
  final Color textColor;

  const _CartBadge({
    super.key,
    required this.count,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final String label = count > 99 ? '99+' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
