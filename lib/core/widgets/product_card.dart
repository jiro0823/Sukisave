import 'package:flutter/material.dart';
import 'package:sukisave/core/widgets/app_image.dart';

class ProductCardData {
  final int id;
  final String title;
  final int price;
  final String category;
  final int quantityLeft;
  final DateTime expiresAt;
  final String imagePath;

  ProductCardData copy() {
    return ProductCardData(
      id: id,
      title: title,
      price: price,
      category: category,
      quantityLeft: quantityLeft,
      expiresAt: expiresAt,
      imagePath: imagePath,
    );
  }

  ProductCardData copyWith({int? quantityLeft}) {
    return ProductCardData(
      id: id,
      title: title,
      price: price,
      category: category,
      quantityLeft: quantityLeft ?? this.quantityLeft,
      expiresAt: expiresAt,
      imagePath: imagePath,
    );
  }

  const ProductCardData({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.quantityLeft,
    required this.expiresAt,
    required this.imagePath,
  });
}

class ProductCard extends StatelessWidget {
  final ProductCardData data;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.data,
    this.onTap,
    this.onAddToCart,
  });

  static const Color _brandGreen = Color(0xFF0F5513);

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

  @override
  Widget build(BuildContext context) {
    final bool isSoldOut = data.quantityLeft <= 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 200, // 🔥 controls total card height
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      color: _brandGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_offer,
                      size: 14,
                      color: _brandGreen,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          isSoldOut ? 'Sold out' : '${data.quantityLeft} left',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatRemaining(data.expiresAt),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppImage(
                    path: data.imagePath,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Expanded(
                flex: 3,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'P ${data.price}.00',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B6B6B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // RIGHT BUTTONS
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 26,
                          child: ElevatedButton(
                            onPressed: onAddToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSoldOut
                                  ? const Color(0xFF9E9E9E)
                                  : _brandGreen,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              shape: const StadiumBorder(),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              isSoldOut ? 'Sold out' : 'Buy now',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'See more',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
