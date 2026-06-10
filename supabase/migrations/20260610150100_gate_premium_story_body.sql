-- Gate the premium story body SERVER-SIDE.
--
-- Until now public_select_lessons (USING true) + a full-table SELECT grant
-- let anyone with the anon key read lessons.body of paid lessons
-- (GET /rest/v1/lessons?select=body&paid=eq.true) — the paywall only gated
-- the child tables. Lists must keep rendering locked lessons, so rows stay
-- public; only the body column is masked.
--
-- Approach: move the real table to the (non-exposed) `private` schema and
-- expose a same-named view in `public` that masks `body` unless the lesson
-- is free, the caller has an active subscription, or the caller is an
-- admin. INSTEAD OF triggers keep the view writable for the dashboard, so
-- no client (Flutter, React Admin, keep-alive curl) changes its queries.
--
-- DESTRUCTIVE parts — rollback notes:
--   * public.lessons (table) moves to private.lessons and a view takes its
--     name. To restore:
--       DROP VIEW IF EXISTS public.lessons;
--       ALTER TABLE private.lessons SET SCHEMA public;
--       DROP FUNCTION IF EXISTS public.lessons_view_insert();
--       DROP FUNCTION IF EXISTS public.lessons_view_update();
--       DROP FUNCTION IF EXISTS public.lessons_view_delete();
--       GRANT SELECT ON public.lessons TO anon, authenticated;
--       GRANT INSERT, UPDATE, DELETE ON public.lessons TO authenticated;
--       GRANT ALL ON public.lessons TO service_role;

-- ─── 1. Private schema (not exposed through PostgREST) ──────────────────────

CREATE SCHEMA IF NOT EXISTS private;

-- The API roles need USAGE so the security-invoker view (and the INSTEAD OF
-- triggers) can reach the underlying table. The schema is not in
-- [api].schemas, so it stays unreachable through the REST API itself.
GRANT USAGE ON SCHEMA private TO anon, authenticated, service_role;

-- ─── 2. Move the table (idempotent: only when it is still a table) ──────────
-- Existing FKs, RLS policies, grants and policy references on/of the table
-- follow it: they are bound by OID, not by name.

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public' AND c.relname = 'lessons' AND c.relkind = 'r'
    ) THEN
        ALTER TABLE public.lessons SET SCHEMA private;
    END IF;
END $$;

-- ─── 3. Masking view ─────────────────────────────────────────────────────────
-- security_invoker: the caller's grants + the table's RLS keep applying
-- (public_select_lessons keeps rows listable; lessons_admin_all keeps
-- writes admin-only). The body is '' (not NULL — the Flutter model expects
-- a string) unless free / subscribed / admin. The scalar subqueries are
-- initplans: each helper runs once per query, not once per row.

CREATE OR REPLACE VIEW public.lessons
WITH (security_invoker = true)
AS
SELECT
    l.id,
    l.title,
    CASE
        WHEN NOT l.paid
          OR (SELECT public.has_active_subscription())
          OR (SELECT public.is_admin())
        THEN l.body
        ELSE ''
    END AS body,
    l.hero_image,
    l.level,
    l.created_at,
    l.grade,
    l.paid,
    l.date
FROM private.lessons l;

-- ─── 4. Keep the view writable (dashboard / seeds) ──────────────────────────
-- The CASE column makes the view non-auto-updatable, so writes go through
-- INSTEAD OF triggers. They run with INVOKER rights: the UPDATE/INSERT/
-- DELETE on private.lessons is still gated by lessons_admin_all RLS.

CREATE OR REPLACE FUNCTION public.lessons_view_insert()
RETURNS trigger
LANGUAGE plpgsql
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
AS $$
BEGIN
    DELETE FROM private.lessons WHERE id = OLD.id;
    RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS lessons_view_insert ON public.lessons;
CREATE TRIGGER lessons_view_insert
    INSTEAD OF INSERT ON public.lessons
    FOR EACH ROW EXECUTE FUNCTION public.lessons_view_insert();

DROP TRIGGER IF EXISTS lessons_view_update ON public.lessons;
CREATE TRIGGER lessons_view_update
    INSTEAD OF UPDATE ON public.lessons
    FOR EACH ROW EXECUTE FUNCTION public.lessons_view_update();

DROP TRIGGER IF EXISTS lessons_view_delete ON public.lessons;
CREATE TRIGGER lessons_view_delete
    INSTEAD OF DELETE ON public.lessons
    FOR EACH ROW EXECUTE FUNCTION public.lessons_view_delete();

-- ─── 5. View privileges ──────────────────────────────────────────────────────
-- The table kept its grants when it moved; the view is a new object and
-- needs its own (mirroring 20260610120300_premium_content_gating.sql).

GRANT SELECT ON public.lessons TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.lessons TO authenticated;
GRANT ALL ON public.lessons TO service_role;
