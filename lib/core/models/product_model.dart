class Product {
  final int? id;
  final int vendorId;
  final String name;
  final double price;
  final String description;
  final int quantity;
  final String category;
  final String imagePath;
  final DateTime expiresAt;
  final DateTime createdAt;

  Product({
    this.id,
    required this.vendorId,
    required this.name,
    required this.price,
    required this.description,
    required this.quantity,
    required this.category,
    required this.imagePath,
    required this.expiresAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'name': name,
      'price': price,
      'description': description,
      'quantity': quantity,
      'category': category,
      'image_path': imagePath,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      vendorId: map['vendor_id'],
      name: map['name'],
      price: map['price'],
      description: map['description'] ?? '',
      quantity: map['quantity'],
      category: map['category'],
      imagePath: map['image_path'],
      expiresAt: DateTime.parse(map['expires_at']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
