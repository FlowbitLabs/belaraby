// Demo subscription endpoint (web demo of the premium experience).
//
// Grants or revokes a REAL `subscriptions` row for the calling user so the
// server-side premium gating (has_active_subscription / story-body masking)
// behaves exactly like a store purchase — without going through RevenueCat.
//
// Security:
//   * Gateway verify_jwt is OFF ([functions.demo-subscription] in
//     supabase/config.toml) for the same reason as delete-account: the
//     gateway cannot verify ES256 user JWTs. This handler is its own auth
//     boundary — the user id comes ONLY from auth.getUser() on the caller's
//     JWT.
//   * Only emails in the DEMO_PREMIUM_EMAILS secret (comma-separated) may
//     call it. Anyone else gets 403 — otherwise any user could self-grant
//     premium for free.
//
// Contract: POST { action: "subscribe" | "unsubscribe" | "check" }.
//   check       -> 200 {authorized:true} for allowlisted accounts (the UI
//                  uses it to decide whether to show the demo toggle)
//   subscribe   -> upsert an active demo row (store='demo', 30 days)
//   unsubscribe -> expire the demo row immediately
// Demo rows never touch RevenueCat-managed rows (store != 'demo').

import { createClient } from "npm:@supabase/supabase-js@2";
import { json, preflight } from "../_shared/http.ts";

const DEMO_ENTITLEMENT = "premium";
const DEMO_STORE = "demo";
const DEMO_DURATION_MS = 30 * 24 * 60 * 60 * 1000;

export async function handler(req: Request): Promise<Response> {
  const preflightResponse = preflight(req);
  if (preflightResponse) return preflightResponse;
  if (req.method !== "POST") {
    return json(405, { ok: false, message: "Method not allowed" });
  }

  let action: string;
  try {
    const body = await req.json();
    action = body?.action;
  } catch {
    return json(400, { ok: false, message: "Invalid JSON body" });
  }
  if (action !== "subscribe" && action !== "unsubscribe" && action !== "check") {
    return json(400, { ok: false, message: "Unknown action" });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json(401, { ok: false, message: "Missing Authorization header" });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const allowedEmails = (Deno.env.get("DEMO_PREMIUM_EMAILS") ?? "")
    .split(",")
    .map((e) => e.trim().toLowerCase())
    .filter((e) => e.length > 0);
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    console.error(
      "[demo-subscription] missing SUPABASE_* environment variables",
    );
    return json(500, { ok: false, message: "Server misconfigured" });
  }

  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data, error: getUserError } = await callerClient.auth.getUser();
  const user = data?.user;
  if (getUserError || !user) {
    return json(401, { ok: false, message: "Invalid or expired JWT" });
  }

  const email = user.email?.toLowerCase() ?? "";
  if (!email || !allowedEmails.includes(email)) {
    console.log(
      `[demo-subscription] forbidden for ${email || "anonymous"} (${user.id})`,
    );
    return json(403, {
      ok: false,
      message: "This account is not authorized for demo subscriptions",
    });
  }

  if (action === "check") {
    return json(200, { ok: true, authorized: true });
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const now = new Date();

  if (action === "subscribe") {
    const { error } = await adminClient.from("subscriptions").upsert(
      {
        user_id: user.id,
        entitlement_id: DEMO_ENTITLEMENT,
        product_id: "demo_premium",
        store: DEMO_STORE,
        environment: "demo",
        status: "active",
        will_renew: false,
        expires_at: new Date(now.getTime() + DEMO_DURATION_MS).toISOString(),
        updated_at: now.toISOString(),
      },
      { onConflict: "user_id,entitlement_id" },
    );
    if (error) {
      console.error(`[demo-subscription] upsert failed: ${error.message}`);
      return json(500, { ok: false, message: "Database error" });
    }
    console.log(`[demo-subscription] subscribed ${email} (${user.id})`);
    return json(200, { ok: true, subscribed: true });
  }

  // unsubscribe: expire only demo rows; never touch store-managed rows.
  const { error } = await adminClient
    .from("subscriptions")
    .update({ expires_at: now.toISOString(), updated_at: now.toISOString() })
    .eq("user_id", user.id)
    .eq("entitlement_id", DEMO_ENTITLEMENT)
    .eq("store", DEMO_STORE);
  if (error) {
    console.error(`[demo-subscription] expire failed: ${error.message}`);
    return json(500, { ok: false, message: "Database error" });
  }
  console.log(`[demo-subscription] unsubscribed ${email} (${user.id})`);
  return json(200, { ok: true, subscribed: false });
}
