# Deployment and Testing Guide - Purchase & Return Flow Fixes

## Summary of Changes

### Backend (Supabase)
1. **Migration 007**: Creates `fs_returns` table (unified cancel/return), adds coupon `used_count` tracking
2. **admin-shipments**: Now sends emails on ALL status changes (preparing/shipped/delivered/cancelled) with correct totals
3. **request-cancel**: Fixed to allow cancellations for shipped orders, adds `request_type` field
4. **stripe_webhook**: Tracks coupon redemptions idempotently on payment success

### Frontend (Flutter)
1. **Admin shipments screen**: Spanish labels for status dropdown (values stay English for backend)
2. **Localization**: Added `shipmentStatus*` keys for Spanish/English
3. **PDF invoice**: Already implemented and working (no changes needed)

---

## Deployment Commands

### 1. Deploy Database Migration

```bash
# From project root
cd c:\Users\ruben\tienda_flutter\fashion_store

# Apply migration to create fs_returns table and coupon tracking
supabase db push

# OR if using remote project directly
supabase migration up --db-url "postgresql://postgres:[PASSWORD]@[PROJECT_REF].supabase.co:5432/postgres"
```

### 2. Deploy Edge Functions

```bash
# Deploy updated functions (from project root)
supabase functions deploy admin-shipments
supabase functions deploy request-cancel
supabase functions deploy stripe_webhook

# Verify deployment
supabase functions list
```

### 3. Verify Environment Variables

Ensure these secrets are set in Supabase Dashboard → Edge Functions → Secrets:

```
BREVO_API_KEY=your_brevo_api_key
EMAIL_FROM=noreply@yourdomain.com
EMAIL_FROM_NAME=Fashion Store
EMAIL_ADMIN_TO=admin@yourdomain.com
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### 4. Deploy Flutter App

```bash
# Generate localization files
flutter gen-l10n

# Build and deploy
flutter build apk --release
# OR
flutter build appbundle --release
```

---

## Testing Checklist

### A) Admin Shipment Status Emails ✅

**Test**: Admin changes shipment status → client receives email

1. Login as admin
2. Go to Admin Panel → Shipments
3. Edit a shipment, change status to "Preparing"
4. **Expected**: Client receives email "Tu pedido #XXX esta en preparacion" with items + totals
5. Change status to "Shipped" with carrier + tracking
6. **Expected**: Client receives email with carrier, tracking, items, subtotal, discount, total
7. Change status to "Delivered"
8. **Expected**: Client receives email "Tu pedido #XXX ha sido entregado"

**Check**:
- Email shows correct subtotal, discount (if coupon used), and total
- Email includes order items table
- Logs in Supabase Functions show email sent successfully

---

### B) Shipment Status Spanish Labels ✅

**Test**: Admin sees Spanish labels in dropdown

1. Login as admin (with Spanish locale)
2. Go to Admin Panel → Shipments
3. Click edit on any shipment
4. **Expected**: Dropdown shows:
   - Pendiente
   - Preparando
   - Enviado
   - Entregado
   - Cancelado
5. Select "Enviado" and save
6. **Expected**: Backend receives `status: "shipped"` (English value)

---

### C) Client Cancel Request for Shipped Orders ✅

**Test**: Client can request cancellation even if order is shipped

1. Login as client
2. Go to My Orders → select an order with status "shipped"
3. **Expected**: "Solicitar cancelación" button is visible
4. Click button, enter reason, submit
5. **Expected**: 
   - Success message shown
   - Client receives confirmation email
   - Admin receives notification email
   - Entry created in `fs_returns` with `request_type='cancellation'` and `status='requested'`

**Check**:
- Query DB: `SELECT * FROM fs_returns WHERE order_id = 'xxx'`
- Verify `request_type` is 'cancellation' (not 'return')
- Verify RLS allows client to read their own return request

---

### D) Email Totals with Discount Coherence ✅

**Test**: Emails show correct subtotal, discount, and total

1. Create order with coupon code (e.g., 10% discount)
2. Complete payment
3. Admin changes shipment status to "shipped"
4. **Expected**: Email shows:
   ```
   Subtotal: 100.00 EUR
   Descuento: -10.00 EUR
   Total: 90.00 EUR
   ```
5. Verify totals match `fs_orders.subtotal_cents`, `coupon_discount_cents`, `total_cents`

**Check**:
- No negative totals
- Discount line only shows if `coupon_discount_cents > 0`
- Total = Subtotal - Discount

---

### E) PDF Invoice Download (Android) ✅

**Test**: Client can download and open PDF invoice on Android

1. Login as client on Android device
2. Go to My Orders → select a paid order
3. Click "Descargar factura"
4. **Expected**:
   - Loading indicator appears
   - PDF downloads successfully
   - PDF opens in system viewer (Adobe, Google PDF, etc.)
   - Success (or file saved to device storage)

**Fallback Test**:
- If download fails, check error message:
   - "Sesión expirada" → re-login
   - "Factura no encontrada" → order has no invoice_token
   - Generic error → check Edge Function logs

**Check**:
- File saved to `getApplicationDocumentsDirectory()`
- File opens with `open_filex`
- No permission errors on Android 10+

---

### F) Coupon Usage Counter ✅

**Test**: Coupon `used_count` increments on successful payment

1. Create coupon with code "TEST10" (10% discount)
2. Query initial count: `SELECT used_count FROM fs_coupons WHERE code = 'TEST10'`
3. Create order with coupon "TEST10"
4. Complete Stripe payment
5. **Expected**:
   - `fs_coupon_redemptions` has new row with `order_id`, `coupon_id`, `discount_cents`
   - `fs_coupons.used_count` incremented by 1
6. Retry webhook (simulate duplicate event)
7. **Expected**: `used_count` does NOT increment again (idempotent via unique constraint on `order_id`)

**Check**:
```sql
-- Verify redemption recorded
SELECT * FROM fs_coupon_redemptions WHERE order_id = 'xxx';

-- Verify count incremented
SELECT code, used_count FROM fs_coupons WHERE code = 'TEST10';
```

**Logs**:
- Stripe webhook logs: `[webhook] Coupon TEST10 redemption tracked for order xxx`
- No duplicate redemption errors (23505 ignored)

---

## Edge Cases to Test

### 1. Duplicate Cancel Requests
- Client requests cancellation
- Client tries to request again
- **Expected**: Error "Ya existe una solicitud pendiente para este pedido"

### 2. Email Failures (Best-Effort)
- Temporarily set invalid `BREVO_API_KEY`
- Admin changes shipment status
- **Expected**: 
  - Shipment status updates successfully
  - Email error logged in `fs_email_events` with error message
  - Function does NOT return 500

### 3. Coupon Redemption Idempotency
- Manually insert redemption for order X
- Trigger webhook again for same order
- **Expected**: No duplicate insert, `used_count` stays same

### 4. Return vs Cancellation Logic
- Order with shipment status "delivered"
- Client clicks cancel button
- **Expected**: `request_type='return'` (not 'cancellation')

---

## Rollback Plan

If issues arise:

### Rollback Migration
```bash
# Revert to migration 006
supabase migration down
```

### Rollback Edge Functions
```bash
# Redeploy previous versions from git
git checkout HEAD~1 supabase/functions/admin-shipments/index.ts
git checkout HEAD~1 supabase/functions/request-cancel/index.ts
git checkout HEAD~1 supabase/functions/stripe_webhook/index.ts

supabase functions deploy admin-shipments
supabase functions deploy request-cancel
supabase functions deploy stripe_webhook
```

---

## Monitoring

### Check Logs
```bash
# Real-time logs
supabase functions logs admin-shipments --tail
supabase functions logs request-cancel --tail
supabase functions logs stripe_webhook --tail
```

### Check Email Events
```sql
SELECT event_type, recipient_email, error, sent_at
FROM fs_email_events
WHERE sent_at > NOW() - INTERVAL '1 hour'
ORDER BY sent_at DESC;
```

### Check Coupon Redemptions
```sql
SELECT c.code, c.used_count, COUNT(r.id) as actual_redemptions
FROM fs_coupons c
LEFT JOIN fs_coupon_redemptions r ON r.coupon_id = c.id
GROUP BY c.id, c.code, c.used_count
HAVING c.used_count != COUNT(r.id);
-- Should return 0 rows (counts match)
```

---

## Files Changed

### Backend
- `supabase/migrations/007_returns_and_coupon_tracking.sql` ✅ NEW
- `supabase/functions/_shared/email.ts` ✅ NEW
- `supabase/functions/admin-shipments/index.ts` ✅ MODIFIED
- `supabase/functions/request-cancel/index.ts` ✅ MODIFIED
- `supabase/functions/stripe_webhook/index.ts` ✅ MODIFIED

### Frontend
- `lib/features/admin/presentation/screens/admin_shipments_screen.dart` ✅ MODIFIED
- `lib/l10n/app_es.arb` ✅ MODIFIED
- `lib/l10n/app_en.arb` ✅ MODIFIED

### Documentation
- `DEPLOYMENT_AND_TESTING.md` ✅ NEW

---

## Notes

- **Deno lints**: TypeScript errors for `Deno` and module imports are expected in IDE - these resolve at runtime in Supabase Edge Functions environment
- **PDF service**: Already implemented correctly with `path_provider` + `open_filex`, no changes needed
- **Email errors**: Best-effort - logged but don't break main flow
- **Coupon tracking**: Trigger-based, increments atomically on insert to `fs_coupon_redemptions`
- **RLS policies**: Clients can only read/insert their own returns, admins have full access via service_role

---

## Success Criteria

✅ Admin changes shipment status → client receives email with correct totals  
✅ Shipment status dropdown shows Spanish labels  
✅ Client can cancel shipped orders  
✅ Email totals show coherent subtotal/discount/total  
✅ PDF invoice downloads and opens on Android  
✅ Coupon `used_count` increments on payment, idempotent on retry  
