import 'package:sukisave/core/models/product_model.dart';
import 'package:sukisave/core/services/app_database.dart';

class ProductService {
  final AppDatabase _db = AppDatabase.instance;
  static final ProductStockNotifier stockChanges = ProductStockNotifier();

  Future<int> insert(Product product) async {
    final db = await _db.database;
    final id = await db.insert('products', product.toMap());
    stockChanges.notify();
    return id;
  }

  Future<List<Product>> getAll() async {
    final db = await _db.database;
    final result = await db.query(
      'products',
      orderBy: 'created_at DESC, id DESC',
    );
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<Product>> getForVendor(int vendorId) async {
    final db = await _db.database;
    final result = await db.query(
      'products',
      where: 'vendor_id = ?',
      whereArgs: [vendorId],
      orderBy: 'created_at DESC, id DESC',
    );
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<Product?> getById(int id) async {
    final db = await _db.database;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Product.fromMap(result.first);
  }

  Future<int?> reserveQuantity(int id, {int amount = 1}) async {
    if (amount <= 0) return null;

    final db = await _db.database;
    final int? quantityLeft = await db.transaction<int?>((txn) async {
      final updated = await txn.rawUpdate(
        '''
        UPDATE products
        SET quantity = quantity - ?
        WHERE id = ? AND quantity >= ?
        ''',
        [amount, id, amount],
      );

      if (updated == 0) return null;

      final rows = await txn.query(
        'products',
        columns: ['quantity'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return rows.first['quantity'] as int;
    });

    if (quantityLeft != null) {
      stockChanges.notify();
    }

    return quantityLeft;
  }

  Future<int?> restoreQuantity(int id, {int amount = 1}) async {
    if (amount <= 0) return null;

    final db = await _db.database;
    final int? quantityLeft = await db.transaction<int?>((txn) async {
      final updated = await txn.rawUpdate(
        'UPDATE products SET quantity = quantity + ? WHERE id = ?',
        [amount, id],
      );
      if (updated == 0) return null;

      final rows = await txn.query(
        'products',
        columns: ['quantity'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return rows.first['quantity'] as int;
    });

    if (quantityLeft != null) {
      stockChanges.notify();
    }

    return quantityLeft;
  }

  Future<int> update(Product product) async {
    final db = await _db.database;
    final updated = await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    stockChanges.notify();
    return updated;
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    final deleted = await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    stockChanges.notify();
    return deleted;
  }
}

class ProductStockNotifier {
  final List<void Function()> _listeners = [];

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void notify() {
    for (final listener in List<void Function()>.from(_listeners)) {
      listener();
    }
  }
}
