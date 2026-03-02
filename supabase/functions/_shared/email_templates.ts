// supabase/functions/_shared/email_templates.ts
// Responsive mobile-friendly email templates for transactional emails.
// Uses table-based layout with inline styles for maximum compatibility (Gmail, Outlook, etc).

export interface EmailTemplateParams {
  title: string;
  bodyHtml: string;
  buttonText?: string;
  buttonUrl?: string;
  footerText?: string;
  brandLogoUrl: string;
  storeName: string;
  supportEmail: string;
}

/**
 * Renders a responsive email with banner, title, body, optional CTA button, and footer.
 * Compatible with Gmail mobile app and major email clients.
 */
export function renderEmailBase(params: EmailTemplateParams): { html: string; text: string } {
  const {
    title,
    bodyHtml,
    buttonText,
    buttonUrl,
    footerText,
    brandLogoUrl,
    storeName,
    supportEmail,
  } = params;

  // HTML version - Gmail mobile friendly (NO media queries, pure inline styles + tables)
  const html = `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
</head>
<body style="margin:0;padding:0;background-color:#f3f4f6;font-family:Arial,Helvetica,sans-serif;">
  <!-- Outer wrapper -->
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:#f3f4f6;">
    <tr>
      <td align="center" style="padding:20px 10px;">
        
        <!-- Inner container (600px max, 100% on mobile) -->
        <table role="presentation" width="600" cellpadding="0" cellspacing="0" border="0" style="width:100%;max-width:600px;background-color:#ffffff;border:1px solid #e5e7eb;border-radius:12px;">
          
          <!-- Header (NO IMAGE - clean text) -->
          <tr>
            <td style="padding:32px 24px 16px 24px;text-align:center;">
              <h2 style="margin:0 0 4px 0;font-size:16px;font-weight:600;color:#111;letter-spacing:1px;">${storeName.toUpperCase()}</h2>
              <p style="margin:0;font-size:12px;color:#999;text-transform:uppercase;letter-spacing:0.5px;">${title}</p>
            </td>
          </tr>

          <!-- Body content -->
          <tr>
            <td style="padding:0 24px 24px 24px;color:#333;font-size:15px;line-height:22px;">
              ${bodyHtml}
            </td>
          </tr>

          ${buttonText && buttonUrl ? `
          <!-- CTA Button (bulletproof) -->
          <tr>
            <td style="padding:0 24px 32px 24px;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td align="center">
                    <table role="presentation" cellpadding="0" cellspacing="0" border="0">
                      <tr>
                        <td style="background-color:#000000;border-radius:8px;">
                          <a href="${buttonUrl}" style="display:inline-block;padding:16px 40px;color:#ffffff;text-decoration:none;font-size:15px;font-weight:600;letter-spacing:0.5px;">${buttonText}</a>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
              <!-- Fallback link -->
              <p style="margin:12px 0 0 0;text-align:center;font-size:12px;color:#999;">
                Si el botón no funciona: <a href="${buttonUrl}" style="color:#666;text-decoration:underline;">abre este enlace</a>
              </p>
            </td>
          </tr>
          ` : ''}

          <!-- Footer -->
          <tr>
            <td style="padding:24px;background-color:#f9fafb;border-top:1px solid #e5e7eb;text-align:center;">
              <p style="margin:0 0 8px 0;font-size:14px;color:#666;line-height:20px;">
                ${footerText || `Gracias por tu compra`}
              </p>
              <p style="margin:0;font-size:12px;color:#999;">
                ${storeName} | <a href="mailto:${supportEmail}" style="color:#999;text-decoration:underline;">${supportEmail}</a>
              </p>
            </td>
          </tr>

        </table>
        
      </td>
    </tr>
  </table>
</body>
</html>
  `.trim();

  // Plain text version (fallback)
  const text = `
${title}

${bodyHtml.replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').trim()}

${buttonText && buttonUrl ? `${buttonText}: ${buttonUrl}\n` : ''}

${footerText || `Gracias por tu compra — ${storeName}`}
${storeName} | ${supportEmail}
  `.trim();

  return { html, text };
}

/**
 * Helper to render a simple items table for emails (order items, return items, etc).
 */
export function renderItemsTable(items: Array<{ name: string; size?: string; qty: number; price_cents?: number; line_total_cents?: number }>): string {
  if (!items || items.length === 0) return '';

  const rows = items.map(item => {
    const name = item.name || 'Artículo';
    const size = item.size ? ` (${item.size})` : '';
    const qty = item.qty || 1;
    const price = item.price_cents ? `${(item.price_cents / 100).toFixed(2)} €` : '';
    const total = item.line_total_cents ? `${(item.line_total_cents / 100).toFixed(2)} €` : '';

    return `
      <tr>
        <td style="padding:12px 8px;border-bottom:1px solid #e5e5e5;color:#333;">${name}${size}</td>
        <td style="padding:12px 8px;border-bottom:1px solid #e5e5e5;text-align:center;color:#333;">${qty}</td>
        ${price ? `<td style="padding:12px 8px;border-bottom:1px solid #e5e5e5;text-align:right;color:#333;">${price}</td>` : ''}
        ${total ? `<td style="padding:12px 8px;border-bottom:1px solid #e5e5e5;text-align:right;color:#333;font-weight:600;">${total}</td>` : ''}
      </tr>
    `;
  }).join('');

  return `
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin:16px 0;border-collapse:collapse;">
      <thead>
        <tr style="background-color:#f9f9f9;">
          <th style="padding:10px 8px;text-align:left;font-size:12px;font-weight:600;color:#666;text-transform:uppercase;letter-spacing:0.5px;">Artículo</th>
          <th style="padding:10px 8px;text-align:center;font-size:12px;font-weight:600;color:#666;text-transform:uppercase;letter-spacing:0.5px;">Cant.</th>
          ${items[0]?.price_cents !== undefined ? `<th style="padding:10px 8px;text-align:right;font-size:12px;font-weight:600;color:#666;text-transform:uppercase;letter-spacing:0.5px;">Precio</th>` : ''}
          ${items[0]?.line_total_cents !== undefined ? `<th style="padding:10px 8px;text-align:right;font-size:12px;font-weight:600;color:#666;text-transform:uppercase;letter-spacing:0.5px;">Total</th>` : ''}
        </tr>
      </thead>
      <tbody>
        ${rows}
      </tbody>
    </table>
  `;
}
