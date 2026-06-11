# Canonical local verification — mirrors .github/workflows/ci.yml
.PHONY: check check-frontend check-dashboard check-functions check-supabase

check: check-frontend check-dashboard check-functions

check-frontend:
	cd frontend && flutter analyze --fatal-infos && flutter test

# eslint invoked directly (not `npm run lint`) — the npm script passes --fix
# and would rewrite files instead of failing.
check-dashboard:
	cd dashboard && npm run type-check && npx eslint --ext .js,.jsx,.ts,.tsx ./src && npm run test && npm run build

# Deno must run from supabase/functions to pick up deno.json there.
check-functions:
	cd supabase/functions && deno check revenuecat-webhook/index.ts delete-account/index.ts _tests/*.ts && deno lint && deno test --allow-env

# Requires Docker — proves all migrations apply from scratch.
check-supabase:
	supabase db start && supabase db reset && supabase db lint
