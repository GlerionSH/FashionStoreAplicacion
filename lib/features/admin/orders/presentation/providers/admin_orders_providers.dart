import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/admin_orders_datasource.dart';
export '../../data/datasources/admin_orders_datasource.dart';

final adminOrdersDatasourceProvider = Provider<AdminOrdersDatasource>((ref) {
  return const AdminOrdersDatasourceImpl();
});

final adminOrdersListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminOrdersDatasourceProvider).listOrders();
});

final adminOrderDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) {
  return ref.watch(adminOrdersDatasourceProvider).getOrder(orderId);
});
