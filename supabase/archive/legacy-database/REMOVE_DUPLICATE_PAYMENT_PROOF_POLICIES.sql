-- Applied to the live Supabase project by migration
-- remove_duplicate_payment_proof_storage_policies.
-- These policy names were redundant; their replacement policies remain enabled.
DROP POLICY IF EXISTS "doma staff payment proof read" ON storage.objects;
DROP POLICY IF EXISTS "doma staff payment proof delete" ON storage.objects;
DROP POLICY IF EXISTS "doma payment proof upload own folder" ON storage.objects;
