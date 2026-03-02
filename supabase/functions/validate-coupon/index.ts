// supabase/functions/validate-coupon/index.ts
// Client calls this to validate a coupon code before/during checkout.
// POST { code, order_cents, user_id? }
// Returns { valid, percent_off, discount_cents, message? }

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

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const { code, order_cents } = await req.json();
    if (!code || typeof code !== "string") return json(400, { error: "code is required" });
    if (!order_cents || typeof order_cents !== "number") return json(400, { error: "order_cents is required" });

    // Extract user info from JWT (optional — guest checkout allowed)
    const authHeader = req.headers.get("authorization") || "";
    let userId: string | null = null;
    let userEmail: string | null = null;
    if (authHeader.startsWith("Bearer ")) {
      const payload = decodeJwtPayload(authHeader.replace("Bearer ", ""));
      userId = (payload?.sub as string) ?? null;
      userEmail = (payload?.email as string) ?? null;
    }

    const upperCode = code.trim().toUpperCase();

    // 1. Fetch coupon
    const { data: coupon, error: couponErr } = await supabase
      .from("fs_coupons")
      .select("*")
      .eq("code", upperCode)
      .eq("active", true)
      .maybeSingle();

    if (couponErr) {
      console.error("[validate-coupon] DB error:", couponErr.message);
      return json(500, { valid: false, message: "Error interno" });
    }
    if (!coupon) return json(200, { valid: false, message: "Código no válido o inactivo" });

    // 2. Date check
    const now = new Date();
    if (coupon.starts_at && new Date(coupon.starts_at) > now) {
      return json(200, { valid: false, message: "El cupón aún no está activo" });
    }
    if (coupon.ends_at && new Date(coupon.ends_at) < now) {
      return json(200, { valid: false, message: "El cupón ha expirado" });
    }

    // 3. Minimum order
    if (coupon.min_order_cents && order_cents < coupon.min_order_cents) {
      const minEur = (coupon.min_order_cents / 100).toFixed(2);
      return json(200, {
        valid: false,
        message: `Pedido mínimo: ${minEur} €`,
      });
    }

    // 4. Global redemption limit
    if (coupon.max_redemptions !== null) {
      const { count } = await supabase
        .from("fs_coupon_redemptions")
        .select("id", { count: "exact", head: true })
        .eq("coupon_id", coupon.id);

      if ((count ?? 0) >= coupon.max_redemptions) {
        return json(200, { valid: false, message: "El cupón ya alcanzó el límite de usos" });
      }
    }

    // 5. Per-user limit (hard check — 1 per user regardless of max_redemptions_per_user)
    if (userId || userEmail) {
      let q = supabase
        .from("fs_coupon_redemptions")
        .select("id", { count: "exact", head: true })
        .eq("coupon_id", coupon.id);

      if (userId) q = q.eq("user_id", userId);
      else if (userEmail) q = q.eq("email", userEmail);

      const { count: perUserCount } = await q;

      // Enforce max_redemptions_per_user if set, otherwise default to 1
      const maxPerUser = coupon.max_redemptions_per_user ?? 1;
      if ((perUserCount ?? 0) >= maxPerUser) {
        console.log(`[validate-coupon] user=${userId ?? userEmail} already redeemed ${upperCode} (${perUserCount}/${maxPerUser})`);
        return json(409, { valid: false, message: "Ya usaste este cupón" });
      }
    }

    // 6. Compute discount
    const discount_cents = Math.floor(order_cents * coupon.percent_off / 100);

    console.log(
      `[validate-coupon] code=${upperCode} percent=${coupon.percent_off}% ` +
      `order_cents=${order_cents} discount_cents=${discount_cents} user=${userId ?? userEmail ?? "guest"}`
    );

    return json(200, {
      valid: true,
      coupon_id: coupon.id,
      code: upperCode,
      percent_off: coupon.percent_off,
      discount_cents,
    });
  } catch (err: any) {
    console.error("[validate-coupon] unhandled:", err);
    return json(500, { valid: false, message: "Error interno" });
  }
});
