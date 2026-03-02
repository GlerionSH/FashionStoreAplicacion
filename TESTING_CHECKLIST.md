# Testing Checklist — Purchase, Shipping & Return Flow

## Pre-requisitos

- [ ] Variables de entorno configuradas en Supabase Dashboard:
  - `STRIPE_SECRET_KEY`
  - `STRIPE_WEBHOOK_SECRET`
  - `SUPABASE_SERVICE_ROLE_KEY`
  - `SUPABASE_URL`
  - `BREVO_API_KEY`
  - `ADMIN_EMAIL` (email del admin que recibe notificaciones)

---

## Deployment — Edge Functions

```bash
# Desde la raiz del proyecto
supabase functions deploy stripe_webhook --no-verify-jwt
supabase functions deploy admin-shipments
supabase functions deploy request-cancel
supabase functions deploy admin-returns
supabase functions deploy admin-cancellations
```

> **Nota**: `stripe_webhook` necesita `--no-verify-jwt` porque Stripe envía webhooks sin JWT.

---

## 1. Flujo de Pago → Envio automatico

### 1.1 Pago exitoso crea shipment
- [ ] Realizar compra de prueba con Stripe test card `4242 4242 4242 4242`
- [ ] Verificar en DB: `SELECT * FROM fs_shipments WHERE order_id = '<ORDER_ID>'`
  - `status` debe ser `'pending'`
- [ ] Verificar en DB: `SELECT status FROM fs_orders WHERE id = '<ORDER_ID>'`
  - `status` debe ser `'paid'`
- [ ] Verificar que admin recibió email de nuevo pedido

### 1.2 Idempotencia del shipment
- [ ] Re-enviar mismo webhook event (Stripe Dashboard → Webhooks → Resend)
- [ ] Verificar que NO se creó un segundo shipment (upsert con `ignoreDuplicates`)

---

## 2. Gestion de Envios (Admin)

### 2.1 Listar envios
```bash
curl -X GET '<SUPABASE_URL>/functions/v1/admin-shipments' \
  -H 'Authorization: Bearer <ADMIN_JWT>'
```
- [ ] Respuesta contiene array de shipments con `order_id`, `status`, `carrier`, etc.

### 2.2 Actualizar a "shipped"
```bash
curl -X PATCH '<SUPABASE_URL>/functions/v1/admin-shipments' \
  -H 'Authorization: Bearer <ADMIN_JWT>' \
  -H 'Content-Type: application/json' \
  -d '{"shipment_id":"<ID>","status":"shipped","carrier":"SEUR","tracking_number":"TR123"}'
```
- [ ] `fs_shipments.status` = `'shipped'`
- [ ] `fs_orders.status` = `'shipped'`
- [ ] Cliente recibe email con datos de envio e items del pedido
- [ ] Admin recibe email de confirmacion

### 2.3 Actualizar a "delivered"
```bash
curl -X PATCH '<SUPABASE_URL>/functions/v1/admin-shipments' \
  -H 'Authorization: Bearer <ADMIN_JWT>' \
  -H 'Content-Type: application/json' \
  -d '{"shipment_id":"<ID>","status":"delivered"}'
```
- [ ] `fs_shipments.status` = `'delivered'`
- [ ] `fs_orders.status` = `'delivered'`
- [ ] Cliente recibe email de entrega completada

---

## 3. Solicitud de Cancelacion (pre-entrega)

### 3.1 Cliente solicita cancelacion
- [ ] Desde la app Flutter, en pedido con status `'paid'` o `'preparing'`, pulsar "Solicitar cancelacion"
- [ ] Escribir motivo y enviar
- [ ] Verificar en DB: `SELECT * FROM fs_returns WHERE order_id = '<ORDER_ID>'`
  - `status` = `'requested'`
  - `request_type` = `'cancellation'`
- [ ] Cliente recibe email de confirmacion de solicitud
- [ ] Admin recibe email de nueva solicitud

### 3.2 Verificar que no se duplica
- [ ] Intentar solicitar cancelacion del mismo pedido otra vez
- [ ] Debe mostrar error "already exists"

---

## 4. Solicitud de Devolucion (post-entrega)

### 4.1 Cliente solicita devolucion
- [ ] Desde la app Flutter, en pedido con status `'delivered'`, pulsar "Solicitar devolucion"
- [ ] Escribir motivo y enviar
- [ ] Verificar en DB: `SELECT * FROM fs_returns WHERE order_id = '<ORDER_ID>'`
  - `status` = `'requested'`
  - `request_type` = `'return'`
- [ ] Emails enviados a cliente y admin

---

## 5. Admin: Aprobar Devolucion/Cancelacion

### 5.1 Listar solicitudes
```bash
curl -X GET '<SUPABASE_URL>/functions/v1/admin-returns' \
  -H 'Authorization: Bearer <ADMIN_JWT>'
```
- [ ] Respuesta contiene array con `request_type`, `order` (con email), `status`

### 5.2 Ver detalle
```bash
curl -X GET '<SUPABASE_URL>/functions/v1/admin-returns?return_id=<RETURN_ID>' \
  -H 'Authorization: Bearer <ADMIN_JWT>'
```
- [ ] Respuesta contiene `return`, `order`, `shipment`, `items`

### 5.3 Aprobar (refund via Stripe)
```bash
curl -X PATCH '<SUPABASE_URL>/functions/v1/admin-returns' \
  -H 'Authorization: Bearer <ADMIN_JWT>' \
  -H 'Content-Type: application/json' \
  -d '{"return_id":"<RETURN_ID>","action":"approve"}'
```
- [ ] `fs_returns.status` = `'refunded'`
- [ ] `fs_returns.refund_total_cents` = total del pedido
- [ ] `fs_orders.status` = `'refunded'`
- [ ] Stripe Dashboard muestra refund creado para el `payment_intent`
- [ ] Stock restaurado (verificar `fs_products.stock` y `size_stock`)
- [ ] `fs_orders.refund_total_cents` actualizado por trigger `trg_fs_returns_recalc_order`
- [ ] Cliente recibe email de reembolso aprobado
- [ ] Admin recibe email de confirmacion

### 5.4 Rechazar
```bash
curl -X PATCH '<SUPABASE_URL>/functions/v1/admin-returns' \
  -H 'Authorization: Bearer <ADMIN_JWT>' \
  -H 'Content-Type: application/json' \
  -d '{"return_id":"<RETURN_ID>","action":"reject","admin_notes":"Fuera de plazo"}'
```
- [ ] `fs_returns.status` = `'rejected'`
- [ ] `fs_returns.notes` contiene las notas del admin
- [ ] Stock NO restaurado
- [ ] Cliente recibe email de rechazo con motivo

---

## 6. Stock Restoration (Trigger automatico)

### 6.1 Producto sin tallas
- [ ] Antes de aprobar: anotar `fs_products.stock` del producto
- [ ] Aprobar devolucion
- [ ] Verificar: `stock` incrementado en la cantidad del item

### 6.2 Producto con tallas
- [ ] Antes de aprobar: anotar `fs_products.size_stock` del producto
- [ ] Aprobar devolucion
- [ ] Verificar: `size_stock->'<TALLA>'` incrementado en la cantidad

### 6.3 Idempotencia
- [ ] Intentar aprobar la misma devolucion dos veces
- [ ] Segunda vez debe fallar (status ya no es 'requested')
- [ ] Stock NO se duplica

---

## 7. Flutter UI

### 7.1 Order Detail Screen (cliente)
- [ ] Pedido `paid`/`preparing`: muestra boton "Solicitar cancelacion"
- [ ] Pedido `shipped`: muestra boton "Solicitar cancelacion"
- [ ] Pedido `delivered`: muestra boton "Solicitar devolucion"
- [ ] Pedido `cancelled`/`refunded`: NO muestra boton
- [ ] Tras solicitar: muestra badge "Cancelacion solicitada"

### 7.2 Admin Returns Screen
- [ ] Lista todas las solicitudes de `fs_returns`
- [ ] Muestra badge DEV/CANCEL segun `request_type`
- [ ] Muestra email del cliente
- [ ] Status con colores: naranja=requested, verde=refunded, rojo=rejected

### 7.3 Admin Return Detail Screen
- [ ] Muestra tipo (DEVOLUCION/CANCELACION)
- [ ] Muestra info del pedido, email, fecha, estado envio
- [ ] Muestra items del pedido con tallas y precios
- [ ] Botones Aprobar/Rechazar solo para status `requested`
- [ ] Estado `refunded` muestra "Reembolso procesado"

---

## 8. Edge Cases

- [ ] Pedido sin `stripe_payment_intent_id`: aprobar debe fallar con error claro
- [ ] Pedido ya reembolsado: no debe permitir segundo reembolso
- [ ] Producto eliminado: trigger de stock hace `CONTINUE` (skip), no falla
- [ ] Email de Brevo falla: operacion continua (email es best-effort)
- [ ] JWT expirado: retorna 401
- [ ] Usuario no-admin intenta admin endpoints: retorna 403

---

## Archivos Modificados

| Archivo | Cambio |
|---------|--------|
| `supabase/functions/stripe_webhook/index.ts` | Upsert `fs_shipments` pending tras pago |
| `supabase/functions/admin-shipments/index.ts` | Items en emails de envio |
| `supabase/functions/request-cancel/index.ts` | Rewrite completo → `fs_returns` unificado |
| `supabase/functions/admin-returns/index.ts` | Rewrite completo: GET list/detail, PATCH approve/reject con Stripe REST refund |
| `supabase/functions/admin-cancellations/index.ts` | Eliminado Stripe SDK, refund via fetch |
| `lib/.../order_detail_screen.dart` | Boton cancel/return expandido a shipped/delivered |
| `lib/.../admin_returns_screen.dart` | Badges tipo, email, colores status |
| `lib/.../admin_return_detail_screen.dart` | Action API, items, shipment info, tipo |
| `lib/l10n/app_es.arb` + `app_en.arb` | Key `ordersReturnRequest` |

## SQL Triggers (ya existentes, no modificados)

| Trigger | Tabla | Accion |
|---------|-------|--------|
| `trg_fs_restore_stock_on_refund` | `fs_returns` | Restaura stock (con tallas) cuando status → `refunded` |
| `trg_fs_returns_recalc_order` | `fs_returns` | Recalcula `fs_orders.refund_total_cents` |
