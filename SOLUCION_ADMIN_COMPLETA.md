# Solución Completa - Admin FashionStore

## ✅ Problemas Resueltos

### 1. Error 500 "Could not find relationship in schema cache"
**Causa**: Las Edge Functions usaban joins implícitos tipo `.select('*, order:fs_orders(...)')` que requieren Foreign Keys explícitas en el esquema.

**Solución**: Implementado **queries en 2 pasos** en todas las Edge Functions:
1. Query tabla base
2. Extraer IDs
3. Query tabla relacionada con `.in('id', ids)`
4. Merge manual en memoria

**Funciones corregidas**:
- ✅ `admin-shipments` - Líneas 153-180
- ✅ `admin-cancellations` - Líneas 127-165 (list), 187-207 (PATCH)
- ✅ `admin-coupons` - Líneas 77-107
- ✅ `admin-returns` - Líneas 50-90 (detalle con order + items)

### 2. Detalle de Devolución en Blanco
**Causa**: La función `admin-returns` no soportaba GET con `?return_id=X` para obtener un detalle individual.

**Solución**: ✅ Añadido soporte en `admin-returns/index.ts` líneas 50-90:
- GET `?return_id=X` → devuelve detalle completo
- Merge manual de order (email, total, status)
- Merge manual de items desde `fs_return_items`
- Respuesta: `{ return: { ...returnData, order: {...}, items: [...] } }`

### 3. Error 404 NOT_FOUND en Edge Functions
**Causa**: Las funciones existen en el código pero **NO están deployadas** en Supabase.

**Solución**: Ver sección "Deployment Obligatorio" más abajo.

### 4. Navegación Back
**Estado**: ✅ Ya implementado en sesión anterior
- Todas las pantallas admin tienen `PopScope(canPop: true)`
- AppBar con `leading: IconButton(icon: Icon(Icons.arrow_back))`
- Botón físico back hace `context.pop()` correctamente

### 5. Carrito y Perfil
**Estado**: ✅ Verificado - No hay regresiones
- `cart_screen.dart` funciona correctamente
- `account_screen.dart` funciona correctamente

## 📋 Edge Functions Modificadas

### admin-returns/index.ts
**Cambios**:
- Añadido soporte para GET `?return_id=X` (detalle individual)
- Query en 2 pasos: return → order → items
- Merge manual sin joins implícitos

**Endpoints**:
- GET `?return_id=X` → Detalle de devolución con order e items
- GET (sin params) → Lista de devoluciones
- PATCH `{ return_id, status }` → Actualizar estado

### admin-shipments/index.ts
**Cambios**:
- Reemplazado `.select('*, order:fs_orders(...)')` por queries en 2 pasos
- Líneas 153-180: Query shipments → Query orders → Merge

**Endpoints**:
- GET `?order_id=X` → Shipment de un pedido
- GET (sin params) → Lista de shipments con orders
- POST → Crear/actualizar shipment
- PATCH → Actualizar shipment + enviar email

### admin-cancellations/index.ts
**Cambios**:
- Reemplazado joins implícitos en GET list (líneas 152-165)
- Reemplazado join en GET detail (líneas 127-149)
- Reemplazado join en PATCH (líneas 187-207)
- Todas las queries ahora en 2 pasos

**Endpoints**:
- GET `?action=detail&id=X` → Detalle de cancelación
- GET (sin params) → Lista de cancelaciones
- PATCH `{ id, action: 'approve'|'reject', admin_notes }` → Aprobar/rechazar

### admin-coupons/index.ts
**Cambios**:
- Reemplazado `.select('*, redemptions_count:...')` por queries en 2 pasos
- Líneas 77-107: Query coupons → Query redemptions → Count manual → Merge

**Endpoints**:
- GET → Lista de cupones con conteo de redemptions
- GET `?action=redemptions&coupon_id=X` → Redemptions de un cupón
- POST → Crear cupón
- PATCH → Actualizar cupón
- DELETE → Eliminar cupón (solo si no tiene redemptions)

### admin-users/index.ts
**Estado**: ✅ Ya estaba correcto
- No usa joins implícitos
- Query en 2 pasos: auth.users → fs_profiles → Merge

## 🚀 Deployment Obligatorio

**CRÍTICO**: Las Edge Functions están corregidas pero **NO deployadas**. Debes ejecutar:

```powershell
cd c:\Users\ruben\tienda_flutter\fashion_store

# Deploy funciones admin corregidas
supabase functions deploy admin-returns
supabase functions deploy admin-shipments
supabase functions deploy admin-cancellations
supabase functions deploy admin-coupons
supabase functions deploy admin-users

# Deploy resto de funciones admin
supabase functions deploy admin-orders
supabase functions deploy admin-metrics
supabase functions deploy admin-flash
supabase functions deploy admin-products-delete

# Deploy funciones cliente
supabase functions deploy validate-coupon
supabase functions deploy newsletter
supabase functions deploy request-cancel
supabase functions deploy create_checkout
supabase functions deploy create_payment_intent
supabase functions deploy invoice_pdf
```

### Verificación Post-Deployment

1. **Supabase Dashboard** → Edge Functions
   - Verifica que todas las funciones aparezcan listadas
   - Estado: "Active"

2. **Variables de Entorno** (Dashboard → Project Settings → Edge Functions)
   - ✅ `SUPABASE_URL`
   - ✅ `SUPABASE_SERVICE_ROLE_KEY`
   - ✅ `STRIPE_SECRET_KEY`
   - ✅ `BREVO_API_KEY`
   - ✅ `EMAIL_FROM`
   - ✅ `EMAIL_FROM_NAME`

3. **Aplicar Migración SQL**
```powershell
supabase db push
```

## 🧪 Testing del Admin

### 1. Coupons (admin-coupons)
```
1. Login como admin
2. Ir a Admin Panel → Cupones
3. Crear cupón: código "TEST10", 10% descuento
4. Verificar que aparece en lista con contador de redemptions = 0
5. Toggle activo/inactivo
6. Intentar eliminar (debe funcionar si no tiene redemptions)
```

### 2. Users (admin-users)
```
1. Admin Panel → Usuarios
2. Ver lista de usuarios con email, role, last_sign_in
3. Cambiar role de un usuario: user ↔ admin
4. Toggle activo/inactivo (ban/unban)
```

### 3. Shipments (admin-shipments)
```
1. Admin Panel → Envíos
2. Ver lista de shipments con order info
3. Crear shipment para un pedido
4. Editar: cambiar status (pending → shipped → delivered)
5. Verificar que se envía email al cliente
```

### 4. Cancellations (admin-cancellations)
```
1. Admin Panel → Cancelaciones
2. Ver lista de solicitudes con order info
3. Aprobar una cancelación:
   - Debe crear refund en Stripe
   - Debe restaurar stock
   - Debe enviar email al cliente
4. Rechazar una cancelación con notas admin
```

### 5. Returns (admin-returns)
```
1. Admin Panel → Devoluciones
2. Click en una devolución → Debe abrir DETALLE (no en blanco)
3. Verificar que muestra:
   - Motivo (reason)
   - Status
   - Monto reembolso
   - Email del pedido
   - Items (si hay fs_return_items)
4. Aprobar/Rechazar desde detalle
```

## 📊 Estructura de Respuestas

### admin-returns GET ?return_id=X
```json
{
  "return": {
    "id": "uuid",
    "order_id": "uuid",
    "status": "requested|approved|rejected|refunded",
    "reason": "...",
    "refund_total_cents": 5000,
    "requested_at": "2026-02-28T...",
    "order": {
      "id": "uuid",
      "email": "user@example.com",
      "total_cents": 10000,
      "status": "paid"
    },
    "items": [
      { "product_id": "...", "quantity": 1, ... }
    ]
  }
}
```

### admin-shipments GET (list)
```json
{
  "shipments": [
    {
      "id": "uuid",
      "order_id": "uuid",
      "status": "pending|shipped|delivered",
      "carrier": "DHL",
      "tracking_number": "123456",
      "order": {
        "id": "uuid",
        "email": "user@example.com",
        "total_cents": 10000,
        "status": "paid"
      }
    }
  ]
}
```

### admin-cancellations GET (list)
```json
{
  "requests": [
    {
      "id": "uuid",
      "order_id": "uuid",
      "status": "requested|approved|rejected",
      "reason": "...",
      "requested_at": "...",
      "order": {
        "id": "uuid",
        "email": "user@example.com",
        "status": "paid",
        "total_cents": 10000
      }
    }
  ]
}
```

### admin-coupons GET (list)
```json
{
  "coupons": [
    {
      "id": "uuid",
      "code": "WELCOME10",
      "percent_off": 10,
      "active": true,
      "redemptions_count": [{ "count": 5 }]
    }
  ]
}
```

## 🔍 Debugging

### Si sigue dando 404
1. Verifica que las funciones están deployadas:
   ```powershell
   supabase functions list
   ```

2. Verifica logs en Supabase Dashboard → Edge Functions → [función] → Logs

3. Verifica que Flutter invoca el nombre correcto:
   ```dart
   debugPrint('[DEBUG] Invoking function: admin-returns with params: ...');
   ```

### Si sigue dando 500
1. Verifica que las tablas existen:
   - `fs_returns`
   - `fs_return_items`
   - `fs_shipments`
   - `fs_cancellation_requests`
   - `fs_coupons`
   - `fs_coupon_redemptions`

2. Verifica que la migración 006 se aplicó:
   ```sql
   SELECT column_name FROM information_schema.columns 
   WHERE table_name = 'fs_orders' AND column_name = 'shipping_status';
   ```

3. Verifica logs de la función en Dashboard

## ✅ Checklist Final

- [x] Edge Functions corregidas con queries en 2 pasos
- [x] admin-returns soporta detalle individual
- [x] Navegación back implementada (PopScope)
- [x] flutter analyze = 0 issues
- [x] Sin emojis en código
- [ ] **PENDIENTE**: Deploy de Edge Functions
- [ ] **PENDIENTE**: Aplicar migración SQL
- [ ] **PENDIENTE**: Testing completo del admin

## 📝 Notas Importantes

1. **No hay Foreign Keys**: Las queries en 2 pasos funcionan sin necesidad de crear FKs en la base de datos.

2. **Service Role**: Todas las Edge Functions admin usan `SUPABASE_SERVICE_ROLE_KEY` internamente y verifican `fs_profiles.role = 'admin'`.

3. **RLS**: El admin Flutter NO puede leer tablas directamente. TODO pasa por Edge Functions.

4. **Idempotencia**: Las funciones de approve/refund son idempotentes (no duplican refunds).

5. **Emails**: Se envían automáticamente en:
   - Shipment shipped/delivered
   - Cancellation approved/rejected

## 🎯 Próximos Pasos

1. **Inmediato**: Deployar Edge Functions (ver comandos arriba)
2. **Inmediato**: Aplicar migración SQL (`supabase db push`)
3. Testing exhaustivo de cada pantalla admin
4. Verificar que no hay más errores 404 o 500
5. Verificar que detalle de devolución muestra datos correctamente

---

**Fecha**: 28 Feb 2026  
**Estado**: ✅ Código corregido, pendiente deployment  
**flutter analyze**: 0 issues
