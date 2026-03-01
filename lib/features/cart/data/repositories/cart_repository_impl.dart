import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDatasource local;

  const CartRepositoryImpl(this.local);

  @override
  Future<Either<Failure, List<CartItem>>> load() async {
    try {
      final models = await local.load();
      return right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> save(List<CartItem> items) async {
    try {
      final models = items.map(CartItemModel.fromEntity).toList();
      await local.save(models);
      return right(null);
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }
}
