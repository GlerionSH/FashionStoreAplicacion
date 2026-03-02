// supabase/functions/_shared/branding.ts
// Fetches branding assets (logo, store name, support email) from DB with safe fallbacks.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

export interface BrandingConfig {
  brandLogoUrl: string;
  storeName: string;
  supportEmail: string;
}

const FALLBACK_LOGO_URL = "https://qtetgglxmvivfbdgylbz.supabase.co/storage/v1/object/public/logos/imagen-fondo.png";
const FALLBACK_STORE_NAME = "Fashion Store";
const FALLBACK_SUPPORT_EMAIL = "soporte@fashionstore.com";

export async function getBranding(
  supabase: ReturnType<typeof createClient>
): Promise<BrandingConfig> {
  try {
    const { data: settings } = await supabase
      .from("fs_site_settings")
      .select("brand_logo_url")
      .limit(1)
      .maybeSingle();

    const brandLogoUrl = settings?.brand_logo_url?.trim() || FALLBACK_LOGO_URL;

    return {
      brandLogoUrl,
      storeName: FALLBACK_STORE_NAME,
      supportEmail: FALLBACK_SUPPORT_EMAIL,
    };
  } catch (err) {
    console.warn("[branding] Failed to fetch settings, using fallbacks:", err);
    return {
      brandLogoUrl: FALLBACK_LOGO_URL,
      storeName: FALLBACK_STORE_NAME,
      supportEmail: FALLBACK_SUPPORT_EMAIL,
    };
  }
}
