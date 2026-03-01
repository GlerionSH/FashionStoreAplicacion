// supabase/functions/create_payment_intent/index.ts
// Creates a Stripe PaymentIntent for an existing fs_orders row.
//
// Input JSON: { order_id: string, customer_email?: string }
// Returns:    { client_secret, payment_intent_id, ephemeral_key?, customer_id? }
//
// The total is ALWAYS computed server-side from fs_order_items + fs_products.
// Idempotent: if order already has a payment_intent_id or status='paid', reuses/skips.

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

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("authorization") || "";
    if (!authHeader.startsWith("Bearer ")) {
      return jsonResponse({ error: "No autorizado" }, 401);
    }

    let userId: string | null = null;
    let jwtEmail: string | null = null;
    try {
      const token = authHeader.replace("Bearer ", "");
      const payload = JSON.parse(decodeBase64Url(token.split(".")[1]));
      userId = payload.sub || null;
      jwtEmail = payload.email || null;
    } catch (e: any) {
      console.warn(`[create_pi] Could not parse JWT: ${e.message}`);
      return jsonResponse({ error: "No autorizado" }, 401);
    }

    const stripeKey = Deno.env.get("STRIPE_SECRET_KEY");
    if (!stripeKey) throw new Error("STRIPE_SECRET_KEY not configured");

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const stripe = new Stripe(stripeKey, {
      apiVersion: "2023-10-16",
      httpClient: Stripe.createFetchHttpClient(),
    });

    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // ── Parse input ──
    const { order_id, customer_email, coupon_code } = await req.json();

    if (!order_id || typeof order_id !== "string") {
      return jsonResponse({ error: "order_id es obligatorio" }, 400);
    }

    console.log(`[create_pi] order_id=${order_id}, customer_email=${customer_email || "none"}`);

    // ── 1. Fetch order ──
    const { data: order, error: orderErr } = await supabase
      .from("fs_orders")
      .select("id, status, email, user_id, total_cents, stripe_payment_intent_id, coupon_code, coupon_percent, coupon_discount_cents")
      .eq("id", order_id)
      .single();

    if (orderErr || !order) {
      console.error(`[create_pi] Order not found: ${orderErr?.message}`);
      return jsonResponse({ error: "Pedido no encontrado" }, 404);
    }

    console.log(
      `[create_pi] Order found — status=${order.status}, ` +
      `total_cents=${order.total_cents}, ` +
      `existing_pi=${order.stripe_payment_intent_id || "none"}`
    );

    const orderUserId = (order as any).user_id as string | null;
    const orderEmail = (order as any).email as string | null;
    if (orderUserId && userId && orderUserId !== userId) {
      return jsonResponse({ error: "No autorizado" }, 403);
    }
    if (!orderUserId && jwtEmail && orderEmail && orderEmail !== jwtEmail) {
      return jsonResponse({ error: "No autorizado" }, 403);
    }

    // ── 2. Idempotency: already paid ──
    if (order.status === "paid") {
      console.log(`[create_pi] Order ${order_id} already paid, returning early.`);
      return jsonResponse({ error: "Este pedido ya está pagado", already_paid: true }, 400);
    }

    // ── 3. Idempotency: reuse existing PaymentIntent if present ──
    if (order.stripe_payment_intent_id) {
      console.log(`[create_pi] Reusing existing PI: ${order.stripe_payment_intent_id}`);
      try {
        const existingPi = await stripe.paymentIntents.retrieve(
          order.stripe_payment_intent_id
        );

        if (existingPi.status === "succeeded") {
          console.log(`[create_pi] PI already succeeded, finalizing order paid.`);
          const nowIso = new Date().toISOString();
          try {
            const { error: finErr } = await supabase.rpc(
              "fs_finalize_paid_order",
              {
                p_order_id: order_id,
                p_payment_intent_id: existingPi.id,
                p_paid_at: nowIso,
              }
            );
            if (finErr) {
              console.error(`[create_pi] finalize FAILED for ${order_id}: ${finErr.message}`);
              try {
                await supabase
                  .from("fs_orders")
                  .update({ status: "paid", paid_at: nowIso, stripe_payment_intent_id: existingPi.id })
                  .eq("id", order_id);
              } catch (_) {}
            }
          } catch (e: any) {
            console.error(`[create_pi] finalize exception for ${order_id}: ${e.message}`);
            try {
              await supabase
                .from("fs_orders")
                .update({ status: "paid", paid_at: nowIso, stripe_payment_intent_id: existingPi.id })
                .eq("id", order_id);
            } catch (_) {}
          }

          return jsonResponse(
            { error: "Este pedido ya está pagado", already_paid: true },
            400
          );
        }

        // If PI is still usable, return its client_secret
        if (
          existingPi.status === "requires_payment_method" ||
          existingPi.status === "requires_confirmation" ||
          existingPi.status === "requires_action"
        ) {
          console.log(`[create_pi] Reusing PI ${existingPi.id}, status=${existingPi.status}`);
          return jsonResponse({
            client_secret: existingPi.client_secret,
            payment_intent_id: existingPi.id,
          });
        }

        // PI in terminal state (canceled, etc.) — create a new one
        console.log(`[create_pi] Existing PI in state ${existingPi.status}, creating new one.`);
      } catch (e: any) {
        console.warn(`[create_pi] Could not retrieve existing PI: ${e.message}, creating new.`);
      }
    }

    // ── 4. Compute total server-side from fs_order_items + fs_products ──
    const { data: items, error: itemsErr } = await supabase
      .from("fs_order_items")
      .select("product_id, qty, size, price_cents, line_total_cents")
      .eq("order_id", order_id);

    if (itemsErr) {
      console.error(`[create_pi] Error fetching items: ${itemsErr.message}`);
      return jsonResponse({ error: "Error cargando items del pedido" }, 500);
    }

    if (!items || items.length === 0) {
      return jsonResponse({ error: "El pedido no tiene items" }, 400);
    }

    const productIds = [...new Set(items.map((i: any) => i.product_id))];
    const { data: products, error: prodErr } = await supabase
      .from("fs_products")
      .select("id, price_cents, stock, size_stock, is_active")
      .in("id", productIds);

    if (prodErr) {
      console.error(`[create_pi] Error fetching products: ${prodErr.message}`);
      return jsonResponse({ error: "Error cargando productos" }, 500);
    }

    const productMap = new Map<string, any>();
    for (const p of products ?? []) productMap.set(p.id, p);

    const reqTotals = new Map<string, number>();
    const reqSizeTotals = new Map<string, number>();

    let computedTotalCents = 0;
    for (const item of items) {
      const product = productMap.get(item.product_id);
      if (!product) {
        return jsonResponse(
          { error: `Producto no encontrado: ${item.product_id}` },
          409
        );
      }
      if (product.is_active === false) {
        return jsonResponse(
          { error: `Producto no disponible: ${item.product_id}` },
          409
        );
      }

      const qty = Math.max(1, Math.floor(Number(item.qty) || 1));
      const stock = Number(product.stock ?? 0);
      const nextReq = (reqTotals.get(item.product_id) || 0) + qty;
      reqTotals.set(item.product_id, nextReq);
      if (stock < nextReq) {
        return jsonResponse(
          {
            error: `Sin stock suficiente (producto ${item.product_id})`,
            code: "INSUFFICIENT_STOCK",
            product_id: item.product_id,
            requested: nextReq,
            available: stock,
          },
          409
        );
      }

      const size = (item.size || "").toString().trim();
      if (size) {
        const sizeStock = (product.size_stock ?? {}) as Record<string, unknown>;
        const availableSize = Number((sizeStock as any)[size] ?? 0);
        const key = `${item.product_id}|${size}`;
        const nextSizeReq = (reqSizeTotals.get(key) || 0) + qty;
        reqSizeTotals.set(key, nextSizeReq);
        if (availableSize < nextSizeReq) {
          return jsonResponse(
            {
              error: `Sin stock en talla ${size} (producto ${item.product_id})`,
              code: "INSUFFICIENT_SIZE_STOCK",
              product_id: item.product_id,
              size,
              requested: nextSizeReq,
              available: availableSize,
            },
            409
          );
        }
      }

      computedTotalCents += (product.price_cents as number) * qty;
    }

    // Sanity: use at least the stored total if computed is 0
    let finalTotalCents = computedTotalCents > 0
      ? computedTotalCents
      : (order.total_cents || 0);

    if (finalTotalCents <= 0) {
      return jsonResponse({ error: "El total del pedido es 0" }, 400);
    }

    // ── 4b. Validate and apply coupon discount ──
    let appliedCouponCode: string | null = null;
    let appliedCouponPercent: number | null = null;
    let couponDiscountCents = 0;
    let appliedCouponId: string | null = null;

    if (coupon_code && typeof coupon_code === "string") {
      // Skip if order already has a coupon (idempotency)
      if (order.coupon_code) {
        console.log(`[create_pi] Order already has coupon ${order.coupon_code}, using stored discount`);
        couponDiscountCents = order.coupon_discount_cents || 0;
        finalTotalCents = Math.max(50, finalTotalCents - couponDiscountCents);
        appliedCouponCode = order.coupon_code;
        appliedCouponPercent = order.coupon_percent;
      } else {
        const upperCode = coupon_code.trim().toUpperCase();
        const now = new Date();

        const { data: coupon } = await supabase
          .from("fs_coupons")
          .select("*")
          .eq("code", upperCode)
          .eq("active", true)
          .maybeSingle();

        if (coupon) {
          // Date check
          const dateOk = (!coupon.starts_at || new Date(coupon.starts_at) <= now)
            && (!coupon.ends_at || new Date(coupon.ends_at) > now);

          // Global limit check
          let globalOk = true;
          if (coupon.max_redemptions !== null) {
            const { count } = await supabase
              .from("fs_coupon_redemptions")
              .select("id", { count: "exact", head: true })
              .eq("coupon_id", coupon.id);
            if ((count ?? 0) >= coupon.max_redemptions) globalOk = false;
          }

          // Per-user limit check
          let perUserOk = true;
          if (globalOk && coupon.max_redemptions_per_user !== null && (userId || jwtEmail)) {
            let q = supabase
              .from("fs_coupon_redemptions")
              .select("id", { count: "exact", head: true })
              .eq("coupon_id", coupon.id);
            if (userId) q = q.eq("user_id", userId);
            else if (jwtEmail) q = q.eq("email", jwtEmail);
            const { count: perCount } = await q;
            if ((perCount ?? 0) >= coupon.max_redemptions_per_user) perUserOk = false;
          }

          if (dateOk && globalOk && perUserOk) {
            couponDiscountCents = Math.floor(finalTotalCents * coupon.percent_off / 100);
            finalTotalCents = Math.max(50, finalTotalCents - couponDiscountCents); // min 0.50€
            appliedCouponCode = upperCode;
            appliedCouponPercent = coupon.percent_off;
            appliedCouponId = coupon.id;
            console.log(`[create_pi] Coupon ${upperCode} applied: -${couponDiscountCents}c, new total=${finalTotalCents}c`);
          } else {
            console.warn(`[create_pi] Coupon ${upperCode} invalid (dateOk=${dateOk} globalOk=${globalOk} perUserOk=${perUserOk})`);
          }
        }
      }
    }

    console.log(
      `[create_pi] Computed total: ${computedTotalCents}c, ` +
      `coupon_discount: ${couponDiscountCents}c, ` +
      `stored total: ${order.total_cents}c, ` +
      `using: ${finalTotalCents}c`
    );

    // ── 5. Create Stripe PaymentIntent ──
    // Update order with coupon info before creating PI (for display purposes)
    if (appliedCouponCode) {
      await supabase
        .from("fs_orders")
        .update({
          coupon_code: appliedCouponCode,
          coupon_percent: appliedCouponPercent,
          coupon_discount_cents: couponDiscountCents,
          total_cents: finalTotalCents,
        })
        .eq("id", order_id);
    }
    // ── 5. Create Stripe PaymentIntent ──
    const piParams: Stripe.PaymentIntentCreateParams = {
      amount: finalTotalCents,
      currency: "eur",
      metadata: { order_id },
      automatic_payment_methods: { enabled: true },
    };

    // Attach email for receipt
    const email = customer_email || order.email;
    if (email) {
      piParams.receipt_email = email;
    }

    const paymentIntent = await stripe.paymentIntents.create(piParams);

    console.log(
      `[create_pi] Created PI ${paymentIntent.id}, ` +
      `amount=${paymentIntent.amount}, ` +
      `status=${paymentIntent.status}`
    );

    // ── 6. Store payment_intent_id on the order ──
    const { error: updateErr } = await supabase
      .from("fs_orders")
      .update({ stripe_payment_intent_id: paymentIntent.id })
      .eq("id", order_id);

    if (updateErr) {
      console.error(`[create_pi] Error saving PI id to order: ${updateErr.message}`);
      // Non-fatal: the PI is created, webhook will still work via metadata
    } else {
      console.log(`[create_pi] Saved stripe_payment_intent_id=${paymentIntent.id} on order ${order_id}`);
    }

    // ── 7a. Record coupon redemption (pending — order not paid yet) ──
    if (appliedCouponId && appliedCouponCode && !order.coupon_code) {
      // Will be formally recorded; we store it here as a pre-redemption marker
      // The actual check for max_redemptions happens at validate-coupon time
      // We do NOT count this as a redemption until the order is paid (webhook)
      // But we store order-level coupon data (done above)
      console.log(`[create_pi] Coupon pre-applied: ${appliedCouponCode}`);
    }

    // ── 7b. Return client_secret ──
    return jsonResponse({
      client_secret: paymentIntent.client_secret,
      payment_intent_id: paymentIntent.id,
      coupon_code: appliedCouponCode,
      coupon_discount_cents: couponDiscountCents,
      final_total_cents: finalTotalCents,
    });
  } catch (err: any) {
    console.error("[create_pi] Unhandled error:", err);
    return new Response(
      JSON.stringify({ error: err.message || "Error interno" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
