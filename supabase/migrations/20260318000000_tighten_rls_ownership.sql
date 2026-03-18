-- Tighten RLS: scope user-owned tables to auth.uid() row ownership.
--
-- Tables affected:
--   user_favorites        – rows belong to the user referenced by user_id
--   user_learned_lessons  – rows belong to the user referenced by user_id
--   profiles              – rows belong to the user referenced by id
--   subscriptions         – rows belong to the user referenced by user_id
--
-- The lessons table keeps its existing public SELECT policy (USING true)
-- and authenticated-only INSERT/UPDATE/DELETE policies (managed by admins).

-- ─── user_favorites ────────────────────────────────────────────────────────

DROP POLICY IF EXISTS authenticated_select ON public.user_favorites;
DROP POLICY IF EXISTS authenticated_insert ON public.user_favorites;
DROP POLICY IF EXISTS authenticated_update ON public.user_favorites;
DROP POLICY IF EXISTS authenticated_delete ON public.user_favorites;

CREATE POLICY user_favorites_select ON public.user_favorites
    FOR SELECT USING (user_id = (SELECT auth.uid()));

CREATE POLICY user_favorites_insert ON public.user_favorites
    FOR INSERT WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY user_favorites_delete ON public.user_favorites
    FOR DELETE USING (user_id = (SELECT auth.uid()));

-- ─── user_learned_lessons ──────────────────────────────────────────────────

DROP POLICY IF EXISTS authenticated_select ON public.user_learned_lessons;
DROP POLICY IF EXISTS authenticated_insert ON public.user_learned_lessons;
DROP POLICY IF EXISTS authenticated_update ON public.user_learned_lessons;
DROP POLICY IF EXISTS authenticated_delete ON public.user_learned_lessons;

CREATE POLICY user_learned_lessons_select ON public.user_learned_lessons
    FOR SELECT USING (user_id = (SELECT auth.uid()));

CREATE POLICY user_learned_lessons_insert ON public.user_learned_lessons
    FOR INSERT WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY user_learned_lessons_delete ON public.user_learned_lessons
    FOR DELETE USING (user_id = (SELECT auth.uid()));

-- ─── profiles ──────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS authenticated_select ON public.profiles;
DROP POLICY IF EXISTS authenticated_insert ON public.profiles;
DROP POLICY IF EXISTS authenticated_update ON public.profiles;
DROP POLICY IF EXISTS authenticated_delete ON public.profiles;

CREATE POLICY profiles_select ON public.profiles
    FOR SELECT USING (id = (SELECT auth.uid()));

CREATE POLICY profiles_insert ON public.profiles
    FOR INSERT WITH CHECK (id = (SELECT auth.uid()));

CREATE POLICY profiles_update ON public.profiles
    FOR UPDATE USING (id = (SELECT auth.uid()));

-- ─── subscriptions ─────────────────────────────────────────────────────────

DROP POLICY IF EXISTS authenticated_select ON public.subscriptions;
DROP POLICY IF EXISTS authenticated_insert ON public.subscriptions;
DROP POLICY IF EXISTS authenticated_update ON public.subscriptions;
DROP POLICY IF EXISTS authenticated_delete ON public.subscriptions;

CREATE POLICY subscriptions_select ON public.subscriptions
    FOR SELECT USING (user_id = (SELECT auth.uid()));
