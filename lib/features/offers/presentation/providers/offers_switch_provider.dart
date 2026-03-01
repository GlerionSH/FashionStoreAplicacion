import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/supabase_service.dart';

final offersSwitchProvider = StreamProvider<bool>((ref) {
  final stream = SupabaseService.client
      .from('fs_settings')
      .stream(primaryKey: ['id'])
      .eq('singleton', true)
      .limit(1);

  return stream.map((rows) {
    if (rows.isEmpty) return false;

    final row = rows.first;
    final value = row['flash_offers_enabled'];

    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }

    return false;
  });
});
