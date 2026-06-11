# Admin Dashboard (`dashboard/`) — Claude Context

React Admin panel for managing lessons, content, profiles and subscriptions.

## Stack

React 19 · TypeScript (strict) · Vite · React Admin 5 · ra-supabase · MUI v7 · Vitest

## Directory Map

```
src/
├── index.tsx          # entrypoint
├── App.tsx            # <Admin> setup: dataProvider, authProvider, all <Resource>s
├── Layout.tsx         # app shell
├── AccessDenied.tsx   # shown to non-admin logins
├── primaryKeys.ts     # composite/non-id primary key config for ra-supabase
├── types.ts           # TS interfaces mirroring DB rows — keep in sync with Dart models
└── resources/         # one file per resource (list/edit/create components)
    └── shared.tsx     # cross-resource helpers (lesson reference fields, etc.)
```

Tests are colocated (`*.test.ts(x)`) next to what they test.

## Commands

```bash
npm run dev          # http://localhost:5173
npm run type-check   # CI gate
npm run lint
npm run test         # vitest — only CI coverage of menu-hidden lesson-content views
npm run build        # CI gate
```

## React Admin Patterns

- Explicit `<Resource>` components — never `AdminGuesser` in production
- Prefer `<List>`, `<Datagrid>`, `<Edit>`, `<Create>`, `<SimpleForm>` before custom pages
- `useNotify` for feedback, `useRecordContext` for the current record,
  `useDataProvider` for non-CRUD calls

```tsx
<Resource name="lessons" list={LessonList} edit={LessonEdit} create={LessonCreate} />
```

## TypeScript

- Strict mode — no `any`, no implicit `any`
- Interfaces for all props, state, and API responses (in `types.ts` for DB rows)
- Named exports for all components

## Auth

- `supabaseAuthProvider` from `ra-supabase`; access gated by `profiles.is_admin`
- `VITE_SUPABASE_KEY` must be the anon JWT (`eyJ...`) — NOT `sb_publishable_`
- Admin users are created manually in Supabase Auth → Users; first admin is
  promoted via SQL (see DEPLOYMENT.md §2)

## Deploy

Cloudflare Worker `admin` (static assets, `wrangler.toml`); push to `main`
touching `dashboard/**` deploys via `.github/workflows/deploy_dashboard.yml`.
