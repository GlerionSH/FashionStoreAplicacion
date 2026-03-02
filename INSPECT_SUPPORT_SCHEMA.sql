-- ============================================================
-- SCRIPT DE INSPECCIÓN: Esquema real de tablas de soporte
-- Ejecuta esto en Supabase SQL Editor y pega el resultado
-- ============================================================

-- 1) Verificar qué tablas existen
SELECT 
  'fs_support_tickets' as table_name,
  to_regclass('public.fs_support_tickets') as exists
UNION ALL
SELECT 
  'fs_support_replies',
  to_regclass('public.fs_support_replies')
UNION ALL
SELECT 
  'fs_support_messages',
  to_regclass('public.fs_support_messages');

-- 2) Esquema completo de todas las tablas de soporte
SELECT 
  table_name, 
  column_name, 
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema='public'
  AND table_name IN ('fs_support_tickets','fs_support_replies','fs_support_messages')
ORDER BY table_name, ordinal_position;

-- 3) Verificar constraints en fs_support_replies (si existe)
SELECT 
  conname as constraint_name,
  contype as constraint_type,
  pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'public.fs_support_replies'::regclass;

-- 4) Verificar índices en fs_support_replies (si existe)
SELECT 
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'fs_support_replies';
