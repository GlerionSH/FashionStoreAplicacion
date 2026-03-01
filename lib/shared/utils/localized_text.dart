import 'dart:ui';

/// Returns the localized text for a bilingual field.
/// Priority: if locale is 'en' → [en] if non-empty, else [es] if non-empty, else [fallback].
/// If locale is not 'en' → [es] if non-empty, else [en] if non-empty, else [fallback].
String localizedText({
  required String? es,
  required String? en,
  required Locale locale,
  String fallback = '',
}) {
  if (locale.languageCode == 'en') {
    if (en != null && en.isNotEmpty) return en;
    if (es != null && es.isNotEmpty) return es;
    return fallback;
  } else {
    if (es != null && es.isNotEmpty) return es;
    if (en != null && en.isNotEmpty) return en;
    return fallback;
  }
}
