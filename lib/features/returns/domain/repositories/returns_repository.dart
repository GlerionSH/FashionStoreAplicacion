import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../data/datasources/returns_remote_datasource.dart';
import '../entities/return_entity.dart';

abstract class ReturnsRepository {
  Future<Either<Failure, List<ReturnEntity>>> getMyReturns();

  Future<Either<Failure, String>> requestReturn({
    required String orderId,
    String? reason,
    required List<ReturnRequestItem> items,
  });
}
