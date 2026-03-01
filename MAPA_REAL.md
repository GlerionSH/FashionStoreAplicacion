# MAPA REAL — Astro "nasty-neptune" → Flutter

> Generado tras auditar el repo Astro en `c:\Users\ruben\Desktop\tienda fashion\CRM-ASTRO\nasty-neptune\`
> Fuentes: 19 migraciones SQL, 10 API endpoints, 1 cart store, 2 flash-offer libs, 6 pages storefront.

---

## 1. TABLAS `fs_*` — Columnas exactas confirmadas

### `fs_products` (base + migraciones 006, 007, 017, 019)

| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| name | text | |
| name_es | text, nullable | i18n (mig 017) |
| name_en | text, nullable | i18n (mig 017) |
| slug | text | |
| description | text | |
| description_es | text, nullable | i18n (mig 019) |
| description_en | text, nullable | i18n (mig 019) |
| price_cents | integer | En centavos EUR |
| stock | integer | Stock general (sin tallas) |
| category_id | uuid FK fs_categories | |
| is_active | boolean | |
| images | text[] o jsonb | Array de URLs |
| product_type | text | 'clothing' \| 'shoes' (mig 007) |
| sizes | text[] | e.g. ['S','M','L'] (mig 007) |
| size_stock | jsonb | e.g. {"M":5,"L":3} (mig 007) |
| is_flash | boolean | Para flash offers (mig 006) |

### `fs_categories` (base + mig 018)

| Columna | Tipo |
|---|---|
| id | uuid PK |
| name | text |
| name_es | text, nullable |
| name_en | text, nullable |
| slug | text |

### `fs_profiles` (confirmado en middleware.ts)

| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK = auth.users.id | |
| role | text | 'admin' \| (implícito 'customer') |

### `fs_settings` (mig 006)

| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| singleton | boolean | constraint = true, unique |
| flash_offers_enabled | boolean | |
| updated_at | timestamptz | |

### `fs_flash_offers` (mig 009)

| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| created_at | timestamptz | |
| updated_at | timestamptz | |
| is_enabled | boolean | Unique index: solo 1 habilitada |
| discount_percent | integer | 0–90 |
| starts_at | timestamptz, nullable | |
| ends_at | timestamptz, nullable | |
| show_popup | boolean | |
| popup_title | text, nullable | |
| popup_text | text, nullable | |

**RLS**: público solo puede leer ofertas activas (is_enabled + fechas válidas). Admins full access.

### `fs_orders` (mig 003 + 005 + 011 + 012)

| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| created_at | timestamptz | |
| email | text, nullable | |
| user_id | uuid FK auth.users, nullable | mig 005 |
| subtotal_cents | integer | |
| discount_cents | integer, default 0 | |
| total_cents | integer | |
| status | text | 'test' \| 'pending' \| 'paid' \| 'cancelled' \| 'refunded' \| 'shipped' |
| invoice_token | text, nullable | mig 011 |
| invoice_number | text, nullable | Formato: FS-YYYY-000001 (mig 011) |
| invoice_issued_at | timestamptz, nullable | mig 011 |
| refund_total_cents | integer, default 0 | mig 012 |
| paid_at | timestamptz, nullable | mig 012 |
| stripe_session_id | text, nullable | mig 012 |
| stripe_payment_intent_id | text, nullable | mig 012 |

### `fs_order_items` (mig 003 + 007 + 010 + 015)

| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| created_at | timestamptz | |
| order_id | uuid FK fs_orders | CASCADE |
| product_id | uuid FK fs_products | |
| name | text | Snapshot del nombre (mig 010) |
| qty | integer | > 0 |
| price_cents | integer | Precio unitario original |
| line_total_cents | integer | price_cents × qty |
| size | text, nullable | mig 007 |
| paid_unit_cents | integer, nullable | Con descuento prorrateado (mig 015) |
| paid_line_total_cents | integer, nullable | Con descuento prorrateado (mig 015) |

### `fs_returns` (mig 012 + 013)

| Columna | Tipo | Notas |
|---|---|---|
| id | uuid PK | |
| order_id | uuid FK fs_orders | CASCADE |
| user_id | uuid, nullable | |
| status | text | 'requested' \| 'approved' \| 'rejected' \| 'refunded' \| 'cancelled' |
| reason | text, nullable | |
| requested_at | timestamptz | |
| reviewed_at | timestamptz, nullable | |
| reviewed_by | text, nullable | |
| refunded_at | timestamptz, nullable | |
| refund_method | text | 'manual' \| 'stripe' |
| refund_total_cents | integer, default 0 | Auto-calculado por trigger |
| currency | text, default 'EUR' | |
| stripe_refund_id | text, nullable | |
| notes | text, nullable | |
| email_sent_requested_at | timestamptz, nullable | mig 013 |
| email_sent_reviewed_at | timestamptz, nullable | mig 013 |
| email_sent_refunded_at | timestamptz, nullable | mig 013 |

### `fs_return_items` (mig 012)

| Columna | Tipo |
|---|---|
| id | uuid PK |
| return_id | uuid FK fs_returns |
| order_item_id | uuid FK fs_order_items |
| qty | integer, > 0 |
| line_total_cents | integer, default 0 |

### `fs_collections` (mig 017) — *no prioritario para Hito 2/3*

| Columna | Tipo |
|---|---|
| id | uuid PK |
| slug | text, unique |
| type | text, default 'season' |
| name_es / name_en | text |
| subtitle_es / subtitle_en | text, nullable |
| hero_image_url / banner_image_url | text, nullable |
| is_active | boolean |
| sort_order | integer |
| starts_at / ends_at | timestamptz, nullable |

### `fs_collection_products` (mig 017)

PK (collection_id, product_id), sort_order integer.

### `fs_invoice_seq` (mig 011) — *server-only, no relevante para Flutter*

Singleton row para numerar facturas secuencialmente.

### `fs_subscribers`, `fs_email_campaigns`, `fs_email_deliveries` (mig 014) — *admin/server-only*

---

## 2. API ENDPOINTS — Rutas reales con payloads y respuestas

### `POST /api/checkout` → delega a `/api/stripe/checkout`
**Archivo**: `src/pages/api/stripe/checkout.ts`

**Request body** (JSON):
```json
{
  "email": "optional@email.com",
  "items": [
    { "product_id": "uuid", "qty": 1, "size": "M" }
  ]
}
```

**Auth**: Cookie `sb-access-token` (opcional — guest checkout funciona sin auth).

**Flujo interno**:
1. Valida items (product_id, qty > 0)
2. Normaliza items por `product_id__size`
3. Resuelve user_id desde cookie (si existe)
4. Llama RPC `fs_checkout_test(items, email, user_id)` con **service_role key**
5. RPC crea orden, decrementa stock, aplica descuentos
6. Carga order_items creados
7. Crea Stripe Checkout Session con line_items + coupon si descuento > 0
8. success_url = `${SITE}/checkout/success?session_id={CHECKOUT_SESSION_ID}`
9. cancel_url = `${SITE}/carrito`

**Response** (200):
```json
{
  "url": "https://checkout.stripe.com/...",
  "session_id": "cs_...",
  "order_id": "uuid",
  "subtotal_cents": 5000,
  "discount_cents": 500,
  "total_cents": 4500
}
```

### `POST /api/checkout-test` (sin Stripe)
**Archivo**: `src/pages/api/checkout-test.ts`

Mismo body que /api/checkout pero sin Stripe. Devuelve `{ order_id, subtotal_cents, discount_cents, total_cents }`.

### `GET /api/flash-offer`
**Archivo**: `src/pages/api/flash-offer.ts`

**Response** (200):
```json
{ "active": false }
// o
{
  "active": true,
  "offer": {
    "id": "uuid",
    "discount_percent": 20,
    "show_popup": true,
    "popup_title": "¡Oferta Flash!",
    "popup_text": "20% de descuento",
    "starts_at": "2025-01-01T00:00:00Z",
    "ends_at": "2025-01-31T23:59:59Z"
  }
}
```

**Lógica**: `fs_settings.flash_offers_enabled` → si true, busca `fs_flash_offers` donde `is_enabled=true` + fechas válidas + `discount_percent > 0`.

### `GET /api/orders/invoice-url?session_id=XXX`
**Archivo**: `src/pages/api/orders/invoice-url.ts`

**Auth**: Cookie `sb-access-token` (requerido).

**Response** (200): `{ "invoiceUrl": "https://site/api/orders/{id}/invoice.pdf?token=XXX" }`
**Response** (404): `{ "error": "invoice_not_ready" }` — polling cada 2s, hasta 30 intentos.

### `GET /api/orders/[orderId]/invoice.pdf?token=XXX`
**Archivo**: `src/pages/api/orders/[orderId]/invoice.pdf.ts`

Genera PDF con pdfkit. Auth por token (no cookie).

### `GET /api/returns/my`
**Archivo**: `src/pages/api/returns/my.ts`

**Auth**: Cookie `sb-access-token` (requerido).

**Response** (200):
```json
{
  "returns": [
    {
      "id": "uuid",
      "order_id": "uuid",
      "status": "requested",
      "reason": "No me queda bien",
      "requested_at": "...",
      "reviewed_at": null,
      "refunded_at": null,
      "refund_method": "manual",
      "refund_total_cents": 2500,
      "currency": "EUR",
      "notes": null,
      "fs_return_items": [
        { "id": "uuid", "order_item_id": "uuid", "qty": 1, "line_total_cents": 2500 }
      ]
    }
  ]
}
```

### `POST /api/returns/request`
**Archivo**: `src/pages/api/returns/request.ts`

**Auth**: Cookie `sb-access-token` (requerido).

**Request body**:
```json
{
  "orderId": "uuid",
  "reason": "No me queda bien",
  "items": [
    { "orderItemId": "uuid", "qty": 1 }
  ]
}
```

**Validaciones**: order.status === 'paid', order.user_id === auth user, qty ≤ available (menos ya devueltas).

**Response** (200): `{ "ok": true, "returnId": "uuid", "status": "requested" }`

### `GET /api/me`
**Archivo**: `src/pages/api/me.ts`

**Response**: `{ "loggedIn": true|false }`

### `POST /api/stripe/webhook`
**Archivo**: `src/pages/api/stripe/webhook.ts`

Server-to-server. No relevante para Flutter directamente.
- `checkout.session.completed` → status='paid', genera invoice_token + invoice_number
- `checkout.session.expired` → status='cancelled'

### `GET /api/cloudinary/sign`
**Archivo**: `src/pages/api/cloudinary/sign.ts`

Admin image upload signing. No prioritario.

---

## 3. CART STORE — `src/stores/cart.ts`

```typescript
type CartItem = {
  id: string;          // product_id
  name: string;
  price_cents: number;
  qty: number;
  stock?: number;
  image_url?: string;
  size?: string;
};
```

- **Storage key**: `fashionstore_cart_v1` (localStorage)
- **Cart key format**: `${id}__${size}` o solo `id` si sin talla
  - ⚠️ Flutter usa `$productId|${size ?? ""}` — diferente separador, pero no importa (Flutter usa SharedPreferences, no comparte con web)
- **Subtotal**: `sum(price_cents × qty)` por item
- **Stock clamping**: `clampQty(qty, stock)` — si stock ≤ 0, no añade; limita qty a stock

---

## 4. FLASH OFFER LOGIC — `src/lib/flashOffer.ts`

```typescript
applyPercentDiscountCents(priceCents, percent):
  p = Math.trunc(percent)
  if p <= 0: return priceCents
  discounted = Math.floor((base * (100 - p)) / 100)
  return Math.max(0, discounted)

isFlashOfferActiveNow(offer):
  is_enabled && (starts_at == null || starts_at <= now) && (ends_at == null || ends_at >= now)

getActiveFlashOffer(sb):
  1. fs_settings.select('flash_offers_enabled').eq('singleton', true).maybeSingle()
  2. Si no enabled → null
  3. fs_flash_offers.select(...).eq('is_enabled', true).order('updated_at', desc).limit(10)
  4. Primer offer donde isFlashOfferActiveNow + discount_percent > 0
```

### Descuento en checkout RPC (server-side, mig 016):
1. subtotal = sum(price_cents × qty)
2. Si flash_offers_enabled + oferta activa: `discount = floor(subtotal × percent / 100)`
3. Else si subtotal >= 10000 (€100): `discount = floor(subtotal × 0.1)` (10% fijo)
4. Else: discount = 0
5. `discount = greatest(0, least(discount, subtotal))`
6. `total = subtotal - discount`

---

## 5. CHECKOUT SUCCESS — `src/pages/checkout/success.astro`

1. Lee `session_id` del query param
2. Limpia carrito: `localStorage.removeItem('fashionstore_cart_v1')`
3. Polling: `GET /api/orders/invoice-url?session_id=XXX` cada 2s, hasta 30 intentos
4. Si 200 + invoiceUrl → muestra botón "Descargar factura (PDF)"
5. Si 401 → "Inicia sesión para descargar la factura"
6. Si 404 invoice_not_ready y tries < 30 → retry

---

## 6. ORDERS DISPLAY — Consultas Supabase directas (NO API)

### Lista de pedidos (`cuenta.astro` y `cuenta/pedidos/index.astro`):
```sql
SELECT id, created_at, total_cents, status, invoice_token, invoice_number
FROM fs_orders
WHERE user_id = $userId
ORDER BY created_at DESC
```

### Detalle de pedido (`cuenta/pedidos/[id].astro`):
Columnas de `fs_orders` + join `fs_order_items` con las columnas del item.

**Status display**: test, pending, paid, cancelled, refunded, shipped

---

## 7. MIDDLEWARE / RUTAS WEB (confirmadas en `src/middleware.ts`)

| Ruta | Tipo | Auth |
|---|---|---|
| `/` | Storefront home | Público |
| `/productos`, `/productos/[slug]` | Catálogo y detalle | Público |
| `/categoria/*` | Categorías | Público |
| `/carrito` | Carrito | Público |
| `/auth/*` | Login/registro | Público |
| `/cuenta`, `/cuenta/*` | Mi cuenta, pedidos | Requiere `sb-access-token` → redirect `/auth/login` |
| `/admin-fs/*` | Admin tienda | Requiere `sb-access-token` + `fs_profiles.role = 'admin'` |
| `/checkout/success` | Post-pago | Público (polling auth para factura) |

---

## 8. DECISIONES PARA FLUTTER

### Checkout
- Flutter debe hacer **POST al endpoint Astro** `/api/checkout` (no RPC directa, porque requiere service_role key)
- Auth: enviar header `Cookie: sb-access-token=XXX` si logged in
- Alternativa: si el Astro server no está desplegado, usar `/api/checkout-test` para testing
- Abrir `url` devuelta con `url_launcher`
- En CheckoutSuccessScreen: poll `/api/orders/invoice-url` y limpiar carrito

### Orders
- Query **Supabase directa** (el web lo hace así, no hay API endpoint para listar)
- Select: `id, created_at, total_cents, status, invoice_token, invoice_number`
- Detail: join `fs_order_items(id, name, qty, size, price_cents, line_total_cents, paid_unit_cents, paid_line_total_cents)`

### Flash Offers
- Opción A: GET `/api/flash-offer` (como el web client)
- Opción B: Supabase directo (como el web server) — preferible para Flutter, evita dependencia del Astro server
- Lógica de descuento visual: `applyPercentDiscountCents(priceCents, discountPercent)`

### Returns
- POST a `/api/returns/request` y GET `/api/returns/my` — endpoints reales existen
- Auth via cookie header

### Variables de entorno necesarias
- `ASTRO_BASE_URL` — URL del servidor Astro para llamar endpoints
- `PUBLIC_SUPABASE_URL` / `PUBLIC_SUPABASE_ANON_KEY` — ya configurados

---

## 9. RPC `fs_checkout_test` — Firma final (mig 016)

```sql
fs_checkout_test(
  items jsonb,           -- [{"product_id":"uuid","qty":1,"size":"M"}]
  customer_email text,   -- nullable
  customer_user_id uuid  -- nullable
)
RETURNS TABLE (order_id uuid, subtotal_cents int, discount_cents int, total_cents int)
```

**Solo ejecutable con service_role key** (GRANT to service_role, REVOKE from public).
