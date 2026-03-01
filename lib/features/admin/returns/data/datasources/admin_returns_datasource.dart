import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../shared/services/supabase_service.dart';

abstract class AdminReturnsDatasource {
  Future<List<Map<String, dynamic>>> listReturns({int limit = 50});
  Future<void> updateReturnStatus(String returnId, {required String status});
}

class AdminReturnsDatasourceImpl implements AdminReturnsDatasource {
  const AdminReturnsDatasourceImpl();

  @override
  Future<List<Map<String, dynamic>>> listReturns({int limit = 50}) async {
    try {
      // ── admin-returns Edge Function (bypasses RLS via service_role) ──
      final response = await SupabaseService.client.functions.invoke(
        'admin-returns',
        method: HttpMethod.get,
        queryParameters: {'limit': '$limit'},
      );
      if (kDebugMode) debugPrint('[admin-returns GET] status=${response.status}');
      final data = (response.data as Map<String, dynamic>?) ?? {};
      return (data['returns'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    } catch (e) {
      if (kDebugMode) debugPrint('[admin-returns GET] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateReturnStatus(String returnId,
      {required String status}) async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'admin-returns',
        method: HttpMethod.patch,
        body: {'return_id': returnId, 'status': status},
      );
      if (kDebugMode) {
        debugPrint('[admin-returns PATCH] status=${response.status}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[admin-returns PATCH] error: $e');
      rethrow;
    }
  }
}
