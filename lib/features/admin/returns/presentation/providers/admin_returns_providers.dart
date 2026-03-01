import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/admin_returns_datasource.dart';
export '../../data/datasources/admin_returns_datasource.dart';

final adminReturnsDatasourceProvider = Provider<AdminReturnsDatasource>((ref) {
  return const AdminReturnsDatasourceImpl();
});

final adminReturnsListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminReturnsDatasourceProvider).listReturns();
});
