import '../../../../shared/services/supabase_service.dart';

abstract class AuthRemoteDatasource {
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  const AuthRemoteDatasourceImpl();

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }
}
