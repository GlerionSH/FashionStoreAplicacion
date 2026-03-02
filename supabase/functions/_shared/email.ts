// supabase/functions/_shared/email.ts
// Shared email helper for Brevo SMTP API (Deno compatible)

export interface EmailOptions {
  to: string;
  subject: string;
  html: string;
  text?: string;
}

export interface EmailResult {
  ok: boolean;
  status: number;
  bodyText: string;
}

export async function sendEmailBrevo(options: EmailOptions): Promise<EmailResult> {
  const brevoApiKey = Deno.env.get("BREVO_API_KEY");
  const emailFrom = Deno.env.get("EMAIL_FROM");
  const emailFromName = Deno.env.get("EMAIL_FROM_NAME") ?? "Fashion Store";

  if (!brevoApiKey || !emailFrom) {
    console.warn("[email] Missing BREVO_API_KEY or EMAIL_FROM - skipping email");
    return { ok: false, status: 0, bodyText: "Missing env vars" };
  }

  try {
    const resp = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        "api-key": brevoApiKey,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        sender: { name: emailFromName, email: emailFrom },
        to: [{ email: options.to }],
        subject: options.subject,
        htmlContent: options.html,
        textContent: options.text,
      }),
    });

    const bodyText = await resp.text();

    if (!resp.ok) {
      console.error(`[email] Brevo API error ${resp.status} to ${options.to}:`, bodyText);
      return { ok: false, status: resp.status, bodyText };
    }

    console.log(`[email] Sent to ${options.to}: ${options.subject}`);
    return { ok: true, status: resp.status, bodyText };
  } catch (err: any) {
    console.error("[email] Send error:", err.message);
    return { ok: false, status: 0, bodyText: err.message };
  }
}
