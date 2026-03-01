import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_remote_datasource.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDatasource remote;

  const CategoriesRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<Category>>> listCategories() async {
    try {
      final models = await remote.listCategories();
      return right(models.map((m) => m.toEntity()).toList());
    } on SocketException catch (e) {
      return left(NetworkFailure(e.message));
    } on PostgrestException catch (e) {
      return left(NetworkFailure(e.message));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }
}
