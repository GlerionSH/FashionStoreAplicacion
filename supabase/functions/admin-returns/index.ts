// supabase/functions/admin-returns/index.ts
// GET  → list returns ordered by requested_at desc
// PATCH → update return status (approve / reject / refunded)
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

    // ── GET: list returns OR get single return detail ──
    if (req.method === "GET") {
      const url = new URL(req.url);
      const returnId = url.searchParams.get("return_id");

      // Single return detail
      if (returnId) {
        const { data: returnData, error: retErr } = await sb
          .from("fs_returns")
          .select("*")
          .eq("id", returnId)
          .maybeSingle();

        if (retErr) {
          console.error("[admin-returns] GET detail error", retErr);
          return json(500, { error: retErr.message });
        }
        if (!returnData) return json(404, { error: "return_not_found" });

        // Fetch order separately (no implicit join)
        const orderId = returnData.order_id;
        let orderData = null;
        if (orderId) {
          const { data: ord } = await sb
            .from("fs_orders")
            .select("id,email,total_cents,status,created_at")
            .eq("id", orderId)
            .maybeSingle();
          orderData = ord;
        }

        // Fetch return items if table exists
        let items = [];
        const { data: itemsData } = await sb
          .from("fs_return_items")
          .select("*")
          .eq("return_id", returnId);
        if (itemsData) items = itemsData;

        return json(200, {
          return: {
            ...returnData,
            order: orderData,
            items,
          },
        });
      }

      // List returns
      const limit = Math.min(
        parseInt(url.searchParams.get("limit") ?? "50", 10) || 50,
        100,
      );
      const statusFilter = url.searchParams.get("status") ?? null;

      let query = sb
        .from("fs_returns")
        .select(
          "id,order_id,user_id,status,reason,requested_at,reviewed_at,refunded_at,refund_method,refund_total_cents,notes",
        )
        .order("requested_at", { ascending: false })
        .limit(limit);

      if (statusFilter) query = query.eq("status", statusFilter);

      const { data, error } = await query;
      if (error) {
        console.error("[admin-returns] GET error", error);
        return json(500, { error: error.message });
      }
      return json(200, { returns: data ?? [] });
    }

    // ── PATCH: update return status ──
    if (req.method === "PATCH") {
      const body = await req.json();
      const { return_id, status } = body as { return_id?: string; status?: string };
      if (!return_id || !status) {
        return json(400, { error: "missing return_id or status" });
      }
      const allowed = ["approved", "rejected", "refunded", "cancelled"];
      if (!allowed.includes(status)) {
        return json(400, { error: `invalid status '${status}'` });
      }

      const patch: Record<string, unknown> = {
        status,
        reviewed_by: user.id,
        reviewed_at: new Date().toISOString(),
      };
      if (status === "refunded") patch.refunded_at = new Date().toISOString();

      const { error } = await sb
        .from("fs_returns")
        .update(patch)
        .eq("id", return_id);
      if (error) return json(500, { error: error.message });
      return json(200, { ok: true });
    }

    return json(405, { error: "method_not_allowed" });
  } catch (err) {
    console.error("[admin-returns]", err);
    return json(500, { error: "server_error", details: String(err) });
  }
});
