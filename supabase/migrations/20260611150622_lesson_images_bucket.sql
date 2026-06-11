-- Public storage bucket for lesson hero/cover images.
--
-- Covers are uploaded by admins (dashboard / service role); the app reads
-- them through the public object URL, so no SELECT policy on
-- storage.objects is required. Writes stay locked down: no INSERT/UPDATE/
-- DELETE policies are defined, which means only the service role can
-- modify objects in this bucket.
INSERT INTO storage.buckets (id, name, public)
VALUES ('lesson-images', 'lesson-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;
