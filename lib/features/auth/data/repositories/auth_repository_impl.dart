import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/exceptions/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;

  const AuthRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, void>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await remote.signInWithEmailPassword(email: email, password: password);
      return right(null);
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remote.signOut();
      return right(null);
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }
}
