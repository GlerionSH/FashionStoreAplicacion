// supabase/functions/create_checkout/index.ts
// Creates a Stripe Checkout Session after validating prices against fs_products.
// Input: { items: [{product_id, qty, size?}], email }
// Returns: { url, session_id, order_id }

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import Stripe from "https://esm.sh/stripe@14.14.0?target=deno";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function decodeBase64Url(input: string) {
  const normalized = input.replace(/-/g, "+").replace(/_/g, "/");
  const pad = normalized.length % 4;
  const padded = pad ? normalized + "=".repeat(4 - pad) : normalized;
  return atob(padded);
}

serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const stripeKey = Deno.env.get("STRIPE_SECRET_KEY");
    if (!stripeKey) throw new Error("STRIPE_SECRET_KEY not configured");

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const publicSiteUrl =
      Deno.env.get("PUBLIC_SITE_URL") || "https://localhost";

    const stripe = new Stripe(stripeKey, {
      apiVersion: "2023-10-16",
      httpClient: Stripe.createFetchHttpClient(),
    });

    // Service-role client for writing orders
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // Extract user_id from JWT (Authorization: Bearer <token>)
    let userId: string | null = null;
    let jwtEmail: string | null = null;
    const authHeader = req.headers.get("authorization") || "";
    if (authHeader.startsWith("Bearer ")) {
      try {
        const token = authHeader.replace("Bearer ", "");
        const payload = JSON.parse(decodeBase64Url(token.split(".")[1]));
        userId = payload.sub || null;
        jwtEmail = payload.email || null;
        console.log(`[create_checkout] JWT user_id=${userId}, email=${jwtEmail}`);
      } catch (e: any) {
        console.warn("[create_checkout] Could not parse JWT:", e.message);
        return new Response(
          JSON.stringify({ error: "No autorizado" }),
          { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
    }

    // Parse input
    const { items, email: bodyEmail } = await req.json();
    const email = jwtEmail || bodyEmail || "";

    if (!items || !Array.isArray(items) || items.length === 0) {
      return new Response(
        JSON.stringify({ error: "items es obligatorio y no puede estar vacío" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!email || typeof email !== "string") {
      return new Response(
        JSON.stringify({ error: "email es obligatorio" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── 1. Validate prices against fs_products ──
    const productIds = [...new Set(items.map((i: any) => i.product_id))];
    const { data: products, error: prodErr } = await supabase
      .from("fs_products")
      .select("id, name, name_es, price_cents, stock, size_stock, is_active, images")
      .in("id", productIds);

    if (prodErr) throw new Error(`Error cargando productos: ${prodErr.message}`);

    const productMap = new Map<string, any>();
    for (const p of products ?? []) {
      productMap.set(p.id, p);
    }

    // Validate each item
    let subtotalCents = 0;
    const validatedItems: Array<{
      product_id: string;
      name: string;
      qty: number;
      size: string | null;
      unit_price_cents: number;
      line_total_cents: number;
      image_url: string | null;
    }> = [];

    const reqTotals = new Map<string, number>();
    const reqSizeTotals = new Map<string, number>();

    for (const item of items) {
      const product = productMap.get(item.product_id);
      if (!product) {
        return new Response(
          JSON.stringify({ error: `Producto no encontrado: ${item.product_id}` }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      if (!product.is_active) {
        return new Response(
          JSON.stringify({ error: `Producto no disponible: ${product.name}` }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const qty = Math.max(1, Math.floor(Number(item.qty) || 1));

      const stock = Number(product.stock ?? 0);
      const nextReq = (reqTotals.get(product.id) || 0) + qty;
      reqTotals.set(product.id, nextReq);
      if (stock < nextReq) {
        return new Response(
          JSON.stringify({
            error: `Sin stock suficiente para ${product.name_es || product.name}`,
            code: "INSUFFICIENT_STOCK",
            product_id: product.id,
            requested: nextReq,
            available: stock,
          }),
          { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const reqSize = (item.size || "").toString().trim();
      if (reqSize) {
        const sizeStock = (product.size_stock ?? {}) as Record<string, unknown>;
        const availableSize = Number((sizeStock as any)[reqSize] ?? 0);
        const key = `${product.id}|${reqSize}`;
        const nextSizeReq = (reqSizeTotals.get(key) || 0) + qty;
        reqSizeTotals.set(key, nextSizeReq);
        if (availableSize < nextSizeReq) {
          return new Response(
            JSON.stringify({
              error: `Sin stock en talla ${reqSize} para ${product.name_es || product.name}`,
              code: "INSUFFICIENT_SIZE_STOCK",
              product_id: product.id,
              size: reqSize,
              requested: nextSizeReq,
              available: availableSize,
            }),
            { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }
      }

      const unitPrice = product.price_cents as number;
      const lineTotal = unitPrice * qty;
      subtotalCents += lineTotal;

      const displayName = product.name_es || product.name;
      const imageUrl =
        Array.isArray(product.images) && product.images.length > 0
          ? product.images[0]
          : null;

      validatedItems.push({
        product_id: product.id,
        name: displayName,
        qty,
        size: reqSize || null,
        unit_price_cents: unitPrice,
        line_total_cents: lineTotal,
        image_url: imageUrl,
      });
    }

    const discountCents = 0; // Future: apply coupon logic here
    const totalCents = subtotalCents - discountCents;

    // ── 2. Create fs_orders ──
    const { data: orderData, error: orderErr } = await supabase
      .from("fs_orders")
      .insert({
        email,
        status: "pending",
        subtotal_cents: subtotalCents,
        discount_cents: discountCents,
        total_cents: totalCents,
        ...(userId ? { user_id: userId } : {}),
      })
      .select("id")
      .single();

    if (orderErr) throw new Error(`Error creando pedido: ${orderErr.message}`);
    const orderId = orderData.id as string;

    // ── 3. Create fs_order_items ──
    const orderItems = validatedItems.map((vi) => ({
      order_id: orderId,
      product_id: vi.product_id,
      name: vi.name,
      qty: vi.qty,
      size: vi.size,
      price_cents: vi.unit_price_cents,
      line_total_cents: vi.line_total_cents,
    }));

    const { error: itemsErr } = await supabase
      .from("fs_order_items")
      .insert(orderItems);

    if (itemsErr)
      throw new Error(`Error creando items del pedido: ${itemsErr.message}`);

    // ── 4. Create Stripe Checkout Session ──
    const lineItems = validatedItems.map((vi) => ({
      price_data: {
        currency: "eur",
        unit_amount: vi.unit_price_cents,
        product_data: {
          name: vi.name + (vi.size ? ` (${vi.size})` : ""),
          ...(vi.image_url ? { images: [vi.image_url] } : {}),
        },
      },
      quantity: vi.qty,
    }));

    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      payment_method_types: ["card"],
      customer_email: email,
      line_items: lineItems,
      metadata: { order_id: orderId },
      success_url: `${publicSiteUrl}/checkout/success?session_id={CHECKOUT_SESSION_ID}&order_id=${orderId}`,
      cancel_url: `${publicSiteUrl}/carrito`,
    });

    // ── 5. Store stripe_session_id on the order ──
    await supabase
      .from("fs_orders")
      .update({ stripe_session_id: session.id })
      .eq("id", orderId);

    return new Response(
      JSON.stringify({
        url: session.url,
        session_id: session.id,
        order_id: orderId,
        subtotal_cents: subtotalCents,
        discount_cents: discountCents,
        total_cents: totalCents,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err: any) {
    console.error("create_checkout error:", err);
    return new Response(
      JSON.stringify({ error: err.message || "Error interno" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
