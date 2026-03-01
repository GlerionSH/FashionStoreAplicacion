# FIXES ADMIN FINAL - FashionStore

## Resumen de Cambios

### A) Cancelaciones - Error 500 "relationship in schema cache"
**Estado**: ✅ YA ARREGLADO en sesión anterior
- **Causa**: Joins implícitos sin FK entre `fs_cancellation_requests` y `fs_orders`
- **Solución**: Queries en 2 pasos con merge manual
- **Archivos**: `supabase/functions/admin-cancellations/index.ts`
- **Líneas**: 127-178 (GET list/detail), 188-207 (PATCH)

### B) Navegación Back - GoRouter "nothing to pop"
**Estado**: ✅ ARREGLADO
- **Causa**: `context.pop()` sin verificar `canPop()` en pantallas admin
- **Solución**: Añadido check `canPop()` con fallback a ruta segura
- **Archivos modificados** (6):
  1. `lib/features/admin/presentation/screens/admin_cancellations_screen.dart:125-131`
  2. `lib/features/admin/presentation/screens/admin_users_screen.dart:76-82`
  3. `lib/features/admin/presentation/screens/admin_shipments_screen.dart:182-188`
  4. `lib/features/admin/presentation/screens/admin_return_detail_screen.dart:135-141`
  5. `lib/features/admin/presentation/screens/admin_returns_screen.dart:24-30`
  6. `lib/features/admin/presentation/screens/admin_coupons_screen.dart:149-155`

**Código del fix**:
```dart
// ANTES:
onPressed: () => context.pop(),

// DESPUÉS:
onPressed: () {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/admin-panel'); // o ruta específica
  }
},
```

### C) Contador Devoluciones
**Estado**: ✅ CORRECTO (no requiere cambios)
- **Verificación MCP**: 
  - `fs_returns` tiene 12 registros con `status='refunded'`
  - 0 registros con `status IN ('requested', 'pending')`
- **Conclusión**: El contador devuelve 0 porque no hay devoluciones pendientes (es correcto)
- **Archivo**: `supabase/functions/admin-metrics/index.ts:65-69`

### D) Detalle Devolución
**Estado**: ✅ CORRECTO (no requiere cambios)
- **Backend**: `admin-returns` GET `?return_id=X` implementado correctamente (líneas 51-90)
- **Merge manual**: order + items sin joins implícitos
- **Frontend**: `admin_return_detail_screen.dart` parsea correctamente el shape
- **Verificación MCP**: `fs_return_items` tiene 13 registros

### E) Edge Functions
**Estado**: ✅ TODAS IMPLEMENTADAS
- **Total**: 16 funciones
- **Verificado**: Todas existen en `supabase/functions/`
- **Nombres coinciden**: Flutter invocations ↔ directorios

---

## Esquema DB Verificado (MCP)

### fs_cancellation_requests
```sql
Columnas: id, order_id (uuid), user_id, email, reason, requested_at,
          status (default 'requested'), reviewed_at, reviewed_by,
          admin_notes, refund_amount_cents, stripe_refund_id
FK: ❌ NO HAY FK a fs_orders
```

### fs_returns
```sql
Columnas: id, order_id (uuid), user_id, status (default 'requested'),
          reason, requested_at, reviewed_at, reviewed_by, refunded_at,
          refund_method, refund_total_cents, currency, stripe_refund_id,
          notes, email_sent_*
FK: ❌ NO HAY FK a fs_orders
Status actual: 'refunded' (12 registros)
```

### fs_return_items
```sql
Columnas: id, return_id (uuid), order_item_id (uuid), qty, line_total_cents
Total registros: 13
```

---

## Comandos de Deployment

### 1. Deploy Edge Functions Críticas
```powershell
cd c:\Users\ruben\tienda_flutter\fashion_store

# Funciones admin (ya corregidas)
supabase functions deploy admin-cancellations
supabase functions deploy admin-returns
supabase functions deploy admin-metrics
supabase functions deploy admin-orders
supabase functions deploy admin-shipments
supabase functions deploy admin-coupons
supabase functions deploy admin-users
supabase functions deploy admin-flash
supabase functions deploy admin-products-delete

# Funciones públicas
supabase functions deploy validate-coupon
supabase functions deploy newsletter
supabase functions deploy request-cancel
supabase functions deploy create_checkout
supabase functions deploy create_payment_intent
supabase functions deploy invoice_pdf
supabase functions deploy stripe_webhook
```

### 2. Verificar Variables de Entorno
```powershell
# Verificar que están configuradas en Supabase Dashboard > Edge Functions > Secrets
SUPABASE_URL
SUPABASE_SERVICE_ROLE_KEY
STRIPE_SECRET_KEY
BREVO_API_KEY
EMAIL_FROM
EMAIL_FROM_NAME
STRIPE_WEBHOOK_SECRET
```

### 3. Flutter Build
```powershell
# Verificar que no hay errores
flutter analyze --no-pub

# Resultado esperado: No issues found!
```

---

## Testing Manual

### A) Cancelaciones
1. **Listar**: Admin Panel > Cancelaciones
   - ✅ Debe cargar lista sin error 500
   - ✅ Cada request muestra email del pedido
   
2. **Detalle**: Click en una cancelación
   - ✅ Muestra detalles completos (order, reason, status)
   
3. **Aprobar/Rechazar**: 
   - ✅ PATCH funciona sin error
   - ✅ Actualiza status y procesa refund (si aplica)

4. **Back button**: 
   - ✅ Flecha back vuelve a admin panel
   - ✅ No da error "nothing to pop"

### B) Devoluciones
1. **Contador Dashboard**: 
   - ✅ Muestra 0 (correcto, no hay pending)
   
2. **Listar**: Admin Panel > Devoluciones
   - ✅ Carga lista de returns
   
3. **Detalle**: Click en una devolución
   - ✅ Muestra order info, reason, refund amount
   - ✅ Muestra items si existen
   - ✅ Botones approve/reject si status='requested'

4. **Back button**:
   - ✅ Vuelve a lista sin error

### C) Navegación General
1. **Todas las pantallas admin**:
   - ✅ Cupones: back funciona
   - ✅ Usuarios: back funciona
   - ✅ Envíos: back funciona
   - ✅ Cancelaciones: back funciona
   - ✅ Devoluciones: back funciona
   - ✅ Detalle devolución: back funciona

2. **Botón físico Android**:
   - ✅ PopScope implementado en todas
   - ✅ `enableOnBackInvokedCallback="false"` en AndroidManifest

---

## Logs de Debug

### Backend (Edge Functions)
```typescript
// admin-cancellations
console.log(`[admin-cancellations] Approved ${id} order=${orderId} refund=${stripeRefundId ?? "none"}`);

// admin-returns
console.log("[admin-returns] GET detail", returnId);
console.log("[admin-returns] PATCH", returnId, newStatus);
```

### Frontend (Flutter)
```dart
// Navegación back
debugPrint('[AdminCancellationsScreen] Back navigation');
debugPrint('[AdminReturnsScreen] Back navigation');
// etc.
```

---

## Validación Final

```powershell
# 1. Análisis estático
flutter analyze --no-pub
# Resultado: No issues found! (ran in 7.2s) ✅

# 2. Build Android
flutter build apk --debug

# 3. Testing en dispositivo
flutter run
```

---

## Problemas Resueltos

| Problema | Estado | Solución |
|----------|--------|----------|
| Cancelaciones 500 error | ✅ | Queries en 2 pasos (ya implementado) |
| Back button "nothing to pop" | ✅ | canPop() check + fallback (6 pantallas) |
| Contador devoluciones = 0 | ✅ | Correcto (no hay pending) |
| Detalle devolución vacío | ✅ | Backend OK, frontend OK |
| Edge Functions faltantes | ✅ | Todas implementadas (16/16) |

---

## Próximos Pasos

1. **Deploy**: Ejecutar comandos de deployment arriba
2. **Testing**: Seguir checklist de testing manual
3. **Monitoreo**: Revisar logs en Supabase Dashboard > Edge Functions > Logs
4. **Validación**: Confirmar que no hay errores 500 ni "nothing to pop" en producción

---

## Notas Técnicas

- **Sin FKs**: `fs_cancellation_requests` y `fs_returns` NO tienen FK a `fs_orders`
- **Queries en 2 pasos**: Patrón usado en todas las funciones admin para evitar joins implícitos
- **Merge manual**: Backend fusiona datos en memoria antes de devolver al frontend
- **PopScope**: Implementado en todas las pantallas de detalle para navegación back consistente
- **canPop()**: Previene error "nothing to pop" cuando stack está vacío
