// supabase/functions/admin-cancellations/index.ts
// Admin: list + approve/reject cancellation requests.
// Approve: Stripe refund + stock restore + status update + email.
// Idempotent: approved requests cannot be re-processed.
//
// GET    ?action=list        → list all requests
// GET    ?action=detail&id=  → single request
// PATCH  { id, action:'approve', admin_notes? }
// PATCH  { id, action:'reject',  admin_notes? }

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(status: number, body: unknown) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function decodeJwtPayload(token: string): Record<string, unknown> | null {
  try {
    const [, b64] = token.split(".");
    const pad = b64.length % 4;
    const padded = pad ? b64 + "=".repeat(4 - pad) : b64;
    return JSON.parse(atob(padded.replace(/-/g, "+").replace(/_/g, "/")));
  } catch { return null; }
}

async function verifyAdmin(
  req: Request,
  supabase: ReturnType<typeof createClient>,
): Promise<string | null> {
  const authHeader = req.headers.get("authorization") || "";
  if (!authHeader.startsWith("Bearer ")) return null;
  const payload = decodeJwtPayload(authHeader.replace("Bearer ", ""));
  const userId = payload?.sub as string | undefined;
  if (!userId) return null;
  const { data } = await supabase
    .from("fs_profiles").select("role").eq("id", userId).maybeSingle();
  return data?.role === "admin" ? userId : null;
}

async function sendCancelEmail(
  supabase: ReturnType<typeof createClient>,
  orderId: string,
  recipientEmail: string,
  approved: boolean,
  adminNotes: string | null,
  brevoApiKey: string,
  emailFrom: string,
  emailFromName: string,
) {
  const shortId = orderId.substring(0, 8);
  const subject = approved
    ? `Tu solicitud de cancelación ha sido aprobada — Pedido #${shortId}`
    : `Tu solicitud de cancelación ha sido rechazada — Pedido #${shortId}`;

  const html = approved
    ? `<div style="font-family:Helvetica,Arial,sans-serif;max-width:600px;margin:0 auto;color:#111">
        <h2 style="font-weight:300;letter-spacing:2px;text-align:center">FASHION STORE</h2>
        <p>Hola,</p>
        <p>Tu solicitud de cancelación para el pedido <strong>#${shortId}</strong> ha sido <strong>aprobada</strong>.</p>
        <p>El reembolso será procesado en los próximos días según el método de pago original.</p>
        ${adminNotes ? `<p><em>Nota: ${adminNotes}</em></p>` : ""}
        <p style="font-size:12px;color:#999">Gracias por tu comprensión.</p>
      </div>`
    : `<div style="font-family:Helvetica,Arial,sans-serif;max-width:600px;margin:0 auto;color:#111">
        <h2 style="font-weight:300;letter-spacing:2px;text-align:center">FASHION STORE</h2>
        <p>Hola,</p>
        <p>Tu solicitud de cancelación para el pedido <strong>#${shortId}</strong> ha sido <strong>rechazada</strong>.</p>
        ${adminNotes ? `<p>Motivo: ${adminNotes}</p>` : ""}
        <p>Tu pedido continuará procesándose con normalidad. Si tienes dudas, contacta con soporte.</p>
      </div>`;

  try {
    const res = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: { "api-key": brevoApiKey, "Content-Type": "application/json" },
      body: JSON.stringify({
        sender: { name: emailFromName, email: emailFrom },
        to: [{ email: recipientEmail }],
        subject,
        htmlContent: html,
      }),
    });

    const eventType = approved ? "cancel_approved" : "cancel_rejected";
    await supabase.from("fs_email_events").insert({
      order_id: orderId,
      event_type: eventType,
      recipient_email: recipientEmail,
      error: res.ok ? null : await res.text(),
    });
  } catch (e: any) {
    console.error("[admin-cancellations] email error:", e.message);
  }
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY") ?? "";
  const brevoApiKey = Deno.env.get("BREVO_API_KEY") ?? "";
  const emailFrom = Deno.env.get("EMAIL_FROM") ?? "";
  const emailFromName = Deno.env.get("EMAIL_FROM_NAME") ?? "Fashion Store";

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  const adminId = await verifyAdmin(req, supabase);
  if (!adminId) return json(403, { error: "Forbidden" });

  try {
    const url = new URL(req.url);

    // ── GET ──
    if (req.method === "GET") {
      const action = url.searchParams.get("action") ?? "list";
      if (action === "detail") {
        const id = url.searchParams.get("id");
        if (!id) return json(400, { error: "id required" });
        const { data: cancelReq, error } = await supabase
          .from("fs_cancellation_requests")
          .select("*")
          .eq("id", id)
          .maybeSingle();
        if (error) return json(500, { error: error.message });
        if (!cancelReq) return json(404, { error: "not_found" });

        // Fetch order separately
        let orderData = null;
        if (cancelReq.order_id) {
          const { data: ord } = await supabase
            .from("fs_orders")
            .select("id, email, status, total_cents, stripe_payment_intent_id")
            .eq("id", cancelReq.order_id)
            .maybeSingle();
          orderData = ord;
        }

        return json(200, { request: { ...cancelReq, order: orderData } });
      }

      // Query in 2 steps to avoid FK requirement
      const { data: requests, error } = await supabase
        .from("fs_cancellation_requests")
        .select("*")
        .order("requested_at", { ascending: false });
      if (error) return json(500, { error: error.message });

      // Fetch orders separately
      const orderIds = (requests ?? []).map((r: any) => r.order_id).filter(Boolean);
      let ordersMap: Record<string, any> = {};
      if (orderIds.length > 0) {
        const { data: orders } = await supabase
          .from("fs_orders")
          .select("id, email, status, total_cents")
          .in("id", orderIds);
        if (orders) {
          ordersMap = Object.fromEntries(orders.map((o: any) => [o.id, o]));
        }
      }

      // Merge
      const enriched = (requests ?? []).map((r: any) => ({
        ...r,
        order: ordersMap[r.order_id] || null,
      }));

      return json(200, { requests: enriched });
    }

    // ── PATCH ──
    if (req.method === "PATCH") {
      const { id, action, admin_notes } = await req.json();
      if (!id || !action) return json(400, { error: "id and action required" });
      if (!["approve", "reject"].includes(action)) return json(400, { error: "action must be approve or reject" });

      // Fetch the request
      const { data: cancelReq, error: fetchErr } = await supabase
        .from("fs_cancellation_requests")
        .select("*")
        .eq("id", id)
        .maybeSingle();

      if (fetchErr || !cancelReq) return json(404, { error: "Request not found" });
      if (cancelReq.status !== "requested") {
        return json(409, { error: `Request already ${cancelReq.status}` });
      }

      // Fetch order separately
      const orderId = cancelReq.order_id;
      const { data: order } = await supabase
        .from("fs_orders")
        .select("id, email, status, total_cents, stripe_payment_intent_id, stripe_refund_id")
        .eq("id", orderId)
        .maybeSingle();

      if (!order) return json(404, { error: "Order not found" });

      const now = new Date().toISOString();

      if (action === "reject") {
        await supabase
          .from("fs_cancellation_requests")
          .update({ status: "rejected", reviewed_at: now, reviewed_by: adminId, admin_notes: admin_notes ?? null })
          .eq("id", id);

        await supabase
          .from("fs_orders")
          .update({ cancel_requested_at: null })
          .eq("id", orderId);

        if (brevoApiKey && emailFrom && cancelReq.email) {
          await sendCancelEmail(supabase, orderId, cancelReq.email, false, admin_notes ?? null, brevoApiKey, emailFrom, emailFromName);
        }

        return json(200, { ok: true, status: "rejected" });
      }

      // ── APPROVE ──
      let stripeRefundId: string | null = null;
      let refundAmountCents: number | null = null;

      // Stripe refund (only if order was paid)
      if (order.status === "paid" || order.status === "preparing") {
        if (!stripeKey) {
          console.warn("[admin-cancellations] STRIPE_SECRET_KEY missing, skipping refund");
        } else if (!order.stripe_payment_intent_id) {
          console.warn("[admin-cancellations] No stripe_payment_intent_id, skipping refund");
        } else {
          // Idempotent: only refund if no refund_id stored yet
          if (order.stripe_refund_id) {
            console.log(`[admin-cancellations] Refund already done: ${order.stripe_refund_id}`);
            stripeRefundId = order.stripe_refund_id;
          } else {
            try {
              // Create refund using Stripe REST API (fetch only, no SDK)
              const refundRes = await fetch("https://api.stripe.com/v1/refunds", {
                method: "POST",
                headers: {
                  "Authorization": `Bearer ${stripeKey}`,
                  "Content-Type": "application/x-www-form-urlencoded",
                },
                body: new URLSearchParams({
                  payment_intent: order.stripe_payment_intent_id,
                  reason: "requested_by_customer",
                }).toString(),
              });

              if (!refundRes.ok) {
                const errText = await refundRes.text();
                console.error("[admin-cancellations] Stripe refund error:", errText);
                return json(502, { error: `Stripe refund failed: ${errText}`, where: "admin-cancellations" });
              }

              const refund = await refundRes.json();
              stripeRefundId = refund.id;
              refundAmountCents = refund.amount;
              console.log(`[admin-cancellations] Refund created: ${refund.id} amount=${refund.amount}`);
            } catch (stripeErr: any) {
              console.error("[admin-cancellations] Stripe refund error:", stripeErr.message);
              return json(502, { error: `Stripe refund failed: ${stripeErr.message}`, details: stripeErr.toString(), where: "admin-cancellations" });
            }
          }
        }
      }

      // Restore stock atomically
      const { error: stockErr } = await supabase.rpc("fs_restore_stock_for_order", {
        p_order_id: orderId,
      });
      if (stockErr) {
        console.error("[admin-cancellations] stock restore error:", stockErr.message);
        // Non-fatal: continue with cancellation
      }

      // Update order status
      const newOrderStatus = stripeRefundId ? "refunded" : "cancelled";
      await supabase
        .from("fs_orders")
        .update({
          status: newOrderStatus,
          stripe_refund_id: stripeRefundId,
          refunded_at: stripeRefundId ? now : null,
          cancel_requested_at: null,
        })
        .eq("id", orderId);

      // Update request
      await supabase
        .from("fs_cancellation_requests")
        .update({
          status: "approved",
          reviewed_at: now,
          reviewed_by: adminId,
          admin_notes: admin_notes ?? null,
          stripe_refund_id: stripeRefundId,
          refund_amount_cents: refundAmountCents,
        })
        .eq("id", id);

      // Update shipment if exists
      await supabase
        .from("fs_shipments")
        .update({ status: "cancelled", updated_at: now })
        .eq("order_id", orderId);

      // Email client
      if (brevoApiKey && emailFrom && cancelReq.email) {
        await sendCancelEmail(supabase, orderId, cancelReq.email, true, admin_notes ?? null, brevoApiKey, emailFrom, emailFromName);
      }

      console.log(`[admin-cancellations] Approved ${id} order=${orderId} refund=${stripeRefundId ?? "none"}`);
      return json(200, {
        ok: true,
        status: "approved",
        new_order_status: newOrderStatus,
        stripe_refund_id: stripeRefundId,
        refund_amount_cents: refundAmountCents,
      });
    }

    return json(405, { error: "Method not allowed" });
  } catch (err: any) {
    console.error("[admin-cancellations] Unhandled error:", err);
    return json(500, { 
      error: err.message ?? "Internal error", 
      details: err.toString(),
      where: "admin-cancellations",
      stack: err.stack?.substring(0, 500)
    });
  }
});
