// Unit tests for the revenuecat-webhook HTTP guards (auth, env, body
// validation) and the no-database "ignore" paths. Branches that reach
// Postgres (upsert, transfer, stale-check) are exercised end-to-end via
// `supabase functions serve` instead — they need a running stack.

import { assertEquals } from "jsr:@std/assert@1";
import { handler } from "../revenuecat-webhook/handler.ts";
import { withEnv } from "./helpers.ts";

const SECRET = "test-webhook-secret";
const USER_ID = "11111111-2222-3333-4444-555555555555";

function request(
  body: string,
  headers: Record<string, string> = {},
): Request {
  return new Request("http://localhost/revenuecat-webhook", {
    method: "POST",
    headers: { "Content-Type": "application/json", ...headers },
    body,
  });
}

function authed(body: unknown): Request {
  return request(JSON.stringify(body), { Authorization: SECRET });
}

Deno.test("500 when REVENUECAT_WEBHOOK_AUTH is unset (never runs open)", async () => {
  await withEnv({ REVENUECAT_WEBHOOK_AUTH: null }, async () => {
    const res = await handler(authed({ event: { type: "TEST" } }));
    assertEquals(res.status, 500);
  });
});

Deno.test("401 when the Authorization header is missing", async () => {
  await withEnv({ REVENUECAT_WEBHOOK_AUTH: SECRET }, async () => {
    const res = await handler(
      request(JSON.stringify({ event: { type: "TEST" } })),
    );
    assertEquals(res.status, 401);
  });
});

Deno.test("401 when the Authorization header does not match", async () => {
  await withEnv({ REVENUECAT_WEBHOOK_AUTH: SECRET }, async () => {
    const res = await handler(
      request(JSON.stringify({ event: { type: "TEST" } }), {
        Authorization: "wrong-secret",
      }),
    );
    assertEquals(res.status, 401);
  });
});

Deno.test("400 for a malformed JSON body", async () => {
  await withEnv({ REVENUECAT_WEBHOOK_AUTH: SECRET }, async () => {
    const res = await handler(
      request("{not json", { Authorization: SECRET }),
    );
    assertEquals(res.status, 400);
  });
});

Deno.test("400 when the body carries no usable event", async () => {
  await withEnv({ REVENUECAT_WEBHOOK_AUTH: SECRET }, async () => {
    for (const body of [{}, { event: {} }, { event: { type: 42 } }]) {
      const res = await handler(authed(body));
      assertEquals(res.status, 400);
    }
  });
});

// The ignore paths must answer 200 (RevenueCat retries anything else forever)
// and must do so without a Supabase client — no SUPABASE_* env needed.
Deno.test("200 for ignored events, without touching the database", async () => {
  await withEnv({
    REVENUECAT_WEBHOOK_AUTH: SECRET,
    SUPABASE_URL: null,
    SUPABASE_SERVICE_ROLE_KEY: null,
  }, async () => {
    const cases: Array<[Record<string, unknown>, string]> = [
      [{ type: "TEST" }, "TEST event ignored"],
      [
        { type: "INITIAL_PURCHASE", app_user_id: "$RCAnonymousID:abc123" },
        "anonymous app_user_id ignored",
      ],
      [
        { type: "INITIAL_PURCHASE", app_user_id: "legacy_user_42" },
        "non-UUID app_user_id ignored",
      ],
      [
        { type: "SOME_FUTURE_EVENT", app_user_id: USER_ID },
        "event type SOME_FUTURE_EVENT ignored",
      ],
    ];
    for (const [event, message] of cases) {
      const res = await handler(authed({ event }));
      assertEquals(res.status, 200);
      assertEquals(await res.json(), { ok: true, message });
    }
  });
});
