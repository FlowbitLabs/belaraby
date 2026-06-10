-- Scheduled cleanup of stale anonymous users (assumed by
-- 20260610120300_premium_content_gating.sql but never built until now).
--
-- Anonymous sign-ins are enabled and the app bootstraps EVERY install with
-- signInAnonymously(), so auth.users accumulates one row per device that
-- never converts. Stale anonymous users count against the free-tier 50K MAU
-- ceiling and bloat backups, so they are deleted after a generous window.
--
-- Criteria are deliberately conservative — an anonymous user is a real
-- user's ONLY identity, and deleting it cascades away their favorites,
-- learned lessons, profile and subscription rows:
--   * is_anonymous = true
--   * account is older than 90 days AND last_sign_in_at older than 90 days
--     (last_sign_in_at is NOT refreshed by token refresh, so additionally:)
--   * no auth.sessions row touched within 90 days
--   * no auth.refresh_tokens row touched within 90 days
--   * no subscription row with expires_at > now() (paying users are never
--     deleted, even if RevenueCat restores would technically recover them)
--
-- Retention policy is documented in DEPLOYMENT.md (Operations runbook).
--
-- Rollback:
--   SELECT cron.unschedule('delete-stale-anonymous-users');
--   DROP FUNCTION IF EXISTS public.delete_stale_anonymous_users();
--   -- (pg_cron itself is left installed; drop with care if anything else
--   --  schedules jobs: DROP EXTENSION IF EXISTS pg_cron;)

-- ─── 1. pg_cron ──────────────────────────────────────────────────────────────
-- Installs into its control-file default schema (pg_catalog on Supabase);
-- jobs run as the role that scheduled them (postgres, via migrations).

CREATE EXTENSION IF NOT EXISTS pg_cron;

-- ─── 2. Cleanup function ─────────────────────────────────────────────────────
-- SECURITY DEFINER (owner: postgres) so the cron job can delete from
-- auth.users. Never callable by API roles.

CREATE OR REPLACE FUNCTION public.delete_stale_anonymous_users()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    deleted_count integer;
BEGIN
    WITH doomed AS (
        DELETE FROM auth.users u
        WHERE u.is_anonymous = true
          AND u.created_at < now() - interval '90 days'
          AND COALESCE(u.last_sign_in_at, u.created_at) < now() - interval '90 days'
          AND NOT EXISTS (
              SELECT 1 FROM auth.sessions s
              WHERE s.user_id = u.id
                AND COALESCE(s.refreshed_at, s.updated_at, s.created_at)
                    > now() - interval '90 days'
          )
          AND NOT EXISTS (
              SELECT 1 FROM auth.refresh_tokens rt
              WHERE rt.user_id = u.id::text
                AND rt.updated_at > now() - interval '90 days'
          )
          AND NOT EXISTS (
              SELECT 1 FROM public.subscriptions sub
              WHERE sub.user_id = u.id
                AND sub.expires_at > now()
          )
        RETURNING u.id
    )
    SELECT count(*) INTO deleted_count FROM doomed;

    RAISE NOTICE 'delete_stale_anonymous_users: deleted % stale anonymous users', deleted_count;
    RETURN deleted_count;
END;
$$;

REVOKE ALL ON FUNCTION public.delete_stale_anonymous_users() FROM public, anon, authenticated;

-- ─── 3. Schedule (daily, 04:17 UTC) ─────────────────────────────────────────
-- cron.schedule upserts by job name, so re-running this migration is safe.

SELECT cron.schedule(
    'delete-stale-anonymous-users',
    '17 4 * * *',
    $$SELECT public.delete_stale_anonymous_users();$$
);
