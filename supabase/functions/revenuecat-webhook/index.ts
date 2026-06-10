// RevenueCat webhook -> public.subscriptions
//
// Entrypoint only. The request handling lives in ./handler.ts and the pure
// event-type mapping in ../_shared/revenuecat.ts so both are importable from
// the unit tests in ../_tests/ without starting a server.

import { handler } from "./handler.ts";

Deno.serve(handler);
