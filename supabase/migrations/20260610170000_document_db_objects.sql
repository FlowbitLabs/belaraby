-- Catalog comments (COMMENT ON) for the non-obvious database objects, so
-- intent and invariants are visible from psql (\df+, \d+) and Supabase
-- Studio without digging through migration history.
--
-- Comments-only migration: no schema or behavior change. COMMENT ON
-- overwrites, so re-running is safe. Function comments survive
-- CREATE OR REPLACE FUNCTION, so later redefinitions keep them.
--
-- Rollback:
--   COMMENT ON <object> IS NULL; -- for each object below

COMMENT ON FUNCTION public.handle_new_user() IS
    'AFTER INSERT ON auth.users trigger: auto-creates the public.profiles row for every new user, including anonymous sign-ins. SECURITY DEFINER so signup never depends on caller privileges; on a metadata unique violation it falls back to a bare profile row rather than blocking the signup.';

COMMENT ON FUNCTION public.is_admin() IS
    'True iff the calling user''s profiles.is_admin is true (false for unauthenticated callers). SECURITY DEFINER so RLS policies - including those on profiles itself - can call it without recursing through the profiles policies.';

COMMENT ON FUNCTION public.has_active_subscription() IS
    'Single source of truth for premium access: true iff the calling user has a subscriptions row with expires_at in the future. status and will_renew are informational only - a cancellation keeps access until expiry, so only expires_at gates.';

COMMENT ON FUNCTION public.protect_profiles_privileged_columns() IS
    'BEFORE INSERT/UPDATE trigger on profiles: reverts is_admin and role on writes by the anon/authenticated API roles unless the caller is an admin, so users cannot self-promote through their own-row UPDATE policy. Invoker rights: service_role and postgres writes are untouched.';

COMMENT ON FUNCTION public.lessons_view_insert() IS
    'INSTEAD OF INSERT body for the public.lessons masking view; forwards to private.lessons with invoker rights, so the lessons_admin_all RLS policy still gates the write.';

COMMENT ON FUNCTION public.lessons_view_update() IS
    'INSTEAD OF UPDATE body for the public.lessons masking view; forwards to private.lessons with invoker rights, so the lessons_admin_all RLS policy still gates the write.';

COMMENT ON FUNCTION public.lessons_view_delete() IS
    'INSTEAD OF DELETE body for the public.lessons masking view; forwards to private.lessons with invoker rights, so the lessons_admin_all RLS policy still gates the write.';

COMMENT ON FUNCTION public.delete_stale_anonymous_users() IS
    'Daily pg_cron job (delete-stale-anonymous-users): deletes anonymous auth users with no sign-in, session or refresh-token activity for 90 days and no active subscription. Deletion cascades away their profile, favorites, learned lessons and subscription rows. Retention policy: DEPLOYMENT.md, Operations runbook.';

COMMENT ON VIEW public.lessons IS
    'Masking view over private.lessons: body is '''' unless the lesson is free, the caller has an active subscription, or the caller is an admin. security_invoker, so the base table''s RLS and grants keep applying; writable through INSTEAD OF triggers so the dashboard needs no query changes.';

COMMENT ON TABLE private.lessons IS
    'Real lessons table, moved out of the API-exposed schemas so premium story bodies cannot be read with the anon key. All client access goes through the masking public.lessons view.';
