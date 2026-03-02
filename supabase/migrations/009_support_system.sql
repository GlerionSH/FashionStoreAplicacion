-- ============================================================
-- Support ticket system for FashionStore
-- Migration 009: Complete support system with conversation
-- Adds new columns to existing tables
-- ============================================================

-- 1) Add new columns to fs_support_tickets if they don't exist
DO $$ 
BEGIN
  -- Add last_message_at if not exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'fs_support_tickets' AND column_name = 'last_message_at'
  ) THEN
    ALTER TABLE fs_support_tickets ADD COLUMN last_message_at timestamptz NOT NULL DEFAULT now();
  END IF;

  -- Add admin_last_read_at if not exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'fs_support_tickets' AND column_name = 'admin_last_read_at'
  ) THEN
    ALTER TABLE fs_support_tickets ADD COLUMN admin_last_read_at timestamptz;
  END IF;

  -- Add user_last_read_at if not exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'fs_support_tickets' AND column_name = 'user_last_read_at'
  ) THEN
    ALTER TABLE fs_support_tickets ADD COLUMN user_last_read_at timestamptz;
  END IF;
END $$;

-- 2) Update existing rows with 'answered' status to 'pending'
UPDATE fs_support_tickets SET status = 'pending' WHERE status = 'answered';

-- 3) Update status constraint to include 'pending'
DO $$
BEGIN
  -- Drop old constraint if exists
  ALTER TABLE fs_support_tickets DROP CONSTRAINT IF EXISTS fs_support_tickets_status_check;
  
  -- Add new constraint with all three statuses
  ALTER TABLE fs_support_tickets ADD CONSTRAINT fs_support_tickets_status_check 
    CHECK (status IN ('open','pending','closed'));
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- 3) Indexes
CREATE INDEX IF NOT EXISTS idx_tickets_user ON fs_support_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON fs_support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_last_message ON fs_support_tickets(last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_replies_ticket ON fs_support_replies(ticket_id);
CREATE INDEX IF NOT EXISTS idx_replies_created ON fs_support_replies(created_at DESC);

-- 4) Auto-update updated_at on tickets
CREATE OR REPLACE FUNCTION update_support_ticket_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_support_ticket_updated ON fs_support_tickets;
CREATE TRIGGER trg_support_ticket_updated
  BEFORE UPDATE ON fs_support_tickets
  FOR EACH ROW EXECUTE FUNCTION update_support_ticket_updated_at();

-- 5) RLS
ALTER TABLE fs_support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE fs_support_replies ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "anon_insert_ticket" ON fs_support_tickets;
DROP POLICY IF EXISTS "user_read_own_tickets" ON fs_support_tickets;
DROP POLICY IF EXISTS "user_update_own_tickets" ON fs_support_tickets;
DROP POLICY IF EXISTS "user_read_own_replies" ON fs_support_replies;
DROP POLICY IF EXISTS "user_insert_own_replies" ON fs_support_replies;

-- Anyone (even anon) can INSERT a ticket (with valid email)
CREATE POLICY "anon_insert_ticket" ON fs_support_tickets
  FOR INSERT WITH CHECK (
    email IS NOT NULL AND email <> '' AND length(email) > 3
  );

-- Authenticated users can read their own tickets
CREATE POLICY "user_read_own_tickets" ON fs_support_tickets
  FOR SELECT USING (
    auth.uid() = user_id
  );

-- Authenticated users can update their own tickets (e.g., close them)
CREATE POLICY "user_update_own_tickets" ON fs_support_tickets
  FOR UPDATE USING (
    auth.uid() = user_id
  );

-- Authenticated users can read replies on their own tickets
CREATE POLICY "user_read_own_replies" ON fs_support_replies
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM fs_support_tickets t
      WHERE t.id = ticket_id AND t.user_id = auth.uid()
    )
  );

-- Authenticated users can insert replies on their own tickets
CREATE POLICY "user_insert_own_replies" ON fs_support_replies
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM fs_support_tickets t
      WHERE t.id = ticket_id AND t.user_id = auth.uid()
    )
  );

-- Service role (admin) can do everything (no extra policy needed,
-- service_role bypasses RLS by default).
