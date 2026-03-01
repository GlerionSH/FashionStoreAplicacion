// supabase/functions/stripe_webhook/index.ts
// Handles Stripe webhook events:
//   - payment_intent.succeeded  (PaymentSheet flow)
//   - checkout.session.completed (legacy Checkout flow)
//   - payment_intent.payment_failed (log only)
//
// Key change:
// - Use await stripe.webhooks.constructEventAsync(...) to avoid:
//   "SubtleCryptoProvider cannot be used in a synchronous context..."

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import Stripe from "https://esm.sh/stripe@14.14.0?target=deno";

function json(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
function ok(body: Record<string, unknown> = { received: true }) {
  return json(200, body);
}
function fail(
  status: number,
  message: string,
  extra: Record<string, unknown> = {},
) {
  return json(status, { received: true, error: message, ...extra });
}

serve(async (req: Request) => {
  // ── 0) ENV ──
  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY") || "";
  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET") || "";
  const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

  const brevoApiKey = Deno.env.get("BREVO_API_KEY") || "";
  const emailFrom = Deno.env.get("EMAIL_FROM") || "";
  const emailFromName = Deno.env.get("EMAIL_FROM_NAME") || "Fashion Store";
  const emailAdminTo = Deno.env.get("EMAIL_ADMIN_TO") || "";

  console.log(
    `[webhook] ENV STRIPE_KEY=${stripeKey ? "ok" : "MISSING"} ` +
      `WEBHOOK_SECRET=${webhookSecret ? "ok" : "MISSING"} ` +
      `SUPA_URL=${supabaseUrl ? "ok" : "MISSING"} ` +
      `SRK=${serviceRoleKey ? "ok" : "MISSING"} ` +
      `BREVO=${brevoApiKey ? "ok" : "MISSING"} ` +
      `EMAIL_FROM=${emailFrom || "MISSING"} ` +
      `EMAIL_ADMIN=${emailAdminTo || "none"}`,
  );

  if (!stripeKey || !webhookSecret || !supabaseUrl || !serviceRoleKey) {
    console.error("[webhook] FATAL: missing required env vars");
    return fail(500, "Server misconfigured (missing env vars)");
  }

  const stripe = new Stripe(stripeKey, {
    apiVersion: "2023-10-16",
    httpClient: Stripe.createFetchHttpClient(),
  });

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  // ── 1) Verify signature with RAW body ──
  // IMPORTANT: RAW body (req.text()) — do NOT JSON.parse before verifying.
  const rawBody = await req.text();
  const sig = req.headers.get("stripe-signature");
  if (!sig) {
    console.error("[webhook] Missing stripe-signature header");
    return fail(400, "Missing stripe-signature");
  }

  let event: Stripe.Event;
  try {
    // ✅ FIX: async construct for Deno
    event = await stripe.webhooks.constructEventAsync(
      rawBody,
      sig,
      webhookSecret,
    );
  } catch (err: any) {
    console.error("[webhook] Signature FAILED:", err.message);
    return new Response(`Signature error: ${err.message}`, { status: 400 });
  }

  console.log(`[webhook] ✓ sig OK — type=${event.type}, id=${event.id}`);

  const HANDLED = new Set([
    "payment_intent.succeeded",
    "checkout.session.completed",
    "payment_intent.payment_failed",
  ]);

  if (!HANDLED.has(event.type)) {
    console.log(`[webhook] Ignoring ${event.type}`);
    return ok();
  }

  const nowIso = new Date().toISOString();

  // ── payment_intent.payment_failed (log + persist if possible) ──
  if (event.type === "payment_intent.payment_failed") {
    const pi = event.data.object as Stripe.PaymentIntent;
    const orderId = pi.metadata?.order_id || null;
    const msg = pi.last_payment_error?.message || "unknown error";

    console.error(
      `[webhook] ❌ payment_intent.payment_failed — order=${
        orderId || "none"
      }, pi=${pi.id}, error=${msg}`,
    );

    if (orderId) {
      const { error: updErr } = await supabase
        .from("fs_orders")
        .update({
          payment_last_error: msg,
          last_webhook_event_id: event.id,
          last_webhook_type: event.type,
          last_webhook_received_at: nowIso,
          stripe_payment_intent_id: pi.id,
        })
        .eq("id", orderId);

      if (updErr) {
        console.error(
          `[webhook] payment_failed persist error: ${updErr.message}`,
        );
      }
    }

    return ok();
  }

  try {
    // ── 2) Extract lookup keys ──
    let metaOrderId: string | null = null;
    let paymentIntentId: string | null = null;
    let sessionId: string | null = null;
    let customerEmail: string | null = null;

    if (event.type === "payment_intent.succeeded") {
      const pi = event.data.object as Stripe.PaymentIntent;
      metaOrderId = pi.metadata?.order_id || null;
      paymentIntentId = pi.id;
      customerEmail = pi.receipt_email || null;

      console.log(
        `[webhook] payment_intent.succeeded pi=${pi.id} metadata.order_id=${
          metaOrderId || "none"
        } amount=${pi.amount}`,
      );
    } else {
      const session = event.data.object as Stripe.Checkout.Session;
      metaOrderId = session.metadata?.order_id || null;
      sessionId = session.id;
      paymentIntentId = typeof session.payment_intent === "string"
        ? session.payment_intent
        : null;
      customerEmail = session.customer_details?.email || null;

      console.log(
        `[webhook] checkout.session.completed session=${session.id} metadata.order_id=${
          metaOrderId || "none"
        } pi=${paymentIntentId || "none"}`,
      );
    }

    // ── 3) Resolve order (3-tier fallback) ──
    const selectCols =
      "id, status, email, stripe_session_id, stripe_payment_intent_id, invoice_token, email_sent_at";

    let order: any = null;

    // 3a) by metadata.order_id
    if (metaOrderId) {
      const { data, error } = await supabase
        .from("fs_orders")
        .select(selectCols)
        .eq("id", metaOrderId)
        .maybeSingle();
      if (error) {
        console.error(
          `[webhook] DB error by id=${metaOrderId}: ${error.message}`,
        );
      }
      if (data) {
        order = data;
        console.log(
          `[webhook] Found order by metadata.order_id=${metaOrderId}, status=${order.status}`,
        );
      } else {
        console.warn(
          `[webhook] No fs_orders row for metadata.order_id=${metaOrderId}`,
        );
      }
    }

    // 3b) by stripe_payment_intent_id
    if (!order && paymentIntentId) {
      console.log(
        `[webhook] Fallback lookup by stripe_payment_intent_id=${paymentIntentId}`,
      );
      const { data, error } = await supabase
        .from("fs_orders")
        .select(selectCols)
        .eq("stripe_payment_intent_id", paymentIntentId)
        .maybeSingle();
      if (error) {
        console.error(
          `[webhook] DB error by pi_id=${paymentIntentId}: ${error.message}`,
        );
      }
      if (data) {
        order = data;
        console.log(
          `[webhook] Found order by pi_id=${paymentIntentId}, id=${order.id}, status=${order.status}`,
        );
      }
    }

    // 3c) by stripe_session_id (legacy)
    if (!order && sessionId) {
      console.log(
        `[webhook] Fallback lookup by stripe_session_id=${sessionId}`,
      );
      const { data, error } = await supabase
        .from("fs_orders")
        .select(selectCols)
        .eq("stripe_session_id", sessionId)
        .maybeSingle();
      if (error) {
        console.error(
          `[webhook] DB error by session_id=${sessionId}: ${error.message}`,
        );
      }
      if (data) {
        order = data;
        console.log(
          `[webhook] Found order by session_id=${sessionId}, id=${order.id}, status=${order.status}`,
        );
      }
    }

    // If not found: return 500 so Stripe retries (prevents “pending forever” if there was a transient mismatch).
    if (!order) {
      console.error(
        `[webhook] ❌ Order not found (will RETRY). metaOrderId=${
          metaOrderId || "none"
        } pi=${paymentIntentId || "none"} session=${sessionId || "none"}`,
      );
      return fail(500, "order_not_found_retry");
    }

    const orderId: string = order.id;

    // ── 4) Persist webhook trace (ALWAYS) ──
    {
      const tracePayload: Record<string, unknown> = {
        last_webhook_event_id: event.id,
        last_webhook_type: event.type,
        last_webhook_received_at: nowIso,
      };
      if (paymentIntentId) tracePayload.stripe_payment_intent_id = paymentIntentId;
      if (sessionId) tracePayload.stripe_session_id = sessionId;

      const { error: traceErr } = await supabase
        .from("fs_orders")
        .update(tracePayload)
        .eq("id", orderId);

      if (traceErr) {
        console.error(
          `[webhook] trace update FAILED for ${orderId}: ${traceErr.message}`,
        );
      } else {
        console.log(`[webhook] trace persisted for ${orderId}`);
      }
    }

    // ── 5) Finalize paid (idempotent) ──
    // If already paid => DO NOT touch stock again.
    // If not paid => call RPC that marks status='paid', paid_at NOT NULL, decrements stock atomically.
    if (order.status !== "paid") {
      const { data: finData, error: finErr } = await supabase.rpc(
        "fs_finalize_paid_order",
        {
          p_order_id: orderId,
          p_payment_intent_id: paymentIntentId,
          p_paid_at: nowIso,
        },
      );

      if (finErr) {
        console.error(
          `[webhook] finalize FAILED for ${orderId}: ${finErr.message}`,
        );

        await supabase
          .from("fs_orders")
          .update({ payment_last_error: finErr.message })
          .eq("id", orderId);

        // Return 500 so Stripe retries (do NOT swallow finalize failures)
        return fail(500, "finalize_failed_retry", { order_id: orderId });
      }

      console.log(
        `[webhook] ✅ finalize OK for ${orderId}: ${JSON.stringify(finData)}`,
      );
    } else {
      console.log(`[webhook] Order ${orderId} already paid — skip finalize.`);
    }

    // ── 6) Email (non-fatal) ──
    const { data: emailOrder, error: emailOrderErr } = await supabase
      .from("fs_orders")
      .select("email, total_cents, invoice_token, email_sent_at")
      .eq("id", orderId)
      .maybeSingle();

    if (emailOrderErr) {
      console.error(`[webhook] emailOrder fetch error: ${emailOrderErr.message}`);
    }

    const recipientEmail = emailOrder?.email || order.email || customerEmail ||
      null;

    if (emailOrder?.email_sent_at) {
      console.log(`[webhook] Email already sent for ${orderId} — skip.`);
    } else if (!brevoApiKey || !emailFrom) {
      console.warn(
        `[webhook] Skipping email — BREVO=${
          brevoApiKey ? "ok" : "MISSING"
        }, FROM=${emailFrom || "MISSING"}`,
      );
    } else if (!recipientEmail) {
      console.warn(`[webhook] Skipping email — no recipient`);
    } else {
      try {
        const { data: emailItems } = await supabase
          .from("fs_order_items")
          .select("name, qty, size, price_cents, line_total_cents")
          .eq("order_id", orderId);

        const rows = (emailItems || [])
          .map(
            (i: any) =>
              `<tr>` +
              `<td style="padding:8px;border-bottom:1px solid #eee">${
                i.name || "Artículo"
              }${i.size ? ` (${i.size})` : ""}</td>` +
              `<td style="padding:8px;border-bottom:1px solid #eee;text-align:center">${i.qty}</td>` +
              `<td style="padding:8px;border-bottom:1px solid #eee;text-align:right">${(
                (i.price_cents || 0) / 100
              ).toFixed(2)} €</td>` +
              `<td style="padding:8px;border-bottom:1px solid #eee;text-align:right">${(
                (i.line_total_cents || 0) / 100
              ).toFixed(2)} €</td>` +
              `</tr>`,
          )
          .join("");

        const totalEur = (((emailOrder?.total_cents || 0) as number) / 100)
          .toFixed(2);
        const shortId = orderId.substring(0, 8);
        const token = emailOrder?.invoice_token || null;
        const baseUrl = supabaseUrl.replace(/\/+$/, "");

        const invoiceUrl = token
          ? `${baseUrl}/functions/v1/invoice_pdf?order_id=${
            encodeURIComponent(orderId)
          }&token=${encodeURIComponent(token)}`
          : "";

        const html = `
          <div style="font-family:Helvetica,Arial,sans-serif;max-width:600px;margin:0 auto;color:#111">
            <h2 style="font-weight:300;letter-spacing:2px;text-align:center;margin-bottom:32px">FASHION STORE</h2>
            <p>Hola,</p>
            <p>Tu pedido <strong>#${shortId}</strong> ha sido confirmado.</p>
            <table style="width:100%;border-collapse:collapse;margin:24px 0">
              <thead>
                <tr style="background:#f5f5f5">
                  <th style="padding:8px;text-align:left;font-weight:500;font-size:12px">ARTÍCULO</th>
                  <th style="padding:8px;text-align:center;font-weight:500;font-size:12px">CANT</th>
                  <th style="padding:8px;text-align:right;font-weight:500;font-size:12px">PRECIO</th>
                  <th style="padding:8px;text-align:right;font-weight:500;font-size:12px">TOTAL</th>
                </tr>
              </thead>
              <tbody>${rows}</tbody>
            </table>
            <p style="text-align:right;font-size:16px;font-weight:500">Total: ${totalEur} €</p>
            ${
          invoiceUrl
            ? `<p style="margin-top:18px"><a href="${invoiceUrl}">Descargar factura (PDF)</a></p>`
            : ``
        }
            <p style="margin-top:32px;font-size:12px;color:#999">Gracias por tu compra.</p>
          </div>`;

        const toList: Array<{ email: string }> = [{ email: recipientEmail }];
        if (emailAdminTo) toList.push({ email: emailAdminTo });

        console.log(`[webhook] Sending email to ${recipientEmail}...`);

        const emailRes = await fetch("https://api.brevo.com/v3/smtp/email", {
          method: "POST",
          headers: { "api-key": brevoApiKey, "Content-Type": "application/json" },
          body: JSON.stringify({
            sender: { name: emailFromName, email: emailFrom },
            to: toList,
            subject: `Pedido confirmado #${shortId}`,
            htmlContent: html,
          }),
        });

        if (emailRes.ok) {
          console.log(`[webhook] ✅ Email sent, status=${emailRes.status}`);
          await supabase
            .from("fs_orders")
            .update({ email_sent_at: nowIso, email_last_error: null })
            .eq("id", orderId);
        } else {
          const errBody = await emailRes.text();
          console.error(
            `[webhook] ❌ Email FAILED status=${emailRes.status}, body=${errBody}`,
          );
          await supabase
            .from("fs_orders")
            .update({ email_last_error: errBody })
            .eq("id", orderId);
        }
      } catch (emailErr: any) {
        console.error(
          `[webhook] Email error (non-fatal): ${emailErr?.message || emailErr}`,
        );
        await supabase
          .from("fs_orders")
          .update({ email_last_error: emailErr?.message || String(emailErr) })
          .eq("id", orderId);
      }
    }

    console.log(`[webhook] ✅ Order ${orderId} fully processed.`);
    return ok();
  } catch (err: any) {
    console.error("[webhook] Unhandled error:", err);
    return fail(500, "unhandled_exception_retry", {
      detail: err?.message || String(err),
    });
  }
});