import 'package:flutter/material.dart';

class ProductDetailBottomBar extends StatelessWidget {
  static const double height = 78;

  final Color backgroundColor;
  final Color foregroundColor;
  final String priceText;
  final VoidCallback onChatTap;
  final VoidCallback onCallTap;
  final VoidCallback onBuyTap;

  const ProductDetailBottomBar({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.priceText,
    required this.onChatTap,
    required this.onCallTap,
    required this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ColoredBox(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: _BottomAction(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat Now',
                  onTap: onChatTap,
                ),
              ),
              Expanded(
                child: _BottomAction(
                  icon: Icons.call,
                  label: 'Call Now',
                  onTap: onCallTap,
                ),
              ),
              SizedBox(
                width: 150,
                height: 48,
                child: Material(
                  color: foregroundColor,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: onBuyTap,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Buy with Discount',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: backgroundColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          priceText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: backgroundColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
