-- ============================================================
-- 005_commercial_pro.sql
-- Módulo Comercial Pro:
--   A) Newsletter + Cupones
--   B) Envíos y estados del pedido
--   C) Cancelaciones
--   D) Gestión admin de usuarios (vista)
--   E) Bloqueo de borrado de productos con pedidos
-- ============================================================

-- ── 1. NEWSLETTER SUBSCRIBERS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fs_newsletter_subscribers (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  email           text        NOT NULL,
  user_id         uuid        REFERENCES auth.users(id) ON DELETE SET NULL,
  is_active       boolean     NOT NULL DEFAULT true,
  welcome_coupon_code text,
  subscribed_at   timestamptz NOT NULL DEFAULT now(),
  unsubscribed_at timestamptz,
  UNIQUE (email)
);

ALTER TABLE fs_newsletter_subscribers ENABLE ROW LEVEL SECURITY;

-- Public can insert (subscribe) — rate-limited via Edge Function
CREATE POLICY "Anyone can subscribe to newsletter"
  ON fs_newsletter_subscribers FOR INSERT
  WITH CHECK (true);

-- Logged-in user can read/update their own row
CREATE POLICY "Users can read own newsletter subscription"
  ON fs_newsletter_subscribers FOR SELECT
  USING (email = (auth.jwt() ->> 'email') OR user_id = auth.uid());

CREATE POLICY "Users can update own newsletter subscription"
  ON fs_newsletter_subscribers FOR UPDATE
  USING (email = (auth.jwt() ->> 'email') OR user_id = auth.uid());

-- ── 2. COUPONS ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fs_coupons (
  id                        uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  code                      text        NOT NULL,
  percent_off               int         NOT NULL CHECK (percent_off BETWEEN 1 AND 100),
  active                    boolean     NOT NULL DEFAULT true,
  starts_at                 timestamptz,
  ends_at                   timestamptz,
  max_redemptions           int,          -- null = unlimited
  max_redemptions_per_user  int,          -- null = unlimited per user
  min_order_cents           int,          -- null = no minimum
  applies_to                text        NOT NULL DEFAULT 'all',  -- 'all' | 'categories' | 'products'
  notes                     text,
  created_at                timestamptz NOT NULL DEFAULT now(),
  UNIQUE (code)
);

ALTER TABLE fs_coupons ENABLE ROW LEVEL SECURITY;
-- No direct client access — all via Edge Functions with service_role

-- ── 3. COUPON REDEMPTIONS ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fs_coupon_redemptions (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  coupon_id       uuid        NOT NULL REFERENCES fs_coupons(id),
  coupon_code     text        NOT NULL,
  order_id        uuid,
  user_id         uuid        REFERENCES auth.users(id) ON DELETE SET NULL,
  email           text,
  discount_cents  int         NOT NULL DEFAULT 0,
  redeemed_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_coupon_redemptions_coupon_id ON fs_coupon_redemptions(coupon_id);
CREATE INDEX IF NOT EXISTS idx_coupon_redemptions_order_id  ON fs_coupon_redemptions(order_id);
CREATE INDEX IF NOT EXISTS idx_coupon_redemptions_user_id   ON fs_coupon_redemptions(user_id);
CREATE INDEX IF NOT EXISTS idx_coupon_redemptions_email     ON fs_coupon_redemptions(email);

ALTER TABLE fs_coupon_redemptions ENABLE ROW LEVEL SECURITY;
-- No direct client access — all via Edge Functions with service_role

-- ── 4. SHIPMENTS ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fs_shipments (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id        uuid        NOT NULL UNIQUE,
  status          text        NOT NULL DEFAULT 'pending',
    -- pending | preparing | shipped | delivered | cancelled
  carrier         text,
  tracking_number text,
  shipped_at      timestamptz,
  delivered_at    timestamptz,
  last_event_at   timestamptz,
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_fs_shipments_order_id ON fs_shipments(order_id);

ALTER TABLE fs_shipments ENABLE ROW LEVEL SECURITY;

-- Client can read shipment for their own order
CREATE POLICY "Users can read own shipment"
  ON fs_shipments FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM fs_orders WHERE user_id = auth.uid()
    )
  );

-- ── 5. CANCELLATION REQUESTS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fs_cancellation_requests (
  id               uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id         uuid        NOT NULL UNIQUE,
  user_id          uuid        REFERENCES auth.users(id) ON DELETE SET NULL,
  email            text,
  reason           text,
  requested_at     timestamptz NOT NULL DEFAULT now(),
  status           text        NOT NULL DEFAULT 'requested',
    -- requested | approved | rejected
  reviewed_at      timestamptz,
  reviewed_by      uuid        REFERENCES auth.users(id) ON DELETE SET NULL,
  admin_notes      text,
  refund_amount_cents int,
  stripe_refund_id text
);

CREATE INDEX IF NOT EXISTS idx_cancel_requests_order_id ON fs_cancellation_requests(order_id);
CREATE INDEX IF NOT EXISTS idx_cancel_requests_status   ON fs_cancellation_requests(status);

ALTER TABLE fs_cancellation_requests ENABLE ROW LEVEL SECURITY;

-- Client can read own cancellation request
CREATE POLICY "Users can read own cancellation request"
  ON fs_cancellation_requests FOR SELECT
  USING (user_id = auth.uid() OR email = (auth.jwt() ->> 'email'));

-- Client can insert their own cancellation request
CREATE POLICY "Users can insert own cancellation request"
  ON fs_cancellation_requests FOR INSERT
  WITH CHECK (
    order_id IN (
      SELECT id FROM fs_orders WHERE user_id = auth.uid()
    )
  );

-- ── 6. EMAIL EVENTS ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fs_email_events (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id        uuid,
  event_type      text        NOT NULL,
    -- order_paid | order_shipped | order_delivered | cancel_requested
    -- cancel_approved | cancel_rejected | newsletter_welcome
  sent_at         timestamptz NOT NULL DEFAULT now(),
  recipient_email text,
  error           text,
  metadata        jsonb
);

CREATE INDEX IF NOT EXISTS idx_email_events_order_id    ON fs_email_events(order_id);
CREATE INDEX IF NOT EXISTS idx_email_events_event_type  ON fs_email_events(event_type);

ALTER TABLE fs_email_events ENABLE ROW LEVEL SECURITY;
-- No direct client access — all via Edge Functions

-- ── 7. NEW COLUMNS ON fs_orders ───────────────────────────────────────────────
DO $$
BEGIN
  -- Coupon fields
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='fs_orders' AND column_name='coupon_code') THEN
    ALTER TABLE fs_orders ADD COLUMN coupon_code text;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='fs_orders' AND column_name='coupon_percent') THEN
    ALTER TABLE fs_orders ADD COLUMN coupon_percent int;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='fs_orders' AND column_name='coupon_discount_cents') THEN
    ALTER TABLE fs_orders ADD COLUMN coupon_discount_cents int NOT NULL DEFAULT 0;
  END IF;
  -- Stripe refund tracking
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='fs_orders' AND column_name='stripe_refund_id') THEN
    ALTER TABLE fs_orders ADD COLUMN stripe_refund_id text;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='fs_orders' AND column_name='refunded_at') THEN
    ALTER TABLE fs_orders ADD COLUMN refunded_at timestamptz;
  END IF;
  -- Cancel request tracking
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='fs_orders' AND column_name='cancel_requested_at') THEN
    ALTER TABLE fs_orders ADD COLUMN cancel_requested_at timestamptz;
  END IF;
  -- Webhook error column (may already exist from 004)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='fs_orders' AND column_name='payment_last_error') THEN
    ALTER TABLE fs_orders ADD COLUMN payment_last_error text;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='fs_orders' AND column_name='last_webhook_event_id') THEN
    ALTER TABLE fs_orders ADD COLUMN last_webhook_event_id text;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='fs_orders' AND column_name='last_webhook_type') THEN
    ALTER TABLE fs_orders ADD COLUMN last_webhook_type text;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='fs_orders' AND column_name='last_webhook_received_at') THEN
    ALTER TABLE fs_orders ADD COLUMN last_webhook_received_at timestamptz;
  END IF;
END $$;

-- ── 8. STOCK RESTORE FUNCTION ─────────────────────────────────────────────────
-- Called atomically when a cancellation is approved for a paid order.
CREATE OR REPLACE FUNCTION public.fs_restore_stock_for_order(p_order_id text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_item        record;
  v_stock       int;
  v_size_stock  jsonb;
  v_size_qty    int;
BEGIN
  FOR v_item IN
    SELECT product_id, qty, size
      FROM fs_order_items
      WHERE order_id::text = p_order_id
  LOOP
    SELECT stock, size_stock
      INTO v_stock, v_size_stock
      FROM fs_products
      WHERE id = v_item.product_id
      FOR UPDATE;

    IF NOT FOUND THEN
      CONTINUE; -- product deleted, skip
    END IF;

    IF v_item.size IS NOT NULL AND btrim(v_item.size) <> '' THEN
      v_size_qty := COALESCE((COALESCE(v_size_stock, '{}'::jsonb) ->> v_item.size)::int, 0);
      v_size_stock := jsonb_set(
        COALESCE(v_size_stock, '{}'::jsonb),
        ARRAY[v_item.size],
        to_jsonb(v_size_qty + v_item.qty),
        true
      );
      UPDATE fs_products
        SET stock     = COALESCE(stock, 0) + v_item.qty,
            size_stock = v_size_stock
        WHERE id = v_item.product_id;
    ELSE
      UPDATE fs_products
        SET stock = COALESCE(stock, 0) + v_item.qty
        WHERE id = v_item.product_id;
    END IF;
  END LOOP;

  RETURN jsonb_build_object('ok', true, 'order_id', p_order_id);
END;
$$;

-- ── 9. PRODUCT DELETE GUARD (TRIGGER) ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.fs_guard_product_delete()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM fs_order_items WHERE product_id = OLD.id LIMIT 1
  ) THEN
    RAISE EXCEPTION 'product_has_orders:%', OLD.id
      USING HINT = 'Use is_active=false instead of deleting';
  END IF;
  RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS trg_guard_product_delete ON fs_products;
CREATE TRIGGER trg_guard_product_delete
  BEFORE DELETE ON fs_products
  FOR EACH ROW EXECUTE FUNCTION public.fs_guard_product_delete();

-- ── 10. AUTO-CREATE SHIPMENT ROW ON ORDER PAID ────────────────────────────────
-- This function is called from Edge Function after finalize, not via trigger,
-- to keep it server-side. But we add a helper in case needed:
CREATE OR REPLACE FUNCTION public.fs_ensure_shipment_row(p_order_id text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO fs_shipments (order_id, status)
  VALUES (p_order_id::uuid, 'pending')
  ON CONFLICT (order_id) DO NOTHING;
END;
$$;

-- ── 11. INDEXES ───────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_fs_orders_coupon_code ON fs_orders(coupon_code) WHERE coupon_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_fs_orders_status ON fs_orders(status);
