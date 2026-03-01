// supabase/functions/admin-metrics/index.ts
// Returns admin dashboard stats: paid orders, gross/net revenue, returns loss,
// pending returns, active products, recent orders.
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
    // ── Admin client (service_role – stays server-side) ──
    const sb = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
      { auth: { persistSession: false, autoRefreshToken: false } },
    );

    // ── Verify caller is authenticated ──
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json(401, { error: "unauthorized" });
    const token = authHeader.split(" ")[1];
    const { data: { user }, error: authErr } = await sb.auth.getUser(token);
    if (authErr || !user) return json(401, { error: "unauthorized" });

    // ── Verify caller is admin ──
    const { data: profile } = await sb
      .from("fs_profiles")
      .select("role")
      .eq("id", user.id)
      .maybeSingle();
    if (!profile || profile.role !== "admin") return json(403, { error: "forbidden" });

    // ── Paid orders: count + gross revenue ──
    const { data: paidOrders } = await sb
      .from("fs_orders")
      .select("total_cents")
      .eq("status", "paid");
    const paidList = (paidOrders ?? []) as { total_cents: number }[];
    const totalOrders = paidList.length;
    const revenueCents = paidList.reduce((s, o) => s + (o.total_cents ?? 0), 0);

    // ── Returns loss: sum refund_total_cents where status='refunded' ──
    const { data: refunds } = await sb
      .from("fs_returns")
      .select("refund_total_cents")
      .eq("status", "refunded");
    const returnsLossCents = ((refunds ?? []) as { refund_total_cents: number }[])
      .reduce((s, r) => s + (r.refund_total_cents ?? 0), 0);
    const netRevenueCents = Math.max(0, revenueCents - returnsLossCents);

    // ── Pending returns (status='requested' OR 'pending') ──
    const { count: pendingReturns } = await sb
      .from("fs_returns")
      .select("id", { count: "exact", head: true })
      .in("status", ["requested", "pending"]);

    // ── Active products ──
    const { count: activeProducts } = await sb
      .from("fs_products")
      .select("id", { count: "exact", head: true })
      .eq("is_active", true);

    // ── Recent orders (last 10) ──
    const { data: recentOrders } = await sb
      .from("fs_orders")
      .select("id,email,status,total_cents,created_at")
      .order("id", { ascending: false })
      .limit(10);

    return json(200, {
      total_orders: totalOrders,
      revenue_cents: revenueCents,
      returns_loss_cents: returnsLossCents,
      net_revenue_cents: netRevenueCents,
      pending_returns: pendingReturns ?? 0,
      active_products: activeProducts ?? 0,
      recent_orders: recentOrders ?? [],
    });
  } catch (err) {
    console.error("[admin-metrics]", err);
    return json(500, { error: "server_error", details: String(err) });
  }
});
