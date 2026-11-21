create or replace function public.doma_get_my_trial_status()
 returns jsonb
 language plpgsql
 security definer
 set search_path to ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_created timestamptz;
  v_confirmed timestamptz;
  v_started timestamptz;
  v_expires timestamptz;
  v_now timestamptz := now();
begin
  if v_uid is null then
    raise exception 'Authentication required' using errcode='42501';
  end if;
  select created_at, email_confirmed_at into v_created, v_confirmed
  from auth.users where id=v_uid;
  if v_created is null then
    raise exception 'Account creation time unavailable' using errcode='P0002';
  end if;
  if v_confirmed is null then
    raise exception 'Email confirmation is required to start the DOMA free trial.' using errcode='42501';
  end if;
  insert into public.doma_global_trials(user_id,started_at,expires_at)
  values(v_uid,v_created,v_created+interval '3 hours')
  on conflict(user_id) do nothing;
  select started_at,expires_at into v_started,v_expires
  from public.doma_global_trials where user_id=v_uid;
  return jsonb_build_object(
    'started_at',v_started,
    'expires_at',v_expires,
    'active',(v_now>=v_started and v_now<v_expires),
    'remaining_seconds',greatest(0,floor(extract(epoch from (v_expires-v_now)))::integer),
    'expired',(v_now>=v_expires),
    'duration_seconds',10800
  );
end;
$function$;