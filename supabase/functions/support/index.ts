// supabase/functions/support/index.ts
// Complete support system Edge Function with emails
// Actions: create_ticket, send_message, admin_reply, close_ticket

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const BREVO_API_KEY = Deno.env.get("BREVO_API_KEY") ?? "";
const ADMIN_EMAIL = Deno.env.get("ADMIN_EMAIL") ?? "";
const EMAIL_FROM = Deno.env.get("EMAIL_FROM") ?? "";
const EMAIL_FROM_NAME = Deno.env.get("EMAIL_FROM_NAME") ?? "Fashion Store";

interface EmailResult {
  ok: boolean;
  status: number;
  bodyText: string;
}

async function sendEmailBrevo(params: {
  to: string;
  subject: string;
  html: string;
  text: string;
}): Promise<EmailResult> {
  if (!BREVO_API_KEY || !EMAIL_FROM) {
    console.warn("[support] Email not configured");
    return { ok: false, status: 0, bodyText: "Email not configured" };
  }

  try {
    const res = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        "api-key": BREVO_API_KEY,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        sender: { name: EMAIL_FROM_NAME, email: EMAIL_FROM },
        to: [{ email: params.to }],
        subject: params.subject,
        htmlContent: params.html,
        textContent: params.text,
      }),
    });

    const bodyText = await res.text();
    return { ok: res.ok, status: res.status, bodyText };
  } catch (err: any) {
    console.error("[support] Email error:", err.message);
    return { ok: false, status: 0, bodyText: err.message };
  }
}

function renderEmailTemplate(params: {
  title: string;
  bodyHtml: string;
}): { html: string; text: string } {
  const { title, bodyHtml } = params;

  const html = `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
</head>
<body style="margin:0;padding:0;background-color:#f3f4f6;font-family:Arial,Helvetica,sans-serif;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f3f4f6;">
    <tr>
      <td align="center" style="padding:20px 10px;">
        <table role="presentation" width="600" cellpadding="0" cellspacing="0" border="0" style="width:100%;max-width:600px;background-color:#ffffff;border:1px solid #e5e7eb;border-radius:12px;">
          <tr>
            <td style="padding:32px 24px 16px 24px;text-align:center;">
              <h2 style="margin:0 0 4px 0;font-size:16px;font-weight:600;color:#111;letter-spacing:1px;">FASHION STORE</h2>
              <p style="margin:0;font-size:12px;color:#999;text-transform:uppercase;letter-spacing:0.5px;">${title}</p>
            </td>
          </tr>
          <tr>
            <td style="padding:0 24px 24px 24px;color:#333;font-size:15px;line-height:22px;">
              ${bodyHtml}
            </td>
          </tr>
          <tr>
            <td style="padding:24px;background-color:#f9fafb;border-top:1px solid #e5e7eb;text-align:center;">
              <p style="margin:0 0 8px 0;font-size:14px;color:#666;line-height:20px;">Gracias por contactarnos</p>
              <p style="margin:0;font-size:12px;color:#999;">Fashion Store | ${EMAIL_FROM}</p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `.trim();

  const text = `
${title}

${bodyHtml.replace(/<[^>]*>/g, "").replace(/&nbsp;/g, " ").trim()}

Gracias por contactarnos
Fashion Store | ${EMAIL_FROM}
  `.trim();

  return { html, text };
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  try {
    const { action, ...params } = await req.json();

    // ── ACTION: create_ticket ──
    if (action === "create_ticket") {
      const { name, email, subject, message, user_id } = params;

      if (!email || !subject || !message) {
        return new Response(
          JSON.stringify({ error: "Missing required fields" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      console.log(`[support] Creating ticket: ${subject} from ${email}`);

      // Create ticket
      const { data: ticket, error: ticketError } = await supabase
        .from("fs_support_tickets")
        .insert({
          user_id: user_id || null,
          name: name || "",
          email,
          subject,
          message,
          status: "open",
          last_message_at: new Date().toISOString(),
        })
        .select()
        .single();

      if (ticketError) {
        console.error("[support] Ticket creation failed:", ticketError.message);
        throw ticketError;
      }

      console.log(`[support] Ticket created: ${ticket.id}`);

      // Send email to user (confirmation)
      const userEmailBody = `
        <p>Hola ${name || ""},</p>
        <p>Hemos recibido tu consulta con asunto <strong>${subject}</strong>.</p>
        <p><strong>Tu mensaje:</strong></p>
        <blockquote style="border-left:3px solid #ddd;padding-left:12px;margin:12px 0;color:#555;">
          ${message.replace(/\n/g, "<br>")}
        </blockquote>
        <p>Te responderemos lo antes posible a tu email <strong>${email}</strong>.</p>
        <p style="margin-top:20px;font-size:13px;color:#999;">Ticket ID: ${ticket.id.substring(0, 8)}</p>
      `;

      const userEmailTemplate = renderEmailTemplate({
        title: "CONSULTA RECIBIDA",
        bodyHtml: userEmailBody,
      });

      const userEmailResult = await sendEmailBrevo({
        to: email,
        subject: `Hemos recibido tu consulta: ${subject}`,
        html: userEmailTemplate.html,
        text: userEmailTemplate.text,
      });

      if (!userEmailResult.ok) {
        console.error(`[support] User email failed: ${userEmailResult.status} ${userEmailResult.bodyText}`);
      } else {
        console.log(`[support] User confirmation email sent to ${email}`);
      }

      // Send email to admin (notification)
      if (ADMIN_EMAIL) {
        const adminEmailBody = `
          <p><strong>Nuevo ticket de soporte</strong></p>
          <p><strong>De:</strong> ${name || "Sin nombre"} (${email})</p>
          <p><strong>Asunto:</strong> ${subject}</p>
          <p><strong>Mensaje:</strong></p>
          <blockquote style="border-left:3px solid #ddd;padding-left:12px;margin:12px 0;color:#333;">
            ${message.replace(/\n/g, "<br>")}
          </blockquote>
          <p style="margin-top:20px;font-size:13px;color:#999;">Ticket ID: ${ticket.id}</p>
        `;

        const adminEmailTemplate = renderEmailTemplate({
          title: "NUEVO TICKET",
          bodyHtml: adminEmailBody,
        });

        const adminEmailResult = await sendEmailBrevo({
          to: ADMIN_EMAIL,
          subject: `[Soporte] Nuevo ticket: ${subject}`,
          html: adminEmailTemplate.html,
          text: adminEmailTemplate.text,
        });

        if (!adminEmailResult.ok) {
          console.error(`[support] Admin email failed: ${adminEmailResult.status} ${adminEmailResult.bodyText}`);
        } else {
          console.log(`[support] Admin notification sent to ${ADMIN_EMAIL}`);
        }
      }

      return new Response(
        JSON.stringify({ ok: true, ticket_id: ticket.id }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── ACTION: send_message ──
    if (action === "send_message") {
      const { ticket_id, author, body, user_id } = params;

      if (!ticket_id || !author || !body) {
        return new Response(
          JSON.stringify({ error: "Missing required fields" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      console.log(`[support] Sending message on ticket ${ticket_id} from ${author}`);

      // Get ticket info
      const { data: ticket, error: ticketError } = await supabase
        .from("fs_support_tickets")
        .select("*")
        .eq("id", ticket_id)
        .single();

      if (ticketError || !ticket) {
        return new Response(
          JSON.stringify({ error: "Ticket not found" }),
          { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Verify ownership if user
      if (author === "user" && user_id && ticket.user_id !== user_id) {
        return new Response(
          JSON.stringify({ error: "Unauthorized" }),
          { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Insert reply
      const replyPayload = {
        ticket_id,
        author,
        reply_text: body,
      };
      
      console.log("[support] Inserting reply with payload keys:", Object.keys(replyPayload));
      
      const { data: reply, error: replyError } = await supabase
        .from("fs_support_replies")
        .insert(replyPayload)
        .select()
        .single();

      if (replyError) {
        console.error("[support] Reply creation failed:", {
          message: replyError.message,
          code: replyError.code,
          details: replyError.details,
          hint: replyError.hint,
          table: "fs_support_replies",
          payload_keys: Object.keys(replyPayload),
        });
        return new Response(
          JSON.stringify({ 
            error: "Failed to create reply", 
            details: replyError.message,
            code: replyError.code 
          }),
          { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      console.log("[support] Reply inserted OK, reply_id:", reply.id);

      // Update ticket status and last_message_at
      const newStatus = author === "admin" ? "pending" : "open";
      const { error: updateError } = await supabase
        .from("fs_support_tickets")
        .update({
          status: newStatus,
          last_message_at: new Date().toISOString(),
        })
        .eq("id", ticket_id);

      if (updateError) {
        console.error("[support] Ticket update failed:", updateError.message);
      }

      console.log(`[support] Reply created: ${reply.id}`);

      // Send email notification
      if (author === "admin") {
        // Admin replied -> notify user
        const emailBody = `
          <p>Hola ${ticket.name || ""},</p>
          <p>Hemos respondido a tu consulta <strong>${ticket.subject}</strong>.</p>
          <p><strong>Respuesta del equipo:</strong></p>
          <blockquote style="border-left:3px solid #ddd;padding-left:12px;margin:12px 0;color:#333;">
            ${body.replace(/\n/g, "<br>")}
          </blockquote>
          <p>Si tienes más preguntas, puedes responder desde la app.</p>
          <p style="margin-top:20px;font-size:13px;color:#999;">Ticket ID: ${ticket_id.substring(0, 8)}</p>
        `;

        const emailTemplate = renderEmailTemplate({
          title: "RESPUESTA A TU CONSULTA",
          bodyHtml: emailBody,
        });

        const emailResult = await sendEmailBrevo({
          to: ticket.email,
          subject: `Respuesta a: ${ticket.subject}`,
          html: emailTemplate.html,
          text: emailTemplate.text,
        });

        if (!emailResult.ok) {
          console.error(`[support] User notification failed: ${emailResult.status} ${emailResult.bodyText}`);
        } else {
          console.log(`[support] User notification sent to ${ticket.email}`);
        }
      } else if (author === "user" && ADMIN_EMAIL) {
        // User replied -> notify admin
        const emailBody = `
          <p><strong>Nuevo mensaje del usuario en ticket</strong></p>
          <p><strong>De:</strong> ${ticket.name || "Sin nombre"} (${ticket.email})</p>
          <p><strong>Asunto:</strong> ${ticket.subject}</p>
          <p><strong>Mensaje:</strong></p>
          <blockquote style="border-left:3px solid #ddd;padding-left:12px;margin:12px 0;color:#333;">
            ${body.replace(/\n/g, "<br>")}
          </blockquote>
          <p style="margin-top:20px;font-size:13px;color:#999;">Ticket ID: ${ticket_id}</p>
        `;

        const emailTemplate = renderEmailTemplate({
          title: "NUEVO MENSAJE",
          bodyHtml: emailBody,
        });

        const emailResult = await sendEmailBrevo({
          to: ADMIN_EMAIL,
          subject: `[Soporte] Nuevo mensaje en: ${ticket.subject}`,
          html: emailTemplate.html,
          text: emailTemplate.text,
        });

        if (!emailResult.ok) {
          console.error(`[support] Admin notification failed: ${emailResult.status} ${emailResult.bodyText}`);
        } else {
          console.log(`[support] Admin notification sent to ${ADMIN_EMAIL}`);
        }
      }

      return new Response(
        JSON.stringify({ ok: true, reply_id: reply.id }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── ACTION: close_ticket ──
    if (action === "close_ticket") {
      const { ticket_id } = params;

      if (!ticket_id) {
        return new Response(
          JSON.stringify({ error: "Missing ticket_id" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const { error: updateError } = await supabase
        .from("fs_support_tickets")
        .update({ status: "closed" })
        .eq("id", ticket_id);

      if (updateError) {
        console.error("[support] Close ticket failed:", updateError.message);
        throw updateError;
      }

      console.log(`[support] Ticket closed: ${ticket_id}`);

      return new Response(
        JSON.stringify({ ok: true }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ error: "Unknown action" }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    console.error("[support] Error:", err);
    return new Response(
      JSON.stringify({ error: err.message || String(err) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
