# Setup: Stripe + Brevo + Supabase Edge Functions

Flutter es ahora **100% independiente de Astro** para checkout, emails y PDFs.

---

## Arquitectura

```
Flutter App
    │
    ├─ create_checkout ──► Supabase Edge Function ──► Stripe Checkout Session
    │                                                  ├─ Valida precios vs fs_products
    │                                                  ├─ Crea fs_orders + fs_order_items
    │                                                  └─ Devuelve { url, session_id, order_id }
    │
    ├─ (usuario paga en Stripe)
    │
    ├─ stripe_webhook ◄── Stripe webhook (checkout.session.completed)
    │                      ├─ Marca fs_orders.status = 'paid'
    │                      ├─ Descuenta stock en fs_products
    │                      ├─ Genera invoice_token
    │                      └─ Envía email con Brevo (resumen + link factura)
    │
    └─ invoice_pdf ──► Supabase Edge Function
                       ├─ Valida order_id + token
                       ├─ Genera PDF con pdf-lib (estilo minimal)
                       ├─ Guarda en Supabase Storage (invoices/)
                       └─ Devuelve signedUrl (1h)
```

---

## 1. Secrets en Supabase

En el dashboard de Supabase → Settings → Edge Functions → Secrets, añadir:

| Secret                  | Valor                                      |
|-------------------------|---------------------------------------------|
| `STRIPE_SECRET_KEY`     | `sk_test_...` o `sk_live_...`              |
| `STRIPE_WEBHOOK_SECRET` | `whsec_...` (se obtiene al crear webhook)  |
| `BREVO_API_KEY`         | Tu API key de Brevo (SMTP)                 |
| `PUBLIC_SITE_URL`       | URL base para success/cancel (ej: `https://tuapp.com` o deep link scheme) |

> `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY` ya están disponibles automáticamente en Edge Functions.

---

## 2. Ejecutar SQL (RLS + Storage)

Ejecutar el contenido de `supabase/migrations/001_rls_policies.sql` en el SQL Editor de Supabase:

```sql
-- Habilita RLS en fs_orders y fs_order_items
-- Crea bucket 'invoices' en Storage
-- Añade columnas stripe_session_id, stripe_payment_intent, invoice_token, paid_at
```

---

## 3. Deploy Edge Functions

```bash
# Instalar Supabase CLI si no lo tienes
npm install -g supabase

# Login
supabase login

# Link al proyecto
supabase link --project-ref qtetgglxmvivfbdgylbz

# Deploy las 3 funciones
supabase functions deploy create_checkout --no-verify-jwt
supabase functions deploy stripe_webhook --no-verify-jwt
supabase functions deploy invoice_pdf --no-verify-jwt
```

> **`--no-verify-jwt`** es necesario para:
> - `create_checkout`: Flutter envía el JWT del anon client automáticamente, pero la función usa service_role internamente.
> - `stripe_webhook`: Stripe no envía JWT, solo firma HMAC.
> - `invoice_pdf`: Se accede por URL directa con token de factura.

---

## 4. Configurar Webhook en Stripe

1. Ve a [Stripe Dashboard → Webhooks](https://dashboard.stripe.com/webhooks)
2. Añadir endpoint:
   - **URL**: `https://qtetgglxmvivfbdgylbz.supabase.co/functions/v1/stripe_webhook`
   - **Eventos**: `checkout.session.completed`
3. Copia el **Signing secret** (`whsec_...`) y ponlo como `STRIPE_WEBHOOK_SECRET` en Supabase Secrets.

---

## 5. Configurar Brevo

1. Crea cuenta en [brevo.com](https://www.brevo.com)
2. Ve a SMTP & API → API Keys → Crear nueva
3. Copia la API key y ponla como `BREVO_API_KEY` en Supabase Secrets
4. **Importante**: Verifica el dominio del sender o usa un email verificado en Brevo
5. En `stripe_webhook/index.ts`, cambia `noreply@fashionstore.com` por tu email verificado

---

## 6. Crear bucket de Storage

Si el SQL no lo creó automáticamente:

1. Supabase Dashboard → Storage → New Bucket
2. Nombre: `invoices`
3. Public: **No** (privado)

---

## 7. Flutter (.env)

El `.env` ya no necesita `ASTRO_BASE_URL` para checkout/emails/PDFs:

```env
SUPABASE_URL=https://qtetgglxmvivfbdgylbz.supabase.co
SUPABASE_ANON_KEY=eyJ...

# ASTRO_BASE_URL ya no es necesario para checkout/emails/PDFs
# Solo mantenerlo si usas Astro para otras cosas (editorial, etc.)
```

---

## 8. Test end-to-end en móvil

### Paso 1: Preparar
```bash
flutter run
```

### Paso 2: Añadir productos al carrito
- Navega al catálogo, añade productos al carrito

### Paso 3: Checkout
- Pulsa "TRAMITAR PEDIDO"
- Se abre Stripe Checkout en el navegador
- Usa tarjeta de test: `4242 4242 4242 4242`, cualquier fecha futura, cualquier CVC
- Completa el pago

### Paso 4: Verificar
- Al volver a la app, la pantalla de éxito muestra:
  - Spinner "Esperando confirmación de pago..."
  - Cuando el webhook procesa (2-10s), cambia a "Generando factura..."
  - Aparece botón "DESCARGAR FACTURA"
- Comprueba tu email (el que usaste en checkout) → debe llegar email de Brevo

### Paso 5: Verificar en Supabase
```sql
SELECT id, status, paid_at, invoice_token FROM fs_orders ORDER BY created_at DESC LIMIT 5;
SELECT * FROM fs_order_items WHERE order_id = '<order_id>';
```

### Paso 6: Verificar stock
```sql
SELECT id, name, stock, size_stock FROM fs_products WHERE id IN (
  SELECT product_id FROM fs_order_items WHERE order_id = '<order_id>'
);
```

### Paso 7: Factura PDF
- En "Mi cuenta" → "Pedidos" → detalle del pedido → "Descargar factura"
- También disponible en el email

---

## 9. Troubleshooting

| Problema | Solución |
|----------|----------|
| "STRIPE_SECRET_KEY not configured" | Añadir secret en Supabase Dashboard |
| Webhook no llega | Verificar URL del endpoint y que el evento `checkout.session.completed` esté seleccionado |
| Email no llega | Verificar BREVO_API_KEY y que el sender email esté verificado en Brevo |
| Factura no se genera | Verificar que el bucket `invoices` existe en Storage |
| "Error del servidor (500)" en checkout | Revisar logs: `supabase functions logs create_checkout` |
| RLS bloquea lectura de pedidos | Ejecutar el SQL de `001_rls_policies.sql` |

### Ver logs de Edge Functions
```bash
supabase functions logs create_checkout --tail
supabase functions logs stripe_webhook --tail
supabase functions logs invoice_pdf --tail
```

---

## Archivos modificados/creados

### Edge Functions (nuevas)
- `supabase/functions/create_checkout/index.ts`
- `supabase/functions/stripe_webhook/index.ts`
- `supabase/functions/invoice_pdf/index.ts`

### SQL
- `supabase/migrations/001_rls_policies.sql`

### Flutter (modificados)
- `lib/features/checkout/data/datasources/checkout_remote_datasource.dart` — Supabase Functions en vez de Astro HTTP
- `lib/features/checkout/domain/repositories/checkout_repository.dart` — Sin accessToken params
- `lib/features/checkout/data/repositories/checkout_repository_impl.dart` — Idem
- `lib/features/checkout/presentation/providers/checkout_providers.dart` — Sin sendOrderConfirmation, pollInvoiceUrl usa orderId+token
- `lib/features/checkout/presentation/screens/checkout_success_screen.dart` — Polling order status → invoice_pdf
- `lib/features/orders/presentation/screens/order_detail_screen.dart` — Invoice URL via Supabase Functions
- `lib/features/admin/presentation/screens/admin_order_detail_screen.dart` — Idem
- `lib/features/returns/data/datasources/returns_remote_datasource.dart` — Supabase directo en vez de Astro HTTP
- `lib/features/returns/domain/repositories/returns_repository.dart` — Sin accessToken
- `lib/features/returns/data/repositories/returns_repository_impl.dart` — Idem
- `lib/features/returns/presentation/providers/returns_providers.dart` — Idem
