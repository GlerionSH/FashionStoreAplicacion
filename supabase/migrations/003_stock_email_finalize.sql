CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_orders' AND column_name = 'email_sent_at'
  ) THEN
    ALTER TABLE fs_orders ADD COLUMN email_sent_at timestamptz;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_orders' AND column_name = 'email_last_error'
  ) THEN
    ALTER TABLE fs_orders ADD COLUMN email_last_error text;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_products' AND column_name = 'stock'
  ) THEN
    ALTER TABLE fs_products ADD COLUMN stock int NOT NULL DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_products' AND column_name = 'size_stock'
  ) THEN
    ALTER TABLE fs_products ADD COLUMN size_stock jsonb NOT NULL DEFAULT '{}'::jsonb;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_fs_orders_user_created_at
  ON fs_orders (user_id, created_at DESC);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'fs_order_items' AND policyname = 'Users can read own order items by user_id'
  ) THEN
    EXECUTE $policy$
      CREATE POLICY "Users can read own order items by user_id"
        ON fs_order_items
        FOR SELECT
        USING (
          order_id IN (SELECT id FROM fs_orders WHERE user_id = auth.uid())
        );
    $policy$;
  END IF;
END $$;

CREATE OR REPLACE FUNCTION public.fs_finalize_paid_order(
  p_order_id text,
  p_payment_intent_id text DEFAULT NULL,
  p_paid_at timestamptz DEFAULT now()
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_order record;
  v_item record;
  v_stock int;
  v_new_stock int;
  v_size_stock jsonb;
  v_size_qty int;
  v_new_size_qty int;
BEGIN
  SELECT id, status, invoice_token
    INTO v_order
    FROM fs_orders
    WHERE id::text = p_order_id
    FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'order_not_found';
  END IF;

  IF v_order.status = 'paid' THEN
    RETURN jsonb_build_object('already_paid', true, 'order_id', p_order_id);
  END IF;

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
      RAISE EXCEPTION 'product_not_found:%', v_item.product_id;
    END IF;

    v_new_stock := COALESCE(v_stock, 0) - COALESCE(v_item.qty, 0);
    IF v_new_stock < 0 THEN
      RAISE EXCEPTION 'insufficient_stock:%', v_item.product_id;
    END IF;

    IF v_item.size IS NOT NULL AND btrim(v_item.size) <> '' THEN
      v_size_qty := COALESCE((COALESCE(v_size_stock, '{}'::jsonb) ->> v_item.size)::int, 0);
      v_new_size_qty := v_size_qty - COALESCE(v_item.qty, 0);
      IF v_new_size_qty < 0 THEN
        RAISE EXCEPTION 'insufficient_size_stock:%:%', v_item.product_id, v_item.size;
      END IF;

      v_size_stock := jsonb_set(
        COALESCE(v_size_stock, '{}'::jsonb),
        ARRAY[v_item.size],
        to_jsonb(v_new_size_qty),
        true
      );

      UPDATE fs_products
        SET stock = v_new_stock,
            size_stock = v_size_stock
        WHERE id = v_item.product_id;
    ELSE
      UPDATE fs_products
        SET stock = v_new_stock
        WHERE id = v_item.product_id;
    END IF;
  END LOOP;

  UPDATE fs_orders
    SET status = 'paid',
        paid_at = COALESCE(p_paid_at, now()),
        stripe_payment_intent_id = COALESCE(p_payment_intent_id, stripe_payment_intent_id),
        invoice_token = COALESCE(invoice_token, gen_random_uuid()::text)
    WHERE id::text = p_order_id;

  RETURN jsonb_build_object('ok', true, 'order_id', p_order_id);
END;
$$;
