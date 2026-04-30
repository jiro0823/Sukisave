import 'package:flutter/foundation.dart';
import 'package:sukisave/core/widgets/product_card.dart';

class CartItem {
  final ProductCardData product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartStore extends ChangeNotifier {
  CartStore._();

  static final CartStore instance = CartStore._();

  // 🔥 KEY: productId → CartItem
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get count => _items.length;

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.values.fold(
    0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  void add(ProductCardData product) {
    if (_items.containsKey(product.id)) {
      // 🔥 SHOPEE BEHAVIOR: increase quantity
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }

    notifyListeners();
  }

  void increase(int productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += 1;
      notifyListeners();
    }
  }

  void decrease(int productId) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;

      item.quantity -= 1;

      if (item.quantity <= 0) {
        _items.remove(productId);
      }

      notifyListeners();
    }
  }

  void remove(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeAll(Iterable<int> productIds) {
    var didRemove = false;

    for (final productId in productIds) {
      didRemove = _items.remove(productId) != null || didRemove;
    }

    if (didRemove) {
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
