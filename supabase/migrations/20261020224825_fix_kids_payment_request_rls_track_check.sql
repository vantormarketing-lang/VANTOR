drop policy if exists "kids submit own verified payment request"
  on public.mrfluent_kids_enrollment_requests;

create policy "kids submit own verified payment request"
on public.mrfluent_kids_enrollment_requests
for insert
to authenticated
with check (
  user_id = (select auth.uid())
  and status = 'pending'
  and reviewed_by is null
  and reviewed_at is null
  and nullif(btrim(sender_phone), '') is not null
  and proof_path is not null
  and left(proof_path, length((select auth.uid())::text || '/kids/')) = (select auth.uid())::text || '/kids/'
  and exists (
    select 1 from public.mrfluent_kids_tracks t
    where t.id = mrfluent_kids_enrollment_requests.track_id and t.is_published = true
  )
  and exists (
    select 1 from public.mrfluent_kids_levels l
    where l.id = mrfluent_kids_enrollment_requests.requested_level_id
      and l.track_id = mrfluent_kids_enrollment_requests.track_id
      and l.is_published = true
  )
  and exists (
    select 1 from storage.objects o
    where o.bucket_id = 'payment-proofs'
      and o.name = mrfluent_kids_enrollment_requests.proof_path
      and lower(coalesce(o.metadata->>'mimetype','')) in ('image/jpeg','image/png','image/webp','application/pdf')
  )
);
