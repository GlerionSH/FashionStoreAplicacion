import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../data/datasources/categories_remote_datasource.dart';
import '../../data/repositories/categories_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';

final categoriesRemoteDatasourceProvider = Provider<CategoriesRemoteDatasource>((ref) {
  return const CategoriesRemoteDatasourceImpl();
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepositoryImpl(ref.watch(categoriesRemoteDatasourceProvider));
});

final categoriesProvider = FutureProvider<Either<Failure, List<Category>>>((ref) {
  return ref.watch(categoriesRepositoryProvider).listCategories();
});
