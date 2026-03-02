-- ============================================================
-- Migration 010: Fix fs_support_replies schema
-- Fixes PGRST204 error: adds missing columns (author, body, etc)
-- ============================================================

-- First, check current schema and add missing columns
DO $$ 
BEGIN
  -- Add ticket_id if missing (handle case where it might exist without FK)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'fs_support_replies' 
    AND column_name = 'ticket_id'
  ) THEN
    ALTER TABLE fs_support_replies 
    ADD COLUMN ticket_id uuid;
    RAISE NOTICE 'Column ticket_id added';
  END IF;
  
  -- Ensure ticket_id is NOT NULL and has FK constraint
  BEGIN
    ALTER TABLE fs_support_replies 
    ALTER COLUMN ticket_id SET NOT NULL;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'ticket_id already NOT NULL or has data issues';
  END;
  
  BEGIN
    ALTER TABLE fs_support_replies 
    ADD CONSTRAINT fk_support_replies_ticket 
    FOREIGN KEY (ticket_id) REFERENCES fs_support_tickets(id) ON DELETE CASCADE;
  EXCEPTION WHEN duplicate_object THEN
    RAISE NOTICE 'FK constraint already exists';
  END;

  -- Add author if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'fs_support_replies' 
    AND column_name = 'author'
  ) THEN
    ALTER TABLE fs_support_replies 
    ADD COLUMN author text NOT NULL DEFAULT 'admin';
    RAISE NOTICE 'Column author added';
  END IF;

  -- Add body if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'fs_support_replies' 
    AND column_name = 'body'
  ) THEN
    ALTER TABLE fs_support_replies 
    ADD COLUMN body text NOT NULL DEFAULT '';
    RAISE NOTICE 'Column body added';
  END IF;

  -- Add created_at if missing
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'fs_support_replies' 
    AND column_name = 'created_at'
  ) THEN
    ALTER TABLE fs_support_replies 
    ADD COLUMN created_at timestamptz NOT NULL DEFAULT now();
    RAISE NOTICE 'Column created_at added';
  END IF;
END $$;

-- Add constraints after columns exist
DO $$
BEGIN
  -- Add check constraint for author
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'fs_support_replies_author_check'
  ) THEN
    ALTER TABLE fs_support_replies 
    ADD CONSTRAINT fs_support_replies_author_check 
    CHECK (author IN ('admin','user'));
    RAISE NOTICE 'Constraint fs_support_replies_author_check added';
  END IF;
END $$;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_replies_ticket ON fs_support_replies(ticket_id);
CREATE INDEX IF NOT EXISTS idx_replies_created ON fs_support_replies(created_at DESC);

-- Ensure RLS policies are correct
ALTER TABLE fs_support_replies ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_read_own_replies" ON fs_support_replies;
CREATE POLICY "user_read_own_replies" ON fs_support_replies
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM fs_support_tickets t
      WHERE t.id = fs_support_replies.ticket_id AND t.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "user_insert_own_replies" ON fs_support_replies;
CREATE POLICY "user_insert_own_replies" ON fs_support_replies
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM fs_support_tickets t
      WHERE t.id = fs_support_replies.ticket_id AND t.user_id = auth.uid()
    )
  );
