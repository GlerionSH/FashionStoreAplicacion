// supabase/functions/request-cancel/index.ts
// Client requests cancellation of an order.
// POST { order_id, reason? }
// Only allowed for orders in status: paid | preparing
// Returns { ok, request_id }

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

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const brevoApiKey = Deno.env.get("BREVO_API_KEY") ?? "";
  const emailFrom = Deno.env.get("EMAIL_FROM") ?? "";
  const emailFromName = Deno.env.get("EMAIL_FROM_NAME") ?? "Fashion Store";
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

    // Verify order belongs to user
    const { data: order, error: orderErr } = await supabase
      .from("fs_orders")
      .select("id, status, email, total_cents, cancel_requested_at")
      .eq("id", order_id)
      .eq("user_id", userId)
      .maybeSingle();

    if (orderErr || !order) return json(404, { error: "Pedido no encontrado" });

    const cancellableStatuses = ["paid", "preparing"];
    if (!cancellableStatuses.includes(order.status)) {
      return json(409, {
        error: `No se puede cancelar un pedido en estado "${order.status}". Solo se puede cancelar si está en estado pagado o preparando.`,
      });
    }

    if (order.cancel_requested_at) {
      return json(409, { error: "Ya existe una solicitud de cancelación para este pedido." });
    }

    const now = new Date().toISOString();

    // Insert cancellation request (UNIQUE on order_id prevents duplicates)
    const { data: cancelReq, error: insertErr } = await supabase
      .from("fs_cancellation_requests")
      .insert({
        order_id,
        user_id: userId,
        email: userEmail ?? order.email,
        reason: reason ?? null,
        requested_at: now,
        status: "requested",
      })
      .select()
      .single();

    if (insertErr) {
      console.error("[request-cancel] insert error:", insertErr.message);
      if (insertErr.code === "23505") {
        return json(409, { error: "Ya existe una solicitud de cancelación para este pedido." });
      }
      return json(500, { error: "Error al crear la solicitud" });
    }

    // Mark order with cancel_requested_at
    await supabase
      .from("fs_orders")
      .update({ cancel_requested_at: now })
      .eq("id", order_id);

    // Send confirmation email to client
    if (brevoApiKey && emailFrom && (userEmail ?? order.email)) {
      const recipient = userEmail ?? order.email;
      const shortId = order_id.substring(0, 8);
      const html = `
        <div style="font-family:Helvetica,Arial,sans-serif;max-width:600px;margin:0 auto;color:#111">
          <h2 style="font-weight:300;letter-spacing:2px;text-align:center">FASHION STORE</h2>
          <p>Hola,</p>
          <p>Hemos recibido tu solicitud de cancelación para el pedido <strong>#${shortId}</strong>.</p>
          <p>Nuestro equipo la revisará en breve y recibirás una confirmación por email.</p>
          ${reason ? `<p><em>Motivo: ${reason}</em></p>` : ""}
          <p style="font-size:12px;color:#999">Si no solicitaste esta cancelación, contacta con soporte.</p>
        </div>`;

      const toList: { email: string }[] = [{ email: recipient }];
      if (emailAdminTo) toList.push({ email: emailAdminTo });

      await fetch("https://api.brevo.com/v3/smtp/email", {
        method: "POST",
        headers: { "api-key": brevoApiKey, "Content-Type": "application/json" },
        body: JSON.stringify({
          sender: { name: emailFromName, email: emailFrom },
          to: toList,
          subject: `Solicitud de cancelación recibida — Pedido #${shortId}`,
          htmlContent: html,
        }),
      });

      await supabase.from("fs_email_events").insert({
        order_id,
        event_type: "cancel_requested",
        recipient_email: recipient,
      });
    }

    console.log(`[request-cancel] Created cancel request ${cancelReq.id} for order ${order_id}`);
    return json(200, { ok: true, request_id: cancelReq.id });
  } catch (err: any) {
    console.error("[request-cancel] error:", err);
    return json(500, { error: err.message ?? "Internal error" });
  }
});
