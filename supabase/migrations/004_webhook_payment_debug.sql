DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_orders' AND column_name = 'payment_last_error'
  ) THEN
    ALTER TABLE fs_orders ADD COLUMN payment_last_error text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_orders' AND column_name = 'last_webhook_event_id'
  ) THEN
    ALTER TABLE fs_orders ADD COLUMN last_webhook_event_id text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_orders' AND column_name = 'last_webhook_type'
  ) THEN
    ALTER TABLE fs_orders ADD COLUMN last_webhook_type text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_orders' AND column_name = 'last_webhook_received_at'
  ) THEN
    ALTER TABLE fs_orders ADD COLUMN last_webhook_received_at timestamptz;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_fs_orders_stripe_payment_intent_id
  ON fs_orders (stripe_payment_intent_id);

CREATE INDEX IF NOT EXISTS idx_fs_orders_stripe_session_id
  ON fs_orders (stripe_session_id);

CREATE INDEX IF NOT EXISTS idx_fs_orders_status_created_at
  ON fs_orders (status, created_at DESC);
