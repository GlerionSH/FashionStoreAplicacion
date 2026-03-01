// supabase/functions/admin-orders/index.ts
// GET  ?limit=50&offset=0          → paginated orders list
// GET  ?order_id=<uuid>            → single order detail
// PATCH                            → update order status {order_id, status}
// Requires: caller is authenticated + fs_profiles.role = 'admin'

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const json = (status: number, data: unknown) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const sb = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
      { auth: { persistSession: false, autoRefreshToken: false } },
    );

    // ── Verify caller ──
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json(401, { error: "unauthorized" });
    const token = authHeader.split(" ")[1];
    const { data: { user }, error: authErr } = await sb.auth.getUser(token);
    if (authErr || !user) return json(401, { error: "unauthorized" });

    const { data: profile } = await sb
      .from("fs_profiles")
      .select("role")
      .eq("id", user.id)
      .maybeSingle();
    if (!profile || profile.role !== "admin") return json(403, { error: "forbidden" });

    // ── GET ──
    if (req.method === "GET") {
      const url = new URL(req.url);
      const orderId = url.searchParams.get("order_id");

      // Single order detail
      if (orderId) {
        const { data, error } = await sb
          .from("fs_orders")
          .select("*")
          .eq("id", orderId)
          .single();
        if (error) return json(error.code === "PGRST116" ? 404 : 500, { error: error.message });
        return json(200, { order: data });
      }

      // List orders
      const limit = Math.min(parseInt(url.searchParams.get("limit") ?? "50", 10) || 50, 100);
      const offset = Math.max(0, parseInt(url.searchParams.get("offset") ?? "0", 10) || 0);

      const { data, error } = await sb
        .from("fs_orders")
        .select("id,email,status,total_cents,created_at,paid_at")
        .order("id", { ascending: false })
        .range(offset, offset + limit - 1);
      if (error) return json(500, { error: error.message });
      return json(200, { orders: data ?? [] });
    }

    // ── PATCH: update order status ──
    if (req.method === "PATCH") {
      const body = await req.json() as { order_id?: string; status?: string };
      if (!body.order_id || !body.status) {
        return json(400, { error: "missing order_id or status" });
      }
      const { error } = await sb
        .from("fs_orders")
        .update({ status: body.status })
        .eq("id", body.order_id);
      if (error) return json(500, { error: error.message });
      return json(200, { ok: true });
    }

    return json(405, { error: "method_not_allowed" });
  } catch (err) {
    console.error("[admin-orders]", err);
    return json(500, { error: "server_error", details: String(err) });
  }
});
