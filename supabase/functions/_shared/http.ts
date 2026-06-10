// Shared JSON response helpers for the edge functions.
//
// Every response body is `{ ok, message }` so clients and the RevenueCat
// delivery log can always read a human-readable reason. RevenueCat retries
// any non-2xx response, so a handler must answer ok(...) for events it
// understands but deliberately drops (TEST, anonymous ids, ...).

export function json(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

export function ok(message: string): Response {
  return json(200, { ok: true, message });
}
