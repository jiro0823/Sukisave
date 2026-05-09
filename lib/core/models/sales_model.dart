class SalesModel {
  final int? id;
  final String productName;
  final int quantity;
  final int sold;
  final String date;

  SalesModel({
    this.id,
    required this.productName,
    required this.quantity,
    required this.sold,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_name': productName,
      'quantity': quantity,
      'sold': sold,
      'date': date,
    };
  }

  factory SalesModel.fromMap(Map<String, dynamic> map) {
    return SalesModel(
      id: map['id'],
      productName: map['product_name'],
      quantity: map['quantity'],
      sold: map['sold'],
      date: map['date'],
    );
  }
}
