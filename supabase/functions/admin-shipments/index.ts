// supabase/functions/admin-shipments/index.ts
// Admin manages shipments: create/update carrier, tracking, status.
// Sends email on status change (shipped / delivered).
//
// GET    ?order_id=    → get shipment for an order
// GET    ?action=list  → list all shipments
// POST   { order_id, carrier?, tracking_number?, status?, notes? } → create/upsert
// PATCH  { id, carrier?, tracking_number?, status?, notes? } → update + email

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

async function verifyAdmin(req: Request, supabase: ReturnType<typeof createClient>): Promise<boolean> {
  const authHeader = req.headers.get("authorization") || "";
  if (!authHeader.startsWith("Bearer ")) return false;
  const payload = decodeJwtPayload(authHeader.replace("Bearer ", ""));
  const userId = payload?.sub as string | undefined;
  if (!userId) return false;
  const { data } = await supabase.from("fs_profiles").select("role").eq("id", userId).maybeSingle();
  return data?.role === "admin";
}

async function sendShipmentEmail(
  supabase: ReturnType<typeof createClient>,
  orderId: string,
  status: string,
  carrier: string | null,
  trackingNumber: string | null,
  brevoApiKey: string,
  emailFrom: string,
  emailFromName: string,
) {
  const { data: order } = await supabase
    .from("fs_orders")
    .select("email, id")
    .eq("id", orderId)
    .maybeSingle();

  if (!order?.email) {
    console.warn("[admin-shipments] No email for order", orderId);
    return;
  }

  const shortId = orderId.substring(0, 8);
  let subject = "";
  let bodyHtml = "";

  if (status === "shipped") {
    subject = `Tu pedido #${shortId} ha sido enviado`;
    bodyHtml = `
      <div style="font-family:Helvetica,Arial,sans-serif;max-width:600px;margin:0 auto;color:#111">
        <h2 style="font-weight:300;letter-spacing:2px;text-align:center">FASHION STORE</h2>
        <p>Hola,</p>
        <p>Tu pedido <strong>#${shortId}</strong> acaba de salir en camino.</p>
        ${carrier ? `<p>Transportista: <strong>${carrier}</strong></p>` : ""}
        ${trackingNumber ? `<p>Número de seguimiento: <strong>${trackingNumber}</strong></p>` : ""}
        <p style="margin-top:24px;font-size:12px;color:#999">Si tienes dudas, contacta con nuestro soporte.</p>
      </div>`;
  } else if (status === "delivered") {
    subject = `Tu pedido #${shortId} ha sido entregado`;
    bodyHtml = `
      <div style="font-family:Helvetica,Arial,sans-serif;max-width:600px;margin:0 auto;color:#111">
        <h2 style="font-weight:300;letter-spacing:2px;text-align:center">FASHION STORE</h2>
        <p>Hola,</p>
        <p>Tu pedido <strong>#${shortId}</strong> ha sido entregado. ¡Esperamos que lo disfrutes!</p>
        <p style="margin-top:24px;font-size:12px;color:#999">Gracias por confiar en Fashion Store.</p>
      </div>`;
  } else {
    return; // No email for other statuses
  }

  try {
    const res = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: { "api-key": brevoApiKey, "Content-Type": "application/json" },
      body: JSON.stringify({
        sender: { name: emailFromName, email: emailFrom },
        to: [{ email: order.email }],
        subject,
        htmlContent: bodyHtml,
      }),
    });

    const eventType = status === "shipped" ? "order_shipped" : "order_delivered";
    await supabase.from("fs_email_events").insert({
      order_id: orderId,
      event_type: eventType,
      recipient_email: order.email,
      error: res.ok ? null : await res.text(),
    });

    console.log(`[admin-shipments] Email ${eventType} sent to ${order.email} → ${res.status}`);
  } catch (e: any) {
    console.error("[admin-shipments] Email error:", e.message);
    await supabase.from("fs_email_events").insert({
      order_id: orderId,
      event_type: status === "shipped" ? "order_shipped" : "order_delivered",
      recipient_email: order.email,
      error: e.message,
    });
  }
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const brevoApiKey = Deno.env.get("BREVO_API_KEY") ?? "";
  const emailFrom = Deno.env.get("EMAIL_FROM") ?? "";
  const emailFromName = Deno.env.get("EMAIL_FROM_NAME") ?? "Fashion Store";

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  if (!(await verifyAdmin(req, supabase))) return json(403, { error: "Forbidden" });

  try {
    const url = new URL(req.url);

    if (req.method === "GET") {
      const orderId = url.searchParams.get("order_id");
      if (orderId) {
        const { data, error } = await supabase
          .from("fs_shipments")
          .select("*")
          .eq("order_id", orderId)
          .maybeSingle();
        if (error) return json(500, { error: error.message });
        return json(200, { shipment: data });
      }

      // list - query in 2 steps to avoid FK requirement
      const { data: shipments, error } = await supabase
        .from("fs_shipments")
        .select("*")
        .order("updated_at", { ascending: false })
        .limit(100);
      if (error) return json(500, { error: error.message });

      // Fetch orders separately
      const orderIds = (shipments ?? []).map((s: any) => s.order_id).filter(Boolean);
      let ordersMap: Record<string, any> = {};
      if (orderIds.length > 0) {
        const { data: orders } = await supabase
          .from("fs_orders")
          .select("id, email, total_cents, status")
          .in("id", orderIds);
        if (orders) {
          ordersMap = Object.fromEntries(orders.map((o: any) => [o.id, o]));
        }
      }

      // Merge
      const enriched = (shipments ?? []).map((s: any) => ({
        ...s,
        order: ordersMap[s.order_id] || null,
      }));

      return json(200, { shipments: enriched });
    }

    if (req.method === "POST") {
      const { order_id, carrier, tracking_number, status, notes } = await req.json();
      if (!order_id) return json(400, { error: "order_id required" });

      const now = new Date().toISOString();
      const { data, error } = await supabase
        .from("fs_shipments")
        .upsert({
          order_id,
          carrier: carrier ?? null,
          tracking_number: tracking_number ?? null,
          status: status ?? "pending",
          notes: notes ?? null,
          last_event_at: now,
          updated_at: now,
          shipped_at: status === "shipped" ? now : null,
          delivered_at: status === "delivered" ? now : null,
        }, { onConflict: "order_id" })
        .select()
        .single();

      if (error) return json(400, { error: error.message });

      if ((status === "shipped" || status === "delivered") && brevoApiKey && emailFrom) {
        await sendShipmentEmail(supabase, order_id, status, carrier, tracking_number, brevoApiKey, emailFrom, emailFromName);
      }

      // Sync order status
      if (status === "shipped" || status === "delivered") {
        await supabase.from("fs_orders").update({ status }).eq("id", order_id);
      }

      return json(201, { shipment: data });
    }

    if (req.method === "PATCH") {
      const { id, order_id, carrier, tracking_number, status, notes, shipped_at, delivered_at } = await req.json();
      if (!id) return json(400, { error: "id required" });

      const now = new Date().toISOString();
      const update: Record<string, unknown> = { updated_at: now, last_event_at: now };
      if (carrier !== undefined) update.carrier = carrier;
      if (tracking_number !== undefined) update.tracking_number = tracking_number;
      if (notes !== undefined) update.notes = notes;
      if (status !== undefined) {
        update.status = status;
        if (status === "shipped" && !shipped_at) update.shipped_at = now;
        if (status === "delivered" && !delivered_at) update.delivered_at = now;
      }
      if (shipped_at !== undefined) update.shipped_at = shipped_at;
      if (delivered_at !== undefined) update.delivered_at = delivered_at;

      const { data, error } = await supabase
        .from("fs_shipments")
        .update(update)
        .eq("id", id)
        .select("*, order_id")
        .single();

      if (error) return json(400, { error: error.message });

      const resolvedOrderId = order_id ?? data.order_id;

      if (status && (status === "shipped" || status === "delivered") && brevoApiKey && emailFrom) {
        await sendShipmentEmail(
          supabase,
          resolvedOrderId,
          status,
          carrier ?? data.carrier,
          tracking_number ?? data.tracking_number,
          brevoApiKey, emailFrom, emailFromName,
        );
      }

      if (status === "shipped" || status === "delivered" || status === "preparing") {
        await supabase.from("fs_orders").update({ status }).eq("id", resolvedOrderId);
      }

      return json(200, { shipment: data });
    }

    return json(405, { error: "Method not allowed" });
  } catch (err: any) {
    console.error("[admin-shipments] Unhandled error:", err);
    return json(500, { 
      error: err.message ?? "Internal error", 
      details: err.toString(),
      where: "admin-shipments",
      stack: err.stack?.substring(0, 500)
    });
  }
});
