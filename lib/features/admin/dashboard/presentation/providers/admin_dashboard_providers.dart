import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/admin_dashboard_datasource.dart';

final adminDashboardDatasourceProvider =
    Provider<AdminDashboardDatasource>((ref) {
  return const AdminDashboardDatasourceImpl();
});

final adminDashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  return ref.watch(adminDashboardDatasourceProvider).getStats();
});
