import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return const AuthRemoteDatasourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
});

final signInNotifierProvider =
    AsyncNotifierProvider<SignInNotifier, void>(SignInNotifier.new);

class SignInNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Failure?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .signInWithEmailPassword(email: email, password: password);

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure;
      },
      (_) {
        state = const AsyncData(null);
        return null;
      },
    );
  }

  Future<Failure?> signOut() async {
    final result = await ref.read(authRepositoryProvider).signOut();
    return result.fold(
      (failure) => failure,
      (_) => null,
    );
  }
}
