# belaraby-dashboard

## Login & Admin Access

The dashboard signs in with **email + password** through `ra-supabase`
(`/forgot-password` and `/set-password` handle recovery and invite flows).
Create admin users manually in Supabase Auth → Users, then set
`is_admin = true` on their row in `public.profiles`. Accounts without the
admin flag see an "Access denied" page — the real enforcement is RLS via
`public.is_admin()`.

## Installation

Install the application dependencies by running:

```sh
npm install
```

## Development

Start the application in development mode by running:

```sh
npm run dev
```

## Tests & Quality

```sh
npm test            # vitest (jsdom + testing-library)
npm run type-check  # tsc -b (checks src and vite.config.ts)
npm run lint        # eslint --fix
```

Tests cover the custom logic only (status chip mapping, compound
primary-key map, shared toolbar/buttons, lesson-content form smoke tests) —
plain react-admin wiring is not re-tested.

## Production

Build the application in production mode by running:

```sh
npm run build
```

## Development Setup

Update the `.env` file to populate the environment variables with the values found on your project API settings:

```sh
# Your supabase instance URL
VITE_SUPABASE_URL=
# Your supabase anon JWT key (eyJ...) - the sb_publishable_ format does not work
VITE_SUPABASE_KEY=
```
