# Professional Invoice PDF & Email Templates - Deployment Guide

## Files Changed/Added

### NEW FILES:
1. `supabase/functions/_shared/branding.ts` - Branding config helper
2. `supabase/functions/_shared/email_templates.ts` - Responsive email templates

### MODIFIED FILES:
3. `supabase/functions/invoice_pdf/index.ts` - Professional PDF with banner
4. `supabase/functions/stripe_webhook/index.ts` - Payment confirmation email
5. `supabase/functions/request-cancel/index.ts` - Cancel/return emails
6. `supabase/functions/admin-returns/index.ts` - Admin decision emails

---

## Summary of Changes

### Invoice PDF (`invoice_pdf/index.ts`)
- ✅ Full-width banner image at top (fetched from branding helper)
- ✅ Professional layout with clear sections
- ✅ Customer info block (email, name if available)
- ✅ Improved table with proper columns
- ✅ Totals section with subtotal, discount, total
- ✅ Footer with store name + support email
- ✅ Fallback to text header if image fails
- ✅ Better spacing and typography for A4

### Email Templates (all functions)
- ✅ Responsive table-based layout (600px max-width, 100% width)
- ✅ Banner image header (scales on mobile)
- ✅ Inline styles only (Gmail/Outlook compatible)
- ✅ Large tap-friendly CTA buttons
- ✅ Readable font sizes (16px+ body, 26px title)
- ✅ Plain text fallback for all emails
- ✅ Shared template function for consistency

---

## Deployment Commands

```bash
cd c:\Users\ruben\tienda_flutter\fashion_store

# Deploy all updated Edge Functions
supabase functions deploy invoice_pdf
supabase functions deploy stripe_webhook --no-verify-jwt
supabase functions deploy request-cancel
supabase functions deploy admin-returns

# Verify deployment
supabase functions list
```

---

## Testing Steps

### 1. Test Invoice PDF with Banner

**Trigger:**
```bash
# From app: Go to "Mis pedidos" → Select paid order → "Descargar factura"
# Or via URL (replace ORDER_ID and TOKEN):
https://qtetgglxmvivfbdgylbz.supabase.co/functions/v1/invoice_pdf?order_id=ORDER_ID&token=TOKEN
```

**Expected:**
- PDF opens with full-width banner image at top
- Professional layout with clear sections
- All order details visible
- Proper totals with discount if applicable
- Footer with store name + support email

**Verify:**
- Banner image loads (or fallback text header appears)
- No layout issues or overlapping text
- All items displayed correctly
- Discount shows coupon code if applicable

---

### 2. Test Payment Confirmation Email (Mobile)

**Trigger:**
```bash
# Complete a test purchase via Stripe
# Or resend webhook:
stripe trigger payment_intent.succeeded
```

**Check Gmail Mobile App:**
- ✅ Banner image displays at top (full width)
- ✅ "PEDIDO CONFIRMADO" title is large and readable
- ✅ Order items table displays correctly
- ✅ "DESCARGAR FACTURA" button is large and tappable
- ✅ Footer with store name + email visible
- ✅ No weird spacing or layout breaks

**Check Desktop:**
- ✅ Email centered with max-width 600px
- ✅ White background with gray outer area
- ✅ All elements properly aligned

---

### 3. Test Cancel/Return Request Email

**Trigger:**
```bash
# From app: Go to order → "Solicitar cancelación" or "Solicitar devolución"
```

**Check Gmail Mobile:**
- ✅ Banner image at top
- ✅ Clear confirmation message
- ✅ Order details visible
- ✅ Reason displayed if provided
- ✅ Footer present

**Check Logs:**
```bash
supabase functions logs request-cancel --tail
```

Expected output:
```
[request-cancel] Sending cancelacion email to client: user@example.com
[email] Sent to user@example.com: Solicitud de cancelacion recibida
```

---

### 4. Test Admin Return Decision Emails

**Trigger:**
```bash
# Admin panel → Returns → Approve or Reject a return
```

**Check Client Email (Gmail Mobile):**
- ✅ Banner image
- ✅ Clear approval/rejection message
- ✅ Refund amount (if approved)
- ✅ Items table
- ✅ Admin notes (if provided)

**Check Admin Email:**
- ✅ Banner image
- ✅ Summary of action taken
- ✅ Order details
- ✅ Stripe refund ID (if applicable)

---

## Verification Queries

### Check Email Events
```sql
SELECT 
  event_type,
  recipient_email,
  error,
  sent_at
FROM fs_email_events
ORDER BY sent_at DESC
LIMIT 10;
```

### Check Branding Settings
```sql
SELECT brand_logo_url FROM fs_site_settings LIMIT 1;
```

If NULL or empty, update:
```sql
UPDATE fs_site_settings 
SET brand_logo_url = 'https://qtetgglxmvivfbdgylbz.supabase.co/storage/v1/object/public/logos/imagen-fondo.png';
```

---

## Troubleshooting

### Banner Image Not Loading in PDF
- Check logs: `supabase functions logs invoice_pdf --tail`
- Verify URL is accessible: Open in browser
- Fallback text header should appear if image fails

### Banner Image Not Loading in Email
- Check email HTML source (View → Show Original in Gmail)
- Verify `<img src="...">` tag present
- Some email clients block images by default - user must click "Display images"

### Email Layout Broken on Mobile
- Verify inline styles are present (no external CSS)
- Check table structure (must use `role="presentation"`)
- Test in Gmail app (most restrictive client)

### Plain Text Version Not Showing
- Check Brevo API payload includes `textContent`
- Verify `renderEmailBase` returns both `html` and `text`

---

## Notes

- All TypeScript lint errors for Deno modules are **expected** and resolve at runtime
- Banner image is fetched fresh each time (no caching) - consider adding timeout
- Email templates use table-based layout for maximum compatibility
- All emails log to `fs_email_events` for audit trail
- PDF generation uses pdf-lib (no HTML-to-PDF conversion)

