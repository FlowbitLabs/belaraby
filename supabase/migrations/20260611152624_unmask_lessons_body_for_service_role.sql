-- Unmask lessons.body for non-API roles (service_role, postgres).
--
-- Bug this fixes: the public.lessons view masks body to '' for paid
-- lessons unless the caller is subscribed or admin. The service role is
-- neither, so it read masked bodies — and because the INSTEAD OF UPDATE
-- trigger writes ALL columns back to private.lessons, any partial UPDATE
-- through the view with the service role (e.g. PATCHing hero_image via
-- PostgREST) silently overwrote the stored body of every paid lesson
-- with ''. Service-role and direct-postgres callers now always see the
-- real body, so partial updates round-trip safely. The anon/authenticated
-- gating is unchanged.
CREATE OR REPLACE VIEW public.lessons
WITH (security_invoker = true)
AS
SELECT
    l.id,
    l.title,
    CASE
        WHEN NOT l.paid
          OR current_user NOT IN ('anon', 'authenticated')
          OR (SELECT public.has_active_subscription())
          OR (SELECT public.is_admin())
        THEN l.body
        ELSE ''
    END AS body,
    l.hero_image,
    l.level,
    l.created_at,
    l.grade,
    l.paid,
    l.date
FROM private.lessons l;
