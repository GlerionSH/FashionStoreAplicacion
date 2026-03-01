import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/services/supabase_service.dart';
import '../../../profiles/data/models/profile_model.dart';
import '../../../profiles/domain/entities/profile.dart';

final authSessionProvider = Provider<Session?>((ref) {
  final sub = SupabaseService.client.auth.onAuthStateChange.listen((event) {
    ref.invalidateSelf();
  });
  ref.onDispose(sub.cancel);
  return SupabaseService.client.auth.currentSession;
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final session = ref.watch(authSessionProvider);
  if (session?.user == null) return null;

  final userId = session!.user.id;

  Map<String, dynamic>? row;

  try {
    row = await SupabaseService.client
        .from('fs_profiles')
        .select('id,role')
        .eq('user_id', userId)
        .maybeSingle();
  } catch (_) {
    row = null;
  }

  row ??= await SupabaseService.client
      .from('fs_profiles')
      .select('id,role')
      .eq('id', userId)
      .maybeSingle();

  if (row == null) return null;
  return ProfileModel.fromJson(row).toEntity();
});

final isAdminProvider = Provider<bool>((ref) {
  final profileAv = ref.watch(currentProfileProvider);
  final role = profileAv.asData?.value?.role;
  return role == 'admin';
});
