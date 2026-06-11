// Shared JSON response helpers for the edge functions.
//
// Every response body is `{ ok, message }` so clients and the RevenueCat
// delivery log can always read a human-readable reason. RevenueCat retries
// any non-2xx response, so a handler must answer ok(...) for events it
// understands but deliberately drops (TEST, anonymous ids, ...).
//
// CORS: the Flutter WEB app calls delete-account and demo-subscription from
// the browser, so every response needs CORS headers and handlers must answer
// the preflight (see preflight()) — without this the browser blocks the real
// request and the client only sees a generic failure.

export const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

/// Answers a CORS preflight request, or returns null for non-OPTIONS.
export function preflight(req: Request): Response | null {
  if (req.method !== "OPTIONS") return null;
  return new Response(null, { status: 204, headers: corsHeaders });
}

export function json(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
}

export function ok(message: string): Response {
  return json(200, { ok: true, message });
}
