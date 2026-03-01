import 'package:fpdart/fpdart.dart';

import '../../../../shared/exceptions/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();
}
