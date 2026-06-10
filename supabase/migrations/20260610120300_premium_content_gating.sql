-- Premium content gating + admin access for the React Admin dashboard.
--
-- DESTRUCTIVE parts — rollback notes:
--   * Drops the authenticated_select policies on lesson_exercises,
--     lesson_exercise_options, lesson_grammar, lesson_keywords
--     (replaced by the gated *_select policies below). To restore:
--       CREATE POLICY authenticated_select ON public.<table>
--         FOR SELECT USING ((SELECT auth.uid()) IS NOT NULL);
--   * Drops the authenticated_insert/update/delete policies on lessons and
--     the four child tables (replaced by admin-only *_admin_all policies).
--     With anonymous sign-ins enabled every app user holds the
--     `authenticated` role, so those old policies would have let anyone
--     edit content. To restore, recreate them per
--     20251101074144_update_rls_again.sql.
--   * Adds the protect_profiles_privileged_columns trigger. To remove:
--       DROP TRIGGER IF EXISTS protect_profiles_privileged_columns ON public.profiles;
--       DROP FUNCTION IF EXISTS public.protect_profiles_privileged_columns();
--
-- Access rule for child content SELECT:
--   parent lesson is free (lessons.paid = false)
--   OR public.has_active_subscription()
--   OR public.is_admin()
-- The lessons table itself stays publicly listable (public_select_lessons)
-- so locked lessons can still render in lists.

-- ─── lesson_exercises ───────────────────────────────────────────────────────

DROP POLICY IF EXISTS authenticated_select ON public.lesson_exercises;
DROP POLICY IF EXISTS lesson_exercises_select ON public.lesson_exercises;
CREATE POLICY lesson_exercises_select ON public.lesson_exercises
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.lessons l
            WHERE l.id = lesson_exercises.lesson_id
              AND l.paid = false
        )
        OR public.has_active_subscription()
        OR public.is_admin()
    );

DROP POLICY IF EXISTS authenticated_insert ON public.lesson_exercises;
DROP POLICY IF EXISTS authenticated_update ON public.lesson_exercises;
DROP POLICY IF EXISTS authenticated_delete ON public.lesson_exercises;
DROP POLICY IF EXISTS lesson_exercises_admin_all ON public.lesson_exercises;
CREATE POLICY lesson_exercises_admin_all ON public.lesson_exercises
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── lesson_exercise_options ────────────────────────────────────────────────

DROP POLICY IF EXISTS authenticated_select ON public.lesson_exercise_options;
DROP POLICY IF EXISTS lesson_exercise_options_select ON public.lesson_exercise_options;
CREATE POLICY lesson_exercise_options_select ON public.lesson_exercise_options
    FOR SELECT USING (
        EXISTS (
            SELECT 1
            FROM public.lesson_exercises e
            JOIN public.lessons l ON l.id = e.lesson_id
            WHERE e.id = lesson_exercise_options.exercise_id
              AND l.paid = false
        )
        OR public.has_active_subscription()
        OR public.is_admin()
    );

DROP POLICY IF EXISTS authenticated_insert ON public.lesson_exercise_options;
DROP POLICY IF EXISTS authenticated_update ON public.lesson_exercise_options;
DROP POLICY IF EXISTS authenticated_delete ON public.lesson_exercise_options;
DROP POLICY IF EXISTS lesson_exercise_options_admin_all ON public.lesson_exercise_options;
CREATE POLICY lesson_exercise_options_admin_all ON public.lesson_exercise_options
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── lesson_grammar ─────────────────────────────────────────────────────────

DROP POLICY IF EXISTS authenticated_select ON public.lesson_grammar;
DROP POLICY IF EXISTS lesson_grammar_select ON public.lesson_grammar;
CREATE POLICY lesson_grammar_select ON public.lesson_grammar
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.lessons l
            WHERE l.id = lesson_grammar.lesson_id
              AND l.paid = false
        )
        OR public.has_active_subscription()
        OR public.is_admin()
    );

DROP POLICY IF EXISTS authenticated_insert ON public.lesson_grammar;
DROP POLICY IF EXISTS authenticated_update ON public.lesson_grammar;
DROP POLICY IF EXISTS authenticated_delete ON public.lesson_grammar;
DROP POLICY IF EXISTS lesson_grammar_admin_all ON public.lesson_grammar;
CREATE POLICY lesson_grammar_admin_all ON public.lesson_grammar
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── lesson_keywords ────────────────────────────────────────────────────────

DROP POLICY IF EXISTS authenticated_select ON public.lesson_keywords;
DROP POLICY IF EXISTS lesson_keywords_select ON public.lesson_keywords;
CREATE POLICY lesson_keywords_select ON public.lesson_keywords
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.lessons l
            WHERE l.id = lesson_keywords.lesson_id
              AND l.paid = false
        )
        OR public.has_active_subscription()
        OR public.is_admin()
    );

DROP POLICY IF EXISTS authenticated_insert ON public.lesson_keywords;
DROP POLICY IF EXISTS authenticated_update ON public.lesson_keywords;
DROP POLICY IF EXISTS authenticated_delete ON public.lesson_keywords;
DROP POLICY IF EXISTS lesson_keywords_admin_all ON public.lesson_keywords;
CREATE POLICY lesson_keywords_admin_all ON public.lesson_keywords
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── lessons ────────────────────────────────────────────────────────────────
-- public_select_lessons (USING true) is kept: locked lessons must render.
-- Writes become admin-only.

DROP POLICY IF EXISTS authenticated_insert ON public.lessons;
DROP POLICY IF EXISTS authenticated_update ON public.lessons;
DROP POLICY IF EXISTS authenticated_delete ON public.lessons;
DROP POLICY IF EXISTS lessons_admin_all ON public.lessons;
CREATE POLICY lessons_admin_all ON public.lessons
    FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── Admin read access for the dashboard ────────────────────────────────────

DROP POLICY IF EXISTS user_favorites_admin_select ON public.user_favorites;
CREATE POLICY user_favorites_admin_select ON public.user_favorites
    FOR SELECT USING (public.is_admin());

DROP POLICY IF EXISTS user_learned_lessons_admin_select ON public.user_learned_lessons;
CREATE POLICY user_learned_lessons_admin_select ON public.user_learned_lessons
    FOR SELECT USING (public.is_admin());

DROP POLICY IF EXISTS profiles_admin_select ON public.profiles;
CREATE POLICY profiles_admin_select ON public.profiles
    FOR SELECT USING (public.is_admin());

-- Admins manage profiles from the dashboard (incl. the is_admin toggle).
DROP POLICY IF EXISTS profiles_admin_update ON public.profiles;
CREATE POLICY profiles_admin_update ON public.profiles
    FOR UPDATE USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─── Protect privileged profile columns ─────────────────────────────────────
-- profiles_update lets users edit their own row, and the GRANTs below give
-- the authenticated role UPDATE on profiles. Without this trigger any user
-- could run `UPDATE profiles SET is_admin = true WHERE id = auth.uid()` and
-- self-promote. Column-level GRANTs are not an option because dashboard
-- admins share the same `authenticated` role and must be able to set
-- is_admin/role. The trigger runs with invoker rights, so current_user is
-- the API role (`anon`/`authenticated`) for client writes and is unaffected
-- for service_role/postgres writes.

CREATE OR REPLACE FUNCTION public.protect_profiles_privileged_columns()
RETURNS trigger
LANGUAGE plpgsql
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

DROP TRIGGER IF EXISTS protect_profiles_privileged_columns ON public.profiles;
CREATE TRIGGER protect_profiles_privileged_columns
    BEFORE INSERT OR UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.protect_profiles_privileged_columns();

-- ─── Owner-scoped policies on user_favorites / user_learned_lessons ────────
-- Anonymous Supabase users hold the `authenticated` role, so these policies
-- cover them too. They normally exist from
-- 20260318000000_tighten_rls_ownership.sql — create only what is missing.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
                   AND tablename = 'user_favorites' AND policyname = 'user_favorites_select') THEN
        CREATE POLICY user_favorites_select ON public.user_favorites
            FOR SELECT USING (user_id = (SELECT auth.uid()));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
                   AND tablename = 'user_favorites' AND policyname = 'user_favorites_insert') THEN
        CREATE POLICY user_favorites_insert ON public.user_favorites
            FOR INSERT WITH CHECK (user_id = (SELECT auth.uid()));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
                   AND tablename = 'user_favorites' AND policyname = 'user_favorites_delete') THEN
        CREATE POLICY user_favorites_delete ON public.user_favorites
            FOR DELETE USING (user_id = (SELECT auth.uid()));
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
                   AND tablename = 'user_learned_lessons' AND policyname = 'user_learned_lessons_select') THEN
        CREATE POLICY user_learned_lessons_select ON public.user_learned_lessons
            FOR SELECT USING (user_id = (SELECT auth.uid()));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
                   AND tablename = 'user_learned_lessons' AND policyname = 'user_learned_lessons_insert') THEN
        CREATE POLICY user_learned_lessons_insert ON public.user_learned_lessons
            FOR INSERT WITH CHECK (user_id = (SELECT auth.uid()));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public'
                   AND tablename = 'user_learned_lessons' AND policyname = 'user_learned_lessons_delete') THEN
        CREATE POLICY user_learned_lessons_delete ON public.user_learned_lessons
            FOR DELETE USING (user_id = (SELECT auth.uid()));
    END IF;
END $$;

-- ─── ON DELETE CASCADE for user-owned rows ──────────────────────────────────
-- Anonymous sign-ins are enabled, so anonymous users get cleaned up from
-- auth.users periodically. Their favorites / learned-lessons rows must not
-- block the delete (profiles and subscriptions already cascade).
-- To restore the old behavior, recreate each FK without ON DELETE CASCADE.

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint c
        WHERE c.conname = 'user_favorites_user_id_fkey'
          AND c.conrelid = 'public.user_favorites'::regclass
          AND c.confdeltype = 'c'
    ) THEN
        ALTER TABLE public.user_favorites DROP CONSTRAINT IF EXISTS user_favorites_user_id_fkey;
        ALTER TABLE public.user_favorites
            ADD CONSTRAINT user_favorites_user_id_fkey
            FOREIGN KEY (user_id) REFERENCES auth.users (id) ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint c
        WHERE c.conname = 'user_learned_lessons_user_id_fkey'
          AND c.conrelid = 'public.user_learned_lessons'::regclass
          AND c.confdeltype = 'c'
    ) THEN
        ALTER TABLE public.user_learned_lessons DROP CONSTRAINT IF EXISTS user_learned_lessons_user_id_fkey;
        ALTER TABLE public.user_learned_lessons
            ADD CONSTRAINT user_learned_lessons_user_id_fkey
            FOREIGN KEY (user_id) REFERENCES auth.users (id) ON DELETE CASCADE;
    END IF;
END $$;

-- ─── Base table privileges ──────────────────────────────────────────────────
-- 20251027110740_remote_schema.sql revoked all table privileges from the API
-- roles. RLS gates the rows; the roles still need base privileges.

GRANT SELECT ON public.lessons, public.lesson_exercises,
    public.lesson_exercise_options, public.lesson_grammar,
    public.lesson_keywords TO anon, authenticated;

-- Writes are RLS-gated to admins (is_admin()), but the role needs privileges.
GRANT INSERT, UPDATE, DELETE ON public.lessons, public.lesson_exercises,
    public.lesson_exercise_options, public.lesson_grammar,
    public.lesson_keywords TO authenticated;

GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.user_favorites TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.user_learned_lessons TO authenticated;

GRANT ALL ON public.lessons, public.lesson_exercises,
    public.lesson_exercise_options, public.lesson_grammar,
    public.lesson_keywords, public.profiles, public.user_favorites,
    public.user_learned_lessons TO service_role;
