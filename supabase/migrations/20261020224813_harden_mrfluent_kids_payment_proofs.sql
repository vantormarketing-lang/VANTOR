alter function public.mrfluent_create_kids_enrollment_request(uuid, uuid, text, text, text, text) security invoker;

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
    where t.id = track_id and t.is_published = true
  )
  and exists (
    select 1 from public.mrfluent_kids_levels l
    where l.id = requested_level_id and l.track_id = track_id and l.is_published = true
  )
  and exists (
    select 1 from storage.objects o
    where o.bucket_id = 'payment-proofs'
      and o.name = proof_path
      and lower(coalesce(o.metadata->>'mimetype','')) in ('image/jpeg','image/png','image/webp','application/pdf')
  )
);

create unique index if not exists mrfluent_kids_one_pending_payment_per_track
on public.mrfluent_kids_enrollment_requests(user_id, track_id)
where status = 'pending';

update storage.buckets
set allowed_mime_types = array(
  select distinct v
  from unnest(coalesce(allowed_mime_types, array[]::text[]) || array['application/pdf']::text[]) as t(v)
)
where id = 'payment-proofs';

revoke all on function public.mrfluent_create_kids_enrollment_request(uuid, uuid, text, text, text, text) from public, anon;
grant execute on function public.mrfluent_create_kids_enrollment_request(uuid, uuid, text, text, text, text) to authenticated;
