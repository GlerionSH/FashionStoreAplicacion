// supabase/functions/invoice_pdf/index.ts
// Generates a professional invoice PDF with banner image, stores it in Supabase Storage,
// and returns a signed URL.
// Input: ?order_id=XXX&token=YYY (GET)

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { PDFDocument, rgb, StandardFonts } from "https://esm.sh/pdf-lib@1.17.1";
import { getBranding } from "../_shared/branding.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const orderId = url.searchParams.get("order_id");
    const token = url.searchParams.get("token");

    if (!orderId || !token) {
      return new Response(
        JSON.stringify({ error: "order_id y token son obligatorios" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // ── 1. Validate token ──
    const { data: order, error: orderErr } = await supabase
      .from("fs_orders")
      .select("*")
      .eq("id", orderId)
      .eq("invoice_token", token)
      .single();

    if (orderErr || !order) {
      return new Response(
        JSON.stringify({ error: "Pedido no encontrado o token inválido" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── 2. Check if PDF already exists in storage ──
    const storagePath = `invoices/${orderId}.pdf`;
    const { data: existingFile } = await supabase.storage
      .from("invoices")
      .createSignedUrl(storagePath, 3600); // 1h

    if (existingFile?.signedUrl) {
      return new Response(
        JSON.stringify({ url: existingFile.signedUrl }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── 3. Load order items ──
    const { data: items } = await supabase
      .from("fs_order_items")
      .select("*")
      .eq("order_id", orderId);

    // ── 4. Generate PDF (NO IMAGE/BANNER - clean professional layout) ──
    const pdfDoc = await PDFDocument.create();
    const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
    const fontBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);
    let page = pdfDoc.addPage([595.28, 841.89]); // A4
    const { width: pageWidth, height: pageHeight } = page.getSize();

    // Layout constants
    const marginX = 48;
    const marginTop = 48;
    const marginBottom = 48;

    const black = rgb(0, 0, 0);
    const gray = rgb(0.5, 0.5, 0.5);
    const lightGray = rgb(0.85, 0.85, 0.85);

    const fmtEur = (cents: number) =>
      `${(cents / 100).toFixed(2).replace(".", ",")} \u20AC`;

    // ── HEADER (clean, no image) ──
    let y = pageHeight - marginTop;
    const shortId = orderId.substring(0, 8).toUpperCase();
    const invoiceDate = order.paid_at
      ? new Date(order.paid_at).toLocaleDateString("es-ES", { day: "2-digit", month: "2-digit", year: "numeric" })
      : new Date(order.created_at).toLocaleDateString("es-ES", { day: "2-digit", month: "2-digit", year: "numeric" });

    // Left: FASHION STORE + FACTURA
    page.drawText("FASHION STORE", {
      x: marginX,
      y,
      size: 18,
      font: fontBold,
      color: black,
    });
    y -= 18;
    page.drawText("FACTURA", {
      x: marginX,
      y,
      size: 12,
      font,
      color: gray,
    });

    // Right: Invoice number + date
    const rightX = pageWidth - marginX;
    let rightY = pageHeight - marginTop;
    const invoiceNumText = `Nº Factura: FS-${shortId}`;
    const invoiceNumWidth = font.widthOfTextAtSize(invoiceNumText, 10);
    page.drawText(invoiceNumText, {
      x: rightX - invoiceNumWidth,
      y: rightY,
      size: 10,
      font: fontBold,
      color: black,
    });
    rightY -= 14;
    const dateText = `Fecha: ${invoiceDate}`;
    const dateWidth = font.widthOfTextAtSize(dateText, 10);
    page.drawText(dateText, {
      x: rightX - dateWidth,
      y: rightY,
      size: 10,
      font,
      color: gray,
    });

    // Separator line
    y -= 10;
    page.drawLine({
      start: { x: marginX, y },
      end: { x: pageWidth - marginX, y },
      thickness: 0.5,
      color: lightGray,
    });
    y -= 20;

    // ── DATA BLOCK (2 columns) ──
    const col1X = marginX;
    const col2X = pageWidth / 2 + 20;
    const dataStartY = y;

    // Left column
    page.drawText("Nº Pedido:", { x: col1X, y, size: 9, font: fontBold, color: gray });
    page.drawText(`#${shortId}`, { x: col1X + 70, y, size: 9, font, color: black });
    y -= 14;
    page.drawText("Email:", { x: col1X, y, size: 9, font: fontBold, color: gray });
    page.drawText(order.email || "-", { x: col1X + 70, y, size: 9, font, color: black });

    // Right column
    y = dataStartY;
    page.drawText("Estado:", { x: col2X, y, size: 9, font: fontBold, color: gray });
    page.drawText((order.status || "").toUpperCase(), { x: col2X + 70, y, size: 9, font, color: black });

    y = dataStartY - 28;
    y -= 10;

    // ── TABLE HEADER ──
    const colX = { name: marginX, size: 250, qty: 330, price: 390, total: 480 };
    // Header background
    page.drawRectangle({
      x: marginX,
      y: y - 4,
      width: pageWidth - 2 * marginX,
      height: 18,
      color: rgb(0.95, 0.95, 0.95),
    });
    const headerTexts = [
      { text: "ARTICULO", x: colX.name + 4 },
      { text: "TALLA", x: colX.size },
      { text: "CANT.", x: colX.qty },
      { text: "PRECIO UD.", x: colX.price },
      { text: "TOTAL", x: colX.total },
    ];
    for (const h of headerTexts) {
      page.drawText(h.text, { x: h.x, y, size: 8, font: fontBold, color: gray });
    }
    y -= 22;

    // ── TABLE ROWS ──
    for (const item of items || []) {
      if (y < 140) {
        // New page
        page = pdfDoc.addPage([595.28, 841.89]);
        y = pageHeight - marginX;
      }
      const name = (item.name || "Articulo").substring(0, 40);
      page.drawText(name, { x: colX.name + 4, y, size: 9, font, color: black });
      page.drawText(item.size || "-", { x: colX.size, y, size: 9, font, color: black });
      page.drawText(String(item.qty || 1), { x: colX.qty, y, size: 9, font, color: black });
      page.drawText(fmtEur(item.unit_price_cents || item.price_cents || 0), { x: colX.price, y, size: 9, font, color: black });
      page.drawText(fmtEur(item.line_total_cents || 0), { x: colX.total, y, size: 9, font, color: black });
      y -= 18;
      // Light row separator
      page.drawLine({
        start: { x: marginX, y: y + 8 },
        end: { x: pageWidth - marginX, y: y + 8 },
        thickness: 0.3,
        color: rgb(0.92, 0.92, 0.92),
      });
    }

    // ── TOTALS BLOCK ──
    y -= 12;
    page.drawLine({
      start: { x: colX.price - 10, y: y + 6 },
      end: { x: pageWidth - marginX, y: y + 6 },
      thickness: 1,
      color: lightGray,
    });
    y -= 8;

    const subtotal = order.subtotal_cents || 0;
    const discount = order.coupon_discount_cents || 0;
    const total = order.total_cents || 0;
    const couponCode = order.coupon_code || null;

    // Subtotal
    page.drawText("Subtotal:", { x: colX.price, y, size: 10, font, color: gray });
    page.drawText(fmtEur(subtotal), { x: colX.total, y, size: 10, font, color: black });
    y -= 18;

    // Discount (only if > 0)
    if (discount > 0) {
      const discLabel = couponCode
        ? `Descuento (${couponCode}):`
        : "Descuento:";
      page.drawText(discLabel, { x: colX.price, y, size: 10, font, color: rgb(0.7, 0.2, 0.2) });
      page.drawText(`-${fmtEur(discount)}`, { x: colX.total, y, size: 10, font, color: rgb(0.7, 0.2, 0.2) });
      y -= 18;
    }

    // Total with bold
    page.drawRectangle({
      x: colX.price - 10,
      y: y - 6,
      width: pageWidth - marginX - colX.price + 10,
      height: 22,
      color: rgb(0.96, 0.96, 0.96),
    });
    page.drawText("TOTAL:", { x: colX.price, y, size: 13, font: fontBold, color: black });
    page.drawText(fmtEur(total), { x: colX.total, y, size: 13, font: fontBold, color: black });

    // ── FOOTER ──
    const footerY = marginBottom + 10;
    page.drawLine({
      start: { x: marginX, y: footerY + 12 },
      end: { x: pageWidth - marginX, y: footerY + 12 },
      thickness: 0.5,
      color: lightGray,
    });
    const footerText = "Gracias por tu compra — Fashion Store";
    const footerWidth = font.widthOfTextAtSize(footerText, 8);
    page.drawText(footerText, {
      x: (pageWidth - footerWidth) / 2,
      y: footerY,
      size: 8,
      font,
      color: gray,
    });

    // ── 5. Save PDF to Supabase Storage ──
    const pdfBytes = await pdfDoc.save();

    const { error: uploadErr } = await supabase.storage
      .from("invoices")
      .upload(storagePath, pdfBytes, {
        contentType: "application/pdf",
        upsert: true,
      });

    if (uploadErr) {
      console.error("Error uploading PDF:", uploadErr.message);
      // Return the PDF directly as fallback
      return new Response(pdfBytes, {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/pdf",
          "Content-Disposition": `attachment; filename="factura-${orderId.substring(0, 8)}.pdf"`,
        },
      });
    }

    // ── 6. Create signed URL ──
    const { data: signedData, error: signErr } = await supabase.storage
      .from("invoices")
      .createSignedUrl(storagePath, 3600);

    if (signErr || !signedData?.signedUrl) {
      throw new Error("Error generando URL firmada");
    }

    return new Response(
      JSON.stringify({ url: signedData.signedUrl }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err: any) {
    console.error("invoice_pdf error:", err);
    return new Response(
      JSON.stringify({ error: err.message || "Error interno" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
