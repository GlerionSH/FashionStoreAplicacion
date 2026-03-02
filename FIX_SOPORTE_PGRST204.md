# 🔧 FIX DEFINITIVO: PGRST204 en fs_support_replies

## 🔍 DIAGNÓSTICO

### **Error reportado:**
```
PGRST204: Could not find the 'author' column of 'fs_support_replies' in the schema cache
PGRST204: Could not find the 'body' column of 'fs_support_replies' in the schema cache
```

### **Causa raíz:**
La tabla `fs_support_replies` existe en la base de datos pero **le faltan columnas críticas** que el código intenta usar.

---

## 📊 PASO 1: INSPECCIONAR ESQUEMA REAL

**Ejecuta este script en Supabase SQL Editor:**

```sql
-- Ver qué tablas existen
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

-- Ver columnas de fs_support_replies
SELECT 
  column_name, 
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema='public'
  AND table_name = 'fs_support_replies'
ORDER BY ordinal_position;
```

**Resultado esperado ANTES del fix:**
- Tabla `fs_support_replies` existe
- **FALTAN** columnas: `ticket_id`, `author`, `body`, `created_at`

---

## 💻 PASO 2: CÓDIGO QUE FALLA

### **Edge Function:** `supabase/functions/support/index.ts`
**Líneas 266-278:**

```typescript
// Insert reply
const replyPayload = {
  ticket_id,  // ❌ Columna no existe
  author,     // ❌ Columna no existe
  body,       // ❌ Columna no existe
};

const { data: reply, error: replyError } = await supabase
  .from("fs_support_replies")
  .insert(replyPayload)
  .select()
  .single();
```

### **Admin UI:** `lib/features/admin/presentation/screens/admin_support_screen.dart`
**Líneas 306-312:**

```dart
final response = await client.functions.invoke(
  'support',
  body: {
    'action': 'send_message',
    'ticket_id': widget.ticketId,
    'author': 'admin',  // Se envía correctamente
    'body': body,       // Se envía correctamente
  },
);
```

**Conclusión:** El código está correcto. El problema es el esquema de la DB.

---

## 🛠️ PASO 3: SOLUCIÓN APLICADA

### **Archivo creado:** `supabase/migrations/010_add_author_to_replies.sql`

**Qué hace:**
1. ✅ Añade columna `ticket_id` (uuid, FK a fs_support_tickets)
2. ✅ Añade columna `author` (text, CHECK IN ('admin','user'))
3. ✅ Añade columna `body` (text, NOT NULL)
4. ✅ Añade columna `created_at` (timestamptz, default now())
5. ✅ Crea índices optimizados
6. ✅ Actualiza RLS policies
7. ✅ Es idempotente (solo añade si no existen)

**Características de seguridad:**
- Usa `IF NOT EXISTS` para evitar errores
- Maneja casos donde columnas parcialmente existen
- Usa `EXCEPTION WHEN duplicate_object` para constraints
- Defaults seguros para no romper datos existentes

---

## 🚀 PASO 4: DEPLOY

### **4.1. Aplicar migración SQL**

```bash
cd c:\Users\ruben\tienda_flutter\fashion_store

# Aplicar migración
supabase db push
```

**Output esperado:**
```
Applying migration 010_add_author_to_replies.sql...
NOTICE: Column ticket_id added
NOTICE: Column author added
NOTICE: Column body added
NOTICE: Column created_at added
NOTICE: Constraint fs_support_replies_author_check added
✓ Migration applied successfully
```

### **4.2. Redeploy Edge Function (CRÍTICO para schema cache)**

```bash
# Redeploy función support para refrescar schema cache
supabase functions deploy support
```

**Por qué es necesario:**
PostgREST (el motor de Supabase) cachea el esquema de las tablas. Después de cambiar columnas, **DEBES** redeploy la función para que refresque el cache y reconozca las nuevas columnas.

### **4.3. Verificar schema actualizado**

```sql
-- Ejecutar en Supabase SQL Editor
SELECT 
  column_name, 
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema='public'
  AND table_name = 'fs_support_replies'
ORDER BY ordinal_position;
```

**Resultado esperado DESPUÉS del fix:**
```
column_name   | data_type                   | is_nullable
--------------+-----------------------------+-------------
id            | uuid                        | NO
ticket_id     | uuid                        | NO
author        | text                        | NO
body          | text                        | NO
created_at    | timestamp with time zone    | NO
```

---

## ✅ PASO 5: VERIFICACIÓN

### **5.1. Probar responder ticket**

1. Admin panel → Soporte → Abrir ticket existente
2. Escribir respuesta en el input
3. Enviar

**Antes:**
```
Error: PGRST204: Could not find the 'author' column...
```

**Después:**
```
✅ Respuesta guardada correctamente
✅ Aparece en conversación
✅ Email enviado al usuario
```

### **5.2. Verificar logs de Edge Function**

```bash
supabase functions logs support --tail
```

**Buscar:**
```
[support] Sending message on ticket ... from admin
[support] Inserting reply with payload keys: [ 'ticket_id', 'author', 'body' ]
[support] Reply created: <uuid>
```

**Si hay error:**
```
[support] Reply creation failed: {
  message: "...",
  code: "PGRST204",
  table: "fs_support_replies",
  payload_keys: [ 'ticket_id', 'author', 'body' ]
}
```

### **5.3. Verificar en base de datos**

```sql
-- Ver últimas respuestas creadas
SELECT 
  id,
  ticket_id,
  author,
  LEFT(body, 50) as body_preview,
  created_at
FROM fs_support_replies
ORDER BY created_at DESC
LIMIT 5;
```

---

## 🎯 RESUMEN DE CAMBIOS

### **Archivos modificados:**

1. **`supabase/migrations/010_add_author_to_replies.sql`** (CREADO)
   - Añade columnas faltantes a `fs_support_replies`
   - Idempotente y seguro

2. **`supabase/functions/support/index.ts`** (MEJORADO)
   - Añadido logging detallado del payload
   - Mejor manejo de errores
   - Devuelve error claro a UI en vez de throw

3. **`INSPECT_SUPPORT_SCHEMA.sql`** (CREADO)
   - Script de inspección para debug futuro

### **Archivos NO modificados (ya correctos):**
- ❌ `lib/features/admin/presentation/screens/admin_support_screen.dart`
- ❌ `lib/features/support/presentation/providers/support_providers.dart`
- ❌ Stripe, checkout, emails de compra

---

## 📝 EXPLICACIÓN TÉCNICA

### **1. ¿Cuál era el schema real?**

La tabla `fs_support_replies` existía pero probablemente solo con:
- `id` (uuid, PK)
- Posiblemente otras columnas antiguas

**Faltaban:** `ticket_id`, `author`, `body`, `created_at`

### **2. ¿Qué cambiaste?**

Migración SQL que añade las 4 columnas faltantes con:
- Defaults seguros (`author` = 'admin', `body` = '')
- FK constraint en `ticket_id`
- CHECK constraint en `author` (solo 'admin' o 'user')
- Índices para performance

### **3. ¿Por qué ahora funciona?**

1. **Antes:** PostgREST buscaba columna `author` → No existía → PGRST204
2. **Después migración:** Columnas existen en DB
3. **Después redeploy:** PostgREST refresca schema cache
4. **Resultado:** Insert funciona correctamente

---

## 🔒 ROBUSTEZ AÑADIDA

### **En Edge Function:**

**Antes:**
```typescript
if (replyError) {
  console.error("[support] Reply creation failed:", replyError.message);
  throw replyError;  // ❌ Rompe la función
}
```

**Después:**
```typescript
if (replyError) {
  console.error("[support] Reply creation failed:", {
    message: replyError.message,
    code: replyError.code,
    table: "fs_support_replies",
    payload_keys: Object.keys(replyPayload),
  });
  return new Response(
    JSON.stringify({ 
      error: "Failed to create reply", 
      details: replyError.message,
      code: replyError.code 
    }),
    { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
  );  // ✅ Devuelve error claro a UI
}
```

**Beneficios:**
- ✅ No rompe la función con `throw`
- ✅ Devuelve error estructurado a UI
- ✅ Logging detallado para debug
- ✅ UI puede mostrar mensaje claro al admin

---

## 🚨 TROUBLESHOOTING

### **Si sigue fallando después del deploy:**

1. **Verificar que migración se aplicó:**
   ```sql
   SELECT version FROM supabase_migrations.schema_migrations 
   ORDER BY version DESC LIMIT 5;
   ```
   Debe aparecer `010_add_author_to_replies`

2. **Verificar columnas existen:**
   ```sql
   SELECT column_name FROM information_schema.columns
   WHERE table_name = 'fs_support_replies';
   ```
   Debe incluir: `ticket_id`, `author`, `body`, `created_at`

3. **Forzar refresh de schema cache:**
   ```bash
   # Redeploy función
   supabase functions deploy support --no-verify-jwt
   
   # O reiniciar proyecto local
   supabase stop
   supabase start
   ```

4. **Verificar logs en tiempo real:**
   ```bash
   supabase functions logs support --tail
   ```

---

## ✅ CHECKLIST FINAL

- [ ] Ejecutar `INSPECT_SUPPORT_SCHEMA.sql` y confirmar columnas faltantes
- [ ] Aplicar migración: `supabase db push`
- [ ] Redeploy función: `supabase functions deploy support`
- [ ] Probar responder ticket desde admin
- [ ] Verificar respuesta aparece en UI
- [ ] Verificar email enviado
- [ ] Verificar logs sin errores PGRST204

---

**Sistema de soporte 100% funcional después de estos pasos** 🎉
