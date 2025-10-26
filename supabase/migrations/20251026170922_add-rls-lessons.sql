ALTER TABLE
    public.lessons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "authenticated_select" ON public.lessons FOR
SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "authenticated_insert" ON public.lessons FOR
INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "authenticated_update" ON public.lessons FOR
UPDATE
    USING (auth.uid() IS NOT NULL);

CREATE POLICY "authenticated_delete" ON public.lessons FOR DELETE USING (auth.uid() IS NOT NULL);