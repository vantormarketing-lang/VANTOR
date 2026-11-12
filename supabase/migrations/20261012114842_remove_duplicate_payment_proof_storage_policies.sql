-- Remove duplicated legacy Storage policies for private payment receipts.
-- The retained *rlsfix policies enforce the same owner-folder access and
-- use the private, fixed-search-path staff predicate.
DROP POLICY IF EXISTS "doma staff payment proof read" ON storage.objects;
DROP POLICY IF EXISTS "doma staff payment proof delete" ON storage.objects;
DROP POLICY IF EXISTS "doma payment proof upload own folder" ON storage.objects;

-- Keep the explicit policy names that continue to be used for:
-- 1) the student’s own folder read/upload, and
-- 2) authenticated staff review/delete.
