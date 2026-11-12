create or replace function public.mrfluent_kids_approve_enrollment_request(
  p_request_id uuid,
  p_admin_note text default 'Approved by admin.'
)
returns jsonb
language plpgsql
security invoker
set search_path = pg_catalog, public
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

  select * into v_track
  from public.mrfluent_kids_tracks
  where id = v_request.track_id and is_published = true;

  if not found then
    raise exception 'The selected Kids track is not published.' using errcode = 'P0001';
  end if;
  if v_track.price_egp is null or v_track.duration_days is null then
    raise exception 'Set the Kids track price and duration in Admin → Mr. Fluent Kids before approving this request.' using errcode = 'P0001';
  end if;
  if v_track.duration_days < 1 or v_track.duration_days > 365 then
    raise exception 'The Kids course duration must be from 1 to 365 days.' using errcode = '22023';
  end if;
  if not exists (
    select 1 from public.mrfluent_kids_levels l
    where l.id = v_request.requested_level_id
      and l.track_id = v_request.track_id
      and l.is_published = true
  ) then
    raise exception 'The requested level is not published for this track.' using errcode = 'P0001';
  end if;
  if not exists (
    select 1
    from public.mrfluent_kids_units u
    join public.mrfluent_kids_lessons l on l.unit_id = u.id
    where u.level_id = v_request.requested_level_id
      and u.is_published = true
      and l.is_published = true
  ) then
    raise exception 'Publish at least one reviewed unit and lesson for this Kids level before activating its subscription.' using errcode = 'P0001';
  end if;

  -- A user has one active Kids path at a time; other courses/subscriptions are untouched.
  update public.mrfluent_kids_subscriptions
  set status = 'cancelled', updated_at = now()
  where user_id = v_request.user_id
    and status = 'active'
    and track_id <> v_request.track_id;

  select * into v_existing
  from public.mrfluent_kids_subscriptions s
  where s.user_id = v_request.user_id
    and s.track_id = v_request.track_id
    and s.status = 'active'
    and s.expires_at > now()
  order by s.expires_at desc
  limit 1
  for update;

  if found then
    update public.mrfluent_kids_subscriptions
    set level_id = v_request.requested_level_id,
        expires_at = greatest(v_existing.expires_at, now()) + make_interval(days => v_track.duration_days),
        price_egp = v_track.price_egp,
        admin_note = coalesce(nullif(trim(p_admin_note), ''), admin_note),
        updated_at = now()
    where id = v_existing.id
    returning expires_at into v_expiry;
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
      reviewed_by = auth.uid(),
      reviewed_at = now(),
      updated_at = now()
  where id = p_request_id;

  return jsonb_build_object('ok', true, 'request_id', p_request_id, 'expires_at', v_expiry,
                            'price_egp', v_track.price_egp, 'duration_days', v_track.duration_days);
end;
$function$;

revoke all on function public.mrfluent_kids_approve_enrollment_request(uuid,text) from public, anon;
grant execute on function public.mrfluent_kids_approve_enrollment_request(uuid,text) to authenticated;
notify pgrst, 'reload schema';