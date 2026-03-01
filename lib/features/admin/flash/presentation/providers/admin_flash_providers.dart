import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/admin_flash_datasource.dart';
export '../../data/datasources/admin_flash_datasource.dart';

final adminFlashDatasourceProvider = Provider<AdminFlashDatasource>((ref) {
  return const AdminFlashDatasourceImpl();
});

final adminFlashListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminFlashDatasourceProvider).listFlashOffers();
});
