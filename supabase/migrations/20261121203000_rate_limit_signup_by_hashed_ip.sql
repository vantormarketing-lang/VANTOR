create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to postgres, service_role;

create table if not exists private.signup_ip_limits (
  ip_hash text primary key check (ip_hash ~ '^[0-9a-f]{64}$'),
  window_started_at timestamptz not null default now(),
  window_count integer not null default 0 check (window_count >= 0),
  day_started_at timestamptz not null default now(),
  day_count integer not null default 0 check (day_count >= 0),
  updated_at timestamptz not null default now()
);
alter table private.signup_ip_limits enable row level security;
revoke all privileges on table private.signup_ip_limits from public, anon, authenticated, service_role;

create or replace function public.doma_allow_signup_ip(p_ip_hash text)
returns boolean
language plpgsql
security definer
set search_path = private, public, pg_temp
as $function$
declare
  v_hash text := lower(coalesce(trim(p_ip_hash), ''));
  v_window_count integer;
  v_day_count integer;
begin
  if v_hash !~ '^[0-9a-f]{64}$' then
    return false;
  end if;

  insert into private.signup_ip_limits
    (ip_hash, window_started_at, window_count, day_started_at, day_count, updated_at)
  values (v_hash, now(), 1, now(), 1, now())
  on conflict (ip_hash) do update
    set window_count = case
          when private.signup_ip_limits.window_started_at <= now() - interval '15 minutes' then 1
          else private.signup_ip_limits.window_count + 1
        end,
        window_started_at = case
          when private.signup_ip_limits.window_started_at <= now() - interval '15 minutes' then now()
          else private.signup_ip_limits.window_started_at
        end,
        day_count = case
          when private.signup_ip_limits.day_started_at <= date_trunc('day', now()) then 1
          else private.signup_ip_limits.day_count + 1
        end,
        day_started_at = case
          when private.signup_ip_limits.day_started_at <= date_trunc('day', now()) then now()
          else private.signup_ip_limits.day_started_at
        end,
        updated_at = now()
  returning window_count, day_count into v_window_count, v_day_count;

  delete from private.signup_ip_limits where updated_at < now() - interval '48 hours';
  return v_window_count <= 6 and v_day_count <= 30;
end;
$function$;

revoke all on function public.doma_allow_signup_ip(text) from public, anon, authenticated;
grant execute on function public.doma_allow_signup_ip(text) to service_role;
notify pgrst, 'reload schema';