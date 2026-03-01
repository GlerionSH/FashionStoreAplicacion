// supabase/functions/admin-products-delete/index.ts
// Safe product delete: blocks deletion if product has any order items.
// DELETE { product_id }
// Returns { ok } or { error, has_orders: true } with 409

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
  const { data } = await supabase.from("fs_profiles").select("role").eq("id", userId).maybeSingle();
  return data?.role === "admin";
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  if (!(await verifyAdmin(req, supabase))) return json(403, { error: "Forbidden" });

  if (req.method !== "DELETE") return json(405, { error: "Method not allowed" });

  try {
    const { product_id } = await req.json();
    if (!product_id) return json(400, { error: "product_id required" });

    // Check if product has any order items
    const { count, error: countErr } = await supabase
      .from("fs_order_items")
      .select("id", { count: "exact", head: true })
      .eq("product_id", product_id);

    if (countErr) return json(500, { error: countErr.message });

    if ((count ?? 0) > 0) {
      return json(409, {
        error: "Este producto tiene pedidos y no puede eliminarse. Desactívalo en su lugar.",
        has_orders: true,
        order_count: count,
      });
    }

    // Safe to delete
    const { error: deleteErr } = await supabase
      .from("fs_products")
      .delete()
      .eq("id", product_id);

    if (deleteErr) {
      // Check for trigger-raised exception
      if (deleteErr.message?.includes("product_has_orders")) {
        return json(409, {
          error: "Este producto tiene pedidos y no puede eliminarse. Desactívalo en su lugar.",
          has_orders: true,
        });
      }
      return json(500, { error: deleteErr.message });
    }

    console.log(`[admin-products-delete] Deleted product ${product_id}`);
    return json(200, { ok: true });
  } catch (err: any) {
    console.error("[admin-products-delete] error:", err);
    return json(500, { error: err.message ?? "Internal error" });
  }
});
