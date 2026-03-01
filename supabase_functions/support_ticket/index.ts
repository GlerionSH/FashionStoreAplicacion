// Supabase Edge Function: support_ticket
// Triggered via database webhook on INSERT to fs_support_tickets
// OR called directly after insert from Flutter.
//
// Sends:
// 1) ACK email to the user who created the ticket
// 2) Notification email to the admin
//
// Environment variables needed:
//   BREVO_API_KEY - Brevo (Sendinblue) API key
//   ADMIN_EMAIL   - Admin email to receive notifications
//   FROM_EMAIL    - Sender email address
//   FROM_NAME     - Sender name

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const BREVO_API_KEY = Deno.env.get("BREVO_API_KEY") ?? "";
const ADMIN_EMAIL = Deno.env.get("ADMIN_EMAIL") ?? "admin@fashionstore.com";
const FROM_EMAIL = Deno.env.get("FROM_EMAIL") ?? "noreply@fashionstore.com";
const FROM_NAME = Deno.env.get("FROM_NAME") ?? "Fashion Store";

interface BrevoPayload {
  sender: { name: string; email: string };
  to: { email: string; name?: string }[];
  subject: string;
  htmlContent: string;
}

async function sendEmail(payload: BrevoPayload) {
  if (!BREVO_API_KEY) {
    console.warn("[support_ticket] BREVO_API_KEY not set, skipping email");
    return;
  }
  const res = await fetch("https://api.brevo.com/v3/smtp/email", {
    method: "POST",
    headers: {
      "api-key": BREVO_API_KEY,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });
  if (!res.ok) {
    const text = await res.text();
    console.error(`[support_ticket] Brevo error: ${res.status} ${text}`);
  }
}

serve(async (req) => {
  try {
    const body = await req.json();
    // Support both direct call and webhook trigger
    const record = body.record ?? body;

    const { id, name, email, subject, message } = record;
    if (!email || !subject) {
      return new Response(JSON.stringify({ error: "missing fields" }), {
        status: 400,
      });
    }

    // 1) ACK email to user
    await sendEmail({
      sender: { name: FROM_NAME, email: FROM_EMAIL },
      to: [{ email, name: name || undefined }],
      subject: `Hemos recibido tu consulta: ${subject}`,
      htmlContent: `
        <div style="font-family:sans-serif;max-width:600px;margin:0 auto">
          <h2 style="color:#111">Hemos recibido tu consulta</h2>
          <p>Hola ${name || ""},</p>
          <p>Hemos recibido tu mensaje con asunto <strong>${subject}</strong>.</p>
          <p>Te responderemos lo antes posible.</p>
          <hr style="border:none;border-top:1px solid #eee;margin:24px 0"/>
          <p style="color:#999;font-size:12px">Fashion Store - Soporte</p>
        </div>
      `,
    });

    // 2) Notification to admin
    await sendEmail({
      sender: { name: FROM_NAME, email: FROM_EMAIL },
      to: [{ email: ADMIN_EMAIL }],
      subject: `[Soporte] Nuevo ticket: ${subject}`,
      htmlContent: `
        <div style="font-family:sans-serif;max-width:600px;margin:0 auto">
          <h2 style="color:#111">Nuevo ticket de soporte</h2>
          <p><strong>De:</strong> ${name} (${email})</p>
          <p><strong>Asunto:</strong> ${subject}</p>
          <p><strong>Mensaje:</strong></p>
          <blockquote style="border-left:3px solid #ddd;padding-left:12px;color:#333">
            ${message}
          </blockquote>
          <p><strong>Ticket ID:</strong> ${id}</p>
        </div>
      `,
    });

    return new Response(JSON.stringify({ ok: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("[support_ticket] Error:", err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
    });
  }
});
