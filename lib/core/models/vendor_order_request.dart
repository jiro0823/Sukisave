enum VendorOrderStatus { pending, accepted, denied }

class VendorOrderPaymentItem {
  final int id;
  final String name;
  final String description;
  final int price;
  final int quantity;
  final String imagePath;

  const VendorOrderPaymentItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imagePath,
  });
}

class VendorOrderRequest {
  final int requestId;
  final int productId;
  final int customerUserId;
  final String name;
  final String description;
  final int price;
  final int quantity;
  final String imagePath;
  final DateTime createdAt;
  VendorOrderStatus status;
  String? declineReason;

  VendorOrderRequest({
    required this.requestId,
    required this.productId,
    required this.customerUserId,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imagePath,
    required this.createdAt,
    required this.status,
    this.declineReason,
  });

  int get totalPrice => price * quantity;

  bool get isPending => status == VendorOrderStatus.pending;

  bool get isAccepted => status == VendorOrderStatus.accepted;

  bool get isDenied => status == VendorOrderStatus.denied;

  VendorOrderPaymentItem toPaymentItem() {
    return VendorOrderPaymentItem(
      id: productId,
      name: name,
      description: description,
      price: price,
      quantity: quantity,
      imagePath: imagePath,
    );
  }
}
