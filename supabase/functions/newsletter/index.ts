// supabase/functions/newsletter/index.ts
// Subscribe / unsubscribe to newsletter.
// POST { email, action: 'subscribe'|'unsubscribe', user_id? }
// On first-time subscribe: generate welcome coupon + send welcome email.

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

function generateCouponCode(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let code = "WELCOME-";
  for (let i = 0; i < 6; i++) code += chars[Math.floor(Math.random() * chars.length)];
  return code;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const brevoApiKey = Deno.env.get("BREVO_API_KEY") ?? "";
  const emailFrom = Deno.env.get("EMAIL_FROM") ?? "";
  const emailFromName = Deno.env.get("EMAIL_FROM_NAME") ?? "Fashion Store";
  const welcomeCouponPercent = parseInt(Deno.env.get("NEWSLETTER_COUPON_PERCENT") ?? "10", 10);

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  // Optional JWT for user_id
  const authHeader = req.headers.get("authorization") || "";
  let userId: string | null = null;
  if (authHeader.startsWith("Bearer ")) {
    const payload = decodeJwtPayload(authHeader.replace("Bearer ", ""));
    userId = (payload?.sub as string) ?? null;
  }

  try {
    const { email, action } = await req.json();
    if (!email || typeof email !== "string") return json(400, { error: "email required" });
    if (!["subscribe", "unsubscribe"].includes(action)) return json(400, { error: "action must be subscribe or unsubscribe" });

    const normalEmail = email.trim().toLowerCase();

    if (action === "unsubscribe") {
      const { error } = await supabase
        .from("fs_newsletter_subscribers")
        .update({ is_active: false, unsubscribed_at: new Date().toISOString() })
        .eq("email", normalEmail);

      if (error) return json(500, { error: error.message });
      return json(200, { ok: true, subscribed: false });
    }

    // action === "subscribe"
    // Check existing
    const { data: existing } = await supabase
      .from("fs_newsletter_subscribers")
      .select("id, is_active, welcome_coupon_code")
      .eq("email", normalEmail)
      .maybeSingle();

    if (existing?.is_active) {
      return json(200, { ok: true, subscribed: true, already: true });
    }

    let couponCode: string | null = null;
    const isFirstTime = !existing;

    if (isFirstTime) {
      // Generate unique welcome coupon
      couponCode = generateCouponCode();
      let attempts = 0;
      while (attempts < 10) {
        const { count } = await supabase
          .from("fs_coupons")
          .select("id", { count: "exact", head: true })
          .eq("code", couponCode);
        if ((count ?? 0) === 0) break;
        couponCode = generateCouponCode();
        attempts++;
      }

      // Create coupon in DB (1 use only, valid for 1 year)
      const expiresAt = new Date();
      expiresAt.setFullYear(expiresAt.getFullYear() + 1);

      await supabase.from("fs_coupons").insert({
        code: couponCode,
        percent_off: welcomeCouponPercent,
        active: true,
        ends_at: expiresAt.toISOString(),
        max_redemptions: 1,
        max_redemptions_per_user: 1,
        applies_to: "all",
        notes: `Welcome coupon for ${normalEmail}`,
      });
    } else {
      couponCode = existing.welcome_coupon_code;
    }

    // Upsert subscriber
    await supabase.from("fs_newsletter_subscribers").upsert({
      email: normalEmail,
      user_id: userId ?? null,
      is_active: true,
      subscribed_at: new Date().toISOString(),
      unsubscribed_at: null,
      welcome_coupon_code: couponCode,
    }, { onConflict: "email" });

    // Send welcome email with coupon
    if (isFirstTime && brevoApiKey && emailFrom && couponCode) {
      const html = `
        <div style="font-family:Helvetica,Arial,sans-serif;max-width:600px;margin:0 auto;color:#111">
          <h2 style="font-weight:300;letter-spacing:2px;text-align:center">FASHION STORE</h2>
          <p>Hola,</p>
          <p>Bienvenid@ a la comunidad Fashion Store. Gracias por suscribirte a nuestro newsletter.</p>
          <p>Como regalo de bienvenida, aquí tienes tu cupón exclusivo de <strong>${welcomeCouponPercent}% de descuento</strong>:</p>
          <div style="text-align:center;margin:32px 0">
            <span style="display:inline-block;background:#111;color:#fff;padding:16px 32px;font-size:22px;letter-spacing:4px;font-weight:300">
              ${couponCode}
            </span>
          </div>
          <p>Aplícalo en el checkout en tu próxima compra.</p>
          <p style="font-size:12px;color:#999">Válido 1 año. Un solo uso por cuenta.</p>
        </div>`;

      await fetch("https://api.brevo.com/v3/smtp/email", {
        method: "POST",
        headers: { "api-key": brevoApiKey, "Content-Type": "application/json" },
        body: JSON.stringify({
          sender: { name: emailFromName, email: emailFrom },
          to: [{ email: normalEmail }],
          subject: `Bienvenid@ a Fashion Store — Tu cupón ${welcomeCouponPercent}% descuento`,
          htmlContent: html,
        }),
      });

      await supabase.from("fs_email_events").insert({
        event_type: "newsletter_welcome",
        recipient_email: normalEmail,
        metadata: { coupon_code: couponCode },
      });
    }

    console.log(`[newsletter] Subscribed ${normalEmail} coupon=${couponCode ?? "existing"}`);
    return json(200, {
      ok: true,
      subscribed: true,
      coupon_code: isFirstTime ? couponCode : null,
      coupon_percent: isFirstTime ? welcomeCouponPercent : null,
    });
  } catch (err: any) {
    console.error("[newsletter] error:", err);
    return json(500, { error: err.message ?? "Internal error" });
  }
});
