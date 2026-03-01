import '../../../../shared/services/supabase_service.dart';
import '../../domain/entities/flash_offer.dart';

abstract class FlashOffersRemoteDatasource {
  /// Fetches the currently active flash offer from Supabase.
  /// Returns null if flash offers are disabled or no active offer exists.
  /// Logic matches Astro src/lib/flashOffer.ts getActiveFlashOffer().
  Future<FlashOffer?> getActiveOffer();
}

class FlashOffersRemoteDatasourceImpl implements FlashOffersRemoteDatasource {
  const FlashOffersRemoteDatasourceImpl();

  @override
  Future<FlashOffer?> getActiveOffer() async {
    final sb = SupabaseService.client;

    // 1. Check fs_settings.flash_offers_enabled
    final settingsRow = await sb
        .from('fs_settings')
        .select('flash_offers_enabled')
        .eq('singleton', true)
        .maybeSingle();

    if (settingsRow == null) return null;
    final enabled = settingsRow['flash_offers_enabled'];
    if (enabled != true) return null;

    // 2. Fetch enabled offers ordered by updated_at desc (limit 10, like Astro)
    final rows = await sb
        .from('fs_flash_offers')
        .select('id,is_enabled,discount_percent,starts_at,ends_at,'
            'show_popup,popup_title,popup_text,updated_at')
        .eq('is_enabled', true)
        .order('updated_at', ascending: false)
        .limit(10);

    final list = rows as List;
    if (list.isEmpty) return null;

    final now = DateTime.now();

    for (final raw in list) {
      final discountPercent = (raw['discount_percent'] as num?)?.toInt() ?? 0;
      if (discountPercent <= 0) continue;

      final startsAt = raw['starts_at'] != null
          ? DateTime.tryParse(raw['starts_at'] as String)
          : null;
      final endsAt = raw['ends_at'] != null
          ? DateTime.tryParse(raw['ends_at'] as String)
          : null;

      final startOk = startsAt == null || !startsAt.isAfter(now);
      final endOk = endsAt == null || !endsAt.isBefore(now);

      if (startOk && endOk) {
        return FlashOffer(
          id: raw['id'] as String,
          discountPercent: discountPercent,
          isEnabled: true,
          showPopup: raw['show_popup'] == true,
          popupTitle: raw['popup_title'] as String?,
          popupText: raw['popup_text'] as String?,
          startsAt: startsAt,
          endsAt: endsAt,
        );
      }
    }

    return null;
  }
}
