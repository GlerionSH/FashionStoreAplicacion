import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    int limit = 20,
    int offset = 0,
    String? categoryId,
    String? search,
  });
  Future<Either<Failure, Product?>> getBySlug(String slug);
  Future<Either<Failure, List<Product>>> getFlashProducts();
}
