# Deployment de Edge Functions

## Funciones requeridas para el Admin

Para que el admin de Flutter funcione correctamente, debes deployar las siguientes Edge Functions:

```bash
# Navega al directorio del proyecto
cd c:\Users\ruben\tienda_flutter\fashion_store

# Deploy de funciones admin
supabase functions deploy admin-metrics
supabase functions deploy admin-orders
supabase functions deploy admin-returns
supabase functions deploy admin-coupons
supabase functions deploy admin-users
supabase functions deploy admin-shipments
supabase functions deploy admin-cancellations
supabase functions deploy admin-flash
supabase functions deploy admin-products-delete

# Deploy de funciones cliente
supabase functions deploy validate-coupon
supabase functions deploy newsletter
supabase functions deploy request-cancel
supabase functions deploy create_checkout
supabase functions deploy create_payment_intent
supabase functions deploy invoice_pdf
supabase functions deploy stripe_webhook
```

## Deploy todas las funciones de una vez

```bash
supabase functions deploy admin-metrics && ^
supabase functions deploy admin-orders && ^
supabase functions deploy admin-returns && ^
supabase functions deploy admin-coupons && ^
supabase functions deploy admin-users && ^
supabase functions deploy admin-shipments && ^
supabase functions deploy admin-cancellations && ^
supabase functions deploy admin-flash && ^
supabase functions deploy admin-products-delete && ^
supabase functions deploy validate-coupon && ^
supabase functions deploy newsletter && ^
supabase functions deploy request-cancel && ^
supabase functions deploy create_checkout && ^
supabase functions deploy create_payment_intent && ^
supabase functions deploy invoice_pdf && ^
supabase functions deploy stripe_webhook
```

## Verificar funciones deployadas

1. Ve a tu proyecto en Supabase Dashboard
2. Navega a Edge Functions
3. Verifica que todas las funciones aparezcan en la lista
4. Prueba cada función desde el dashboard

## Aplicar migraciones

```bash
# Aplicar migración de shipping_status
supabase db push
```

## Variables de entorno requeridas

Asegúrate de tener configuradas en Supabase Dashboard > Project Settings > Edge Functions:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `STRIPE_SECRET_KEY`
- `BREVO_API_KEY`
- `EMAIL_FROM`
- `STRIPE_WEBHOOK_SECRET`
