import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../entities/order_entity.dart';
import '../entities/order_item_entity.dart';

abstract class OrdersRepository {
  Future<Either<Failure, List<OrderEntity>>> listOrders({
    required String userId,
    required String email,
  });
  Future<Either<Failure, OrderEntity?>> getOrderById(String orderId);
  Future<Either<Failure, List<OrderItemEntity>>> getOrderItems(String orderId);
}
