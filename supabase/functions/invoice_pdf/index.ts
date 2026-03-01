// supabase/functions/invoice_pdf/index.ts
// Generates a minimal invoice PDF for an order, stores it in Supabase Storage,
// and returns a signed URL.
// Input: ?order_id=XXX&token=YYY (GET)

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { PDFDocument, rgb, StandardFonts } from "https://esm.sh/pdf-lib@1.17.1";

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

    // ── 4. Generate PDF ──
    const pdfDoc = await PDFDocument.create();
    const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
    const fontBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);
    const page = pdfDoc.addPage([595.28, 841.89]); // A4
    const { width, height } = page.getSize();

    const margin = 50;
    let y = height - margin;
    const black = rgb(0, 0, 0);
    const gray = rgb(0.5, 0.5, 0.5);
    const lightGray = rgb(0.85, 0.85, 0.85);

    // Header
    page.drawText("FASHION STORE", {
      x: margin,
      y,
      size: 20,
      font: fontBold,
      color: black,
    });
    y -= 14;
    page.drawText("FACTURA", {
      x: margin,
      y,
      size: 10,
      font,
      color: gray,
    });

    // Order info
    y -= 36;
    const infoLines = [
      `Pedido: #${orderId.substring(0, 8)}`,
      `Fecha: ${order.paid_at ? new Date(order.paid_at).toLocaleDateString("es-ES") : new Date(order.created_at).toLocaleDateString("es-ES")}`,
      `Email: ${order.email || "-"}`,
      `Estado: ${(order.status || "").toUpperCase()}`,
    ];
    for (const line of infoLines) {
      page.drawText(line, { x: margin, y, size: 10, font, color: black });
      y -= 16;
    }

    // Separator
    y -= 8;
    page.drawLine({
      start: { x: margin, y },
      end: { x: width - margin, y },
      thickness: 0.5,
      color: lightGray,
    });
    y -= 20;

    // Table header
    const colX = { name: margin, size: 280, qty: 360, price: 420, total: 490 };
    const headerTexts = [
      { text: "ARTÍCULO", x: colX.name },
      { text: "TALLA", x: colX.size },
      { text: "CANT", x: colX.qty },
      { text: "PRECIO", x: colX.price },
      { text: "TOTAL", x: colX.total },
    ];
    for (const h of headerTexts) {
      page.drawText(h.text, {
        x: h.x,
        y,
        size: 8,
        font: fontBold,
        color: gray,
      });
    }
    y -= 6;
    page.drawLine({
      start: { x: margin, y },
      end: { x: width - margin, y },
      thickness: 0.5,
      color: lightGray,
    });
    y -= 16;

    // Table rows
    const fmtEur = (cents: number) =>
      `${(cents / 100).toFixed(2).replace(".", ",")} €`;

    for (const item of items || []) {
      const name = (item.name || "Artículo").substring(0, 35);
      page.drawText(name, { x: colX.name, y, size: 9, font, color: black });
      page.drawText(item.size || "-", {
        x: colX.size,
        y,
        size: 9,
        font,
        color: black,
      });
      page.drawText(String(item.qty || 1), {
        x: colX.qty,
        y,
        size: 9,
        font,
        color: black,
      });
      page.drawText(fmtEur(item.unit_price_cents || 0), {
        x: colX.price,
        y,
        size: 9,
        font,
        color: black,
      });
      page.drawText(fmtEur(item.line_total_cents || 0), {
        x: colX.total,
        y,
        size: 9,
        font,
        color: black,
      });
      y -= 18;

      // Add new page if running out of space
      if (y < 120) {
        // For simplicity, just stop — most orders won't exceed one page
        page.drawText("...", { x: margin, y, size: 9, font, color: gray });
        y -= 18;
        break;
      }
    }

    // Separator
    y -= 8;
    page.drawLine({
      start: { x: margin, y },
      end: { x: width - margin, y },
      thickness: 0.5,
      color: lightGray,
    });
    y -= 20;

    // Totals
    const subtotal = order.subtotal_cents || 0;
    const discount = order.discount_cents || 0;
    const total = order.total_cents || 0;

    page.drawText("Subtotal:", {
      x: colX.price,
      y,
      size: 10,
      font,
      color: gray,
    });
    page.drawText(fmtEur(subtotal), {
      x: colX.total,
      y,
      size: 10,
      font,
      color: black,
    });
    y -= 16;

    if (discount > 0) {
      page.drawText("Descuento:", {
        x: colX.price,
        y,
        size: 10,
        font,
        color: gray,
      });
      page.drawText(`-${fmtEur(discount)}`, {
        x: colX.total,
        y,
        size: 10,
        font,
        color: black,
      });
      y -= 16;
    }

    page.drawText("TOTAL:", {
      x: colX.price,
      y,
      size: 12,
      font: fontBold,
      color: black,
    });
    page.drawText(fmtEur(total), {
      x: colX.total,
      y,
      size: 12,
      font: fontBold,
      color: black,
    });

    // Footer
    page.drawText("Gracias por tu compra — Fashion Store", {
      x: margin,
      y: 40,
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
