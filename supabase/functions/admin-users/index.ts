// supabase/functions/admin-users/index.ts
// Admin: list users and patch role/active.
// GET    ?limit=50&offset=0         → list users (auth.users + fs_profiles)
// PATCH  { user_id, role?, disabled? } → update role or disable/enable

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

  try {
    if (req.method === "GET") {
      const url = new URL(req.url);
      const limit = parseInt(url.searchParams.get("limit") ?? "50", 10);
      const offset = parseInt(url.searchParams.get("offset") ?? "0", 10);

      // Get auth users via admin API
      const { data: authData, error: authErr } = await supabase.auth.admin.listUsers({
        page: Math.floor(offset / limit) + 1,
        perPage: limit,
      });

      if (authErr) {
        console.error("[admin-users] auth.admin.listUsers error:", authErr.message);
        return json(500, { error: authErr.message });
      }

      const userIds = authData.users.map((u: any) => u.id);

      // Get profiles
      const { data: profiles } = await supabase
        .from("fs_profiles")
        .select("id, role, display_name")
        .in("id", userIds);

      const profileMap = new Map<string, any>();
      for (const p of profiles ?? []) profileMap.set(p.id, p);

      const users = authData.users.map((u: any) => {
        const profile = profileMap.get(u.id);
        return {
          id: u.id,
          email: u.email,
          created_at: u.created_at,
          last_sign_in_at: u.last_sign_in_at ?? null,
          role: profile?.role ?? "user",
          display_name: profile?.display_name ?? null,
          is_active: !u.banned_until || new Date(u.banned_until) < new Date(),
          banned_until: u.banned_until ?? null,
        };
      });

      return json(200, { users, total: authData.total ?? users.length });
    }

    if (req.method === "PATCH") {
      const { user_id, role, disabled } = await req.json();
      if (!user_id) return json(400, { error: "user_id required" });

      // Update role in fs_profiles
      if (role !== undefined) {
        const allowedRoles = ["user", "admin"];
        if (!allowedRoles.includes(role)) return json(400, { error: "Invalid role" });

        const { error: profileErr } = await supabase
          .from("fs_profiles")
          .upsert({ id: user_id, role })
          .eq("id", user_id);

        if (profileErr) {
          console.error("[admin-users] profile update error:", profileErr.message);
          return json(500, { error: profileErr.message });
        }
      }

      // Disable/enable user in auth
      if (disabled !== undefined) {
        if (disabled) {
          // Ban for 100 years = effectively disable
          const bannedUntil = new Date();
          bannedUntil.setFullYear(bannedUntil.getFullYear() + 100);

          const { error: banErr } = await supabase.auth.admin.updateUserById(user_id, {
            ban_duration: "876000h", // 100 years in hours
          });
          if (banErr) {
            console.error("[admin-users] ban error:", banErr.message);
            return json(500, { error: banErr.message });
          }
        } else {
          // Unban
          const { error: unbanErr } = await supabase.auth.admin.updateUserById(user_id, {
            ban_duration: "none",
          });
          if (unbanErr) {
            console.error("[admin-users] unban error:", unbanErr.message);
            return json(500, { error: unbanErr.message });
          }
        }
      }

      return json(200, { ok: true });
    }

    return json(405, { error: "Method not allowed" });
  } catch (err: any) {
    console.error("[admin-users] error:", err);
    return json(500, { error: err.message ?? "Internal error" });
  }
});
