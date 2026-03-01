import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/admin_settings_datasource.dart';
export '../../data/datasources/admin_settings_datasource.dart';

final adminSettingsDatasourceProvider = Provider<AdminSettingsDatasource>((ref) {
  return const AdminSettingsDatasourceImpl();
});

final adminSettingsProvider =
    FutureProvider<Map<String, dynamic>?>((ref) {
  return ref.watch(adminSettingsDatasourceProvider).getSingletonSettings();
});
