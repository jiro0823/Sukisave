import 'package:sukisave/core/models/product_model.dart';
import 'package:sukisave/core/widgets/product_card.dart';

ProductCardData mapProductToCard(Product product) {
  return ProductCardData(
    id: product.id ?? 0,
    title: product.name,
    price: product.price.round(),
    category: product.category,
    quantityLeft: product.quantity,
    expiresAt: product.expiresAt,
    imagePath: product.imagePath,
  );
}
