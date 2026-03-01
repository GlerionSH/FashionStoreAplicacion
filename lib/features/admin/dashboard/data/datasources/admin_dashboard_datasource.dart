import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../shared/services/supabase_service.dart';

class DashboardStats {
  final int totalOrders;
  final int totalRevenueCents;
  final int returnsLossCents;
  final int netRevenueCents;
  final int pendingReturns;
  final int activeProducts;
  final List<Map<String, dynamic>> recentOrders;

  const DashboardStats({
    required this.totalOrders,
    required this.totalRevenueCents,
    required this.returnsLossCents,
    required this.netRevenueCents,
    required this.pendingReturns,
    required this.activeProducts,
    required this.recentOrders,
  });
}

abstract class AdminDashboardDatasource {
  Future<DashboardStats> getStats();
}

class AdminDashboardDatasourceImpl implements AdminDashboardDatasource {
  const AdminDashboardDatasourceImpl();

  @override
  Future<DashboardStats> getStats() async {
    try {
      // ── Call admin-metrics Edge Function (uses service_role server-side) ──
      final response = await SupabaseService.client.functions.invoke(
        'admin-metrics',
        method: HttpMethod.get,
      );
      if (kDebugMode) {
        debugPrint(
            '[admin-metrics] status=${response.status} data=${response.data}');
      }
      final data = (response.data as Map<String, dynamic>?) ?? {};
      return DashboardStats(
        totalOrders: (data['total_orders'] as num?)?.toInt() ?? 0,
        totalRevenueCents: (data['revenue_cents'] as num?)?.toInt() ?? 0,
        returnsLossCents: (data['returns_loss_cents'] as num?)?.toInt() ?? 0,
        netRevenueCents: (data['net_revenue_cents'] as num?)?.toInt() ?? 0,
        pendingReturns: (data['pending_returns'] as num?)?.toInt() ?? 0,
        activeProducts: (data['active_products'] as num?)?.toInt() ?? 0,
        recentOrders: (data['recent_orders'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [],
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[admin-metrics] invoke error: $e');
      rethrow;
    }
  }
}
