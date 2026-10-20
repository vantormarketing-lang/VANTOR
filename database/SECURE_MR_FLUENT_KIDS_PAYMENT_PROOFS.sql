-- Secure Mobile Cash receipt workflow for Mr. Fluent Kids.
-- Run against the existing Mr. Fluent Kids schema. Existing historical requests
-- remain readable; new requests require a private uploaded proof and sender phone.

alter table public.mrfluent_kids_enrollment_requests
  add column if not exists sender_phone text,
  add column if not exists proof_path text;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.mrfluent_kids_enrollment_requests'::regclass
      and conname = 'mrfluent_kids_payment_proof_pair_check'
  ) then
    alter table public.mrfluent_kids_enrollment_requests
      add constraint mrfluent_kids_payment_proof_pair_check
      check (
        (sender_phone is null and proof_path is null)
        or (
          nullif(btrim(sender_phone), '') is not null
          and proof_path is not null
          and left(proof_path, length(user_id::text || '/kids/')) = user_id::text || '/kids/'
        )
      ) not valid;
  end if;
end $$;

-- Add the A1–C2 Kids journey as a separate paid path in the main index.html SPA.
-- Existing Start from Zero / Primary School Support paths remain available.
alter table public.mrfluent_kids_tracks drop constraint if exists mrfluent_kids_tracks_code_check;
alter table public.mrfluent_kids_tracks
  add constraint mrfluent_kids_tracks_code_check
  check (code in ('START_ZERO','PRIMARY_SUPPORT','KIDS_JOURNEY'));

alter table public.mrfluent_kids_levels drop constraint if exists mrfluent_kids_levels_code_check;
alter table public.mrfluent_kids_levels
  add constraint mrfluent_kids_levels_code_check
  check (code in ('K0','K1','K2','K3','K4','K5','P12','P34','P56','A1','B1','C1','A2','B2','C2'));

insert into public.mrfluent_kids_tracks
  (code,title,description,price_egp,duration_days,sort_order,is_published)
values
  ('KIDS_JOURNEY','Mr. Fluent Kids Journey (A1–C2)',
   'The six-level Mr. Fluent Kids learning journey displayed on the main DOMA Academy site. Each level has its own independent 30-day access request.',
   100,30,3,true)
on conflict (code) do update
set title=excluded.title,description=excluded.description,price_egp=100,
    duration_days=30,sort_order=3,is_published=true,updated_at=now();

insert into public.mrfluent_kids_levels
  (track_id,code,title,description,sort_order,is_published)
select t.id,v.code,v.title,v.description,v.sort_order,true
from public.mrfluent_kids_tracks t
cross join (values
  ('A1','My First ABC','Letters, sounds and first words',1),
  ('B1','My First Words','Useful words for daily life',2),
  ('C1','My First Sentences','Build sentences and follow stories',3),
  ('A2','Word Explorers','Vocabulary in everyday contexts',4),
  ('B2','Reading Builders','Read, understand and connect ideas',5),
  ('C2','Confident English','Advanced reading and communication',6)
) as v(code,title,description,sort_order)
where t.code='KIDS_JOURNEY'
on conflict (code) do update
set track_id=excluded.track_id,title=excluded.title,description=excluded.description,
    sort_order=excluded.sort_order,is_published=true,updated_at=now();

-- These metadata rows reflect the actual static course route on index.html.
-- They let the existing admin "content ready" gate validate the published page.
insert into public.mrfluent_kids_units(level_id,title,description,sort_order,is_published)
select l.id,l.code || ' static journey content',
       'Published static course content rendered in index.html?kids=' || lower(l.code) || '.',
       0,true
from public.mrfluent_kids_levels l
join public.mrfluent_kids_tracks t on t.id=l.track_id
where t.code='KIDS_JOURNEY'
on conflict (level_id,sort_order) do update
set title=excluded.title,description=excluded.description,is_published=true,updated_at=now();

insert into public.mrfluent_kids_lessons(unit_id,title,objective,lesson_type,lesson_payload,sort_order,is_published)
select u.id,l.code || ' static lesson page',
       'The corresponding published interactive learning content is rendered from index.html.',
       'learn',jsonb_build_object('source','index.html','route',lower(l.code),'static_content',true),0,true
from public.mrfluent_kids_units u
join public.mrfluent_kids_levels l on l.id=u.level_id
join public.mrfluent_kids_tracks t on t.id=l.track_id
where t.code='KIDS_JOURNEY' and u.sort_order=0
on conflict (unit_id,sort_order) do update
set title=excluded.title,objective=excluded.objective,lesson_type=excluded.lesson_type,
    lesson_payload=excluded.lesson_payload,is_published=true,updated_at=now();

drop policy if exists "kids submit own pending enrollment request"
  on public.mrfluent_kids_enrollment_requests;
drop policy if exists "kids submit own verified payment request"
  on public.mrfluent_kids_enrollment_requests;

create policy "kids submit own verified payment request"
on public.mrfluent_kids_enrollment_requests
for insert to authenticated
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

create unique index if not exists mrfluent_kids_one_pending_payment_per_track
on public.mrfluent_kids_enrollment_requests(user_id, track_id)
where status = 'pending';

update storage.buckets
set allowed_mime_types = array(
  select distinct v
  from unnest(coalesce(allowed_mime_types, array[]::text[]) || array['application/pdf']::text[]) as t(v)
)
where id = 'payment-proofs';

create or replace function public.mrfluent_create_kids_enrollment_request(
  p_track_id uuid,
  p_level_id uuid,
  p_guardian_contact text,
  p_sender_phone text,
  p_proof_path text,
  p_note text default null
)
returns uuid
language plpgsql
security invoker
set search_path = pg_catalog, public, storage
as $function$
declare
  v_user_id uuid := auth.uid();
  v_id uuid;
  v_metadata jsonb;
  v_mimetype text;
  v_file_size bigint;
begin
  if v_user_id is null then
    raise exception 'Please sign in before requesting Kids course access.';
  end if;
  if not exists (select 1 from public.profiles p where p.id = v_user_id) then
    raise exception 'Student profile not found. Complete your account setup first.';
  end if;
  if nullif(btrim(p_guardian_contact), '') is null or length(btrim(p_guardian_contact)) < 7 then
    raise exception 'Enter a valid parent or guardian contact.';
  end if;
  if nullif(btrim(p_sender_phone), '') is null or length(btrim(p_sender_phone)) < 5 then
    raise exception 'Enter the Mobile Cash sender number.';
  end if;
  if p_proof_path is null
     or left(p_proof_path, length(v_user_id::text || '/kids/')) <> v_user_id::text || '/kids/'
     or length(p_proof_path) > 500 then
    raise exception 'The payment receipt path is invalid or does not belong to this student.';
  end if;

  select o.metadata into v_metadata
  from storage.objects o
  where o.bucket_id = 'payment-proofs'
    and o.name = p_proof_path
  limit 1;
  if not found then
    raise exception 'Upload the payment receipt before sending the request.';
  end if;

  v_mimetype := lower(coalesce(v_metadata->>'mimetype', ''));
  if v_mimetype not in ('image/jpeg','image/png','image/webp','application/pdf') then
    raise exception 'The receipt must be a JPG, PNG, WEBP, or PDF file.';
  end if;
  begin
    v_file_size := nullif(v_metadata->>'size', '')::bigint;
  exception when others then
    v_file_size := null;
  end;
  if v_file_size is null or v_file_size < 1 or v_file_size > 5242880 then
    raise exception 'The receipt file must be no larger than 5 MB.';
  end if;

  if not exists (
    select 1 from public.mrfluent_kids_tracks t
    where t.id = p_track_id and t.is_published = true
  ) then
    raise exception 'The selected Kids learning path is not published.';
  end if;
  if not exists (
    select 1 from public.mrfluent_kids_levels l
    where l.id = p_level_id and l.track_id = p_track_id and l.is_published = true
  ) then
    raise exception 'Choose a published level from the selected Kids learning path.';
  end if;

  perform pg_advisory_xact_lock(hashtextextended(v_user_id::text || ':' || p_track_id::text, 0));
  if exists (
    select 1 from public.mrfluent_kids_enrollment_requests r
    where r.user_id = v_user_id and r.track_id = p_track_id and r.status = 'pending'
  ) then
    raise exception 'A Kids payment request for this learning path is already awaiting review.';
  end if;

  insert into public.mrfluent_kids_enrollment_requests
    (user_id, track_id, requested_level_id, guardian_contact, note, status, sender_phone, proof_path)
  values
    (v_user_id, p_track_id, p_level_id, btrim(p_guardian_contact),
     left(coalesce(btrim(p_note), ''), 300), 'pending', btrim(p_sender_phone), p_proof_path)
  returning id into v_id;

  return v_id;
end
$function$;

revoke all on function public.mrfluent_create_kids_enrollment_request(uuid, uuid, text, text, text, text) from public, anon;
grant execute on function public.mrfluent_create_kids_enrollment_request(uuid, uuid, text, text, text, text) to authenticated;
revoke all on function public.mrfluent_kids_approve_enrollment_request(uuid, text) from public, anon;
grant execute on function public.mrfluent_kids_approve_enrollment_request(uuid, text) to authenticated;

create or replace function public.mrfluent_kids_approve_enrollment_request(
  p_request_id uuid,
  p_admin_note text default 'Approved by admin.'
)
returns jsonb
language plpgsql
security invoker
set search_path to 'pg_catalog', 'public'
as $function$
declare
  v_request public.mrfluent_kids_enrollment_requests%rowtype;
  v_track public.mrfluent_kids_tracks%rowtype;
  v_expiry timestamptz;
  v_existing public.mrfluent_kids_subscriptions%rowtype;
begin
  if auth.uid() is null or not public.mrfluent_english_is_staff() then
    raise exception 'Staff access required.' using errcode = '42501';
  end if;
  select * into v_request
  from public.mrfluent_kids_enrollment_requests
  where id = p_request_id
  for update;
  if not found then
    raise exception 'Kids registration request not found.' using errcode = 'P0002';
  end if;
  if v_request.status <> 'pending' then
    raise exception 'This Kids registration request has already been reviewed.' using errcode = 'P0001';
  end if;
  if nullif(btrim(v_request.sender_phone), '') is null
     or v_request.proof_path is null
     or left(v_request.proof_path, length(v_request.user_id::text || '/kids/')) <> v_request.user_id::text || '/kids/'
     or not exists (
       select 1 from storage.objects o
       where o.bucket_id = 'payment-proofs' and o.name = v_request.proof_path
     ) then
    raise exception 'Cannot approve this Kids request without its uploaded payment receipt and sender number. Ask the parent to submit a new payment request.' using errcode = 'P0001';
  end if;
  select * into v_track from public.mrfluent_kids_tracks
  where id = v_request.track_id and is_published = true;
  if not found then raise exception 'The selected Kids track is not published.' using errcode = 'P0001'; end if;
  if v_track.price_egp is null or v_track.duration_days is null then
    raise exception 'Set the Kids track price and duration in Admin → Mr. Fluent Kids before approving this request.' using errcode = 'P0001';
  end if;
  if v_track.duration_days < 1 or v_track.duration_days > 365 then
    raise exception 'The Kids course duration must be from 1 to 365 days.' using errcode = '22023';
  end if;
  if not exists (
    select 1 from public.mrfluent_kids_levels l
    where l.id = v_request.requested_level_id
      and l.track_id = v_request.track_id and l.is_published = true
  ) then
    raise exception 'The requested level is not published for this track.' using errcode = 'P0001';
  end if;
  if not exists (
    select 1 from public.mrfluent_kids_units u
    join public.mrfluent_kids_lessons l on l.unit_id = u.id
    where u.level_id = v_request.requested_level_id
      and u.is_published = true and l.is_published = true
  ) then
    raise exception 'Publish at least one reviewed unit and lesson for this Kids level before activating its subscription.' using errcode = 'P0001';
  end if;

  update public.mrfluent_kids_subscriptions
  set status = 'cancelled', updated_at = now()
  where user_id = v_request.user_id and status = 'active' and track_id <> v_request.track_id;

  select * into v_existing from public.mrfluent_kids_subscriptions s
  where s.user_id = v_request.user_id and s.track_id = v_request.track_id
    and s.status = 'active' and s.expires_at > now()
  order by s.expires_at desc limit 1 for update;

  if found then
    update public.mrfluent_kids_subscriptions
    set level_id = v_request.requested_level_id,
        expires_at = greatest(v_existing.expires_at, now()) + make_interval(days => v_track.duration_days),
        price_egp = v_track.price_egp,
        admin_note = coalesce(nullif(trim(p_admin_note), ''), admin_note),
        updated_at = now()
    where id = v_existing.id returning expires_at into v_expiry;
  else
    insert into public.mrfluent_kids_subscriptions
      (user_id, track_id, level_id, status, starts_at, expires_at, price_egp, created_by, admin_note)
    values
      (v_request.user_id, v_request.track_id, v_request.requested_level_id, 'active',
       now(), now() + make_interval(days => v_track.duration_days), v_track.price_egp,
       auth.uid(), coalesce(nullif(trim(p_admin_note), ''), 'Approved by admin.'))
    returning expires_at into v_expiry;
  end if;

  update public.mrfluent_kids_enrollment_requests
  set status = 'approved',
      admin_note = coalesce(nullif(trim(p_admin_note), ''), 'Approved by admin.'),
      reviewed_by = auth.uid(), reviewed_at = now(), updated_at = now()
  where id = p_request_id;

  return jsonb_build_object('ok', true, 'request_id', p_request_id, 'expires_at', v_expiry,
                            'price_egp', v_track.price_egp, 'duration_days', v_track.duration_days);
end
$function$;


-- Permit removal only of an unlinked, student-owned Kids upload after a failed request.
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
