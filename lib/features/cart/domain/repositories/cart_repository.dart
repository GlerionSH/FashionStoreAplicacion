import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> load();
  Future<Either<Failure, void>> save(List<CartItem> items);
}
