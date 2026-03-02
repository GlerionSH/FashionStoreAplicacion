// supabase/functions/admin-returns/index.ts
// UNIFIED admin panel for cancellations + returns (both stored in fs_returns).
//
// GET  ?return_id=X       -> single return detail (+ order + items)
// GET  ?limit=50&status=  -> list returns with order info (2-step merge)
// PATCH { return_id, action:'approve', admin_notes? } -> Stripe refund + status='refunded'
// PATCH { return_id, action:'reject',  admin_notes? } -> status='rejected'
//
// Stock restore happens automatically via DB trigger trg_fs_restore_stock_on_refund
// when fs_returns.status changes to 'refunded'.
//
// NO Stripe SDK. NO Node polyfills. Only Deno/Web APIs + fetch.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { sendEmailBrevo } from "../_shared/email.ts";
import { getBranding } from "../_shared/branding.ts";
import { renderEmailBase, renderItemsTable } from "../_shared/email_templates.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function json(status: number, data: unknown) {
  return new Response(JSON.stringify(data), {
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
  sb: ReturnType<typeof createClient>,
): Promise<string | null> {
  const authHeader = req.headers.get("authorization") || "";
  if (!authHeader.startsWith("Bearer ")) return null;
  const payload = decodeJwtPayload(authHeader.replace("Bearer ", ""));
  const userId = payload?.sub as string | undefined;
  if (!userId) return null;
  const { data } = await sb
    .from("fs_profiles").select("role").eq("id", userId).maybeSingle();
  return data?.role === "admin" ? userId : null;
}

// ── Email + log helper ──
async function sendAndLog(
  sb: ReturnType<typeof createClient>,
  to: string,
  subject: string,
  html: string,
  text: string,
  orderId: string,
  eventType: string,
) {
  console.log(`[admin-returns] Sending email to=${to} subject="${subject}"`);
  const result = await sendEmailBrevo({ to, subject, html, text });
  if (!result.ok) {
    console.error(`[admin-returns] Email FAILED to=${to} status=${result.status} body=${result.bodyText}`);
  }
  // Log to fs_email_events (best-effort)
  const { error: logErr } = await sb.from("fs_email_events").insert({
    order_id: orderId,
    event_type: eventType,
    recipient_email: to,
    error: result.ok ? null : `${result.status}: ${result.bodyText}`,
  });
  if (logErr) {
    console.error("[admin-returns] fs_email_events insert error:", logErr.message);
  }
  return result;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY") ?? "";
  const emailAdminTo = Deno.env.get("EMAIL_ADMIN_TO") ?? "";

  const sb = createClient(supabaseUrl, serviceRoleKey);

  const adminId = await verifyAdmin(req, sb);
  if (!adminId) return json(403, { error: "Forbidden" });

  try {
    const url = new URL(req.url);

    // ═══════════════════════════════════════════════
    // GET: list or detail
    // ═══════════════════════════════════════════════
    if (req.method === "GET") {
      const returnId = url.searchParams.get("return_id");

      // ── Single return detail ──
      if (returnId) {
        const { data: ret, error: retErr } = await sb
          .from("fs_returns")
          .select("*")
          .eq("id", returnId)
          .maybeSingle();

        if (retErr) return json(500, { error: retErr.message, where: "admin-returns" });
        if (!ret) return json(404, { error: "return_not_found" });

        // Fetch order separately (no FK join)
        let orderData = null;
        if (ret.order_id) {
          const { data: ord } = await sb
            .from("fs_orders")
            .select("id, email, total_cents, status, created_at, stripe_payment_intent_id")
            .eq("id", ret.order_id)
            .maybeSingle();
          orderData = ord;
        }

        // Fetch shipment status for context
        let shipmentStatus = null;
        if (ret.order_id) {
          const { data: ship } = await sb
            .from("fs_shipments")
            .select("status, carrier, tracking_number")
            .eq("order_id", ret.order_id)
            .maybeSingle();
          shipmentStatus = ship;
        }

        // Fetch order items (from fs_order_items, not fs_return_items)
        let items: any[] = [];
        if (ret.order_id) {
          const { data: oi } = await sb
            .from("fs_order_items")
            .select("id, product_id, name, qty, size, price_cents, line_total_cents")
            .eq("order_id", ret.order_id);
          if (oi) items = oi;
        }

        // Determine type
        const isDelivered = shipmentStatus?.status === "delivered";
        const requestType = isDelivered ? "return" : "cancellation";

        return json(200, {
          return: {
            ...ret,
            order: orderData,
            shipment: shipmentStatus,
            items,
            request_type: requestType,
          },
        });
      }

      // ── List returns ──
      const limit = Math.min(
        parseInt(url.searchParams.get("limit") ?? "50", 10) || 50,
        100,
      );
      const statusFilter = url.searchParams.get("status") ?? null;

      let query = sb
        .from("fs_returns")
        .select("id, order_id, user_id, status, reason, requested_at, reviewed_at, refunded_at, refund_total_cents, notes")
        .order("requested_at", { ascending: false })
        .limit(limit);

      if (statusFilter) query = query.eq("status", statusFilter);

      const { data: returns, error } = await query;
      if (error) return json(500, { error: error.message, where: "admin-returns" });

      // 2-step: fetch orders for all returns
      const orderIds = (returns ?? []).map((r: any) => r.order_id).filter(Boolean);
      let ordersMap: Record<string, any> = {};
      if (orderIds.length > 0) {
        const { data: orders } = await sb
          .from("fs_orders")
          .select("id, email, total_cents, status")
          .in("id", orderIds);
        if (orders) {
          ordersMap = Object.fromEntries(orders.map((o: any) => [o.id, o]));
        }
      }

      // 2-step: fetch shipment statuses
      let shipmentsMap: Record<string, string> = {};
      if (orderIds.length > 0) {
        const { data: ships } = await sb
          .from("fs_shipments")
          .select("order_id, status")
          .in("order_id", orderIds);
        if (ships) {
          shipmentsMap = Object.fromEntries(ships.map((s: any) => [s.order_id, s.status]));
        }
      }

      // Merge
      const enriched = (returns ?? []).map((r: any) => {
        const shipStatus = shipmentsMap[r.order_id] ?? "pending";
        return {
          ...r,
          order: ordersMap[r.order_id] || null,
          shipment_status: shipStatus,
          request_type: shipStatus === "delivered" ? "return" : "cancellation",
        };
      });

      return json(200, { returns: enriched });
    }

    // ═══════════════════════════════════════════════
    // PATCH: approve or reject
    // ═══════════════════════════════════════════════
    if (req.method === "PATCH") {
      const body = await req.json();
      const { return_id, action, admin_notes } = body as {
        return_id?: string;
        action?: string;
        admin_notes?: string;
      };

      if (!return_id || !action) return json(400, { error: "return_id and action required" });
      if (!["approve", "reject"].includes(action)) {
        return json(400, { error: "action must be 'approve' or 'reject'" });
      }

      // Fetch the return
      const { data: ret, error: retErr } = await sb
        .from("fs_returns")
        .select("*")
        .eq("id", return_id)
        .maybeSingle();

      if (retErr || !ret) return json(404, { error: "Return not found" });
      if (ret.status !== "requested") {
        return json(409, { error: `Return already ${ret.status}` });
      }

      // Fetch order separately
      const orderId = ret.order_id;
      const { data: order } = await sb
        .from("fs_orders")
        .select("id, email, status, total_cents, stripe_payment_intent_id, stripe_refund_id")
        .eq("id", orderId)
        .maybeSingle();

      if (!order) return json(404, { error: "Order not found" });

      const now = new Date().toISOString();
      const recipientEmail = order.email ?? "";
      const shortId = orderId.substring(0, 8);

      // ── REJECT ──
      if (action === "reject") {
        await sb
          .from("fs_returns")
          .update({
            status: "rejected",
            reviewed_at: now,
            reviewed_by: adminId,
            notes: admin_notes ?? ret.notes,
          })
          .eq("id", return_id);

        // Clear cancel_requested_at on order
        await sb
          .from("fs_orders")
          .update({ cancel_requested_at: null })
          .eq("id", orderId);

        // Email client (best-effort)
        if (recipientEmail) {
          const branding = await getBranding(sb);
          const bodyHtml = `
            <p>Hola,</p>
            <p>Lamentamos informarte que tu solicitud para el pedido <strong>#${shortId}</strong> ha sido <strong>rechazada</strong>.</p>
            ${admin_notes ? `<p style="background-color:#fff3cd;padding:12px;border-left:3px solid #ffc107;margin:16px 0;"><strong>Motivo:</strong> ${admin_notes}</p>` : ""}
            <p>Tu pedido continuará procesándose con normalidad. Si tienes dudas, contacta con soporte.</p>
          `;
          const { html, text } = renderEmailBase({
            title: "SOLICITUD RECHAZADA",
            bodyHtml,
            footerText: "Gracias por tu comprensión",
            brandLogoUrl: branding.brandLogoUrl,
            storeName: branding.storeName,
            supportEmail: branding.supportEmail,
          });
          await sendAndLog(sb, recipientEmail,
            `Tu solicitud ha sido rechazada - Pedido #${shortId}`,
            html, text, orderId, "return_rejected",
          );
        }
        // Email admin (best-effort)
        if (emailAdminTo) {
          const branding = await getBranding(sb);
          const adminBodyHtml = `
            <p>Solicitud rechazada para pedido <strong>#${shortId}</strong>.</p>
            ${admin_notes ? `<p style="background-color:#f9f9f9;padding:12px;border-left:3px solid #666;margin:16px 0;"><strong>Motivo:</strong> ${admin_notes}</p>` : ""}
          `;
          const { html: adminHtml, text: adminText } = renderEmailBase({
            title: "[ADMIN] SOLICITUD RECHAZADA",
            bodyHtml: adminBodyHtml,
            footerText: "Panel de administración",
            brandLogoUrl: branding.brandLogoUrl,
            storeName: branding.storeName,
            supportEmail: branding.supportEmail,
          });
          await sendAndLog(sb, emailAdminTo,
            `[Admin] Solicitud rechazada - Pedido #${shortId}`,
            adminHtml, adminText, orderId, "return_rejected_admin",
          );
        }

        console.log(`[admin-returns] Rejected ${return_id} for order ${orderId}`);
        return json(200, { ok: true, status: "rejected" });
      }

      // ── APPROVE ──
      let stripeRefundId: string | null = null;
      let refundAmountCents: number | null = null;

      // Only refund if order was actually paid and has a PI
      const refundableStatuses = ["paid", "preparing", "shipped", "delivered"];
      if (refundableStatuses.includes(order.status)) {
        if (!stripeKey) {
          console.warn("[admin-returns] STRIPE_SECRET_KEY missing, skipping refund");
        } else if (!order.stripe_payment_intent_id) {
          console.warn("[admin-returns] No stripe_payment_intent_id, skipping refund");
        } else if (order.stripe_refund_id) {
          // Idempotent: refund already done
          console.log(`[admin-returns] Refund already exists: ${order.stripe_refund_id}`);
          stripeRefundId = order.stripe_refund_id;
        } else {
          // Create refund via Stripe REST API (NO SDK)
          try {
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
              console.error("[admin-returns] Stripe refund error:", errText);
              return json(502, {
                error: `Stripe refund failed: ${errText}`,
                where: "admin-returns",
              });
            }

            const refund = await refundRes.json();
            stripeRefundId = refund.id;
            refundAmountCents = refund.amount;
            console.log(`[admin-returns] Stripe refund created: ${refund.id} amount=${refund.amount}`);
          } catch (stripeErr: any) {
            console.error("[admin-returns] Stripe error:", stripeErr.message);
            return json(502, {
              error: `Stripe refund failed: ${stripeErr.message}`,
              where: "admin-returns",
            });
          }
        }
      }

      // Update fs_returns -> status='refunded'
      // This triggers trg_fs_restore_stock_on_refund (restores stock with sizes)
      // This triggers trg_fs_returns_recalc_order (recalculates order refund_total_cents)
      const { error: updateErr } = await sb
        .from("fs_returns")
        .update({
          status: "refunded",
          reviewed_at: now,
          reviewed_by: adminId,
          refunded_at: now,
          refund_method: stripeRefundId ? "stripe" : "manual",
          refund_total_cents: refundAmountCents ?? (order.total_cents ?? 0),
          stripe_refund_id: stripeRefundId,
          notes: admin_notes ?? ret.notes,
        })
        .eq("id", return_id);

      if (updateErr) {
        console.error("[admin-returns] update fs_returns error:", updateErr.message);
        return json(500, { error: updateErr.message, where: "admin-returns" });
      }

      // Update fs_orders
      const newOrderStatus = stripeRefundId ? "refunded" : "cancelled";
      await sb
        .from("fs_orders")
        .update({
          status: newOrderStatus,
          stripe_refund_id: stripeRefundId,
          refunded_at: stripeRefundId ? now : null,
          cancel_requested_at: null,
        })
        .eq("id", orderId);

      // Cancel shipment if not delivered
      const { data: shipment } = await sb
        .from("fs_shipments")
        .select("status")
        .eq("order_id", orderId)
        .maybeSingle();

      if (shipment && shipment.status !== "delivered") {
        await sb
          .from("fs_shipments")
          .update({ status: "cancelled", updated_at: now })
          .eq("order_id", orderId);
      }

      // Fetch items for email
      const { data: orderItems } = await sb
        .from("fs_order_items")
        .select("name, qty, size, line_total_cents")
        .eq("order_id", orderId);

      const itemsHtml = (orderItems && orderItems.length > 0)
        ? `<table style="width:100%;border-collapse:collapse;margin:16px 0">
            <thead><tr style="background:#f5f5f5">
              <th style="padding:6px 8px;text-align:left;font-size:12px">ARTICULO</th>
              <th style="padding:6px 8px;text-align:center;font-size:12px">CANT</th>
              <th style="padding:6px 8px;text-align:right;font-size:12px">TOTAL</th>
            </tr></thead>
            <tbody>${orderItems.map((i: any) =>
              `<tr>
                <td style="padding:6px 8px;border-bottom:1px solid #eee">${i.name || "Articulo"}${i.size ? ` (${i.size})` : ""}</td>
                <td style="padding:6px 8px;border-bottom:1px solid #eee;text-align:center">${i.qty}</td>
                <td style="padding:6px 8px;border-bottom:1px solid #eee;text-align:right">${((i.line_total_cents || 0) / 100).toFixed(2)} EUR</td>
              </tr>`).join("")}</tbody>
          </table>`
        : "";

      const refundEur = ((refundAmountCents ?? order.total_cents ?? 0) / 100).toFixed(2);

      // Email client: refund approved (best-effort)
      if (recipientEmail) {
        const branding = await getBranding(sb);
        const itemsTableHtml = renderItemsTable(orderItems || []);
        const bodyHtml = `
          <p>Hola,</p>
          <p>¡Buenas noticias! Tu solicitud para el pedido <strong>#${shortId}</strong> ha sido <strong>aprobada</strong>.</p>
          <p style="background-color:#d4edda;padding:16px;border-left:4px solid #28a745;margin:16px 0;">
            <strong style="font-size:18px;color:#155724;">Importe reembolsado: ${refundEur} €</strong>
          </p>
          ${itemsTableHtml}
          ${admin_notes ? `<p style="background-color:#f9f9f9;padding:12px;border-left:3px solid #666;margin:16px 0;"><strong>Nota:</strong> ${admin_notes}</p>` : ""}
          <p>El reembolso aparecerá en tu cuenta en los próximos días según tu método de pago.</p>
          <p style="font-size:14px;color:#666;">Gracias por tu comprensión.</p>
        `;
        const { html, text } = renderEmailBase({
          title: "REEMBOLSO APROBADO",
          bodyHtml,
          footerText: "Gracias por tu comprensión",
          brandLogoUrl: branding.brandLogoUrl,
          storeName: branding.storeName,
          supportEmail: branding.supportEmail,
        });
        await sendAndLog(sb, recipientEmail,
          `Reembolso procesado - Pedido #${shortId}`,
          html, text, orderId, "refund_approved",
        );
      }

      // Email admin: confirmation (best-effort)
      if (emailAdminTo) {
        const branding = await getBranding(sb);
        const adminBodyHtml = `
          <p>Reembolso procesado correctamente:</p>
          <table role="presentation" style="width:100%;margin:16px 0;">
            <tr><td style="padding:8px 0;color:#666;font-size:14px;"><strong>Pedido:</strong></td><td style="padding:8px 0;color:#111;font-size:14px;">#${shortId}</td></tr>
            <tr><td style="padding:8px 0;color:#666;font-size:14px;"><strong>Cliente:</strong></td><td style="padding:8px 0;color:#111;font-size:14px;">${recipientEmail}</td></tr>
            <tr><td style="padding:8px 0;color:#666;font-size:14px;"><strong>Importe:</strong></td><td style="padding:8px 0;color:#111;font-size:14px;">${refundEur} €</td></tr>
            <tr><td style="padding:8px 0;color:#666;font-size:14px;"><strong>Stripe Refund:</strong></td><td style="padding:8px 0;color:#111;font-size:14px;">${stripeRefundId ?? "N/A"}</td></tr>
          </table>
          <p style="font-size:14px;color:#666;">Stock restaurado automáticamente via trigger.</p>
        `;
        const { html: adminHtml, text: adminText } = renderEmailBase({
          title: "[ADMIN] REEMBOLSO PROCESADO",
          bodyHtml: adminBodyHtml,
          footerText: "Panel de administración",
          brandLogoUrl: branding.brandLogoUrl,
          storeName: branding.storeName,
          supportEmail: branding.supportEmail,
        });
        await sendAndLog(sb, emailAdminTo,
          `[Admin] Reembolso procesado - Pedido #${shortId}`,
          adminHtml, adminText, orderId, "refund_approved_admin",
        );
      }

      console.log(`[admin-returns] Approved ${return_id} order=${orderId} refund=${stripeRefundId ?? "none"}`);
      return json(200, {
        ok: true,
        status: "refunded",
        new_order_status: newOrderStatus,
        stripe_refund_id: stripeRefundId,
        refund_amount_cents: refundAmountCents ?? (order.total_cents ?? 0),
      });
    }

    return json(405, { error: "Method not allowed" });
  } catch (err: any) {
    console.error("[admin-returns] Unhandled error:", err);
    return json(500, {
      error: err.message ?? "Internal error",
      details: err.toString(),
      where: "admin-returns",
      stack: err.stack?.substring(0, 500),
    });
  }
});
