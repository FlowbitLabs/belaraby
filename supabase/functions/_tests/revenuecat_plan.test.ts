// Unit tests for the pure RevenueCat event mapping (_shared/revenuecat.ts).
// Every event-type branch is covered here; the HTTP guard branches of the
// handler are covered in revenuecat_handler.test.ts.

import {
  assert,
  assertEquals,
  assertFalse,
} from "jsr:@std/assert@1";
import {
  msToIso,
  planEvent,
  type RevenueCatEvent,
  type UpsertPlan,
} from "../_shared/revenuecat.ts";
import { timingSafeEqual } from "../_shared/timing_safe_equal.ts";

const USER_ID = "11111111-2222-3333-4444-555555555555";
const OTHER_USER_ID = "99999999-8888-7777-6666-555555555555";
const EVENT_TS_MS = 1749000000000;
const EXPIRY_MS = 1750000000000;
const EXPIRY_ISO = new Date(EXPIRY_MS).toISOString();

function event(
  overrides: Partial<RevenueCatEvent> & { type: string },
): RevenueCatEvent {
  return {
    app_user_id: USER_ID,
    product_id: "belaraby_premium_monthly",
    store: "APP_STORE",
    environment: "PRODUCTION",
    original_transaction_id: "txn_1",
    event_timestamp_ms: EVENT_TS_MS,
    expiration_at_ms: EXPIRY_MS,
    ...overrides,
  };
}

function asUpsert(e: RevenueCatEvent): UpsertPlan {
  const plan = planEvent(e);
  assertEquals(plan.action, "upsert");
  return plan as UpsertPlan;
}

// ─── Entitlement-granting events ──────────────────────────────────────────────

for (
  const type of [
    "INITIAL_PURCHASE",
    "RENEWAL",
    "UNCANCELLATION",
    "NON_RENEWING_PURCHASE",
    "SUBSCRIPTION_EXTENDED",
  ]
) {
  Deno.test(`${type} maps to an active, renewing row`, () => {
    const plan = asUpsert(event({ type }));
    assertEquals(plan.eventType, type);
    assertEquals(plan.userId, USER_ID);
    assertEquals(plan.entitlementId, "premium");
    assertEquals(plan.eventTimestampMs, EVENT_TS_MS);
    assertEquals(plan.record.user_id, USER_ID);
    assertEquals(plan.record.entitlement_id, "premium");
    assertEquals(plan.record.status, "active");
    assertEquals(plan.record.will_renew, true);
    assertEquals(plan.record.expires_at, EXPIRY_ISO);
    assertEquals(plan.record.last_event_timestamp_ms, EVENT_TS_MS);
    assertEquals(plan.record.product_id, "belaraby_premium_monthly");
    assertEquals(plan.record.store, "APP_STORE");
    assertEquals(plan.record.environment, "PRODUCTION");
    assertEquals(plan.record.original_transaction_id, "txn_1");
  });
}

Deno.test("entitlement id comes from entitlement_ids[0] when present", () => {
  const plan = asUpsert(
    event({ type: "INITIAL_PURCHASE", entitlement_ids: ["gold", "premium"] }),
  );
  assertEquals(plan.entitlementId, "gold");
  assertEquals(plan.record.entitlement_id, "gold");
});

Deno.test("entitlement id falls back to premium for empty/null lists", () => {
  assertEquals(
    asUpsert(event({ type: "RENEWAL", entitlement_ids: [] })).entitlementId,
    "premium",
  );
  assertEquals(
    asUpsert(event({ type: "RENEWAL", entitlement_ids: null })).entitlementId,
    "premium",
  );
});

// ─── CANCELLATION ────────────────────────────────────────────────────────────

Deno.test("CANCELLATION keeps the access window (expires_at untouched)", () => {
  const plan = asUpsert(event({ type: "CANCELLATION" }));
  assertEquals(plan.record.status, "cancelled");
  assertEquals(plan.record.will_renew, false);
  assertEquals(plan.record.expires_at, EXPIRY_ISO);
});

Deno.test("CANCELLATION without expiration_at_ms never writes expires_at", () => {
  const plan = asUpsert(
    event({ type: "CANCELLATION", expiration_at_ms: null }),
  );
  assertFalse("expires_at" in plan.record);
});

// ─── EXPIRATION ──────────────────────────────────────────────────────────────

Deno.test("EXPIRATION maps to expired, not renewing", () => {
  const plan = asUpsert(event({ type: "EXPIRATION" }));
  assertEquals(plan.record.status, "expired");
  assertEquals(plan.record.will_renew, false);
});

// ─── BILLING_ISSUE ───────────────────────────────────────────────────────────

Deno.test("BILLING_ISSUE without grace period keeps the nominal expiry", () => {
  const plan = asUpsert(event({ type: "BILLING_ISSUE" }));
  assertEquals(plan.record.status, "billing_issue");
  assertEquals(plan.record.expires_at, EXPIRY_ISO);
  assertFalse("will_renew" in plan.record);
});

Deno.test("BILLING_ISSUE grace period extends expires_at when later", () => {
  const graceMs = EXPIRY_MS + 86_400_000;
  const plan = asUpsert(
    event({ type: "BILLING_ISSUE", grace_period_expiration_at_ms: graceMs }),
  );
  assertEquals(plan.record.expires_at, new Date(graceMs).toISOString());
});

Deno.test("BILLING_ISSUE grace period never shortens expires_at", () => {
  const plan = asUpsert(
    event({
      type: "BILLING_ISSUE",
      grace_period_expiration_at_ms: EXPIRY_MS - 86_400_000,
    }),
  );
  assertEquals(plan.record.expires_at, EXPIRY_ISO);
});

Deno.test("BILLING_ISSUE grace period applies when no expiry is present", () => {
  const graceMs = EXPIRY_MS + 1;
  const plan = asUpsert(
    event({
      type: "BILLING_ISSUE",
      expiration_at_ms: null,
      grace_period_expiration_at_ms: graceMs,
    }),
  );
  assertEquals(plan.record.expires_at, new Date(graceMs).toISOString());
});

// ─── PRODUCT_CHANGE ──────────────────────────────────────────────────────────

Deno.test("PRODUCT_CHANGE swaps the product and touches nothing else", () => {
  const plan = asUpsert(
    event({
      type: "PRODUCT_CHANGE",
      new_product_id: "belaraby_premium_yearly",
    }),
  );
  assertEquals(plan.record.product_id, "belaraby_premium_yearly");
  assertFalse("status" in plan.record);
  assertFalse("will_renew" in plan.record);
});

Deno.test("PRODUCT_CHANGE falls back to product_id without new_product_id", () => {
  const plan = asUpsert(event({ type: "PRODUCT_CHANGE" }));
  assertEquals(plan.record.product_id, "belaraby_premium_monthly");
});

// ─── SUBSCRIPTION_PAUSED ─────────────────────────────────────────────────────

Deno.test("SUBSCRIPTION_PAUSED maps to paused, not renewing", () => {
  const plan = asUpsert(event({ type: "SUBSCRIPTION_PAUSED" }));
  assertEquals(plan.record.status, "paused");
  assertEquals(plan.record.will_renew, false);
});

// ─── TRANSFER ────────────────────────────────────────────────────────────────

Deno.test("TRANSFER picks the UUID entries from the transfer lists", () => {
  const plan = planEvent(
    event({
      type: "TRANSFER",
      transferred_from: ["$RCAnonymousID:abc123", USER_ID],
      transferred_to: ["$RCAnonymousID:def456", OTHER_USER_ID],
    }),
  );
  assertEquals(plan, {
    action: "transfer",
    fromUserId: USER_ID,
    toUserId: OTHER_USER_ID,
  });
});

Deno.test("TRANSFER without two UUID user ids is ignored", () => {
  for (
    const lists of [
      { transferred_from: ["$RCAnonymousID:abc"], transferred_to: [USER_ID] },
      { transferred_from: [USER_ID], transferred_to: ["$RCAnonymousID:abc"] },
      { transferred_from: [], transferred_to: [] },
      { transferred_from: null, transferred_to: null },
    ]
  ) {
    const plan = planEvent(event({ type: "TRANSFER", ...lists }));
    assertEquals(plan.action, "ignore");
  }
});

// Documents existing behavior: the anonymous-id guard runs before the
// TRANSFER branch, so a TRANSFER reported under a $RCAnonymousID app_user_id
// is dropped even if its transfer lists contain UUIDs.
Deno.test("TRANSFER under an anonymous app_user_id is ignored", () => {
  const plan = planEvent(
    event({
      type: "TRANSFER",
      app_user_id: "$RCAnonymousID:abc123",
      transferred_from: [USER_ID],
      transferred_to: [OTHER_USER_ID],
    }),
  );
  assertEquals(plan.action, "ignore");
});

// ─── Ignored events ──────────────────────────────────────────────────────────

Deno.test("TEST events are ignored", () => {
  const plan = planEvent(event({ type: "TEST" }));
  assertEquals(plan, { action: "ignore", reason: "TEST event ignored" });
});

Deno.test("SANDBOX environment events are ignored by default", () => {
  const plan = planEvent(
    event({ type: "INITIAL_PURCHASE", environment: "SANDBOX" }),
  );
  assertEquals(plan, {
    action: "ignore",
    reason: "SANDBOX environment event ignored",
  });
});

Deno.test("SANDBOX events apply when allowSandbox is set", () => {
  const plan = planEvent(
    event({ type: "INITIAL_PURCHASE", environment: "SANDBOX" }),
    { allowSandbox: true },
  );
  assertEquals(plan.action, "upsert");
});

Deno.test("REFUND_REVERSED reinstates access", () => {
  const plan = asUpsert(event({ type: "REFUND_REVERSED" }));
  assertEquals(plan.record.status, "active");
  assertEquals(plan.record.expires_at, EXPIRY_ISO);
});

Deno.test("unknown event types are ignored", () => {
  const plan = planEvent(event({ type: "SOME_FUTURE_EVENT" }));
  assertEquals(plan, {
    action: "ignore",
    reason: "event type SOME_FUTURE_EVENT ignored",
  });
});

Deno.test("$RCAnonymousID app_user_id is ignored", () => {
  const plan = planEvent(
    event({ type: "INITIAL_PURCHASE", app_user_id: "$RCAnonymousID:abc123" }),
  );
  assertEquals(plan, {
    action: "ignore",
    reason: "anonymous app_user_id ignored",
  });
});

Deno.test("non-UUID app_user_id is ignored", () => {
  for (const appUserId of ["legacy_user_42", "", undefined]) {
    const plan = planEvent(
      event({ type: "INITIAL_PURCHASE", app_user_id: appUserId }),
    );
    assertEquals(plan, {
      action: "ignore",
      reason: "non-UUID app_user_id ignored",
    });
  }
});

// ─── Timestamp handling ──────────────────────────────────────────────────────

Deno.test("missing event_timestamp_ms yields null and writes no column", () => {
  const plan = asUpsert(event({ type: "RENEWAL", event_timestamp_ms: null }));
  assertEquals(plan.eventTimestampMs, null);
  assertFalse("last_event_timestamp_ms" in plan.record);
});

Deno.test("msToIso converts finite numbers and rejects everything else", () => {
  assertEquals(msToIso(0), "1970-01-01T00:00:00.000Z");
  assertEquals(msToIso(EXPIRY_MS), EXPIRY_ISO);
  assertEquals(msToIso(null), null);
  assertEquals(msToIso(undefined), null);
  assertEquals(msToIso(Number.NaN), null);
  assertEquals(msToIso(Number.POSITIVE_INFINITY), null);
  assertEquals(msToIso("1750000000000"), null);
});

// ─── timingSafeEqual ─────────────────────────────────────────────────────────

Deno.test("timingSafeEqual matches only identical strings", async () => {
  assert(await timingSafeEqual("secret-value", "secret-value"));
  assert(await timingSafeEqual("", ""));
  assertFalse(await timingSafeEqual("secret-value", "secret-valuf"));
  assertFalse(await timingSafeEqual("secret-value", "secret-valu"));
  assertFalse(await timingSafeEqual("", "secret-value"));
});
