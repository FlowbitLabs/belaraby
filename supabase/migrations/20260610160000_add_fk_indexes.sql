-- Indexes for the six unindexed foreign-key columns.
--
-- Verified missing on a fresh `supabase db reset`: only the primary keys
-- exist on these tables. Each index serves
--   * every lesson-detail child query (WHERE lesson_id = ...),
--   * the EXISTS subqueries in the premium-gating RLS policies
--     (20260610120300_premium_content_gating.sql),
--   * the ON DELETE CASCADE scans triggered by lesson deletes
--     (20260610150000_cascade_lesson_content_fks.sql).
--
-- Rollback:
--   DROP INDEX IF EXISTS public.lesson_exercises_lesson_id_idx;
--   DROP INDEX IF EXISTS public.lesson_exercise_options_exercise_id_idx;
--   DROP INDEX IF EXISTS public.lesson_grammar_lesson_id_idx;
--   DROP INDEX IF EXISTS public.lesson_keywords_lesson_id_idx;
--   DROP INDEX IF EXISTS public.user_favorites_lesson_id_idx;
--   DROP INDEX IF EXISTS public.user_learned_lessons_lesson_id_idx;

CREATE INDEX IF NOT EXISTS lesson_exercises_lesson_id_idx
    ON public.lesson_exercises (lesson_id);

CREATE INDEX IF NOT EXISTS lesson_exercise_options_exercise_id_idx
    ON public.lesson_exercise_options (exercise_id);

CREATE INDEX IF NOT EXISTS lesson_grammar_lesson_id_idx
    ON public.lesson_grammar (lesson_id);

CREATE INDEX IF NOT EXISTS lesson_keywords_lesson_id_idx
    ON public.lesson_keywords (lesson_id);

CREATE INDEX IF NOT EXISTS user_favorites_lesson_id_idx
    ON public.user_favorites (lesson_id);

CREATE INDEX IF NOT EXISTS user_learned_lessons_lesson_id_idx
    ON public.user_learned_lessons (lesson_id);
