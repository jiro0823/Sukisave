import 'package:flutter/foundation.dart';
import 'package:sukisave/core/services/product_service.dart';
import 'package:sukisave/core/widgets/product_card.dart';

class CartItem {
  final ProductCardData product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartStore extends ChangeNotifier {
  CartStore._();

  static final CartStore instance = CartStore._();
  final ProductService _productService = ProductService();

  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get count => _items.length;

  int get totalItems =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.values.fold(
    0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  Future<CartMutationResult> add(ProductCardData product) async {
    final quantityLeft = await _productService.reserveQuantity(product.id);
    if (quantityLeft == null) {
      return const CartMutationResult.soldOut();
    }

    final reservedProduct = product.copyWith(quantityLeft: quantityLeft);

    if (_items.containsKey(product.id)) {
      final current = _items[product.id]!;
      _items[product.id] = CartItem(
        product: reservedProduct,
        quantity: current.quantity + 1,
      );
    } else {
      _items[product.id] = CartItem(product: reservedProduct, quantity: 1);
    }

    notifyListeners();
    return CartMutationResult.added(quantityLeft);
  }

  Future<CartMutationResult> increase(int productId) async {
    final item = _items[productId];
    if (item == null) {
      return const CartMutationResult.notFound();
    }

    return add(item.product);
  }

  Future<CartMutationResult> decrease(int productId) async {
    final item = _items[productId];
    if (item == null) {
      return const CartMutationResult.notFound();
    }

    final quantityLeft = await _productService.restoreQuantity(productId);
    item.quantity -= 1;

    if (item.quantity <= 0) {
      _items.remove(productId);
    } else if (quantityLeft != null) {
      _items[productId] = CartItem(
        product: item.product.copyWith(quantityLeft: quantityLeft),
        quantity: item.quantity,
      );
    }

    notifyListeners();
    return CartMutationResult.restored(quantityLeft);
  }

  Future<void> remove(int productId, {bool restoreStock = true}) async {
    final item = _items.remove(productId);
    if (item == null) return;

    if (restoreStock) {
      await _productService.restoreQuantity(productId, amount: item.quantity);
    }

    notifyListeners();
  }

  Future<void> removeAll(
    Iterable<int> productIds, {
    bool restoreStock = true,
  }) async {
    var didRemove = false;

    for (final productId in productIds) {
      final item = _items.remove(productId);
      if (item == null) continue;
      didRemove = true;

      if (restoreStock) {
        await _productService.restoreQuantity(productId, amount: item.quantity);
      }
    }

    if (didRemove) {
      notifyListeners();
    }
  }

  Future<void> clear({bool restoreStock = true}) async {
    if (restoreStock) {
      for (final item in _items.values) {
        await _productService.restoreQuantity(
          item.product.id,
          amount: item.quantity,
        );
      }
    }

    _items.clear();
    notifyListeners();
  }
}

enum CartMutationStatus { added, restored, soldOut, notFound }

class CartMutationResult {
  final CartMutationStatus status;
  final int? quantityLeft;

  const CartMutationResult._(this.status, this.quantityLeft);

  const CartMutationResult.added(int quantityLeft)
    : this._(CartMutationStatus.added, quantityLeft);

  const CartMutationResult.restored(int? quantityLeft)
    : this._(CartMutationStatus.restored, quantityLeft);

  const CartMutationResult.soldOut() : this._(CartMutationStatus.soldOut, null);

  const CartMutationResult.notFound()
    : this._(CartMutationStatus.notFound, null);

  bool get isAdded => status == CartMutationStatus.added;
  bool get isSoldOut => status == CartMutationStatus.soldOut;
}
