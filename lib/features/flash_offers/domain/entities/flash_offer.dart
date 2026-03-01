import 'package:freezed_annotation/freezed_annotation.dart';

part 'flash_offer.freezed.dart';

@freezed
class FlashOffer with _$FlashOffer {
  const factory FlashOffer({
    required String id,
    required int discountPercent,
    required bool isEnabled,
    required bool showPopup,
    String? popupTitle,
    String? popupText,
    DateTime? startsAt,
    DateTime? endsAt,
  }) = _FlashOffer;

  const FlashOffer._();

  bool get isActiveNow {
    if (!isEnabled) return false;
    final now = DateTime.now();
    final startOk = startsAt == null || !startsAt!.isAfter(now);
    final endOk = endsAt == null || !endsAt!.isBefore(now);
    return startOk && endOk;
  }
}

/// Applies a percent discount to a price in cents.
/// Matches Astro: Math.floor((base * (100 - p)) / 100)
int applyPercentDiscountCents(int priceCents, int percent) {
  final p = percent.clamp(0, 100);
  if (p <= 0) return priceCents;
  final base = priceCents < 0 ? 0 : priceCents;
  final discounted = (base * (100 - p)) ~/ 100;
  return discounted < 0 ? 0 : discounted;
}
