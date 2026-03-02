// supabase/functions/request-cancel/index.ts
// UNIFIED cancel / return request from client.
// POST { order_id, reason? }
//
// - If shipment NOT delivered yet  -> interpreted as CANCELLATION
// - If shipment delivered           -> interpreted as RETURN
// Both are stored in fs_returns (single table).
//
// Allowed when order status in: paid, preparing, shipped, delivered
// Returns { ok, return_id, type: 'cancellation'|'return' }

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { sendEmailBrevo } from "../_shared/email.ts";
import { getBranding } from "../_shared/branding.ts";
import { renderEmailBase } from "../_shared/email_templates.ts";

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

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const emailAdminTo = Deno.env.get("EMAIL_ADMIN_TO") ?? "";

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  // Auth required
  const authHeader = req.headers.get("authorization") || "";
  if (!authHeader.startsWith("Bearer ")) return json(401, { error: "No autorizado" });
  const payload = decodeJwtPayload(authHeader.replace("Bearer ", ""));
  const userId = payload?.sub as string | undefined;
  const userEmail = payload?.email as string | undefined;
  if (!userId) return json(401, { error: "No autorizado" });

  try {
    const { order_id, reason } = await req.json();
    if (!order_id) return json(400, { error: "order_id required" });

    // 1) Verify order belongs to user
    const { data: order, error: orderErr } = await supabase
      .from("fs_orders")
      .select("id, status, email, total_cents, cancel_requested_at")
      .eq("id", order_id)
      .eq("user_id", userId)
      .maybeSingle();

    if (orderErr || !order) return json(404, { error: "Pedido no encontrado" });

    // Allow cancel/return for these statuses
    const allowedStatuses = ["paid", "preparing", "shipped", "delivered"];
    if (!allowedStatuses.includes(order.status)) {
      return json(409, {
        error: `No se puede solicitar para un pedido en estado "${order.status}".`,
      });
    }

    // Check if there is already a pending return/cancel for this order
    const { data: existing } = await supabase
      .from("fs_returns")
      .select("id, status")
      .eq("order_id", order_id)
      .in("status", ["requested", "approved"])
      .maybeSingle();

    if (existing) {
      return json(409, { error: "Ya existe una solicitud pendiente para este pedido." });
    }

    // 2) Check shipment status to determine type
    const { data: shipment } = await supabase
      .from("fs_shipments")
      .select("status")
      .eq("order_id", order_id)
      .maybeSingle();

    const shipmentStatus = shipment?.status ?? "pending";
    const isReturn = shipmentStatus === "delivered";
    const requestType = isReturn ? "return" : "cancellation";

    const now = new Date().toISOString();
    const recipientEmail = userEmail ?? order.email;

    // 3) Insert into fs_returns (unified table)
    const reasonText = reason
      ? reason
      : (isReturn ? "Devolucion solicitada por el cliente" : "Cancelacion solicitada por el cliente");

    const { data: returnReq, error: insertErr } = await supabase
      .from("fs_returns")
      .insert({
        order_id,
        user_id: userId,
        status: "requested",
        request_type: requestType,
        reason: reasonText,
        requested_at: now,
        refund_total_cents: order.total_cents ?? 0,
        notes: `Estado envio: ${shipmentStatus}.`,
      })
      .select("id")
      .single();

    if (insertErr) {
      console.error("[request-cancel] insert fs_returns error:", insertErr.message);
      return json(500, {
        error: "Error al crear la solicitud",
        details: insertErr.message,
        where: "request-cancel",
      });
    }

    // 4) Mark order
    await supabase
      .from("fs_orders")
      .update({ cancel_requested_at: now })
      .eq("id", order_id);

    // 5) Send confirmation emails (best-effort - never fail the request)
    const branding = await getBranding(supabase);
    const shortId = order_id.substring(0, 8).toUpperCase();
    const typeLabel = isReturn ? "devolución" : "cancelación";
    const typeTitle = isReturn ? "DEVOLUCIÓN" : "CANCELACIÓN";

    // Send client email
    if (recipientEmail) {
      console.log(`[request-cancel] Sending ${typeLabel} email to client: ${recipientEmail}`);
      
      const bodyHtml = `
        <p>Hola,</p>
        <p>Hemos recibido tu solicitud de ${typeLabel} para el pedido <strong>#${shortId}</strong>.</p>
        <p>Nuestro equipo la revisará en breve y recibirás una confirmación por email.</p>
        ${reason ? `<p style="background-color:#f9f9f9;padding:12px;border-left:3px solid #666;margin:16px 0;"><strong>Motivo:</strong> ${reason}</p>` : ""}
        <p style="font-size:14px;color:#666;">Si no solicitaste esta ${typeLabel}, contacta con soporte inmediatamente.</p>
      `;

      const { html, text } = renderEmailBase({
        title: `SOLICITUD DE ${typeTitle} RECIBIDA`,
        bodyHtml,
        footerText: `Tu solicitud está siendo procesada`,
        brandLogoUrl: branding.brandLogoUrl,
        storeName: branding.storeName,
        supportEmail: branding.supportEmail,
      });

      const clientResult = await sendEmailBrevo({
        to: recipientEmail,
        subject: `Solicitud de ${typeLabel} recibida - Pedido #${shortId}`,
        html,
        text,
      });

      if (!clientResult.ok) {
        console.error(`[request-cancel] Client email failed (${clientResult.status}): ${clientResult.bodyText}`);
      }

      // Log email event to fs_email_events (check if table exists first)
      const { error: checkErr } = await supabase.rpc("to_regclass", { relname: "public.fs_email_events" }).single();
      if (!checkErr) {
        const { error: logErr } = await supabase.from("fs_email_events").insert({
          order_id,
          event_type: `${requestType}_requested`,
          recipient_email: recipientEmail,
          error: clientResult.ok ? null : `${clientResult.status}: ${clientResult.bodyText}`,
        });
        if (logErr) {
          console.error("[request-cancel] fs_email_events insert error:", logErr.message);
        }
      }
    }

    // Send admin notification email
    if (emailAdminTo) {
      console.log(`[request-cancel] Sending ${typeLabel} notification to admin: ${emailAdminTo}`);
      
      const totalEur = ((order.total_cents ?? 0) / 100).toFixed(2);
      const adminBodyHtml = `
        <p>Nueva solicitud de <strong>${typeLabel}</strong> recibida:</p>
        <table role="presentation" style="width:100%;margin:16px 0;">
          <tr><td style="padding:8px 0;color:#666;font-size:14px;"><strong>Pedido:</strong></td><td style="padding:8px 0;color:#111;font-size:14px;">#${shortId}</td></tr>
          <tr><td style="padding:8px 0;color:#666;font-size:14px;"><strong>Cliente:</strong></td><td style="padding:8px 0;color:#111;font-size:14px;">${recipientEmail}</td></tr>
          <tr><td style="padding:8px 0;color:#666;font-size:14px;"><strong>Total:</strong></td><td style="padding:8px 0;color:#111;font-size:14px;">${totalEur} €</td></tr>
          <tr><td style="padding:8px 0;color:#666;font-size:14px;"><strong>Estado envío:</strong></td><td style="padding:8px 0;color:#111;font-size:14px;">${shipmentStatus}</td></tr>
          ${reason ? `<tr><td style="padding:8px 0;color:#666;font-size:14px;"><strong>Motivo:</strong></td><td style="padding:8px 0;color:#111;font-size:14px;">${reason}</td></tr>` : ""}
        </table>
        <p style="font-size:14px;color:#666;">Gestionar en el panel de administración → Devoluciones.</p>
      `;

      const { html: adminHtml, text: adminText } = renderEmailBase({
        title: `[ADMIN] NUEVA SOLICITUD DE ${typeTitle}`,
        bodyHtml: adminBodyHtml,
        footerText: `Panel de administración`,
        brandLogoUrl: branding.brandLogoUrl,
        storeName: branding.storeName,
        supportEmail: branding.supportEmail,
      });

      const adminResult = await sendEmailBrevo({
        to: emailAdminTo,
        subject: `[Admin] Nueva solicitud de ${typeLabel} - Pedido #${shortId}`,
        html: adminHtml,
        text: adminText,
      });

      if (!adminResult.ok) {
        console.error(`[request-cancel] Admin email failed (${adminResult.status}): ${adminResult.bodyText}`);
      }
    }

    console.log(`[request-cancel] Created ${requestType} request ${returnReq.id} for order ${order_id}`);
    return json(200, { ok: true, return_id: returnReq.id, type: requestType });
  } catch (err: any) {
    console.error("[request-cancel] Unhandled error:", err);
    return json(500, {
      error: err.message ?? "Internal error",
      details: err.toString(),
      where: "request-cancel",
    });
  }
});
