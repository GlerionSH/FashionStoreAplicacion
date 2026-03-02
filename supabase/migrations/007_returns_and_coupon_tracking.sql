-- ============================================================
-- 007_returns_and_coupon_tracking.sql
-- Creates fs_returns table (unified cancel/return) + RLS
-- Adds trigger to track coupon redemptions and increment used_count
-- ============================================================

-- ── 1. RETURNS TABLE (unified cancellation + return) ─────────────────────────
CREATE TABLE IF NOT EXISTS fs_returns (
  id                   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id             uuid        NOT NULL,
  user_id              uuid        REFERENCES auth.users(id) ON DELETE SET NULL,
  status               text        NOT NULL DEFAULT 'requested',
    -- requested | approved | rejected | refunded
  request_type         text        NOT NULL DEFAULT 'cancellation',
    -- cancellation | return
  reason               text,
  notes                text,
  requested_at         timestamptz NOT NULL DEFAULT now(),
  reviewed_at          timestamptz,
  reviewed_by          uuid        REFERENCES auth.users(id) ON DELETE SET NULL,
  refund_total_cents   int         NOT NULL DEFAULT 0,
  stripe_refund_id     text,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_fs_returns_order_id ON fs_returns(order_id);
CREATE INDEX IF NOT EXISTS idx_fs_returns_status ON fs_returns(status);
CREATE INDEX IF NOT EXISTS idx_fs_returns_user_id ON fs_returns(user_id);

ALTER TABLE fs_returns ENABLE ROW LEVEL SECURITY;

-- Client can read own returns
CREATE POLICY "Users can read own returns"
  ON fs_returns FOR SELECT
  USING (
    user_id = auth.uid()
    OR order_id IN (SELECT id FROM fs_orders WHERE user_id = auth.uid())
  );

-- Client can insert return request for their own order
CREATE POLICY "Users can insert return request for own order"
  ON fs_returns FOR INSERT
  WITH CHECK (
    order_id IN (SELECT id FROM fs_orders WHERE user_id = auth.uid())
  );

-- ── 2. RETURN ITEMS (optional detail tracking) ────────────────────────────────
CREATE TABLE IF NOT EXISTS fs_return_items (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  return_id       uuid        NOT NULL REFERENCES fs_returns(id) ON DELETE CASCADE,
  order_item_id   uuid,
  product_id      uuid,
  name            text        NOT NULL,
  size            text,
  qty             int         NOT NULL DEFAULT 1,
  line_total_cents int        NOT NULL DEFAULT 0,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_fs_return_items_return_id ON fs_return_items(return_id);

ALTER TABLE fs_return_items ENABLE ROW LEVEL SECURITY;

-- No direct client access — managed via Edge Functions

-- ── 3. COUPON REDEMPTION TRIGGER ───────────────────────────────────────────────
-- Increment fs_coupons.used_count when a redemption is recorded

-- Add used_count column to fs_coupons if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_coupons' AND column_name = 'used_count'
  ) THEN
    ALTER TABLE fs_coupons ADD COLUMN used_count int NOT NULL DEFAULT 0;
  END IF;
END $$;

-- Function to increment used_count
CREATE OR REPLACE FUNCTION fs_increment_coupon_usage()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE fs_coupons
  SET used_count = COALESCE(used_count, 0) + 1
  WHERE id = NEW.coupon_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger on fs_coupon_redemptions insert
DROP TRIGGER IF EXISTS trg_fs_increment_coupon_usage ON fs_coupon_redemptions;
CREATE TRIGGER trg_fs_increment_coupon_usage
  AFTER INSERT ON fs_coupon_redemptions
  FOR EACH ROW
  EXECUTE FUNCTION fs_increment_coupon_usage();

-- ── 4. UNIQUE CONSTRAINT on fs_coupon_redemptions.order_id ────────────────────
-- Prevent duplicate redemptions for same order (idempotency)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'fs_coupon_redemptions_order_id_key'
  ) THEN
    ALTER TABLE fs_coupon_redemptions
      ADD CONSTRAINT fs_coupon_redemptions_order_id_key UNIQUE (order_id);
  END IF;
END $$;
