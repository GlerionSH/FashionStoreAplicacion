-- ============================================================
-- 002: Support PaymentIntent flow (in-app PaymentSheet)
-- ============================================================

-- 1. Add stripe_payment_intent_id if not exists
--    (separate from the old stripe_payment_intent column)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_orders' AND column_name = 'stripe_payment_intent_id'
  ) THEN
    ALTER TABLE fs_orders ADD COLUMN stripe_payment_intent_id text;
  END IF;
END $$;

-- 2. Allow authenticated users to INSERT their own orders (pending only)
--    Edge Functions with service_role bypass RLS anyway, but if the app
--    ever inserts directly this policy covers it.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'fs_orders' AND policyname = 'Authenticated users can insert own orders'
  ) THEN
    EXECUTE $policy$
      CREATE POLICY "Authenticated users can insert own orders"
        ON fs_orders
        FOR INSERT
        WITH CHECK (
          email = (auth.jwt() ->> 'email')
          AND status = 'pending'
        );
    $policy$;
  END IF;
END $$;

-- 3. Allow authenticated users to INSERT items for their own orders
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'fs_order_items' AND policyname = 'Authenticated users can insert own order items'
  ) THEN
    EXECUTE $policy$
      CREATE POLICY "Authenticated users can insert own order items"
        ON fs_order_items
        FOR INSERT
        WITH CHECK (
          order_id IN (
            SELECT id FROM fs_orders WHERE email = (auth.jwt() ->> 'email')
          )
        );
    $policy$;
  END IF;
END $$;

-- 4. Allow authenticated users to read their own orders by user_id too
--    (the existing policy only matches by email)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'fs_orders' AND policyname = 'Users can read own orders by user_id'
  ) THEN
    EXECUTE $policy$
      CREATE POLICY "Users can read own orders by user_id"
        ON fs_orders
        FOR SELECT
        USING (
          user_id = auth.uid()
        );
    $policy$;
  END IF;
END $$;
