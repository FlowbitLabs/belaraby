# Belaraby (بالعربي)

An interactive Arabic learning platform: stories per CEFR level (A1–C2) with audio playback, keyword flashcards, grammar notes and quizzes. Flutter app (iOS, Android & web), React Admin dashboard, Supabase backend.

**Live:** [app.belaraby.workers.dev](https://app.belaraby.workers.dev) (app) · [admin.belaraby.workers.dev](https://admin.belaraby.workers.dev) (dashboard)

---

## Project Structure

```
belaraby/
├── frontend/     # Flutter app (iOS, Android & web)
├── dashboard/    # React Admin panel
└── supabase/     # Migrations, edge functions, config & seed
```

---

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Flutter | 3.35+ | Mobile app |
| Dart | 3.9+ | Flutter language |
| Node.js | 18+ | Dashboard |
| Supabase CLI | latest | Local backend |
| Docker | latest | Supabase local stack |

---

## Getting Started

### 1. Backend (Supabase)

Start the local Supabase stack first — both Flutter and the dashboard connect to it.

```bash
supabase start
```

This spins up a local PostgreSQL database, REST API, and auth server via Docker. On first run it applies all migrations from `supabase/migrations/`.

To stop:
```bash
supabase stop
```

To reset the database and re-seed:
```bash
supabase db reset
```

**Environment URLs (local):**
- API: `http://localhost:54321`
- Studio: `http://localhost:54323`
- DB: `postgresql://postgres:postgres@localhost:54322/postgres`

**Production:** Hosted at [supabase.com](https://supabase.com). Credentials are in `.env` files (not committed).

---

### 2. Flutter App

```bash
cd frontend
flutter pub get
flutter run
```

To run on a specific platform:
```bash
flutter run -d ios
flutter run -d android
flutter run -d chrome   # web
```

**Architecture:** BLoC pattern (`flutter_bloc`). Feature folders under `lib/app/`, data layer under `lib/data/`.

**Key packages:**
- `supabase_flutter` — backend client
- `flutter_bloc` — state management
- `easy_localization` — translations (Arabic-only UI)
- `flutter_tts` — text-to-speech

---

### 3. Dashboard

```bash
cd dashboard
npm install
npm run dev
```

Opens at `http://localhost:5173` (or next available port).

**Or use VS Code:** Run & Debug panel → select **dashboard** → press F5. The browser opens automatically.

**Environment:** Copy `.env.example` to `.env` and fill in your Supabase credentials:
```
VITE_SUPABASE_URL=https://<project>.supabase.co
VITE_SUPABASE_KEY=<anon-public-key>
```

> The key must be the anon JWT key (`eyJ...`) from Supabase → Settings → API, not the publishable key format.

**Login:** Create an admin user in Supabase Auth → Users before logging in.

**Resources managed:**
- Lessons (full CRUD)
- Profiles (list & edit)
- Subscriptions (read-only)

---

## Database Migrations

Migrations live in `supabase/migrations/`. Always create a new migration file rather than editing existing ones.

```bash
# Create a new migration
supabase migration new <name>

# Apply pending migrations locally
supabase db reset

# Push migrations to production
supabase db push
```

---

## Contributing

1. Branch off `main` (the only long-lived branch); merging to `main` deploys production — see [DEPLOYMENT.md](DEPLOYMENT.md)
2. Keep Flutter, dashboard, and Supabase changes in separate commits
3. Run `flutter analyze` before pushing Flutter changes
4. Run `npm run lint` before pushing dashboard changes
5. Never commit `.env` files or Supabase service role keys

