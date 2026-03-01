import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../shared/services/supabase_service.dart';

abstract class AdminOrdersDatasource {
  Future<List<Map<String, dynamic>>> listOrders(
      {int limit = 50, int offset = 0});
  Future<Map<String, dynamic>> getOrder(String orderId);
  Future<void> updateOrderStatus(String orderId, {required String status});
}

class AdminOrdersDatasourceImpl implements AdminOrdersDatasource {
  const AdminOrdersDatasourceImpl();

  @override
  Future<List<Map<String, dynamic>>> listOrders(
      {int limit = 50, int offset = 0}) async {
    try {
      // ── admin-orders Edge Function (bypasses RLS via service_role) ──
      final response = await SupabaseService.client.functions.invoke(
        'admin-orders',
        method: HttpMethod.get,
        queryParameters: {'limit': '$limit', 'offset': '$offset'},
      );
      if (kDebugMode) {
        debugPrint('[admin-orders GET] status=${response.status}');
      }
      final data = (response.data as Map<String, dynamic>?) ?? {};
      return (data['orders'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    } catch (e) {
      if (kDebugMode) debugPrint('[admin-orders GET] error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'admin-orders',
        method: HttpMethod.get,
        queryParameters: {'order_id': orderId},
      );
      if (kDebugMode) {
        debugPrint('[admin-orders detail] status=${response.status}');
      }
      final data = (response.data as Map<String, dynamic>?) ?? {};
      return (data['order'] as Map<String, dynamic>?) ?? {};
    } catch (e) {
      if (kDebugMode) debugPrint('[admin-orders detail] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId,
      {required String status}) async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'admin-orders',
        method: HttpMethod.patch,
        body: {'order_id': orderId, 'status': status},
      );
      if (kDebugMode) {
        debugPrint('[admin-orders PATCH] status=${response.status}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[admin-orders PATCH] error: $e');
      rethrow;
    }
  }
}
