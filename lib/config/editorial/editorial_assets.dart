import 'dart:ui' show Color;

/// Centralised editorial imagery for the app.
///
/// Every visual asset that is NOT a product image lives here.
/// To change any image across the entire app, edit **only** this file.
///
/// All paths point to Flutter assets inside `assets/editorial/`.
/// Drop the real images there (same files as Astro `public/`).
class EditorialAssets {
  const EditorialAssets._();

  static const _base = 'assets/editorial';

  // ── Hero (Home) ─────────────────────────────────────────────
  /// Full-bleed hero on the home editorial page.
  /// Copy Astro's `public/hero.png` (or `imagen-fondo.png`) here.
  static const homeHero = '$_base/hero.png';

  // ── Category blocks (Home) ──────────────────────────────────
  /// "New In" category block.
  /// Astro equivalent: `public/fondo-1.png`
  static const categoryNewIn = '$_base/fondo-1.png';

  /// "Basics" category block.
  /// Astro equivalent: `public/fondo-2.png`
  static const categoryBasics = '$_base/fondo-2.png';

  // ── Lookbook (Home) ─────────────────────────────────────────
  /// Mid-page lookbook image. Change to any vertical fashion shot.
  static const lookbook = '$_base/fondo-2.png';

  // ── Banner ──────────────────────────────────────────────────
  /// Promotional banner strip.
  /// Astro equivalent: `public/banner.png`
  static const banner = '$_base/banner.png';

  // ── Placeholder ─────────────────────────────────────────────
  /// Fallback colour when an editorial image fails to load.
  static const fallbackColor = Color(0xFFF0F0F0);
}
