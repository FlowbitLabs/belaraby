-- Enable RLS on all tables in the public schema except 'lessons'
DO $$ DECLARE t RECORD;

BEGIN FOR t IN
SELECT
    tablename
FROM
    pg_tables
WHERE
    schemaname = 'public'
    AND tablename NOT LIKE 'pg_%'
    AND tablename NOT LIKE 'sql_%' LOOP EXECUTE format(
        'ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;',
        t.tablename
    );

END LOOP;

END $$;

-- Create standard RLS policies for authenticated users (if not existing)
DO $$ DECLARE t RECORD;

BEGIN FOR t IN
SELECT
    tablename
FROM
    pg_tables
WHERE
    schemaname = 'public'
    AND tablename NOT LIKE 'pg_%'
    AND tablename NOT LIKE 'sql_%' LOOP -- SELECT policy
    IF NOT EXISTS (
        SELECT
            1
        FROM
            pg_policies
        WHERE
            policyname = 'authenticated_select'
            AND tablename = t.tablename
    ) THEN EXECUTE format(
        'CREATE POLICY authenticated_select ON public.%I FOR SELECT USING ((SELECT auth.uid()) IS NOT NULL);',
        t.tablename
    );

END IF;

-- INSERT policy
IF NOT EXISTS (
    SELECT
        1
    FROM
        pg_policies
    WHERE
        policyname = 'authenticated_insert'
        AND tablename = t.tablename
) THEN EXECUTE format(
    'CREATE POLICY authenticated_insert ON public.%I FOR INSERT WITH CHECK ((SELECT auth.uid()) IS NOT NULL);',
    t.tablename
);

END IF;

-- UPDATE policy
IF NOT EXISTS (
    SELECT
        1
    FROM
        pg_policies
    WHERE
        policyname = 'authenticated_update'
        AND tablename = t.tablename
) THEN EXECUTE format(
    'CREATE POLICY authenticated_update ON public.%I FOR UPDATE USING ((SELECT auth.uid()) IS NOT NULL);',
    t.tablename
);

END IF;

-- DELETE policy
IF NOT EXISTS (
    SELECT
        1
    FROM
        pg_policies
    WHERE
        policyname = 'authenticated_delete'
        AND tablename = t.tablename
) THEN EXECUTE format(
    'CREATE POLICY authenticated_delete ON public.%I FOR DELETE USING ((SELECT auth.uid()) IS NOT NULL);',
    t.tablename
);

END IF;

END LOOP;

END $$;