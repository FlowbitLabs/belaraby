# Deployment

## Branching strategy

```
feature/* ──► dev ──► staging ──► prod
```

| Branch | Environment | Auto-deploys |
|---|---|---|
| `dev` | Local development | Nothing (manual `supabase start`) |
| `staging` | Staging | Supabase staging, Cloudflare Workers staging, Flutter internal/TestFlight |
| `prod` | Production | Supabase prod, Cloudflare Workers prod, Flutter production/App Store |

### CI

`.github/workflows/ci.yml` runs on every PR into `dev`/`staging`/`prod` and
every push to `dev`. Jobs are path-filtered (each runs only when its tree —
or the workflow file — changed):

- **flutter** — `flutter analyze --fatal-infos` + `flutter test` (Flutter 3.35.2, matching the deploy workflow)
- **dashboard** — `npm run type-check`, report-only ESLint, `npm run test` (vitest — the only CI coverage of the menu-hidden lesson-content authoring views), `npm run build`
- **supabase** — `supabase db start` + `supabase db reset` (proves all migrations apply from scratch) + `supabase db lint`
- **functions** — `deno check` + `deno lint` + `deno test` over the edge functions (unit tests in `supabase/functions/_tests/` cover every RevenueCat event-type mapping and the HTTP guard branches)

---

## 1. Supabase

Workflow: `.github/workflows/deploy_supabase_migration.yml` (display name: **Deploy Supabase**)
Triggers on push to `staging` or `prod` when files under `supabase/migrations/`, `supabase/functions/` or `supabase/config.toml` change.

It runs, in order:

1. `supabase db push` — applies new migrations
2. `supabase config push --yes` — applies `supabase/config.toml` to the project
3. `supabase functions deploy --use-api` — deploys all edge functions

Deploys are serialized per branch via a `concurrency` group
(`deploy-supabase-<ref>`, `cancel-in-progress: false`) so two pushes can
never interleave their db/config/functions steps.

Each environment needs its own Supabase project and corresponding GitHub environment variables.

**GitHub environments** (Settings → Environments): create `staging` and `prod`.

| Variable/Secret | `staging` value | `prod` value |
|---|---|---|
| `SUPABASE_ACCESS_TOKEN` (secret, shared) | same token | same token |
| `SUPABASE_PROJECT_ID` (var) | staging project ref | prod project ref |
| `AUTH_SITE_URL` (var) | staging public URL (e.g. the staging dashboard URL) | prod public URL |

### Settings as code (`config.toml`)

`supabase/config.toml` is the **source of truth** for project settings (auth,
API, functions, …). CI pushes it on every deploy via `supabase config push`.
There is no `config pull` — never change settings in the Supabase dashboard
and expect them to survive: edit `config.toml` instead.

Notes:

- `site_url` / `additional_redirect_urls` in `config.toml` are **local-dev
  values** (127.0.0.1). The deploy workflow substitutes the environment's
  `AUTH_SITE_URL` GitHub variable before pushing, so the hosted projects
  never get localhost auth URLs (which would break admin invite/recovery
  email links and redirect allow-lists). The deploy **fails loudly** when
  `AUTH_SITE_URL` is not set on the GitHub environment.
- Sections that reference `env(...)` variables (Twilio SMS, Apple OAuth,
  experimental S3, Studio OpenAI key) are commented out so `config push`
  works in CI without those env vars. Each block has a comment explaining how
  to re-enable it.
- `enable_anonymous_sign_ins = true` — the app bootstraps **every** user with
  `signInAnonymously()`; favorites, learned lessons and subscriptions rely on
  it. `config push` applies this, but if you configure a project before the
  first deploy, enable it manually under Supabase Dashboard → Authentication →
  Sign In / Providers → "Allow anonymous sign-ins".
- `[functions.revenuecat-webhook] verify_jwt = false` — the RevenueCat
  webhook authenticates with its own shared secret, not a Supabase JWT.
- `[functions.delete-account] verify_jwt = false` — the functions gateway
  cannot verify the **asymmetric (ES256) user JWTs** that current Supabase
  projects issue by default, so gateway verification would 401 every
  legitimate call. The function enforces auth itself (see *Edge functions*
  below).

### Edge functions

The deploy workflow runs a bare `supabase functions deploy --use-api`, so
every directory under `supabase/functions/` is deployed automatically — no
workflow change is needed when a function is added. Directories starting
with `_` are **not** deployed: `_shared/` holds code imported by the
functions (notably the pure RevenueCat event mapping), `_tests/` holds the
deno unit tests. Each function's `index.ts` is a thin `Deno.serve(handler)`
entrypoint; the testable request handling lives in its `handler.ts`.

**`revenuecat-webhook`** processes RevenueCat webhooks and writes
`public.subscriptions` with the service role. It rejects any request whose
`Authorization` header does not match the `REVENUECAT_WEBHOOK_AUTH` function
secret (constant-time comparison; see the RevenueCat section below for
setup). It also skips stale/out-of-order deliveries (RevenueCat is
at-least-once and unordered) via `subscriptions.last_event_timestamp_ms`,
and answers 200 when the target user no longer exists so RevenueCat stops
retrying events for deleted accounts.

**`delete-account`** implements full account deletion (required by both app
stores). Design:

- Gateway `verify_jwt` is **off** (`[functions.delete-account]` in
  `config.toml`): current Supabase projects sign user access tokens with
  asymmetric keys (ES256) by default, which the functions gateway cannot
  verify — with `verify_jwt` on, every legitimate call 401s before the
  handler runs. The **handler is its own auth boundary**: it returns 401 for
  any request without a valid user JWT.
- The user id is derived **only from the caller's JWT** (`auth.getUser()` on
  an anon-key client that forwards the request's `Authorization` header) —
  never from the request body, so a user can only ever delete themselves.
- Deletion happens via the service-role admin API
  (`auth.admin.deleteUser(userId)`). All four `auth.users` foreign keys —
  `profiles`, `subscriptions`, `user_favorites`, `user_learned_lessons` —
  are `ON DELETE CASCADE`, so one call erases every row the user owns.
- The Flutter app calls `supabase.functions.invoke('delete-account')`, then
  signs out and starts a fresh anonymous session.
- Returns 200 JSON on success, 401 without a valid JWT.

---

## 2. Dashboard → Cloudflare Workers

Workflow: `.github/workflows/deploy_dashboard.yml`
Triggers on push to `staging` or `prod` when `dashboard/**` changes.

The dashboard is served as Workers **static assets** — on the Cloudflare free
plan static-asset requests are free and unmetered, and commercial use is
permitted (unlike Vercel's Hobby plan, which is non-commercial only and
cannot connect to org-owned repos). Config lives in `dashboard/wrangler.toml`
with two environments:

| Branch | Worker | URL |
|---|---|---|
| `staging` | `belaraby-admin-staging` | `https://belaraby-admin-staging.<your-subdomain>.workers.dev` |
| `prod` | `belaraby-admin-prod` | `https://belaraby-admin-prod.<your-subdomain>.workers.dev` |

**One-time setup:**
1. Create a Cloudflare account (free, no card).
2. Dashboard → My Profile → API Tokens → Create Token → use the
   **"Edit Cloudflare Workers"** template.
3. Add to GitHub repo secrets (shared, not per-environment):
   `CLOUDFLARE_API_TOKEN` (the token) and `CLOUDFLARE_ACCOUNT_ID`
   (Cloudflare dashboard → Workers & Pages → right sidebar).

**Environment variables** — Vite bakes `VITE_SUPABASE_URL` /
`VITE_SUPABASE_KEY` in at **build time** (`dashboard/src/App.tsx`). The
workflow reuses the existing `SUPABASE_URL` / `SUPABASE_ANON_KEY` GitHub
environment secrets (same values the Flutter build uses), so there is
nothing extra to configure per environment.

> The key must be the anon JWT format (`eyJ...`) — ra-supabase does not work
> with the `sb_publishable_` format.

**Optional hardening — Cloudflare Access:** the Zero Trust free tier (up to
50 users) can put an email/SSO login wall in front of the admin Workers
before React Admin's own login even loads: Zero Trust → Access →
Applications → add the two `workers.dev` hostnames and an allow-policy for
your admin emails. Note: Zero Trust signup asks for payment details even on
the free plan (it does not charge).

**Optional:** map a custom domain (e.g. `admin.belaraby.app`) to the prod
Worker via a `routes` entry in `wrangler.toml` once the domain is on
Cloudflare.

The dashboard login is ra-supabase's email/password page; `/forgot-password`
and `/set-password` handle the Supabase invite/recovery email callbacks. For
those links to work, the Supabase Auth redirect allow-list must include the
dashboard origin — set the `AUTH_SITE_URL` GitHub variable (section 1) to the
environment's dashboard URL so the deploy workflow pushes it into
`site_url`/`additional_redirect_urls`.

### Making a dashboard admin

Dashboard access is gated by `profiles.is_admin` and RLS policies built on
`public.is_admin()`. Admin auth users themselves are created manually in
Supabase Auth → Users. To promote a user:

1. Create (or locate) the user in Supabase Auth → Users — a `profiles` row is
   auto-created by trigger on signup.
2. Run in the SQL editor (or Supabase Studio):

```sql
update public.profiles set is_admin = true where id = '<user-uuid>';
```

The **first** admin must be promoted this way: the dashboard's `is_admin`
checkbox is itself protected by the `is_admin()` RLS policies, so it is only
usable by someone who is already an admin.

Admins can manage lessons and all lesson content, edit profiles (including
the `is_admin` toggle for other users — only the *first* admin needs the SQL
above), and read subscriptions, favorites and learned-lessons data.
Non-admin clients can never change `is_admin` or `role`: a database trigger
(`protect_profiles_privileged_columns`) reverts those columns on any
non-admin write.

---

## 3. Flutter → App Store + Play Store

Workflow: `.github/workflows/deploy_flutter.yml`
Triggers on push to `staging` or `prod` **only when `frontend/**` (or the
workflow file itself) changed** — Supabase/dashboard-only pushes do not burn
macOS IPA build minutes. Deploys are serialized per branch via a
`concurrency` group (`deploy-flutter-<ref>`, `cancel-in-progress: false`).

Supabase credentials are injected at build time via `--dart-define` so each environment points to the right backend.

Four `--dart-define` values are passed to every CI build: `SUPABASE_URL`,
`SUPABASE_ANON_KEY`, `REVENUECAT_APPLE_API_KEY` (public Apple SDK key,
`appl_...`) and `REVENUECAT_GOOGLE_API_KEY` (`goog_...`). The RevenueCat keys
are optional at runtime: when a key is absent the app still builds and runs
with billing disabled (the paywall shows "purchases unavailable"), so local
and dev builds need no store credentials.

**Build numbers:** both stores reject a re-used build number (Play:
`versionCode`, TestFlight: `CFBundleVersion`), and staging + prod share **one
sequence** (staging → internal and prod → production are the *same* Play app;
both branches upload to the same TestFlight app). CI therefore passes
`--build-number=$(( github.run_number + 10 ))` to both builds — monotonically
increasing, no manual step. The **marketing version** (`1.0.0`) still comes
from `pubspec.yaml`: bump it there for user-visible releases (see section 8).
If you ever upload a build manually, keep its build number below the current
CI sequence or raise the `+10` offset in the workflow.

**GitHub environment secrets** — set on both `staging` and `prod` environments:

| Secret | staging | prod |
|---|---|---|
| `SUPABASE_URL` | staging project URL | prod project URL |
| `SUPABASE_ANON_KEY` | staging anon key | prod anon key |
| `REVENUECAT_APPLE_API_KEY` | public Apple SDK key | public Apple SDK key |
| `REVENUECAT_GOOGLE_API_KEY` | public Google SDK key | public Google SDK key |
| `ANDROID_KEYSTORE_BASE64` | same | same |
| `ANDROID_STORE_PASSWORD` | same | same |
| `ANDROID_KEY_PASSWORD` | same | same |
| `PLAY_STORE_SERVICE_ACCOUNT` | same | same |
| `APPLE_ISSUER_ID` | same | same |
| `APPLE_API_KEY_ID` | same | same |
| `APPLE_API_PRIVATE_KEY` | same | same |
| `APPLE_CERTIFICATE_BASE64` | same | same |
| `APPLE_CERTIFICATE_PASSWORD` | same | same |

`APPLE_CERTIFICATE_BASE64` is the base64 of the Apple **distribution
certificate** exported as `.p12` (Keychain Access → export, then
`base64 -i cert.p12 | pbcopy`); `APPLE_CERTIFICATE_PASSWORD` is the password
chosen at export. The iOS job imports the certificate into the runner
keychain and downloads the App Store provisioning profile for
`com.belaraby.belaraby` via the App Store Connect API before building.

**Play Store track per branch:**
- `staging` → internal track
- `prod` → production track

**iOS:** Both branches upload to TestFlight. Promote to App Store manually from App Store Connect.

---

### One-time setup

**Android keystore:**
```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

For local release builds, create `frontend/android/key.properties`
(gitignored) and place the keystore at `frontend/android/upload-keystore.jks`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

`android/app/build.gradle` is already wired: it signs release builds with
this keystore whenever `android/key.properties` exists (CI creates it from
the `ANDROID_*` secrets with the same `storeFile=../upload-keystore.jks`
path) and falls back to debug signing locally so `flutter run --release`
keeps working without store credentials.

**iOS:**
1. Create App ID `com.belaraby.belaraby` in Apple Developer portal
2. Create a distribution certificate and an App Store provisioning profile
   **named exactly `BelAraby App Store`** — the Runner **Release** config uses
   **manual signing** pinned to that profile name
   (`CODE_SIGN_STYLE = Manual`, `CODE_SIGN_IDENTITY = "Apple Distribution"`,
   `PROVISIONING_PROFILE_SPECIFIER = "BelAraby App Store"`, mirrored in
   `ExportOptions.plist`). Manual signing is required in CI: the runner only
   has the distribution certificate + downloaded App Store profile, and
   automatic signing ignores those (it wants a development cert /
   Xcode-managed profile, failing with "No profiles for
   'com.belaraby.belaraby' were found"). Rename the profile in the portal →
   update both files. Debug builds keep automatic signing, so `flutter run`
   is unaffected; local **release** builds need the profile installed
   (Xcode → Settings → Accounts → Download Manual Profiles).
3. Create the app record in App Store Connect
4. In Xcode, add the **In-App Purchase** capability to the Runner target
   (Signing & Capabilities → + Capability) — required by `purchases_flutter`
5. `frontend/ios/ExportOptions.plist` is committed (method `app-store`,
   team `DH3FB9KB74`, manual signing) — update `teamID` only if the Apple
   team changes

`purchases_flutter`, `url_launcher` and `package_info_plus` each add a
CocoaPod; `flutter build` runs `pod install` automatically after
`flutter pub get` (the minimum iOS version is already 13.0, no Podfile change
was needed) — no workflow change, dart-define or secret is needed for them.
The exported IPA is named after the Xcode product (`Runner.ipa`), which the
workflow resolves automatically.

Store-metadata facts: the display name (`CFBundleDisplayName`) is
**BelAraby**; `ITSAppUsesNonExemptEncryption` is `false`, so there is no
export-compliance questionnaire per upload; the app is **iPhone
portrait-only**.

**Play Store:**
1. Create the app in Google Play Console with package `com.belaraby.frontend`
2. Upload the first build manually — Google requires this before API uploads work

The `com.android.vending.BILLING` permission is merged automatically by the
`purchases_flutter` plugin — no `AndroidManifest.xml` edit is needed
(`minSdk 24` is already sufficient).

---

## 4. RevenueCat (subscriptions) — one-time setup

The app sells the `premium` entitlement via two products:
`belaraby_premium_monthly` and `belaraby_premium_yearly`.

1. **Create the RevenueCat project** at app.revenuecat.com.
2. **Add the apps:**
   - iOS app with bundle id `com.belaraby.belaraby` — upload an App Store
     Connect **In-App Purchase Key** to RevenueCat
   - Android app with package `com.belaraby.frontend` — link a Google Play
     **service-account JSON** in RevenueCat
3. **Create the subscription products** `belaraby_premium_monthly` and
   `belaraby_premium_yearly` as auto-renewable subscriptions in App Store
   Connect and as subscriptions in Google Play Console, then import/add them
   in RevenueCat.
4. **Entitlement + offering:** create the entitlement **`premium`**, attach
   both products to it, and create a **default (current) offering**
   containing the monthly + yearly packages — the paywall lists
   `offerings.current.availablePackages`, so without a current offering it
   shows "no plans available".
5. **SDK keys → GitHub secrets:** copy the *public* Apple and Google SDK keys
   (RevenueCat → Project → API keys) into the GitHub environment secrets
   `REVENUECAT_APPLE_API_KEY` and `REVENUECAT_GOOGLE_API_KEY` on **both**
   `staging` and `prod`. They are injected at build time via `--dart-define`.
   The app sets the RevenueCat `appUserID` to the Supabase auth user id
   (`Purchases.configure` at boot + `Purchases.logIn` on every auth change),
   so webhook user resolution can rely on `app_user_id` being
   `auth.users.id`.
6. **Webhook:** in RevenueCat → Project → Integrations → Webhooks, add a
   webhook pointing at:

   ```
   https://<project-ref>.supabase.co/functions/v1/revenuecat-webhook
   ```

   Set an **Authorization header value** (generate a long random string, e.g.
   `openssl rand -hex 32` — prefix it however you like; the function compares
   the header verbatim). Then set the *same* value once per Supabase project:

   ```bash
   supabase secrets set REVENUECAT_WEBHOOK_AUTH=<value> --project-ref <project-ref>
   ```

   The function returns 401 for any request without that exact header and
   500 if the secret is unset (it never runs open). Repeat for staging and
   prod (use the RevenueCat sandbox/production environments accordingly).

Premium access is derived **only** from `subscriptions.expires_at` (via
`public.has_active_subscription()`); `status` and `will_renew` are
informational — a cancellation keeps access until expiry.

Users manage/cancel subscriptions in the stores, not in the app: the
Settings screen links to `https://apps.apple.com/account/subscriptions`
(iOS) and `https://play.google.com/store/account/subscriptions` (Android).
Cancellations and expirations flow back through the RevenueCat webhook.

> **Testing purchases:** purchases can only be exercised with App Store
> sandbox testers / Google Play license testers on real builds — not on
> simulators without a store account.

---

## 5. Keep-alive + backups

### Keep-alive

Workflow: `.github/workflows/supabase_keep_alive.yml`
Free-tier Supabase projects pause after 7 days without API activity. The
workflow curls `GET $SUPABASE_URL/rest/v1/lessons?select=id&limit=1` against
**both** the `staging` and `prod` GitHub environments (a job matrix, so the
free-tier staging project never pauses either) every 3 days and on manual
dispatch, using each environment's existing `SUPABASE_URL` /
`SUPABASE_ANON_KEY` secrets, and fails loudly on any non-2xx response. The
matrix uses `fail-fast: false` — a staging failure does not skip the prod
ping or vice versa.

### Weekly backups

Workflow: `.github/workflows/supabase_backup.yml`
Runs weekly (and on manual dispatch) against the `prod` environment. It dumps
**three** files with `supabase db dump --db-url ...` and uploads them as a
GitHub artifact with **90-day retention**:

| File | Contents |
|---|---|
| `roles.sql` | custom Postgres roles (`--role-only`) |
| `schema.sql` | schema DDL — includes the `private` schema, **excludes** the managed schemas (`auth`, `storage`, …) |
| `data.sql` | **all** data (`--data-only`) — `auth.*` (users, identities, sessions, …), `storage.*`, `public.*` and `private.lessons`, which holds the **unmasked premium story bodies** (treat artifacts as sensitive) |

`data.sql` is self-sufficient: unlike the schema-DDL dump, the `--data-only`
dump **includes** the managed schemas' data, and `auth.users` is COPYed
before every table that FKs it (verified against CLI v2.72.7 and v2.105.0).
Do **not** add a separate auth-schema dump next to it — restoring both loads
every auth row twice, and the duplicate keys abort the whole restore
transaction.

It needs one new secret on the `prod` GitHub environment:

| Secret | Value |
|---|---|
| `SUPABASE_DB_URL` | the prod Postgres connection string, e.g. `postgresql://postgres.<project-ref>:<db-password>@aws-0-<region>.pooler.supabase.com:5432/postgres` (Supabase Dashboard → Connect → Session pooler URI) |

#### Restore runbook

> ⚠️ These backups have **never been restore-tested**. Do a dry run against a
> scratch project before you need them in anger.

1. Create a fresh Supabase project and grab its session-pooler connection
   string (`$DB_URL` below).
2. Restore **in this exact order** — roles, then schema, then data:

   ```bash
   psql --single-transaction -d "$DB_URL" -f roles.sql       # see note below
   psql --single-transaction -d "$DB_URL" -f schema.sql
   psql --single-transaction -d "$DB_URL" -f data.sql
   ```

3. Notes:
   - `roles.sql` emits `role "..." already exists` errors on a fresh project
     (Supabase pre-creates `anon`, `authenticated`, `service_role`, …). Those
     are ignorable — but because `--single-transaction` aborts on any error,
     run the roles file **without** `--single-transaction` (or pre-filter the
     existing roles) if it fails: `psql -d "$DB_URL" -f roles.sql`.
   - `schema.sql` includes the `private` schema (the real `lessons` table
     lives at `private.lessons` behind the masking `public.lessons` view).
     The managed schemas' DDL (`auth`, `storage`, …) already exists on a
     fresh project — that is why the schema dump excludes it.
   - `data.sql` carries the `auth`/`storage` **data** itself (users before
     the tables that FK them), so there is no separate auth restore step —
     the target project's auth tables must be empty (fresh project), or the
     COPYs will hit duplicate keys.
   - After restoring, re-set function secrets (`REVENUECAT_WEBHOOK_AUTH`) and
     redeploy edge functions — they are not part of the database dump.
   - The artifact is at most one week old: a restore loses **up to 7 days**
     of data (see Operations runbook below).

---

## 6. Operations runbook

### Free-tier ceilings (know what breaks first)

| Limit | Free tier | Notes |
|---|---|---|
| Database size | **500 MB** | per project |
| Egress | **5 GB / month** | lesson list responses carry the **full Arabic story bodies**, so egress is the ceiling that falls first as usage grows |
| Monthly active users | **50K MAU** | **includes anonymous users** — every install creates one (the pg_cron cleanup below keeps this in check) |
| Projects | **2 per org** | staging + prod already uses both |
| Pausing | after **7 days** idle | the keep-alive workflow pings staging + prod every 3 days |
| Log retention | **~1 day** | debug webhook/function incidents the same day or lose the logs |
| PITR | **none** | the weekly 90-day GitHub backup artifact is the **only** recovery path — a restore loses up to **7 days** of data |

### Alerts and routine checks

- Enable **spend/usage email alerts**: Supabase Dashboard → Organization →
  Usage → enable usage notifications (and set a spend cap if the org is ever
  upgraded). Do this once per org.
- **Weekly usage check** (piggyback on the weekly backup run): Dashboard →
  Project → Reports — watch DB size and egress against the table above.
- **RevenueCat webhook monitoring**, two sides:
  - Supabase: Dashboard → Edge Functions → `revenuecat-webhook` → error
    rate/logs (remember: ~1-day retention).
  - RevenueCat: Project → Integrations → Webhooks → delivery/health page —
    a growing retry backlog means the function is rejecting events.

### Anonymous-user retention policy

The app bootstraps **every** install with `signInAnonymously()`, so
`auth.users` grows by one row per device. A pg_cron job (migration
`20260610160200_anonymous_user_cleanup.sql`, daily at 04:17 UTC) deletes
anonymous users that meet **all** of:

- `is_anonymous = true`,
- account **and** last sign-in older than **90 days**,
- no `auth.sessions` / `auth.refresh_tokens` activity in 90 days
  (`last_sign_in_at` is not refreshed by token refresh, so session activity
  is checked separately),
- **no active subscription** (`expires_at > now()`) — paying users are never
  deleted.

Deletion cascades away the user's profile, favorites, learned lessons and
subscription rows — an anonymous user is that person's **only** identity, so
the 90-day window is deliberately generous. To change the policy, ship a new
migration that re-runs `cron.schedule(...)` (it upserts by job name); to stop
it: `SELECT cron.unschedule('delete-stale-anonymous-users');`.

### Account deletion

Implemented by the `delete-account` edge function — see *Edge functions* in
section 1 for the full design (JWT-derived user id, service-role
`auth.admin.deleteUser`, FK cascades, Flutter signs out into a fresh
anonymous session afterwards).

---

## 7. Local development

Run Flutter pointing at your local Supabase stack:

```bash
supabase start   # starts local stack at http://localhost:54321

cd frontend
flutter run \
  --dart-define=SUPABASE_URL=http://localhost:54321 \
  --dart-define=SUPABASE_ANON_KEY=<local-anon-key>
```

The local anon key is printed by `supabase start` or available in the Supabase Studio at `http://localhost:54323`.

---

## 8. Release flow

```
feature/* ──► dev        local dev + testing
dev ──► staging          staging deploy (Supabase + Dashboard + Flutter internal)
staging ──► prod         production deploy (Supabase + Dashboard + Flutter production)
```

**To release:**
1. For a user-visible version change, bump the **marketing version** in
   `frontend/pubspec.yaml` (e.g. `1.1.0+1`) — the build *number* is
   CI-generated per upload (see *Build numbers* in section 3), so it never
   needs a manual bump
2. Open a PR from `staging` → `prod`
3. Review and merge
4. All three production deployments trigger automatically
5. Promote iOS build from TestFlight → App Store in App Store Connect

---

## 9. Setup checklist

### Supabase
- [ ] Create a staging Supabase project
- [ ] Create a prod Supabase project
- [ ] Add `SUPABASE_ACCESS_TOKEN` secret to GitHub (shared)
- [ ] Add `SUPABASE_PROJECT_ID` var to GitHub `staging` environment
- [ ] Add `SUPABASE_PROJECT_ID` var to GitHub `prod` environment
- [ ] Add `AUTH_SITE_URL` var to GitHub `staging` environment (public URL — the deploy fails without it)
- [ ] Add `AUTH_SITE_URL` var to GitHub `prod` environment
- [ ] Verify "Allow anonymous sign-ins" is enabled on both projects (Auth → Sign In / Providers) — the app bootstraps every user with `signInAnonymously()`
- [ ] Verify the Deploy Supabase workflow runs on push to `staging` (migrations + config + functions)
- [ ] Verify the Deploy Supabase workflow runs on push to `prod` (migrations + config + functions)
- [ ] Add `SUPABASE_DB_URL` secret to GitHub `prod` environment (Postgres session-pooler connection string, for backups)
- [ ] Manually dispatch the Supabase Backup workflow once and check the artifact contains `roles.sql`, `schema.sql` and `data.sql`
- [ ] Restore-test the backup once against a scratch project (see the restore runbook — backups have never been restore-tested)
- [ ] Manually dispatch the Supabase Keep-Alive workflow once and check **both** the staging and prod pings pass (the job is a matrix over both environments; staging needs its `SUPABASE_URL`/`SUPABASE_ANON_KEY` secrets too)
- [ ] Enable Supabase spend/usage email alerts on the organization (see Operations runbook) and diarize a weekly usage check
- [ ] After the first deploy, verify the `delete-stale-anonymous-users` pg_cron job exists: `select jobname, schedule from cron.job;`
- [ ] E2E-verify account deletion on staging: with a real user JWT, `curl -X POST https://<staging-ref>.supabase.co/functions/v1/delete-account -H "Authorization: Bearer <jwt>" -H "apikey: <anon-key>"` must return **200** and the user's `profiles`/`subscriptions`/`user_favorites`/`user_learned_lessons` rows must be gone (the function runs with `verify_jwt = false` because the gateway cannot verify ES256 user JWTs — the handler enforces auth itself)

### RevenueCat
- [ ] Create the RevenueCat project
- [ ] Add iOS app (`com.belaraby.belaraby`) and Android app (`com.belaraby.frontend`)
- [ ] Upload an App Store Connect In-App Purchase Key to RevenueCat (iOS app)
- [ ] Link a Google Play service-account JSON in RevenueCat (Android app)
- [ ] Create `belaraby_premium_monthly` + `belaraby_premium_yearly` (auto-renewable) in App Store Connect
- [ ] Create `belaraby_premium_monthly` + `belaraby_premium_yearly` in Play Console
- [ ] Create entitlement `premium`, attach both products to it
- [ ] Create the default (current) offering with the monthly + yearly packages
- [ ] Add `REVENUECAT_APPLE_API_KEY` secret to GitHub `staging` + `prod`
- [ ] Add `REVENUECAT_GOOGLE_API_KEY` secret to GitHub `staging` + `prod`
- [ ] Configure the webhook to `https://<project-ref>.supabase.co/functions/v1/revenuecat-webhook` with an Authorization header value (per Supabase project)
- [ ] Run `supabase secrets set REVENUECAT_WEBHOOK_AUTH=<value>` for staging and prod projects (same value as the webhook Authorization header)
- [ ] Send the RevenueCat test webhook event and verify a 200 response

### Dashboard (Cloudflare Workers)
- [ ] Create a Cloudflare account (free)
- [ ] Create an API token with the "Edit Cloudflare Workers" template
- [ ] Add `CLOUDFLARE_API_TOKEN` secret to GitHub (shared)
- [ ] Add `CLOUDFLARE_ACCOUNT_ID` secret to GitHub (shared)
- [ ] Push to `staging` (or dispatch Deploy Dashboard) and verify `belaraby-admin-staging.<subdomain>.workers.dev` loads
- [ ] Optional: gate both Workers behind Cloudflare Access (Zero Trust free tier)
- [ ] Optional: remove the old Vercel project once Cloudflare is confirmed working
- [ ] Create an admin user in each Supabase project (Auth → Users)
- [ ] Promote it: `update public.profiles set is_admin = true where id = '<user-uuid>';` (required for the first admin — the dashboard `is_admin` checkbox only works for existing admins)
- [ ] Confirm dashboard login works and content is editable

### Android
- [ ] Generate upload keystore (`upload-keystore.jks`)
- [ ] For local release builds: create `frontend/android/key.properties` (gitignored) with `storeFile=../upload-keystore.jks` — `android/app/build.gradle` already reads it
- [ ] Test locally: `flutter build appbundle --release --dart-define=...`
- [ ] Create app in Google Play Console (package: `com.belaraby.frontend`)
- [ ] Do first manual upload to Play Console (required before API uploads)
- [ ] Create Play Store service account and grant it release permissions
- [ ] Add `ANDROID_KEYSTORE_BASE64` secret to GitHub `staging` + `prod`
- [ ] Add `ANDROID_STORE_PASSWORD` secret to GitHub `staging` + `prod`
- [ ] Add `ANDROID_KEY_PASSWORD` secret to GitHub `staging` + `prod`
- [ ] Add `PLAY_STORE_SERVICE_ACCOUNT` secret to GitHub `staging` + `prod`

### iOS
- [ ] Enroll in Apple Developer Program
- [ ] Create App ID `com.belaraby.belaraby` in Apple Developer portal
- [ ] Create distribution certificate and App Store provisioning profile — the profile must be named exactly **`BelAraby App Store`** (the Runner Release config and `ExportOptions.plist` use manual signing pinned to that name; see section 3)
- [ ] Create app record in App Store Connect
- [ ] Add the In-App Purchase capability to the Runner target in Xcode (Signing & Capabilities)
- [ ] Verify `frontend/ios/ExportOptions.plist` (committed) has the right `teamID`
- [ ] Test locally: `flutter build ipa --release --export-options-plist=ios/ExportOptions.plist --dart-define=...`
- [ ] Generate App Store Connect API key
- [ ] Add `APPLE_ISSUER_ID` secret to GitHub `staging` + `prod`
- [ ] Add `APPLE_API_KEY_ID` secret to GitHub `staging` + `prod`
- [ ] Add `APPLE_API_PRIVATE_KEY` secret to GitHub `staging` + `prod`
- [ ] Export the distribution certificate as `.p12` and add `APPLE_CERTIFICATE_BASE64` secret to GitHub `staging` + `prod`
- [ ] Add `APPLE_CERTIFICATE_PASSWORD` secret to GitHub `staging` + `prod`

### Flutter env vars
- [ ] Add `SUPABASE_URL` secret to GitHub `staging` environment
- [ ] Add `SUPABASE_ANON_KEY` secret to GitHub `staging` environment
- [ ] Add `SUPABASE_URL` secret to GitHub `prod` environment
- [ ] Add `SUPABASE_ANON_KEY` secret to GitHub `prod` environment

### CI/CD
- [ ] Open a PR into `dev` and verify the CI workflow runs only the jobs whose paths changed
- [ ] Push a migration to `staging` and verify Supabase workflow runs
- [ ] Dispatch the Deploy Flutter workflow once against `staging` to prove the iOS signing chain (certificate import + manual profile) end-to-end **before** relying on it for a release — it has never run on a clean runner
- [ ] Merge a change to `staging` and verify Flutter workflow runs (internal track + TestFlight) — note it only triggers when `frontend/**` changed
- [ ] Merge `staging` → `prod` and verify all production deployments succeed

### Store submission (blocking — both stores reject without these)
- [ ] **REQUIRED:** replace the placeholder app icons — `frontend/android/app/src/main/res/mipmap-*/ic_launcher.png` and `frontend/ios/Runner/Assets.xcassets/AppIcon.appiconset/` still contain the **stock Flutter template logo**. Apple rejects placeholder icons (Guideline 2.3.8) and Play would ship the generic Flutter "F". Generate branded icons for every density (e.g. with the `flutter_launcher_icons` package) and add an Android **adaptive icon**
- [ ] **REQUIRED:** host real privacy-policy and terms pages and replace the placeholder URLs in `frontend/lib/constant/legal_links.dart` (`https://belaraby.app/privacy` and `https://belaraby.app/terms`) **before** submitting to either store — both the paywall **and Settings** link to them, and Apple/Google both require working URLs (Apple additionally requires the privacy policy URL in App Store Connect, Google in the Play Console data-safety form)
- [ ] Verify the privacy policy covers account deletion (the in-app `delete-account` flow) and anonymous-usage data retention (90-day cleanup)
- [ ] Fill in the App Store privacy "nutrition labels" / Play data-safety form consistently with the hosted policy
