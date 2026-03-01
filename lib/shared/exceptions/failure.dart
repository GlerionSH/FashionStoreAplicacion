sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class CorsFailure extends Failure {
  const CorsFailure(super.message);
}

class RlsFailure extends Failure {
  final String? sqlHint;
  const RlsFailure(super.message, {this.sqlHint});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
