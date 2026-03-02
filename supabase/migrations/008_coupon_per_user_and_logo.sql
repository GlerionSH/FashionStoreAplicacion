-- ============================================================
-- 008_coupon_per_user_and_logo.sql
-- 1) Add UNIQUE(coupon_id, user_id) to fs_coupon_redemptions
--    → enforces 1 use per user per coupon at DB level
-- 2) Add brand_logo_url to fs_site_settings for invoice PDF
-- ============================================================

-- ── 1. Per-user coupon constraint ─────────────────────────────────────────────
-- Ensures the same user cannot redeem the same coupon twice.
-- Combined with existing UNIQUE(order_id), this makes redemptions fully idempotent.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.fs_coupon_redemptions'::regclass
      AND conname = 'uq_coupon_user'
  ) THEN
    ALTER TABLE public.fs_coupon_redemptions
      ADD CONSTRAINT uq_coupon_user UNIQUE (coupon_id, user_id);
  END IF;
END$$;

-- ── 2. Brand logo URL in site settings ────────────────────────────────────────
ALTER TABLE public.fs_site_settings
  ADD COLUMN IF NOT EXISTS brand_logo_url text;

-- Seed a default empty value if row exists
UPDATE public.fs_site_settings
  SET brand_logo_url = ''
  WHERE brand_logo_url IS NULL;
