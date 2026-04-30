import 'package:sqflite/sqflite.dart';
import 'package:sukisave/core/models/purchased_product.dart';

import 'app_database.dart';
import 'auth_service.dart';

class OrderHistoryService {
  OrderHistoryService._();

  static final OrderHistoryService instance = OrderHistoryService._();

  Future<int> _currentUserId() async {
    final user = AuthService.instance.currentUser ??
        await AuthService.instance.restoreSession();
    return user?.id ?? 0;
  }

  Future<void> savePaidItems(List<PurchasedProduct> items) async {
    if (items.isEmpty) return;

    final int userId = await _currentUserId();
    final Database db = await AppDatabase.instance.database;
    final Batch batch = db.batch();

    for (final item in items) {
      batch.insert(
        'order_items',
        item.forUser(userId).toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<PurchasedProduct>> fetchCurrentUserOrders() async {
    final int userId = await _currentUserId();
    final Database db = await AppDatabase.instance.database;
    final rows = await db.query(
      'order_items',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'purchased_at DESC, id DESC',
    );

    return rows.map(PurchasedProduct.fromMap).toList();
  }
}
