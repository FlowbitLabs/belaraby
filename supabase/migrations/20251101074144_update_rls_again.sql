-- ✅ 1. Enable RLS on all tables and drop any existing policies
DO $$
DECLARE
    t RECORD;
    p RECORD;
BEGIN
    FOR t IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
          AND tablename NOT LIKE 'pg_%'
          AND tablename NOT LIKE 'sql_%'
    LOOP
        RAISE NOTICE 'Resetting RLS for table: %', t.tablename;

        -- Enable RLS (safe to call multiple times)
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', t.tablename);

        -- Drop all existing policies on the table
        FOR p IN
            SELECT policyname
            FROM pg_policies
            WHERE tablename = t.tablename
        LOOP
            RAISE NOTICE 'Dropping policy: % on table: %', p.policyname, t.tablename;
            EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I;', p.policyname, t.tablename);
        END LOOP;
    END LOOP;
END $$;

-- ✅ 2. Apply fresh RLS policies (authenticated users only)
DO $$
DECLARE
    t RECORD;
BEGIN
    FOR t IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
          AND tablename NOT LIKE 'pg_%'
          AND tablename NOT LIKE 'sql_%'
    LOOP
        RAISE NOTICE 'Applying new RLS policies to table: %', t.tablename;

        -- SELECT policy
        EXECUTE format(
            'CREATE POLICY authenticated_select ON public.%I FOR SELECT USING ((SELECT auth.uid()) IS NOT NULL);',
            t.tablename
        );

        -- INSERT policy
        EXECUTE format(
            'CREATE POLICY authenticated_insert ON public.%I FOR INSERT WITH CHECK ((SELECT auth.uid()) IS NOT NULL);',
            t.tablename
        );

        -- UPDATE policy
        EXECUTE format(
            'CREATE POLICY authenticated_update ON public.%I FOR UPDATE USING ((SELECT auth.uid()) IS NOT NULL);',
            t.tablename
        );

        -- DELETE policy
        EXECUTE format(
            'CREATE POLICY authenticated_delete ON public.%I FOR DELETE USING ((SELECT auth.uid()) IS NOT NULL);',
            t.tablename
        );
    END LOOP;
END $$;

-- ✅ 3. Special case: Allow public SELECT on lessons table
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "authenticated_select" ON public.lessons;

CREATE POLICY "public_select_lessons" ON public.lessons
    FOR SELECT
    USING (true);