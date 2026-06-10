-- Hygiene pass: subscriptions columns, status CHECK, favorites timestamps,
-- and search_path hardening of the invoker-rights trigger functions.
--
-- DESTRUCTIVE parts — rollback notes:
--   * Drops the dead Stripe-era columns (created by
--     20251026113043_create_subscriptions.sql, read by nothing since the
--     RevenueCat migration). To restore:
--       ALTER TABLE public.subscriptions
--           ADD COLUMN price_id text,
--           ADD COLUMN started_at timestamp without time zone DEFAULT now(),
--           ADD COLUMN current_period_end timestamp without time zone,
--           ADD COLUMN cancel_at_period_end boolean DEFAULT false;
--     (column DATA is not recoverable after the drop.)
--   * Re-adds subscriptions_status_check (dropped by 20260610120200 without
--     replacement). To remove:
--       ALTER TABLE public.subscriptions DROP CONSTRAINT IF EXISTS subscriptions_status_check;
--
-- NOTE for type sync (dashboard + Flutter): subscriptions loses price_id,
-- started_at, current_period_end, cancel_at_period_end; user_favorites gains
-- created_at timestamptz NOT NULL DEFAULT now().

-- ─── 1. Drop dead Stripe-era columns ────────────────────────────────────────

ALTER TABLE public.subscriptions
    DROP COLUMN IF EXISTS price_id,
    DROP COLUMN IF EXISTS started_at,
    DROP COLUMN IF EXISTS current_period_end,
    DROP COLUMN IF EXISTS cancel_at_period_end;

-- ─── 2. Re-add the status CHECK constraint ──────────────────────────────────
-- Allows exactly what the revenuecat-webhook writes, plus whatever legacy
-- values are still present in the data (so the migration can never fail on
-- a project that still carries Stripe-era rows like 'canceled'/'trial').

DO $$
DECLARE
    allowed text[] := ARRAY['active', 'cancelled', 'expired', 'billing_issue', 'paused'];
    legacy  text[];
BEGIN
    ALTER TABLE public.subscriptions DROP CONSTRAINT IF EXISTS subscriptions_status_check;

    SELECT array_agg(DISTINCT s.status) INTO legacy
    FROM public.subscriptions s
    WHERE s.status IS NOT NULL
      AND NOT (s.status = ANY (allowed));

    IF legacy IS NOT NULL THEN
        allowed := allowed || legacy;
        RAISE NOTICE 'subscriptions_status_check: also allowing legacy status values %', legacy;
    END IF;

    EXECUTE format(
        'ALTER TABLE public.subscriptions ADD CONSTRAINT subscriptions_status_check CHECK (status = ANY (%L::text[]))',
        allowed
    );
END $$;

-- ─── 3. user_favorites.created_at — make favorites sortable ────────────────
-- Existing rows are backfilled by the DEFAULT (best available approximation).

ALTER TABLE public.user_favorites
    ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now();

-- ─── 4. Pin search_path on the invoker-rights trigger functions ─────────────
-- Bodies are UNCHANGED from 20260610120300 / 20260610150100 — they already
-- schema-qualify every reference. SET search_path = '' just clears the
-- linter's function_search_path_mutable warnings (0011) and removes the
-- theoretical search-path-hijack surface. The three SECURITY DEFINER
-- functions (handle_new_user, is_admin, has_active_subscription) already
-- set search_path = '' — do not touch them here.

CREATE OR REPLACE FUNCTION public.protect_profiles_privileged_columns()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    IF current_user IN ('anon', 'authenticated') AND NOT public.is_admin() THEN
        IF TG_OP = 'UPDATE' THEN
            NEW.is_admin := OLD.is_admin;
            NEW.role := OLD.role;
        ELSE -- INSERT
            NEW.is_admin := false;
            NEW.role := 'student';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.lessons_view_insert()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    NEW.id := COALESCE(NEW.id, gen_random_uuid());
    NEW.created_at := COALESCE(NEW.created_at, now());
    NEW.paid := COALESCE(NEW.paid, false);
    INSERT INTO private.lessons (id, title, body, hero_image, level, created_at, grade, paid, date)
    VALUES (NEW.id, NEW.title, NEW.body, NEW.hero_image, NEW.level,
            NEW.created_at, NEW.grade, NEW.paid, NEW.date);
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.lessons_view_update()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    UPDATE private.lessons SET
        title = NEW.title,
        body = NEW.body,
        hero_image = NEW.hero_image,
        level = NEW.level,
        created_at = NEW.created_at,
        grade = NEW.grade,
        paid = NEW.paid,
        date = NEW.date
    WHERE id = OLD.id;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.lessons_view_delete()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    DELETE FROM private.lessons WHERE id = OLD.id;
    RETURN OLD;
END;
$$;
