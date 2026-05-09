import 'package:sqflite/sqflite.dart';
import 'package:sukisave/core/models/vendor_order_request.dart';
import 'package:sukisave/core/services/app_database.dart';
import 'package:sukisave/core/state/vendor_order_store.dart';

class VendorDashboardData {
  final int totalVisitors;
  final int totalOrders;
  final double totalSales;
  final double conversionRate;
  final List<String> todayLabels;
  final List<double> todaySeries;
  final List<String> weeklyLabels;
  final List<double> weeklySeries;
  final List<String> monthlyLabels;
  final List<double> monthlySeries;

  const VendorDashboardData({
    required this.totalVisitors,
    required this.totalOrders,
    required this.totalSales,
    required this.conversionRate,
    required this.todayLabels,
    required this.todaySeries,
    required this.weeklyLabels,
    required this.weeklySeries,
    required this.monthlyLabels,
    required this.monthlySeries,
  });

  factory VendorDashboardData.empty() {
    return const VendorDashboardData(
      totalVisitors: 0,
      totalOrders: 0,
      totalSales: 0,
      conversionRate: 0,
      todayLabels: <String>[],
      todaySeries: <double>[],
      weeklyLabels: <String>[],
      weeklySeries: <double>[],
      monthlyLabels: <String>[],
      monthlySeries: <double>[],
    );
  }
}

class VendorDashboardService {
  final AppDatabase _db = AppDatabase.instance;

  Future<VendorDashboardData> fetch(int vendorId) async {
    if (vendorId <= 0) return VendorDashboardData.empty();

    final db = await _db.database;
    final Set<int> vendorProductIds = await _queryIntSet(
      db,
      'SELECT id FROM products WHERE vendor_id = ?',
      [vendorId],
    );
    final acceptedRequests = VendorOrderStore.instance.requests
        .where(
          (item) =>
              item.isAccepted && vendorProductIds.contains(item.productId),
        )
        .toList();

    final Set<int> visitorIds = await _queryIntSet(
      db,
      '''
      SELECT DISTINCT oi.user_id as id
      FROM order_items oi
      INNER JOIN products p ON p.id = oi.product_id
      WHERE p.vendor_id = ?
      ''',
      [vendorId],
    );
    visitorIds.addAll(
      acceptedRequests
          .map((item) => item.customerUserId)
          .where((userId) => userId > 0),
    );
    final int totalVisitors = visitorIds.length;

    final int paidOrders = await _queryInt(
      db,
      '''
      SELECT COUNT(*) as total
      FROM order_items oi
      INNER JOIN products p ON p.id = oi.product_id
      WHERE p.vendor_id = ?
      ''',
      [vendorId],
    );
    final int totalOrders = paidOrders + acceptedRequests.length;

    final double paidSales = await _queryDouble(
      db,
      '''
      SELECT SUM(oi.price * oi.quantity) as total
      FROM order_items oi
      INNER JOIN products p ON p.id = oi.product_id
      WHERE p.vendor_id = ?
      ''',
      [vendorId],
    );
    final double acceptedSales = acceptedRequests.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final double totalSales = paidSales + acceptedSales;

    final double conversionRate = totalVisitors == 0
        ? 0
        : (totalOrders / totalVisitors) * 100;

    final _Series today = await _buildTodaySeries(
      db,
      vendorId,
      acceptedRequests,
    );
    final _Series weekly = await _buildWeeklySeries(
      db,
      vendorId,
      acceptedRequests,
    );
    final _Series monthly = await _buildMonthlySeries(
      db,
      vendorId,
      acceptedRequests,
    );

    return VendorDashboardData(
      totalVisitors: totalVisitors,
      totalOrders: totalOrders,
      totalSales: totalSales,
      conversionRate: conversionRate,
      todayLabels: today.labels,
      todaySeries: today.values,
      weeklyLabels: weekly.labels,
      weeklySeries: weekly.values,
      monthlyLabels: monthly.labels,
      monthlySeries: monthly.values,
    );
  }

  Future<int> _queryInt(Database db, String sql, List<Object?> args) async {
    final result = await db.rawQuery(sql, args);
    final value = result.isNotEmpty ? result.first['total'] : null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  Future<Set<int>> _queryIntSet(
    Database db,
    String sql,
    List<Object?> args,
  ) async {
    final result = await db.rawQuery(sql, args);
    return result
        .map((row) => row.values.first)
        .whereType<num>()
        .map((value) => value.toInt())
        .toSet();
  }

  Future<double> _queryDouble(
    Database db,
    String sql,
    List<Object?> args,
  ) async {
    final result = await db.rawQuery(sql, args);
    final value = result.isNotEmpty ? result.first['total'] : null;
    if (value is num) return value.toDouble();
    return 0;
  }

  Future<_Series> _buildTodaySeries(
    Database db,
    int vendorId,
    List<VendorOrderRequest> acceptedRequests,
  ) async {
    final now = DateTime.now();
    final buckets = _buildHourBuckets(now, 7);
    final totals = await _querySeries(
      db,
      vendorId,
      "strftime('%H', oi.purchased_at, 'localtime')",
      "DATE(oi.purchased_at, 'localtime') = DATE('now', 'localtime')",
    );

    _addAcceptedToTotals(
      totals,
      acceptedRequests,
      (date) => date.hour.toString().padLeft(2, '0'),
      (date) => _isSameLocalDay(date, now),
    );

    return _seriesFromBuckets(buckets, totals);
  }

  Future<_Series> _buildWeeklySeries(
    Database db,
    int vendorId,
    List<VendorOrderRequest> acceptedRequests,
  ) async {
    final now = DateTime.now();
    final buckets = _buildDayBuckets(now, 7);
    final totals = await _querySeries(
      db,
      vendorId,
      "DATE(oi.purchased_at, 'localtime')",
      "DATE(oi.purchased_at, 'localtime') >= DATE('now', 'localtime', '-6 days')",
    );

    final start = DateTime(now.year, now.month, now.day).subtract(
      const Duration(days: 6),
    );
    _addAcceptedToTotals(
      totals,
      acceptedRequests,
      _formatDateKey,
      (date) => !DateTime(date.year, date.month, date.day).isBefore(start),
    );

    return _seriesFromBuckets(buckets, totals);
  }

  Future<_Series> _buildMonthlySeries(
    Database db,
    int vendorId,
    List<VendorOrderRequest> acceptedRequests,
  ) async {
    final now = DateTime.now();
    final buckets = _buildMonthBuckets(now, 7);
    final totals = await _querySeries(
      db,
      vendorId,
      "strftime('%Y-%m', oi.purchased_at, 'localtime')",
      "DATE(oi.purchased_at, 'localtime') >= DATE('now', 'localtime', 'start of month', '-6 months')",
    );

    final start = DateTime(now.year, now.month - 6, 1);
    _addAcceptedToTotals(
      totals,
      acceptedRequests,
      _formatMonthKey,
      (date) => !DateTime(date.year, date.month, 1).isBefore(start),
    );

    return _seriesFromBuckets(buckets, totals);
  }

  void _addAcceptedToTotals(
    Map<String, double> totals,
    List<VendorOrderRequest> acceptedRequests,
    String Function(DateTime date) bucketFor,
    bool Function(DateTime date) include,
  ) {
    for (final item in acceptedRequests) {
      final DateTime createdAt = item.createdAt;
      if (!include(createdAt)) continue;
      final key = bucketFor(createdAt);
      totals[key] = (totals[key] ?? 0) + item.totalPrice;
    }
  }

  Future<Map<String, double>> _querySeries(
    Database db,
    int vendorId,
    String bucketExpr,
    String whereClause,
  ) async {
    final result = await db.rawQuery(
      '''
      SELECT $bucketExpr as bucket, SUM(oi.price * oi.quantity) as total
      FROM order_items oi
      INNER JOIN products p ON p.id = oi.product_id
      WHERE p.vendor_id = ? AND $whereClause
      GROUP BY bucket
      ''',
      [vendorId],
    );

    final Map<String, double> map = {};
    for (final row in result) {
      final key = row['bucket']?.toString();
      if (key == null) continue;
      final value = row['total'];
      map[key] = value is num ? value.toDouble() : 0.0;
    }
    return map;
  }

  _Series _seriesFromBuckets(
    List<_Bucket> buckets,
    Map<String, double> totals,
  ) {
    final labels = <String>[];
    final values = <double>[];
    for (final bucket in buckets) {
      labels.add(bucket.label);
      values.add(totals[bucket.key] ?? 0.0);
    }
    return _Series(labels, values);
  }

  List<_Bucket> _buildHourBuckets(DateTime now, int count) {
    final buckets = <_Bucket>[];
    for (int i = count - 1; i >= 0; i--) {
      final dt = now.subtract(Duration(hours: i));
      final hour = dt.hour.toString().padLeft(2, '0');
      buckets.add(_Bucket(hour, hour));
    }
    return buckets;
  }

  List<_Bucket> _buildDayBuckets(DateTime now, int count) {
    final buckets = <_Bucket>[];
    for (int i = count - 1; i >= 0; i--) {
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final key = _formatDateKey(dt);
      buckets.add(_Bucket(key, dt.day.toString()));
    }
    return buckets;
  }

  List<_Bucket> _buildMonthBuckets(DateTime now, int count) {
    final buckets = <_Bucket>[];
    for (int i = count - 1; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i, 1);
      final key = _formatMonthKey(dt);
      buckets.add(_Bucket(key, dt.month.toString().padLeft(2, '0')));
    }
    return buckets;
  }

  String _formatDateKey(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$mm-$dd';
  }

  String _formatMonthKey(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    return '${dt.year}-$mm';
  }

  bool _isSameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _Bucket {
  final String key;
  final String label;

  const _Bucket(this.key, this.label);
}

class _Series {
  final List<String> labels;
  final List<double> values;

  const _Series(this.labels, this.values);
}
