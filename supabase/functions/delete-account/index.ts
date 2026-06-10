// Account deletion endpoint.
//
// Entrypoint only. The request handling lives in ./handler.ts so the unit
// tests in ../_tests/ can import it without starting a server.

import { handler } from "./handler.ts";

Deno.serve(handler);
