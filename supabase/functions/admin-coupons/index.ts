// supabase/functions/admin-coupons/index.ts
// Admin CRUD for coupons + list redemptions.
// GET  ?action=list                   → list coupons
// GET  ?action=redemptions&coupon_id= → list redemptions for a coupon
// POST { action:'create', ...fields } → create coupon
// PATCH{ action:'update', id, ...fields } → update coupon
// DELETE { action:'delete', id }      → delete coupon (only if no redemptions)

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
  const { data } = await supabase
    .from("fs_profiles")
    .select("role")
    .eq("id", userId)
    .maybeSingle();
  return data?.role === "admin";
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  if (!(await verifyAdmin(req, supabase))) {
    return json(403, { error: "Forbidden" });
  }

  try {
    const url = new URL(req.url);

    // ── GET ──
    if (req.method === "GET") {
      const action = url.searchParams.get("action") ?? "list";

      if (action === "redemptions") {
        const couponId = url.searchParams.get("coupon_id");
        if (!couponId) return json(400, { error: "coupon_id required" });
        const { data, error } = await supabase
          .from("fs_coupon_redemptions")
          .select("*")
          .eq("coupon_id", couponId)
          .order("redeemed_at", { ascending: false });
        if (error) return json(500, { error: error.message });
        return json(200, { redemptions: data ?? [] });
      }

      // list coupons - query in 2 steps to avoid FK requirement
      const { data: coupons, error } = await supabase
        .from("fs_coupons")
        .select("*")
        .order("created_at", { ascending: false });
      if (error) return json(500, { error: error.message });

      // Fetch redemption counts separately
      const couponIds = (coupons ?? []).map((c: any) => c.id);
      let countsMap: Record<string, number> = {};
      if (couponIds.length > 0) {
        const { data: redemptions } = await supabase
          .from("fs_coupon_redemptions")
          .select("coupon_id");
        if (redemptions) {
          // Count by coupon_id
          const counts: Record<string, number> = {};
          for (const r of redemptions as any[]) {
            counts[r.coupon_id] = (counts[r.coupon_id] || 0) + 1;
          }
          countsMap = counts;
        }
      }

      // Merge
      const enriched = (coupons ?? []).map((c: any) => ({
        ...c,
        redemptions_count: [{ count: countsMap[c.id] || 0 }],
      }));

      return json(200, { coupons: enriched });
    }

    // ── POST (create) ──
    if (req.method === "POST") {
      const body = await req.json();
      const { code, percent_off, active, starts_at, ends_at,
              max_redemptions, max_redemptions_per_user, min_order_cents,
              applies_to, notes } = body;

      if (!code || !percent_off) return json(400, { error: "code and percent_off required" });
      const upperCode = String(code).trim().toUpperCase();

      const { data, error } = await supabase
        .from("fs_coupons")
        .insert({
          code: upperCode,
          percent_off: Number(percent_off),
          active: active !== false,
          starts_at: starts_at ?? null,
          ends_at: ends_at ?? null,
          max_redemptions: max_redemptions ?? null,
          max_redemptions_per_user: max_redemptions_per_user ?? null,
          min_order_cents: min_order_cents ?? null,
          applies_to: applies_to ?? "all",
          notes: notes ?? null,
        })
        .select()
        .single();

      if (error) return json(400, { error: error.message });
      return json(201, { coupon: data });
    }

    // ── PATCH (update) ──
    if (req.method === "PATCH") {
      const body = await req.json();
      const { id, ...fields } = body;
      if (!id) return json(400, { error: "id required" });

      const allowed = ["percent_off","active","starts_at","ends_at",
                       "max_redemptions","max_redemptions_per_user",
                       "min_order_cents","applies_to","notes","code"];
      const update: Record<string, unknown> = {};
      for (const k of allowed) {
        if (k in fields) {
          update[k] = fields[k];
        }
      }
      if (update.code) update.code = String(update.code).trim().toUpperCase();

      const { data, error } = await supabase
        .from("fs_coupons")
        .update(update)
        .eq("id", id)
        .select()
        .single();

      if (error) return json(400, { error: error.message });
      return json(200, { coupon: data });
    }

    // ── DELETE ──
    if (req.method === "DELETE") {
      const body = await req.json();
      const { id } = body;
      if (!id) return json(400, { error: "id required" });

      // Check if has redemptions
      const { count } = await supabase
        .from("fs_coupon_redemptions")
        .select("id", { count: "exact", head: true })
        .eq("coupon_id", id);

      if ((count ?? 0) > 0) {
        return json(409, { error: "Cannot delete coupon with existing redemptions. Deactivate it instead." });
      }

      const { error } = await supabase.from("fs_coupons").delete().eq("id", id);
      if (error) return json(400, { error: error.message });
      return json(200, { ok: true });
    }

    return json(405, { error: "Method not allowed" });
  } catch (err: any) {
    console.error("[admin-coupons] error:", err);
    return json(500, { error: err.message ?? "Internal error" });
  }
});
