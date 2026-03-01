import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_session_providers.dart';

/// Fetches tickets for the currently logged-in user, ordered by newest first.
final myTicketsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final session = ref.watch(authSessionProvider);
  if (session == null) return [];

  final userId = session.user.id;
  final result = await Supabase.instance.client
      .from('fs_support_tickets')
      .select('id,subject,status,created_at')
      .eq('user_id', userId)
      .order('created_at', ascending: false);

  return (result as List).cast<Map<String, dynamic>>();
});

/// Fetches a single ticket + its replies.
final ticketDetailProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, ticketId) async {
    final client = Supabase.instance.client;

    final ticket = await client
        .from('fs_support_tickets')
        .select()
        .eq('id', ticketId)
        .maybeSingle();

    final replies = await client
        .from('fs_support_replies')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);

    return {
      'ticket': ticket,
      'replies': (replies as List).cast<Map<String, dynamic>>(),
    };
  },
);
