import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../shared/services/supabase_service.dart';

abstract class AdminFlashDatasource {
  Future<List<Map<String, dynamic>>> listFlashOffers();
  Future<void> upsertFlashOffer(Map<String, dynamic> data);
  Future<void> deleteFlashOffer(String id);
  Future<void> toggleEnabled(String id, {required bool enabled});
  Future<void> disableAllExcept(String id);
}

class AdminFlashDatasourceImpl implements AdminFlashDatasource {
  const AdminFlashDatasourceImpl();

  @override
  Future<List<Map<String, dynamic>>> listFlashOffers() async {
    try {
      // ── admin-flash Edge Function (bypasses RLS via service_role) ──
      final response = await SupabaseService.client.functions.invoke(
        'admin-flash',
        method: HttpMethod.get,
      );
      if (kDebugMode) debugPrint('[admin-flash GET] status=${response.status}');
      final data = (response.data as Map<String, dynamic>?) ?? {};
      return (data['offers'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    } catch (e) {
      if (kDebugMode) debugPrint('[admin-flash GET] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> upsertFlashOffer(Map<String, dynamic> data) async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'admin-flash',
        method: HttpMethod.post,
        body: data,
      );
      if (kDebugMode) debugPrint('[admin-flash POST] status=${response.status}');
    } catch (e) {
      if (kDebugMode) debugPrint('[admin-flash POST] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteFlashOffer(String id) async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'admin-flash',
        method: HttpMethod.delete,
        body: {'id': id},
      );
      if (kDebugMode) {
        debugPrint('[admin-flash DELETE] status=${response.status}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[admin-flash DELETE] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleEnabled(String id, {required bool enabled}) async {
    try {
      // Disable-others logic is handled server-side in the Edge Function
      final response = await SupabaseService.client.functions.invoke(
        'admin-flash',
        method: HttpMethod.patch,
        body: {'id': id, 'is_enabled': enabled},
      );
      if (kDebugMode) {
        debugPrint('[admin-flash PATCH] status=${response.status}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[admin-flash PATCH] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> disableAllExcept(String id) async {
    // No-op: handled server-side inside upsertFlashOffer / toggleEnabled
  }
}
