// HTTP + Postgres side of the RevenueCat webhook. The event-to-row mapping
// is pure and lives in ../_shared/revenuecat.ts so every branch can be unit
// tested without a database; this file only authenticates the request,
// enforces delivery ordering, and executes the resulting plan.
//
// Security: every request must carry an Authorization header that equals the
// REVENUECAT_WEBHOOK_AUTH secret (set once per Supabase project with
// `supabase secrets set REVENUECAT_WEBHOOK_AUTH=<value>` and configured as
// the webhook Authorization header value in the RevenueCat dashboard). The
// comparison is constant-time (see ../_shared/timing_safe_equal.ts) so
// response timing leaks nothing about the secret. verify_jwt is disabled for
// this function in supabase/config.toml.

import {
  createClient,
  type SupabaseClient,
} from "npm:@supabase/supabase-js@2";
import { ok } from "../_shared/http.ts";
import { timingSafeEqual } from "../_shared/timing_safe_equal.ts";
import {
  planEvent,
  type RevenueCatEvent,
  type UpsertPlan,
} from "../_shared/revenuecat.ts";

// NOTE: the delete-then-update below is NOT transactional — two separate
// PostgREST calls. If the function dies between them, the target user's
// colliding rows are gone but the source rows have not moved yet. RevenueCat
// retries non-2xx deliveries, and re-running both steps is idempotent, so the
// transfer converges on retry; a stronger guarantee would need an RPC that
// wraps both statements in one Postgres function/transaction.
async function applyTransfer(
  supabase: SupabaseClient,
  fromUserId: string,
  toUserId: string,
): Promise<Response> {
  const { data: rows, error: selectError } = await supabase
    .from("subscriptions")
    .select("entitlement_id")
    .eq("user_id", fromUserId);
  if (selectError) {
    console.error(
      `[revenuecat-webhook] TRANSFER select failed: ${selectError.message}`,
    );
    return new Response("Database error", { status: 500 });
  }
  if (!rows || rows.length === 0) {
    return ok("TRANSFER: no subscription rows to move");
  }

  // Remove colliding rows on the target user so the move cannot violate
  // UNIQUE (user_id, entitlement_id).
  const entitlements = rows.map((r) => r.entitlement_id as string);
  const { error: deleteError } = await supabase
    .from("subscriptions")
    .delete()
    .eq("user_id", toUserId)
    .in("entitlement_id", entitlements);
  if (deleteError) {
    console.error(
      `[revenuecat-webhook] TRANSFER delete failed: ${deleteError.message}`,
    );
    return new Response("Database error", { status: 500 });
  }

  const { error: updateError } = await supabase
    .from("subscriptions")
    .update({ user_id: toUserId, updated_at: new Date().toISOString() })
    .eq("user_id", fromUserId);
  if (updateError) {
    console.error(
      `[revenuecat-webhook] TRANSFER update failed: ${updateError.message}`,
    );
    return new Response("Database error", { status: 500 });
  }
  return ok("TRANSFER processed");
}

async function applyUpsert(
  supabase: SupabaseClient,
  plan: UpsertPlan,
): Promise<Response> {
  // RevenueCat delivery is at-least-once and unordered: a retried event can
  // arrive after a newer one was already applied. Skip anything older than
  // the last event applied to this (user_id, entitlement_id) row. (Small
  // read-then-write race window between concurrent deliveries — acceptable:
  // the next genuine event converges the row.)
  if (plan.eventTimestampMs !== null) {
    const { data: existing, error: staleCheckError } = await supabase
      .from("subscriptions")
      .select("last_event_timestamp_ms")
      .eq("user_id", plan.userId)
      .eq("entitlement_id", plan.entitlementId)
      .maybeSingle();
    if (staleCheckError) {
      console.error(
        `[revenuecat-webhook] stale-check select failed: ${staleCheckError.message}`,
      );
      return new Response("Database error", { status: 500 });
    }
    const lastApplied = existing?.last_event_timestamp_ms;
    if (typeof lastApplied === "number" && plan.eventTimestampMs <= lastApplied) {
      console.log(
        `[revenuecat-webhook] stale event skipped: ${plan.eventTimestampMs} <= last applied ${lastApplied}`,
      );
      return ok("stale/out-of-order event ignored");
    }
  }

  const { error } = await supabase
    .from("subscriptions")
    .upsert(
      { ...plan.record, updated_at: new Date().toISOString() },
      { onConflict: "user_id,entitlement_id" },
    );
  if (error) {
    // 23503 = foreign_key_violation on subscriptions_user_id_fkey: the auth
    // user is gone (delete-account edge function or the scheduled anonymous
    // user cleanup). Return 200 so RevenueCat stops retrying an event that
    // can never be applied.
    if (error.code === "23503") {
      console.log(
        `[revenuecat-webhook] user ${plan.userId} no longer exists - event dropped`,
      );
      return ok("user no longer exists");
    }
    console.error(`[revenuecat-webhook] upsert failed: ${error.message}`);
    return new Response("Database error", { status: 500 });
  }

  return ok(`${plan.eventType} processed`);
}

export async function handler(req: Request): Promise<Response> {
  const expectedAuth = Deno.env.get("REVENUECAT_WEBHOOK_AUTH");
  if (!expectedAuth) {
    console.error(
      "[revenuecat-webhook] REVENUECAT_WEBHOOK_AUTH is not set - refusing to run open",
    );
    return new Response("Server misconfigured", { status: 500 });
  }
  const providedAuth = req.headers.get("Authorization") ?? "";
  if (!(await timingSafeEqual(providedAuth, expectedAuth))) {
    return new Response("Unauthorized", { status: 401 });
  }

  let body: { event?: RevenueCatEvent; api_version?: string };
  try {
    body = await req.json();
  } catch {
    return new Response("Invalid JSON body", { status: 400 });
  }

  const event = body?.event;
  if (!event || typeof event !== "object" || typeof event.type !== "string") {
    return new Response("Malformed webhook body: missing event", {
      status: 400,
    });
  }

  console.log(
    `[revenuecat-webhook] event=${event.type} app_user_id=${event.app_user_id ?? ""}`,
  );

  const plan = planEvent(event);
  if (plan.action === "ignore") {
    console.log(`[revenuecat-webhook] ${plan.reason}`);
    return ok(plan.reason);
  }

  // Service role: the webhook is the only writer of subscriptions (clients
  // are SELECT-only by RLS), and it must bypass RLS to do so.
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  if (plan.action === "transfer") {
    return await applyTransfer(supabase, plan.fromUserId, plan.toUserId);
  }
  return await applyUpsert(supabase, plan);
}
