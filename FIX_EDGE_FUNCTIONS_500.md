# FIX EDGE FUNCTIONS 500 - Eliminación de Stripe SDK

## Problema Root Cause

**Error en logs de Supabase**:
```
Error: Deno.core.runMicrotasks() is not supported in this environment
Stack: https://deno.land/std@0.177.1/node/_core.ts
       node/_next_tick.ts
       node/process.ts
```

**Causa**: El import de Stripe SDK (`https://esm.sh/stripe@14.14.0?target=deno`) usa polyfills de Node.js (`process`, `nextTick`, `EventEmitter`) que son incompatibles con el runtime de Supabase Edge Functions.

**Funciones afectadas**:
- ❌ `admin-cancellations` (usaba Stripe SDK)
- ✅ `admin-shipments` (ya estaba limpio, solo mejoras de error handling)

---

## Cambios Realizados

### 1. admin-cancellations/index.ts

#### A) Import eliminado
```typescript
// ANTES (línea 13):
import Stripe from "https://esm.sh/stripe@14.14.0?target=deno";

// DESPUÉS:
// ❌ ELIMINADO - causaba error Deno.core.runMicrotasks()
```

#### B) Código Stripe SDK reemplazado con fetch puro
```typescript
// ANTES (líneas 245-256):
const stripe = new Stripe(stripeKey, {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});
const refund = await stripe.refunds.create({
  payment_intent: order.stripe_payment_intent_id,
  reason: "requested_by_customer",
});
stripeRefundId = refund.id;
refundAmountCents = refund.amount;

// DESPUÉS (líneas 245-267):
// Create refund using Stripe REST API (fetch only, no SDK)
const refundRes = await fetch("https://api.stripe.com/v1/refunds", {
  method: "POST",
  headers: {
    "Authorization": `Bearer ${stripeKey}`,
    "Content-Type": "application/x-www-form-urlencoded",
  },
  body: new URLSearchParams({
    payment_intent: order.stripe_payment_intent_id,
    reason: "requested_by_customer",
  }).toString(),
});

if (!refundRes.ok) {
  const errText = await refundRes.text();
  console.error("[admin-cancellations] Stripe refund error:", errText);
  return json(502, { error: `Stripe refund failed: ${errText}`, where: "admin-cancellations" });
}

const refund = await refundRes.json();
stripeRefundId = refund.id;
refundAmountCents = refund.amount;
console.log(`[admin-cancellations] Refund created: ${refund.id} amount=${refund.amount}`);
```

#### C) Error handling mejorado
```typescript
// ANTES (líneas 320-323):
} catch (err: any) {
  console.error("[admin-cancellations] error:", err);
  return json(500, { error: err.message ?? "Internal error" });
}

// DESPUÉS (líneas 332-339):
} catch (err: any) {
  console.error("[admin-cancellations] Unhandled error:", err);
  return json(500, { 
    error: err.message ?? "Internal error", 
    details: err.toString(),
    where: "admin-cancellations",
    stack: err.stack?.substring(0, 500)
  });
}
```

### 2. admin-shipments/index.ts

#### Solo mejoras de error handling
```typescript
// ANTES (líneas 265-267):
} catch (err: any) {
  console.error("[admin-shipments] error:", err);
  return json(500, { error: err.message ?? "Internal error" });
}

// DESPUÉS (líneas 265-272):
} catch (err: any) {
  console.error("[admin-shipments] Unhandled error:", err);
  return json(500, { 
    error: err.message ?? "Internal error", 
    details: err.toString(),
    where: "admin-shipments",
    stack: err.stack?.substring(0, 500)
  });
}
```

**Nota**: `admin-shipments` ya usaba fetch puro para emails (Brevo API) y no tenía Stripe SDK.

---

## Verificación Esquema DB (MCP)

### fs_shipments
```sql
✅ Columnas confirmadas:
- id (uuid, PK)
- order_id (uuid, NOT NULL)
- status (text, default 'pending')
- carrier (text, nullable)
- tracking_number (text, nullable)
- shipped_at (timestamptz, nullable)
- delivered_at (timestamptz, nullable)
- last_event_at (timestamptz, nullable)
- notes (text, nullable)
- created_at (timestamptz, default now())
- updated_at (timestamptz, default now())
```

### fs_cancellation_requests
```sql
✅ Tabla existe con columnas:
- id (uuid, PK)
- order_id (uuid, NOT NULL)
- user_id (uuid, nullable)
- email (text, nullable)
- reason (text, nullable)
- requested_at (timestamptz, default now())
- status (text, default 'requested')
- reviewed_at (timestamptz, nullable)
- reviewed_by (uuid, nullable)
- admin_notes (text, nullable)
- refund_amount_cents (integer, nullable)
- stripe_refund_id (text, nullable)
```

**No hay FKs** → Queries en 2 pasos implementadas correctamente.

---

## Comandos de Redeploy

```powershell
cd c:\Users\ruben\tienda_flutter\fashion_store

# Deploy admin-cancellations (CRÍTICO - eliminado Stripe SDK)
supabase functions deploy admin-cancellations

# Deploy admin-shipments (mejoras de error handling)
supabase functions deploy admin-shipments

# Verificar deployment
supabase functions list
```

**Salida esperada**:
```
┌─────────────────────────┬──────────┬─────────────────────────┐
│ NAME                    │ VERSION  │ UPDATED                 │
├─────────────────────────┼──────────┼─────────────────────────┤
│ admin-cancellations     │ v2       │ 2026-03-01 05:00:00     │
│ admin-shipments         │ v2       │ 2026-03-01 05:00:00     │
└─────────────────────────┴──────────┴─────────────────────────┘
```

---

## Tests con cURL

### 1. admin-cancellations - GET list

```bash
# Reemplazar:
# - YOUR_PROJECT_REF con tu project ref de Supabase
# - YOUR_ANON_KEY con tu anon key
# - YOUR_ADMIN_JWT con un JWT de usuario admin

curl -X GET \
  "https://YOUR_PROJECT_REF.supabase.co/functions/v1/admin-cancellations?action=list" \
  -H "Authorization: Bearer YOUR_ADMIN_JWT" \
  -H "apikey: YOUR_ANON_KEY"
```

**Respuesta esperada** (200):
```json
{
  "requests": [
    {
      "id": "uuid",
      "order_id": "uuid",
      "status": "requested",
      "reason": "...",
      "order": {
        "id": "uuid",
        "email": "user@example.com",
        "status": "paid",
        "total_cents": 5000
      }
    }
  ]
}
```

**Error esperado si no admin** (403):
```json
{
  "error": "Forbidden"
}
```

### 2. admin-cancellations - PATCH approve

```bash
curl -X PATCH \
  "https://YOUR_PROJECT_REF.supabase.co/functions/v1/admin-cancellations" \
  -H "Authorization: Bearer YOUR_ADMIN_JWT" \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "CANCELLATION_REQUEST_ID",
    "action": "approve",
    "admin_notes": "Aprobado por admin"
  }'
```

**Respuesta esperada** (200):
```json
{
  "ok": true,
  "status": "approved",
  "new_order_status": "refunded",
  "stripe_refund_id": "re_xxxxx",
  "refund_amount_cents": 5000
}
```

**Error si Stripe falla** (502):
```json
{
  "error": "Stripe refund failed: ...",
  "where": "admin-cancellations"
}
```

### 3. admin-shipments - GET list

```bash
curl -X GET \
  "https://YOUR_PROJECT_REF.supabase.co/functions/v1/admin-shipments?action=list" \
  -H "Authorization: Bearer YOUR_ADMIN_JWT" \
  -H "apikey: YOUR_ANON_KEY"
```

**Respuesta esperada** (200):
```json
{
  "shipments": [
    {
      "id": "uuid",
      "order_id": "uuid",
      "status": "shipped",
      "carrier": "DHL",
      "tracking_number": "123456789",
      "order": {
        "id": "uuid",
        "email": "user@example.com",
        "total_cents": 5000,
        "status": "shipped"
      }
    }
  ]
}
```

### 4. admin-shipments - POST create

```bash
curl -X POST \
  "https://YOUR_PROJECT_REF.supabase.co/functions/v1/admin-shipments" \
  -H "Authorization: Bearer YOUR_ADMIN_JWT" \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "ORDER_UUID",
    "carrier": "DHL",
    "tracking_number": "123456789",
    "status": "shipped",
    "notes": "Enviado hoy"
  }'
```

**Respuesta esperada** (201):
```json
{
  "shipment": {
    "id": "uuid",
    "order_id": "ORDER_UUID",
    "status": "shipped",
    "carrier": "DHL",
    "tracking_number": "123456789",
    "shipped_at": "2026-03-01T05:00:00Z",
    "notes": "Enviado hoy"
  }
}
```

---

## Validación de Errores Mejorados

Si ocurre un error 500, ahora la respuesta incluye:

```json
{
  "error": "mensaje de error",
  "details": "Error: ...",
  "where": "admin-cancellations" | "admin-shipments",
  "stack": "primeras 500 chars del stack trace"
}
```

Esto facilita el debugging en logs de Supabase Dashboard > Edge Functions > Logs.

---

## Checklist Post-Deploy

- [ ] Deploy admin-cancellations
- [ ] Deploy admin-shipments
- [ ] Verificar logs en Supabase Dashboard (no debe aparecer "Deno.core.runMicrotasks")
- [ ] Test GET list en ambas funciones
- [ ] Test PATCH approve en admin-cancellations (con pedido de prueba)
- [ ] Test POST create en admin-shipments
- [ ] Verificar que emails se envían correctamente (Brevo)
- [ ] Confirmar que refunds de Stripe funcionan (sin SDK)
- [ ] Validar Flutter app: Admin > Cancelaciones y Admin > Envíos

---

## Imports Eliminados - Resumen

### admin-cancellations
```typescript
// ❌ ELIMINADO:
import Stripe from "https://esm.sh/stripe@14.14.0?target=deno";

// ✅ REEMPLAZADO CON:
// fetch puro a https://api.stripe.com/v1/refunds
```

### admin-shipments
```typescript
// ✅ YA ESTABA LIMPIO
// Solo usa:
// - fetch para Brevo API (emails)
// - Supabase client
// - Web APIs estándar (atob, URLSearchParams, etc.)
```

---

## Stripe REST API - Referencia

### Crear Refund
```typescript
POST https://api.stripe.com/v1/refunds
Headers:
  Authorization: Bearer sk_xxx
  Content-Type: application/x-www-form-urlencoded
Body (URLSearchParams):
  payment_intent=pi_xxx
  reason=requested_by_customer
  
Response (200):
{
  "id": "re_xxx",
  "amount": 5000,
  "status": "succeeded",
  ...
}
```

**Documentación**: https://stripe.com/docs/api/refunds/create

---

## Notas Técnicas

1. **No usar SDK de Stripe en Edge Functions**: El SDK usa polyfills de Node.js incompatibles con Deno runtime de Supabase.

2. **Usar fetch puro**: Todas las llamadas a APIs externas (Stripe, Brevo) deben usar `fetch` con Web APIs estándar.

3. **URLSearchParams para form-urlencoded**: Stripe API requiere `application/x-www-form-urlencoded`, usar `new URLSearchParams({...}).toString()`.

4. **Error handling robusto**: Siempre incluir `where`, `details`, `stack` en respuestas 500 para facilitar debugging.

5. **Idempotencia**: admin-cancellations verifica `order.stripe_refund_id` antes de crear refund para evitar duplicados.

6. **Queries en 2 pasos**: Sin FKs en DB, todas las funciones admin usan pattern:
   - Query tabla principal
   - Extraer IDs
   - Query tabla relacionada con `.in(ids)`
   - Merge manual en memoria

---

## Estado Final

| Función | Stripe SDK | Fetch Puro | Error Handling | Estado |
|---------|-----------|------------|----------------|--------|
| admin-cancellations | ❌ Eliminado | ✅ Implementado | ✅ Mejorado | ✅ LISTO |
| admin-shipments | ✅ N/A | ✅ Ya tenía | ✅ Mejorado | ✅ LISTO |

**Listo para redeploy** 🚀
