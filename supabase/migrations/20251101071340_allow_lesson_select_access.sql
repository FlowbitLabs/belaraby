ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "authenticated_select" ON public.lessons;

CREATE POLICY "public_select_lessons" ON public.lessons
    FOR SELECT
    USING (true);