class PurchasedProduct {
  final int? id;
  final int userId;
  final int productId;
  final String name;
  final String category;
  final int price;
  final int quantity;
  final String imagePath;
  final DateTime purchasedAt;

  const PurchasedProduct({
    this.id,
    required this.userId,
    required this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.imagePath,
    required this.purchasedAt,
  });

  PurchasedProduct forUser(int userId) {
    return PurchasedProduct(
      id: id,
      userId: userId,
      productId: productId,
      name: name,
      category: category,
      price: price,
      quantity: quantity,
      imagePath: imagePath,
      purchasedAt: purchasedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'image_path': imagePath,
      'purchased_at': purchasedAt.toIso8601String(),
    };
  }

  factory PurchasedProduct.fromMap(Map<String, Object?> map) {
    return PurchasedProduct(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      productId: map['product_id'] as int,
      name: map['name'] as String,
      category: map['category'] as String,
      price: map['price'] as int,
      quantity: map['quantity'] as int,
      imagePath: map['image_path'] as String,
      purchasedAt: DateTime.parse(map['purchased_at'] as String),
    );
  }
}
