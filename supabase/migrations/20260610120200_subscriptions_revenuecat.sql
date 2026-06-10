-- Bring public.subscriptions to the RevenueCat contract shape.
--
-- DESTRUCTIVE parts — rollback notes:
--   * Drops the old subscriptions_status_check constraint
--     (status IN ('active','canceled','trial','past_due')). To restore:
--       ALTER TABLE public.subscriptions ADD CONSTRAINT subscriptions_status_check
--         CHECK (status = ANY (ARRAY['active','canceled','trial','past_due']));
--   * Recreates subscriptions_user_id_fkey with ON DELETE CASCADE. To restore:
--       ALTER TABLE public.subscriptions DROP CONSTRAINT subscriptions_user_id_fkey;
--       ALTER TABLE public.subscriptions ADD CONSTRAINT subscriptions_user_id_fkey
--         FOREIGN KEY (user_id) REFERENCES auth.users (id);
--   * Drops any client INSERT/UPDATE/DELETE policies on subscriptions
--     (writes now go exclusively through the service role / webhook).

-- ─── 1. Contract columns (idempotent) ───────────────────────────────────────

ALTER TABLE public.subscriptions
    ADD COLUMN IF NOT EXISTS entitlement_id text NOT NULL DEFAULT 'premium',
    ADD COLUMN IF NOT EXISTS product_id text,
    ADD COLUMN IF NOT EXISTS store text,
    ADD COLUMN IF NOT EXISTS environment text,
    ADD COLUMN IF NOT EXISTS will_renew boolean NOT NULL DEFAULT true,
    ADD COLUMN IF NOT EXISTS original_transaction_id text,
    ADD COLUMN IF NOT EXISTS expires_at timestamptz,
    ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
    ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

-- The old CHECK only allowed active/canceled/trial/past_due; the RevenueCat
-- webhook also writes cancelled/expired/billing_issue/paused.
ALTER TABLE public.subscriptions DROP CONSTRAINT IF EXISTS subscriptions_status_check;
ALTER TABLE public.subscriptions ALTER COLUMN status SET DEFAULT 'active';

-- ─── 2. user_id: FK with ON DELETE CASCADE ──────────────────────────────────

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint c
        WHERE c.conname = 'subscriptions_user_id_fkey'
          AND c.conrelid = 'public.subscriptions'::regclass
          AND c.confdeltype = 'c' -- already ON DELETE CASCADE
    ) THEN
        ALTER TABLE public.subscriptions DROP CONSTRAINT IF EXISTS subscriptions_user_id_fkey;
        ALTER TABLE public.subscriptions
            ADD CONSTRAINT subscriptions_user_id_fkey
            FOREIGN KEY (user_id) REFERENCES auth.users (id) ON DELETE CASCADE;
    END IF;
END $$;

-- ─── 3. user_id NOT NULL (guarded — skipped if legacy NULL rows exist) ──────

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.subscriptions WHERE user_id IS NULL) THEN
        RAISE NOTICE 'subscriptions.user_id has NULL rows - skipping SET NOT NULL; clean them up and re-run.';
    ELSE
        ALTER TABLE public.subscriptions ALTER COLUMN user_id SET NOT NULL;
    END IF;
END $$;

-- ─── 4. UNIQUE (user_id, entitlement_id) — webhook upsert target ────────────

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'subscriptions_user_id_entitlement_id_key'
          AND conrelid = 'public.subscriptions'::regclass
    ) THEN
        IF EXISTS (
            SELECT 1 FROM public.subscriptions
            GROUP BY user_id, entitlement_id
            HAVING count(*) > 1
        ) THEN
            RAISE NOTICE 'duplicate (user_id, entitlement_id) rows exist - skipping UNIQUE constraint; deduplicate and re-run.';
        ELSE
            ALTER TABLE public.subscriptions
                ADD CONSTRAINT subscriptions_user_id_entitlement_id_key
                UNIQUE (user_id, entitlement_id);
        END IF;
    END IF;
END $$;

-- ─── 5. RLS: clients may only read their own row ────────────────────────────

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Drop ALL client write policies — the RevenueCat webhook writes with the
-- service role, which bypasses RLS. Clients must never write subscriptions.
DO $$
DECLARE p RECORD;
BEGIN
    FOR p IN
        SELECT policyname
        FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'subscriptions'
          AND cmd IN ('INSERT', 'UPDATE', 'DELETE', 'ALL')
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.subscriptions;', p.policyname);
    END LOOP;
END $$;

DROP POLICY IF EXISTS subscriptions_select ON public.subscriptions;
CREATE POLICY subscriptions_select ON public.subscriptions
    FOR SELECT USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS subscriptions_admin_select ON public.subscriptions;
CREATE POLICY subscriptions_admin_select ON public.subscriptions
    FOR SELECT USING (public.is_admin());

-- ─── 6. Premium gate — single source of truth ──────────────────────────────
-- A user is premium iff a subscriptions row exists with expires_at in the
-- future. status / will_renew are informational only (a cancellation keeps
-- access until expiry — only expires_at gates).

CREATE OR REPLACE FUNCTION public.has_active_subscription()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.subscriptions s
        WHERE s.user_id = auth.uid()
          AND s.expires_at > now()
    );
$$;

REVOKE ALL ON FUNCTION public.has_active_subscription() FROM public;
GRANT EXECUTE ON FUNCTION public.has_active_subscription() TO anon, authenticated, service_role;

-- ─── 7. Base table privileges ───────────────────────────────────────────────
-- 20251027110740_remote_schema.sql revoked all table privileges from the API
-- roles; RLS gates the rows, but the roles still need base privileges.

GRANT SELECT ON public.subscriptions TO authenticated;
GRANT ALL ON public.subscriptions TO service_role;
