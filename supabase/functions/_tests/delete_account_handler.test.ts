// Unit tests for the delete-account HTTP guards. The happy path (JWT →
// auth.admin.deleteUser → cascades) needs a running auth server and is
// exercised end-to-end via `supabase functions serve`.

import { assertEquals } from "jsr:@std/assert@1";
import { handler } from "../delete-account/handler.ts";
import { withEnv } from "./helpers.ts";

Deno.test("405 for non-POST requests", async () => {
  const res = await handler(
    new Request("http://localhost/delete-account", { method: "GET" }),
  );
  assertEquals(res.status, 405);
  assertEquals((await res.json()).ok, false);
});

Deno.test("401 when the Authorization header is missing", async () => {
  // The function is deployed with verify_jwt = false (the gateway cannot
  // verify the asymmetric ES256 user JWTs current projects issue), so this
  // handler-side check IS the auth boundary — not defense in depth.
  const res = await handler(
    new Request("http://localhost/delete-account", { method: "POST" }),
  );
  assertEquals(res.status, 401);
});

Deno.test("500 when the SUPABASE_* env vars are missing", async () => {
  await withEnv({
    SUPABASE_URL: null,
    SUPABASE_ANON_KEY: null,
    SUPABASE_SERVICE_ROLE_KEY: null,
  }, async () => {
    const res = await handler(
      new Request("http://localhost/delete-account", {
        method: "POST",
        headers: { Authorization: "Bearer some-jwt" },
      }),
    );
    assertEquals(res.status, 500);
  });
});
