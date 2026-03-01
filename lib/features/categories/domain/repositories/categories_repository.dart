import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../entities/category.dart';

abstract class CategoriesRepository {
  Future<Either<Failure, List<Category>>> listCategories();
}
