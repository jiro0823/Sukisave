import 'package:sukisave/core/models/sales_model.dart';
import 'package:sukisave/core/services/app_database.dart';
import 'package:sukisave/core/state/vendor_order_store.dart';

class SalesService {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<SalesModel>> getSales(String filter, int vendorId) async {
    if (vendorId <= 0) return [];

    final db = await _db.database;
    final String dateFilter = _buildDateFilter(filter, 'oi.purchased_at');

    final result = await db.rawQuery(
      '''
      SELECT
        oi.name as product_name,
        SUM(oi.quantity) as quantity,
        SUM(oi.price * oi.quantity) as sold,
        MIN(oi.purchased_at) as date
      FROM order_items oi
      INNER JOIN products p ON p.id = oi.product_id
      WHERE p.vendor_id = ? AND $dateFilter
      GROUP BY oi.product_id, oi.name
      ORDER BY sold DESC
      ''',
      [vendorId],
    );

    final salesByName = <String, SalesModel>{};
    for (final row in result) {
      final sale = SalesModel.fromMap(Map<String, dynamic>.from(row));
      salesByName[sale.productName] = sale;
    }

    final vendorProductIds = await _vendorProductIds(vendorId);
    for (final request in VendorOrderStore.instance.requests.where(
      (item) =>
          item.isAccepted &&
          vendorProductIds.contains(item.productId) &&
          _matchesFilter(filter, item.createdAt),
    )) {
      final existing = salesByName[request.name];
      salesByName[request.name] = SalesModel(
        productName: request.name,
        quantity: (existing?.quantity ?? 0) + request.quantity,
        sold: (existing?.sold ?? 0) + request.totalPrice,
        date: existing?.date ?? request.createdAt.toIso8601String(),
      );
    }

    final sales = salesByName.values.toList()
      ..sort((a, b) => b.sold.compareTo(a.sold));
    return sales;
  }

  Future<double> calculateProgress(
    int target,
    String filter,
    int vendorId,
  ) async {
    if (vendorId <= 0 || target <= 0) return 0.0;

    final db = await _db.database;
    final String dateFilter = _buildDateFilter(filter, 'oi.purchased_at');

    final result = await db.rawQuery(
      '''
      SELECT SUM(oi.quantity) as total
      FROM order_items oi
      INNER JOIN products p ON p.id = oi.product_id
      WHERE p.vendor_id = ? AND $dateFilter
      ''',
      [vendorId],
    );

    final totalValue = result.first['total'];
    final paidTotal = totalValue is num ? totalValue.toInt() : 0;
    final vendorProductIds = await _vendorProductIds(vendorId);
    final acceptedTotal = VendorOrderStore.instance.requests
        .where(
          (item) =>
              item.isAccepted &&
              vendorProductIds.contains(item.productId) &&
              _matchesFilter(filter, item.createdAt),
        )
        .fold<int>(0, (sum, item) => sum + item.quantity);

    return (paidTotal + acceptedTotal) / target;
  }

  String _buildDateFilter(String filter, String column) {
    if (filter == "Today") {
      return "DATE($column) = DATE('now')";
    }
    if (filter == "Weekly") {
      return "strftime('%W', $column) = strftime('%W', 'now') AND strftime('%Y', $column) = strftime('%Y', 'now')";
    }
    return "strftime('%m', $column) = strftime('%m', 'now') AND strftime('%Y', $column) = strftime('%Y', 'now')";
  }

  Future<Set<int>> _vendorProductIds(int vendorId) async {
    final db = await _db.database;
    final rows = await db.query(
      'products',
      columns: ['id'],
      where: 'vendor_id = ?',
      whereArgs: [vendorId],
    );
    return rows
        .map((row) => row['id'])
        .whereType<num>()
        .map((value) => value.toInt())
        .toSet();
  }

  bool _matchesFilter(String filter, DateTime date) {
    final now = DateTime.now();
    if (filter == "Today") {
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }
    if (filter == "Weekly") {
      final start = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 6));
      return !DateTime(date.year, date.month, date.day).isBefore(start);
    }
    return date.year == now.year && date.month == now.month;
  }
}
