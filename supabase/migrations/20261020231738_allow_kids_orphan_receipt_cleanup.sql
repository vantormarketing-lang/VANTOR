drop policy if exists "kids delete unlinked payment proofs" on storage.objects;
create policy "kids delete unlinked payment proofs"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'payment-proofs'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and (storage.foldername(name))[2] = 'kids'
  and not exists (
    select 1
    from public.mrfluent_kids_enrollment_requests r
    where r.proof_path = storage.objects.name
  )
);
