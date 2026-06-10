-- Profiles auto-create + admin flag/helper.
--
-- Rollback:
--   DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
--   DROP FUNCTION IF EXISTS public.handle_new_user();
--   DROP FUNCTION IF EXISTS public.is_admin();
--   ALTER TABLE public.profiles DROP COLUMN IF EXISTS is_admin;
--   -- profiles_id_fkey is recreated with ON DELETE CASCADE. To restore:
--   --   ALTER TABLE public.profiles DROP CONSTRAINT profiles_id_fkey;
--   --   ALTER TABLE public.profiles ADD CONSTRAINT profiles_id_fkey
--   --     FOREIGN KEY (id) REFERENCES auth.users (id);

-- ─── 1. Admin flag on profiles ──────────────────────────────────────────────

ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS is_admin boolean NOT NULL DEFAULT false;

-- ─── 2. Auto-create a profiles row for every new auth user ─────────────────
-- SECURITY DEFINER: runs as the function owner so it can insert into
-- public.profiles regardless of the caller's RLS/privileges. Applies to
-- anonymous sign-ins too (they are rows in auth.users like any other user).

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    BEGIN
        INSERT INTO public.profiles (id, username, full_name, avatar_url)
        VALUES (
            NEW.id,
            NULLIF(NEW.raw_user_meta_data ->> 'username', ''),
            NULLIF(NEW.raw_user_meta_data ->> 'full_name', ''),
            NULLIF(NEW.raw_user_meta_data ->> 'avatar_url', '')
        )
        ON CONFLICT (id) DO NOTHING;
    EXCEPTION WHEN unique_violation THEN
        -- e.g. duplicate username in metadata: never block the signup,
        -- fall back to a bare profile row.
        INSERT INTO public.profiles (id)
        VALUES (NEW.id)
        ON CONFLICT (id) DO NOTHING;
    END;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Backfill: users created before this trigger existed get a profile row too
-- (otherwise e.g. `update profiles set is_admin = true ...` matches nothing).
INSERT INTO public.profiles (id)
SELECT u.id FROM auth.users u
ON CONFLICT (id) DO NOTHING;

-- Every auth user now has a profiles row, so deleting a user (e.g. cleaning
-- up anonymous users) would always hit profiles_id_fkey. Recreate it with
-- ON DELETE CASCADE so deleting an auth user removes the profile too.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint c
        WHERE c.conname = 'profiles_id_fkey'
          AND c.conrelid = 'public.profiles'::regclass
          AND c.confdeltype = 'c' -- already ON DELETE CASCADE
    ) THEN
        ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;
        ALTER TABLE public.profiles
            ADD CONSTRAINT profiles_id_fkey
            FOREIGN KEY (id) REFERENCES auth.users (id) ON DELETE CASCADE;
    END IF;
END $$;

-- ─── 3. public.is_admin() ───────────────────────────────────────────────────
-- SECURITY DEFINER so RLS policies (including policies on profiles itself)
-- can call it without recursing through the profiles RLS policies.

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT COALESCE(
        (SELECT p.is_admin FROM public.profiles p WHERE p.id = auth.uid()),
        false
    );
$$;

REVOKE ALL ON FUNCTION public.is_admin() FROM public;
GRANT EXECUTE ON FUNCTION public.is_admin() TO anon, authenticated, service_role;
