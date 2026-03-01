import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../domain/entities/return_entity.dart';
import '../../domain/repositories/returns_repository.dart';
import '../datasources/returns_remote_datasource.dart';

class ReturnsRepositoryImpl implements ReturnsRepository {
  final ReturnsRemoteDatasource remote;

  const ReturnsRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<ReturnEntity>>> getMyReturns() async {
    try {
      final returns = await remote.getMyReturns();
      return right(returns);
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestReturn({
    required String orderId,
    String? reason,
    required List<ReturnRequestItem> items,
  }) async {
    try {
      final returnId = await remote.requestReturn(
        orderId: orderId,
        reason: reason,
        items: items,
      );
      return right(returnId);
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }
}
