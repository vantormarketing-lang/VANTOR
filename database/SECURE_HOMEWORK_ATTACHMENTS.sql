-- Applied to Supabase by migration secure_homework_attachments_storage.
-- Keep homework attachments private; only the owning student and staff can read them.
UPDATE storage.buckets
SET public = false,
    file_size_limit = 10485760,
    allowed_mime_types = ARRAY[
      'application/pdf','image/jpeg','image/png','image/webp',
      'image/gif','image/heic','image/heif'
    ]::text[]
WHERE id = 'homework-submissions';

DROP POLICY IF EXISTS "doma homework attachments read own or staff" ON storage.objects;
CREATE POLICY "doma homework attachments read own or staff"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'homework-submissions'
  AND (
    (storage.foldername(name))[1] = (SELECT auth.uid())::text
    OR private.doma_is_staff()
  )
);

DROP POLICY IF EXISTS "doma homework attachments upload own folder" ON storage.objects;
CREATE POLICY "doma homework attachments upload own folder"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'homework-submissions'
  AND (storage.foldername(name))[1] = (SELECT auth.uid())::text
);

DROP POLICY IF EXISTS "doma homework attachments delete own or staff" ON storage.objects;
CREATE POLICY "doma homework attachments delete own or staff"
ON storage.objects FOR DELETE TO authenticated
USING (
  bucket_id = 'homework-submissions'
  AND (
    (storage.foldername(name))[1] = (SELECT auth.uid())::text
    OR private.doma_is_staff()
  )
);
