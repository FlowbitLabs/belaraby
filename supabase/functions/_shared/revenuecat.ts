// Pure mapping from a RevenueCat webhook event to a subscription-row plan.
//
// No I/O lives here — every event-type branch is testable without a
// database (see ../_tests/). The handler in ../revenuecat-webhook/handler.ts
// owns authentication, the out-of-order delivery check and all Postgres
// calls, and executes whatever plan this module returns.
//
// Contract (mirrors 20260610120200_subscriptions_revenuecat.sql):
//   entitlement id  : event.entitlement_ids?.[0] ?? "premium"
//   upsert target   : UNIQUE (user_id, entitlement_id)
//   premium access  : gated by expires_at only (status is informational)

export interface RevenueCatEvent {
  type: string;
  app_user_id?: string;
  entitlement_ids?: string[] | null;
  product_id?: string | null;
  new_product_id?: string | null;
  store?: string | null;
  environment?: string | null;
  original_transaction_id?: string | null;
  event_timestamp_ms?: number | null;
  expiration_at_ms?: number | null;
  grace_period_expiration_at_ms?: number | null;
  transferred_from?: string[] | null;
  transferred_to?: string[] | null;
}

// The plan an event maps to:
//   ignore   — answer 200 without touching the database (RevenueCat would
//              retry any other status forever for events we can never apply)
//   transfer — move all subscription rows from one auth user to another
//   upsert   — write one (user_id, entitlement_id) row
export type WebhookPlan =
  | { action: "ignore"; reason: string }
  | { action: "transfer"; fromUserId: string; toUserId: string }
  | UpsertPlan;

export interface UpsertPlan {
  action: "upsert";
  eventType: string;
  userId: string;
  entitlementId: string;
  // For the staleness check against subscriptions.last_event_timestamp_ms.
  eventTimestampMs: number | null;
  // Column values for the upsert. updated_at is NOT included — the handler
  // stamps it at write time so this mapping stays deterministic.
  record: Record<string, unknown>;
}

// The app sets the RevenueCat appUserID to the Supabase auth user id, so
// anything that is not a UUID cannot be matched to auth.users.
export const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export function msToIso(ms: unknown): string | null {
  return typeof ms === "number" && Number.isFinite(ms)
    ? new Date(ms).toISOString()
    : null;
}

export interface PlanOptions {
  // Sandbox/TestFlight purchases must not grant real premium access in
  // production. Set the REVENUECAT_ALLOW_SANDBOX function secret to "true"
  // during pre-launch store testing to let them through deliberately.
  allowSandbox?: boolean;
}

export function planEvent(
  event: RevenueCatEvent,
  options: PlanOptions = {},
): WebhookPlan {
  const type = event.type;
  const appUserId = typeof event.app_user_id === "string"
    ? event.app_user_id
    : "";

  if (type === "TEST") {
    return { action: "ignore", reason: "TEST event ignored" };
  }
  if (event.environment === "SANDBOX" && !options.allowSandbox) {
    return { action: "ignore", reason: "SANDBOX environment event ignored" };
  }
  // Purchases made before Purchases.logIn() ran arrive under RevenueCat's
  // device-generated alias; a later TRANSFER event moves them to the real id.
  if (appUserId.startsWith("$RCAnonymousID:")) {
    return { action: "ignore", reason: "anonymous app_user_id ignored" };
  }

  if (type === "TRANSFER") {
    // transferred_from/to mix UUIDs with $RCAnonymousID aliases — only the
    // UUID entries can be matched to auth.users.
    const fromUserId = (event.transferred_from ?? []).find((id) =>
      UUID_RE.test(id)
    );
    const toUserId = (event.transferred_to ?? []).find((id) =>
      UUID_RE.test(id)
    );
    if (!fromUserId || !toUserId) {
      return {
        action: "ignore",
        reason: "TRANSFER without two UUID user ids ignored",
      };
    }
    return { action: "transfer", fromUserId, toUserId };
  }

  if (!UUID_RE.test(appUserId)) {
    return { action: "ignore", reason: "non-UUID app_user_id ignored" };
  }

  const entitlementId =
    (Array.isArray(event.entitlement_ids) && event.entitlement_ids[0]) ||
    "premium";
  const expiresAt = msToIso(event.expiration_at_ms);
  const eventTimestampMs = typeof event.event_timestamp_ms === "number" &&
      Number.isFinite(event.event_timestamp_ms)
    ? event.event_timestamp_ms
    : null;

  const record: Record<string, unknown> = {
    user_id: appUserId,
    entitlement_id: entitlementId,
    product_id: event.product_id ?? null,
    store: event.store ?? null,
    environment: event.environment ?? null,
    original_transaction_id: event.original_transaction_id ?? null,
  };
  if (eventTimestampMs !== null) {
    record.last_event_timestamp_ms = eventTimestampMs;
  }
  // Only touch expires_at when the event carries one, so e.g. a CANCELLATION
  // without expiration_at_ms can never wipe the remaining access window.
  if (expiresAt !== null) {
    record.expires_at = expiresAt;
  }

  switch (type) {
    case "INITIAL_PURCHASE":
    case "RENEWAL":
    case "UNCANCELLATION":
    case "NON_RENEWING_PURCHASE":
    case "SUBSCRIPTION_EXTENDED":
      record.status = "active";
      record.will_renew = true;
      break;
    case "CANCELLATION":
      // Access keeps running until expires_at — never zero it here.
      record.status = "cancelled";
      record.will_renew = false;
      break;
    case "EXPIRATION":
      record.status = "expired";
      record.will_renew = false;
      break;
    case "BILLING_ISSUE": {
      record.status = "billing_issue";
      // A grace period extends access past the nominal expiry; never let it
      // shorten the window the user already has.
      const graceIso = msToIso(event.grace_period_expiration_at_ms);
      if (graceIso !== null && (expiresAt === null || graceIso > expiresAt)) {
        record.expires_at = graceIso;
      }
      break;
    }
    case "PRODUCT_CHANGE":
      // Only the product changes; leave status/will_renew untouched.
      record.product_id = event.new_product_id ?? event.product_id ?? null;
      break;
    case "SUBSCRIPTION_PAUSED":
      record.status = "paused";
      record.will_renew = false;
      break;
    // Play Store only: a refund was reversed and access is reinstated; the
    // event carries the restored expiration. (Refunds themselves arrive as
    // CANCELLATION/EXPIRATION with an updated expiration_at_ms.)
    case "REFUND_REVERSED":
      record.status = "active";
      break;
    default:
      return { action: "ignore", reason: `event type ${type} ignored` };
  }

  return {
    action: "upsert",
    eventType: type,
    userId: appUserId,
    entitlementId,
    eventTimestampMs,
    record,
  };
}
