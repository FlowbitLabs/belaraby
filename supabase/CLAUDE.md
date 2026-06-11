# Supabase (`supabase/`) — Claude Context

Postgres migrations, edge functions, project config (settings-as-code) and seed data.

## Directory Map

```
config.toml            # SOURCE OF TRUTH for project settings — never edit in the dashboard
migrations/            # append-only; one file per change
seed.local.sql         # local-dev seed (applied by `supabase db reset`)
functions/
├── deno.json
├── _shared/           # code imported by functions (NOT deployed as a function)
│   ├── http.ts        # response helpers
│   ├── revenuecat.ts  # pure RevenueCat event → subscription-row mapping
│   └── timing_safe_equal.ts
├── _tests/            # deno unit tests for the handlers
├── revenuecat-webhook/  # writes public.subscriptions; own shared-secret auth
├── delete-account/      # full account deletion; handler is its own auth boundary
└── demo-subscription/
```

Each function: `index.ts` is a thin `Deno.serve(handler)` entrypoint; all
testable logic lives in `handler.ts`. Directories starting with `_` are not
deployed. New function directories deploy automatically — no workflow change.

## Commands

```bash
supabase start                  # local stack (Docker); Studio :54323, API :54321
supabase db reset               # re-apply all migrations + seed (CI proves this)
supabase migration new <name>   # create a migration — NEVER edit existing ones
supabase db push                # push migrations to production (CI does this)

cd functions
deno check **/*.ts && deno lint && deno test --allow-all _tests/
```

## Migrations

- Append-only: one new file per change, `<timestamp>_<description>.sql`
  (use `supabase migration new`)
- Idempotent SQL: `IF NOT EXISTS`, `IF EXISTS`, `OR REPLACE`
- Rollback comment at the top of destructive migrations
- Schema changes ripple: update the Dart model (`frontend/lib/data/models/`)
  and TS interface (`dashboard/src/types.ts`) in the same change

## Row Level Security

- RLS enabled on every table; explicit policy per operation
- `auth.uid()` scopes user data; `public.is_admin()` gates admin writes
- Restrictive defaults: deny all, then add allow policies

```sql
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public can read lessons" ON lessons FOR SELECT USING (true);
CREATE POLICY "owner can update" ON lessons FOR UPDATE USING (auth.uid() = user_id);
```

## Domain Facts (load-bearing)

- Premium story bodies are masked: the real table is `private.lessons`;
  `public.lessons` is a masking view (`gate_premium_story_body` migration).
  Premium access = `public.has_active_subscription()` (driven only by
  `subscriptions.expires_at`).
- Every app install signs in anonymously; a pg_cron job
  (`anonymous_user_cleanup`) deletes stale anonymous users after 90 days.
- `revenuecat-webhook` and `delete-account` run with `verify_jwt = false`
  (see config.toml comments and DEPLOYMENT.md §1 for why) — both enforce
  auth inside the handler.
- Webhook ordering: RevenueCat is at-least-once/unordered; staleness is
  guarded via `subscriptions.last_event_timestamp_ms`.

## Deploy

Push to `main` touching `migrations/`, `functions/` or `config.toml` runs
`db push` → `config push` → `functions deploy` (serialized). Details,
secrets and runbooks: ../DEPLOYMENT.md.
