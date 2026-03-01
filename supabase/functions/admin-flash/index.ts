// supabase/functions/admin-flash/index.ts
// GET   → list flash offers ordered by updated_at desc
// POST  → upsert offer (disables others if is_enabled=true)
// PATCH → toggle is_enabled on one offer
// DELETE → delete offer (id in body)
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

    // ── GET: list offers ──
    if (req.method === "GET") {
      const { data, error } = await sb
        .from("fs_flash_offers")
        .select(
          "id,is_enabled,discount_percent,starts_at,ends_at,show_popup,popup_title,popup_text,updated_at",
        )
        .order("updated_at", { ascending: false });
      if (error) return json(500, { error: error.message });
      return json(200, { offers: data ?? [] });
    }

    // ── POST: upsert/create offer ──
    if (req.method === "POST") {
      const body = await req.json() as Record<string, unknown>;
      const offerId = body.id as string | undefined;
      const isEnabled = Boolean(body.is_enabled);

      // Astro rule: only one offer enabled at a time
      if (isEnabled) {
        if (offerId) {
          await sb.from("fs_flash_offers").update({ is_enabled: false }).neq("id", offerId);
        } else {
          await sb.from("fs_flash_offers").update({ is_enabled: false });
        }
      }

      const discountRaw = Number(body.discount_percent ?? 0);
      const payload: Record<string, unknown> = {
        discount_percent: Math.max(0, Math.min(90, Math.trunc(isFinite(discountRaw) ? discountRaw : 0))),
        is_enabled: isEnabled,
        show_popup: Boolean(body.show_popup),
        popup_title: (body.popup_title as string | null) || null,
        popup_text: (body.popup_text as string | null) || null,
        starts_at: (body.starts_at as string | null) || null,
        ends_at: (body.ends_at as string | null) || null,
      };
      if (offerId) payload.id = offerId;

      const { data, error } = await sb
        .from("fs_flash_offers")
        .upsert(payload, { onConflict: "id" })
        .select()
        .single();
      if (error) return json(500, { error: error.message });
      return json(200, { offer: data });
    }

    // ── PATCH: toggle is_enabled ──
    if (req.method === "PATCH") {
      const body = await req.json() as { id?: string; is_enabled?: boolean };
      if (!body.id) return json(400, { error: "missing id" });
      const isEnabled = Boolean(body.is_enabled);

      if (isEnabled) {
        await sb.from("fs_flash_offers").update({ is_enabled: false }).neq("id", body.id);
      }
      const { error } = await sb
        .from("fs_flash_offers")
        .update({ is_enabled: isEnabled })
        .eq("id", body.id);
      if (error) return json(500, { error: error.message });
      return json(200, { ok: true });
    }

    // ── DELETE: delete offer (id in body) ──
    if (req.method === "DELETE") {
      const body = await req.json() as { id?: string };
      if (!body.id) return json(400, { error: "missing id" });
      const { error } = await sb.from("fs_flash_offers").delete().eq("id", body.id);
      if (error) return json(500, { error: error.message });
      return json(200, { ok: true });
    }

    return json(405, { error: "method_not_allowed" });
  } catch (err) {
    console.error("[admin-flash]", err);
    return json(500, { error: "server_error", details: String(err) });
  }
});
