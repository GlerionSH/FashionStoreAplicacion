import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';
import '../../data/datasources/orders_remote_datasource.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/repositories/orders_repository.dart';

final ordersRemoteDatasourceProvider = Provider<OrdersRemoteDatasource>((ref) {
  return const OrdersRemoteDatasourceImpl();
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(ref.watch(ordersRemoteDatasourceProvider));
});

final ordersProvider =
    FutureProvider<Either<Failure, List<OrderEntity>>>((ref) {
  final session = ref.watch(authSessionProvider);
  if (session == null) return Future.value(right(const []));
  return ref.watch(ordersRepositoryProvider).listOrders(
        userId: session.user.id,
        email: session.user.email ?? '',
      );
});

final orderDetailProvider =
    FutureProvider.family<Either<Failure, OrderEntity?>, String>(
        (ref, orderId) {
  return ref.watch(ordersRepositoryProvider).getOrderById(orderId);
});

final orderItemsProvider =
    FutureProvider.family<Either<Failure, List<OrderItemEntity>>, String>(
        (ref, orderId) {
  return ref.watch(ordersRepositoryProvider).getOrderItems(orderId);
});
