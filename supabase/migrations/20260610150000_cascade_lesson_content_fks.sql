-- Lesson deletes must cascade to lesson content and user activity rows.
--
-- The dashboard exposes a Delete button on lessons; without ON DELETE
-- CASCADE on the lesson_id FKs every delete of a lesson that has
-- exercises/grammar/keywords (or that any user favorited/learned) fails
-- with a 23503 foreign-key violation. lesson_exercise_options.exercise_id
-- is included so the cascade flows through lesson_exercises.
--
-- DESTRUCTIVE parts — rollback notes:
--   * Each FK below is recreated with ON DELETE CASCADE. To restore the old
--     behavior, drop the constraint and re-add it without ON DELETE CASCADE,
--     e.g.:
--       ALTER TABLE public.lesson_exercises DROP CONSTRAINT lesson_exercises_lesson_id_fkey;
--       ALTER TABLE public.lesson_exercises ADD CONSTRAINT lesson_exercises_lesson_id_fkey
--         FOREIGN KEY (lesson_id) REFERENCES public.lessons (id);

DO $$
BEGIN
    -- lesson_exercises.lesson_id → lessons.id
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint c
        WHERE c.conname = 'lesson_exercises_lesson_id_fkey'
          AND c.conrelid = 'public.lesson_exercises'::regclass
          AND c.confdeltype = 'c'
    ) THEN
        ALTER TABLE public.lesson_exercises DROP CONSTRAINT IF EXISTS lesson_exercises_lesson_id_fkey;
        ALTER TABLE public.lesson_exercises
            ADD CONSTRAINT lesson_exercises_lesson_id_fkey
            FOREIGN KEY (lesson_id) REFERENCES public.lessons (id) ON DELETE CASCADE;
    END IF;

    -- lesson_exercise_options.exercise_id → lesson_exercises.id
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint c
        WHERE c.conname = 'lesson_exercise_options_exercise_id_fkey'
          AND c.conrelid = 'public.lesson_exercise_options'::regclass
          AND c.confdeltype = 'c'
    ) THEN
        ALTER TABLE public.lesson_exercise_options DROP CONSTRAINT IF EXISTS lesson_exercise_options_exercise_id_fkey;
        ALTER TABLE public.lesson_exercise_options
            ADD CONSTRAINT lesson_exercise_options_exercise_id_fkey
            FOREIGN KEY (exercise_id) REFERENCES public.lesson_exercises (id) ON DELETE CASCADE;
    END IF;

    -- lesson_grammar.lesson_id → lessons.id
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint c
        WHERE c.conname = 'lesson_grammar_lesson_id_fkey'
          AND c.conrelid = 'public.lesson_grammar'::regclass
          AND c.confdeltype = 'c'
    ) THEN
        ALTER TABLE public.lesson_grammar DROP CONSTRAINT IF EXISTS lesson_grammar_lesson_id_fkey;
        ALTER TABLE public.lesson_grammar
            ADD CONSTRAINT lesson_grammar_lesson_id_fkey
            FOREIGN KEY (lesson_id) REFERENCES public.lessons (id) ON DELETE CASCADE;
    END IF;

    -- lesson_keywords.lesson_id → lessons.id
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint c
        WHERE c.conname = 'lesson_keywords_lesson_id_fkey'
          AND c.conrelid = 'public.lesson_keywords'::regclass
          AND c.confdeltype = 'c'
    ) THEN
        ALTER TABLE public.lesson_keywords DROP CONSTRAINT IF EXISTS lesson_keywords_lesson_id_fkey;
        ALTER TABLE public.lesson_keywords
            ADD CONSTRAINT lesson_keywords_lesson_id_fkey
            FOREIGN KEY (lesson_id) REFERENCES public.lessons (id) ON DELETE CASCADE;
    END IF;

    -- user_favorites.lesson_id → lessons.id
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint c
        WHERE c.conname = 'user_favorites_lesson_id_fkey'
          AND c.conrelid = 'public.user_favorites'::regclass
          AND c.confdeltype = 'c'
    ) THEN
        ALTER TABLE public.user_favorites DROP CONSTRAINT IF EXISTS user_favorites_lesson_id_fkey;
        ALTER TABLE public.user_favorites
            ADD CONSTRAINT user_favorites_lesson_id_fkey
            FOREIGN KEY (lesson_id) REFERENCES public.lessons (id) ON DELETE CASCADE;
    END IF;

    -- user_learned_lessons.lesson_id → lessons.id
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint c
        WHERE c.conname = 'user_learned_lessons_lesson_id_fkey'
          AND c.conrelid = 'public.user_learned_lessons'::regclass
          AND c.confdeltype = 'c'
    ) THEN
        ALTER TABLE public.user_learned_lessons DROP CONSTRAINT IF EXISTS user_learned_lessons_lesson_id_fkey;
        ALTER TABLE public.user_learned_lessons
            ADD CONSTRAINT user_learned_lessons_lesson_id_fkey
            FOREIGN KEY (lesson_id) REFERENCES public.lessons (id) ON DELETE CASCADE;
    END IF;
END $$;
