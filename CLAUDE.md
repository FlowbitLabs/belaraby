# Belaraby — Claude Context

Arabic learning platform: stories per CEFR level with audio, flashcards,
grammar notes and quizzes. Arabic-only UI.

```
frontend/   Flutter app (iOS, Android & web)   → see frontend/CLAUDE.md
dashboard/  React admin panel                  → see dashboard/CLAUDE.md
supabase/   Migrations, edge functions, config → see supabase/CLAUDE.md
```

Each subproject has its own CLAUDE.md with its directory map, commands and
conventions — read the one for the tree you're changing. Deployment, CI,
secrets and operations runbooks live in DEPLOYMENT.md.

## Verification (run before committing)

```bash
make check-frontend    # flutter analyze --fatal-infos + flutter test
make check-dashboard   # type-check + lint + vitest + build
make check-functions   # deno check + lint + test
make check             # all of the above
```

(Or run the underlying commands directly — they're listed in each
subproject's CLAUDE.md and mirror `.github/workflows/ci.yml`.)

## Cross-Cutting Rules

- Check `pubspec.yaml` / `package.json` before suggesting new packages —
  prefer what's already installed
- Never commit `.env` files or Supabase service role keys
- `main` is the only long-lived branch; pushing to it deploys production.
  Keep Flutter, dashboard, and Supabase changes in **separate commits**
- Keep Flutter, dashboard, and DB types in sync — if a column changes,
  update the Dart model (`frontend/lib/data/models/`) and the TS interface
  (`dashboard/src/types.ts`)
- Global Supabase client in Flutter: `frontend/lib/data/supabase_client.dart` —
  use `supabase` directly, never instantiate a new client
