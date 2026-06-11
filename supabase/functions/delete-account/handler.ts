// Account deletion (App Store / Play Store requirement).
//
// Security: gateway verify_jwt is OFF for this function
// ([functions.delete-account] in supabase/config.toml). Current Supabase
// projects sign user access tokens with asymmetric keys (ES256) by default,
// which the functions gateway cannot verify — with verify_jwt on, every
// legitimate call 401s before this handler runs. This handler is therefore
// its own auth boundary: it rejects requests without a valid JWT, and the
// user id is derived ONLY from the caller's JWT via auth.getUser() — never
// from the request body — so a user can delete exactly one account: their
// own.
//
// Deletion uses the service-role admin API. All four auth.users foreign keys
// (profiles, subscriptions, user_favorites, user_learned_lessons) are
// ON DELETE CASCADE (migrations 20260610120100 / 20260610120200 /
// 20260610120300), so a single auth.admin.deleteUser() erases every row the
// user owns.
//
// Client contract (Flutter): supabase.functions.invoke('delete-account'),
// then signOut() and start a fresh anonymous session.

import { createClient } from "npm:@supabase/supabase-js@2";
import { json, preflight } from "../_shared/http.ts";

export async function handler(req: Request): Promise<Response> {
  const preflightResponse = preflight(req);
  if (preflightResponse) return preflightResponse;
  if (req.method !== "POST") {
    return json(405, { ok: false, message: "Method not allowed" });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json(401, { ok: false, message: "Missing Authorization header" });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    console.error("[delete-account] missing SUPABASE_* environment variables");
    return json(500, { ok: false, message: "Server misconfigured" });
  }

  // Resolve the caller from their own JWT. The anon-key client forwards the
  // caller's Authorization header, so getUser() validates the JWT against
  // Supabase Auth and returns the user it belongs to.
  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data, error: getUserError } = await callerClient.auth.getUser();
  const userId = data?.user?.id;
  if (getUserError || !userId) {
    return json(401, { ok: false, message: "Invalid or expired JWT" });
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { error: deleteError } = await adminClient.auth.admin.deleteUser(
    userId,
  );
  if (deleteError) {
    console.error(
      `[delete-account] deleteUser(${userId}) failed: ${deleteError.message}`,
    );
    return json(500, { ok: false, message: "Account deletion failed" });
  }

  console.log(`[delete-account] deleted user ${userId}`);
  return json(200, { ok: true, message: "Account deleted" });
}
