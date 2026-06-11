-- Keyword practice (flashcards):
--   * lesson_keywords gains a `meaning` so the cards show word + meaning.
--   * user_practice_words tracks which keywords a user practices and the
--     self-assessed difficulty ('new' until first review, 'done' = mastered).
-- Rollback:
--   alter table public.lesson_keywords drop column if exists meaning;
--   drop table if exists public.user_practice_words;

ALTER TABLE public.lesson_keywords
    ADD COLUMN IF NOT EXISTS meaning text NOT NULL DEFAULT '';

CREATE TABLE IF NOT EXISTS public.user_practice_words (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
    keyword_id uuid NOT NULL
        REFERENCES public.lesson_keywords (id) ON DELETE CASCADE,
    difficulty text NOT NULL DEFAULT 'new'
        CHECK (difficulty IN ('new', 'easy', 'medium', 'hard', 'done')),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (user_id, keyword_id)
);

CREATE INDEX IF NOT EXISTS user_practice_words_user_id_idx
    ON public.user_practice_words (user_id);
CREATE INDEX IF NOT EXISTS user_practice_words_keyword_id_idx
    ON public.user_practice_words (keyword_id);

ALTER TABLE public.user_practice_words ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS user_practice_words_select ON public.user_practice_words;
CREATE POLICY user_practice_words_select ON public.user_practice_words
    FOR SELECT TO authenticated USING (user_id = auth.uid());

DROP POLICY IF EXISTS user_practice_words_insert ON public.user_practice_words;
CREATE POLICY user_practice_words_insert ON public.user_practice_words
    FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS user_practice_words_update ON public.user_practice_words;
CREATE POLICY user_practice_words_update ON public.user_practice_words
    FOR UPDATE TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS user_practice_words_delete ON public.user_practice_words;
CREATE POLICY user_practice_words_delete ON public.user_practice_words
    FOR DELETE TO authenticated USING (user_id = auth.uid());

GRANT SELECT, INSERT, UPDATE, DELETE
    ON public.user_practice_words TO authenticated;
