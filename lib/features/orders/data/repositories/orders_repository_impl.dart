import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDatasource remote;

  const OrdersRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<OrderEntity>>> listOrders({
    required String userId,
    required String email,
  }) async {
    try {
      final models = await remote.listOrders(userId: userId, email: email);
      return right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity?>> getOrderById(String orderId) async {
    try {
      final model = await remote.getOrderById(orderId);
      return right(model?.toEntity());
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderItemEntity>>> getOrderItems(
      String orderId) async {
    try {
      final models = await remote.getOrderItems(orderId);
      return right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }
}
