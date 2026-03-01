-- ============================================================
-- Support ticket system for FashionStore
-- Run this in Supabase SQL Editor
-- ============================================================

-- 1) Tickets table
CREATE TABLE IF NOT EXISTS fs_support_tickets (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  name        text NOT NULL,
  email       text NOT NULL,
  subject     text NOT NULL,
  message     text NOT NULL,
  status      text NOT NULL DEFAULT 'open' CHECK (status IN ('open','answered','closed')),
  admin_notes text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- 2) Replies table
CREATE TABLE IF NOT EXISTS fs_support_replies (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id       uuid NOT NULL REFERENCES fs_support_tickets(id) ON DELETE CASCADE,
  author          text NOT NULL DEFAULT 'admin' CHECK (author IN ('admin','user')),
  body            text NOT NULL,
  created_at      timestamptz NOT NULL DEFAULT now(),
  sent_to_user_at timestamptz,
  last_error      text
);

-- 3) Indexes
CREATE INDEX IF NOT EXISTS idx_tickets_user ON fs_support_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON fs_support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_replies_ticket ON fs_support_replies(ticket_id);

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

-- Authenticated users can read replies on their own tickets
CREATE POLICY "user_read_own_replies" ON fs_support_replies
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM fs_support_tickets t
      WHERE t.id = ticket_id AND t.user_id = auth.uid()
    )
  );

-- Service role (admin) can do everything (no extra policy needed,
-- service_role bypasses RLS by default).
