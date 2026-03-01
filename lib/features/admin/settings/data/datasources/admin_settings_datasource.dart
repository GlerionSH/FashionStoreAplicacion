import '../../../../../shared/services/supabase_service.dart';

abstract class AdminSettingsDatasource {
  Future<Map<String, dynamic>?> getSingletonSettings();
  Future<void> updateFlashEnabled({required bool enabled});
}

class AdminSettingsDatasourceImpl implements AdminSettingsDatasource {
  const AdminSettingsDatasourceImpl();

  @override
  Future<Map<String, dynamic>?> getSingletonSettings() async {
    final result = await SupabaseService.client
        .from('fs_settings')
        .select()
        .eq('singleton', true)
        .maybeSingle();

    return result;
  }

  @override
  Future<void> updateFlashEnabled({required bool enabled}) async {
    await SupabaseService.client
        .from('fs_settings')
        .update({'flash_offers_enabled': enabled}).eq('singleton', true);
  }
}
