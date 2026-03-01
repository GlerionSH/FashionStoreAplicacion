import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';
import '../../data/datasources/returns_remote_datasource.dart';
import '../../data/repositories/returns_repository_impl.dart';
import '../../domain/entities/return_entity.dart';
import '../../domain/repositories/returns_repository.dart';

final returnsRemoteDatasourceProvider =
    Provider<ReturnsRemoteDatasource>((ref) {
  return const ReturnsRemoteDatasourceImpl();
});

final returnsRepositoryProvider = Provider<ReturnsRepository>((ref) {
  return ReturnsRepositoryImpl(ref.watch(returnsRemoteDatasourceProvider));
});

/// List of the current user's returns.
final myReturnsProvider =
    FutureProvider<Either<Failure, List<ReturnEntity>>>((ref) {
  final session = ref.watch(authSessionProvider);
  if (session == null) return Future.value(right(const <ReturnEntity>[]));
  return ref.watch(returnsRepositoryProvider).getMyReturns();
});

/// Notifier for requesting a new return.
final returnRequestNotifierProvider =
    AsyncNotifierProvider<ReturnRequestNotifier, String?>(
        ReturnRequestNotifier.new);

class ReturnRequestNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<Failure?> submitRequest({
    required String orderId,
    String? reason,
    required List<ReturnRequestItem> items,
  }) async {
    state = const AsyncLoading();

    final session = ref.read(authSessionProvider);
    if (session == null) {
      const f = AuthFailure('Inicia sesión para solicitar una devolución');
      state = AsyncError(f, StackTrace.current);
      return f;
    }

    final result =
        await ref.read(returnsRepositoryProvider).requestReturn(
              orderId: orderId,
              reason: reason,
              items: items,
            );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure;
      },
      (returnId) {
        state = AsyncData(returnId);
        ref.invalidate(myReturnsProvider);
        return null;
      },
    );
  }
}
