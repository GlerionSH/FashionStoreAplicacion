import 'package:supabase_flutter/supabase_flutter.dart';

/// Returns Authorization header map for the current session.
/// Returns an empty map if no session is active.
Map<String, String> authHeaders() {
  final token = Supabase.instance.client.auth.currentSession?.accessToken;
  if (token == null) return {};
  return {'Authorization': 'Bearer $token'};
}
