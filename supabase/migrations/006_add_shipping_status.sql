-- ============================================================
-- 006_add_shipping_status.sql
-- Añade shipping_status a fs_orders para tracking de envíos
-- ============================================================

-- Añadir columna shipping_status si no existe
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_orders' AND column_name = 'shipping_status'
  ) THEN
    ALTER TABLE fs_orders ADD COLUMN shipping_status text NOT NULL DEFAULT 'pending_shipment';
  END IF;
END $$;

-- Actualizar pedidos existentes con status 'paid' a 'pending_shipment'
UPDATE fs_orders 
SET shipping_status = 'pending_shipment' 
WHERE status = 'paid' AND shipping_status IS NULL;

-- Crear índice para búsquedas por shipping_status
CREATE INDEX IF NOT EXISTS idx_fs_orders_shipping_status ON fs_orders(shipping_status);

-- Añadir columnas de tracking de coupon si no existen
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_orders' AND column_name = 'coupon_code'
  ) THEN
    ALTER TABLE fs_orders ADD COLUMN coupon_code text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_orders' AND column_name = 'coupon_percent'
  ) THEN
    ALTER TABLE fs_orders ADD COLUMN coupon_percent int;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_orders' AND column_name = 'coupon_discount_cents'
  ) THEN
    ALTER TABLE fs_orders ADD COLUMN coupon_discount_cents int DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fs_orders' AND column_name = 'cancel_requested_at'
  ) THEN
    ALTER TABLE fs_orders ADD COLUMN cancel_requested_at timestamptz;
  END IF;
END $$;
