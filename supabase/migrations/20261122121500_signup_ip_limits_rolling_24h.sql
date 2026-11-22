create or replace function public.doma_allow_signup_ip(p_ip_hash text)
returns boolean
language plpgsql
security definer
set search_path = pg_catalog, private
as $function$
declare
  v_hash text := lower(coalesce(trim(p_ip_hash), ''));
  v_window_count integer;
  v_day_count integer;
begin
  if v_hash !~ '^[0-9a-f]{64}$' then return false; end if;
  insert into private.signup_ip_limits (ip_hash, window_started_at, window_count, day_started_at, day_count, updated_at)
  values (v_hash, now(), 1, now(), 1, now())
  on conflict (ip_hash) do update
    set window_count = case when private.signup_ip_limits.window_started_at <= now() - interval '15 minutes' then 1 else private.signup_ip_limits.window_count + 1 end,
        window_started_at = case when private.signup_ip_limits.window_started_at <= now() - interval '15 minutes' then now() else private.signup_ip_limits.window_started_at end,
        day_count = case when private.signup_ip_limits.day_started_at <= now() - interval '24 hours' then 1 else private.signup_ip_limits.day_count + 1 end,
        day_started_at = case when private.signup_ip_limits.day_started_at <= now() - interval '24 hours' then now() else private.signup_ip_limits.day_started_at end,
        updated_at = now()
  returning window_count, day_count into v_window_count, v_day_count;
  if random() < 0.02 then delete from private.signup_ip_limits where updated_at < now() - interval '48 hours'; end if;
  return v_window_count <= 6 and v_day_count <= 30;
end;
$function$;
revoke all on function public.doma_allow_signup_ip(text) from public, anon, authenticated;
grant execute on function public.doma_allow_signup_ip(text) to service_role;
notify pgrst, 'reload schema';