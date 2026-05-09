import 'package:flutter/material.dart';
import 'package:sukisave/core/widgets/cart_feedback.dart';
import 'package:sukisave/core/widgets/product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductCardData> products;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final ValueChanged<ProductCardData>? onProductTap;
  final ValueChanged<ProductCardData>? onAddToCart;

  const ProductGrid({
    super.key,
    required this.products,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 10,
    this.crossAxisSpacing = 10,
    this.childAspectRatio = 0.78,
    this.onProductTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, color: Color(0xFF9E9E9E)),
            SizedBox(height: 8),
            Text(
              'No products in this category yet',
              style: TextStyle(
                color: Color(0xFF6B6B6B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          data: product,
          onTap: onProductTap == null ? null : () => onProductTap!(product),
          onAddToCart: () {
            if (onAddToCart != null) {
              onAddToCart!(product);
            } else {
              CartFeedback.addProduct(context, product);
            }
          },
        );
      },
    );
  }
}
