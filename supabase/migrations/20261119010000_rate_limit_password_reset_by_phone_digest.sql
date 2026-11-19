-- Apply the password-recovery rate limit to every normalized phone number,
-- whether or not it belongs to an existing student. Only a one-way digest is stored.
create table if not exists private.password_reset_phone_limits (
  phone_hash text primary key
    check (phone_hash ~ '^[0-9a-f]{64}$'),
  window_started_at timestamptz not null default now(),
  request_count integer not null default 0 check (request_count >= 0),
  updated_at timestamptz not null default now()
);

create index if not exists password_reset_phone_limits_updated_at_idx
  on private.password_reset_phone_limits(updated_at);

alter table private.password_reset_phone_limits enable row level security;
revoke all privileges on table private.password_reset_phone_limits
  from public, anon, authenticated, service_role;

create or replace function public.doma_allow_password_reset_phone(p_phone_hash text)
returns boolean
language plpgsql
security definer
set search_path = private, public, pg_temp
as $function$
declare
  v_hash text;
  v_count integer;
begin
  v_hash := lower(coalesce(btrim(p_phone_hash), ''));
  if v_hash !~ '^[0-9a-f]{64}$' then
    return false;
  end if;

  insert into private.password_reset_phone_limits
    (phone_hash, window_started_at, request_count, updated_at)
  values (v_hash, now(), 1, now())
  on conflict (phone_hash) do update
    set request_count = case
          when private.password_reset_phone_limits.window_started_at <= now() - interval '15 minutes' then 1
          else private.password_reset_phone_limits.request_count + 1
        end,
        window_started_at = case
          when private.password_reset_phone_limits.window_started_at <= now() - interval '15 minutes' then now()
          else private.password_reset_phone_limits.window_started_at
        end,
        updated_at = now()
  returning request_count into v_count;

  delete from private.password_reset_phone_limits
  where updated_at < now() - interval '24 hours';

  return v_count <= 3;
end;
$function$;

revoke all on function public.doma_allow_password_reset_phone(text)
  from public, anon, authenticated;
grant execute on function public.doma_allow_password_reset_phone(text)
  to service_role;

comment on function public.doma_allow_password_reset_phone(text) is
  'Service-role-only 3-per-15-minute password recovery limiter keyed by a SHA-256 phone digest; callers must return the same public response for limited, known, and unknown numbers.';

notify pgrst, 'reload schema';
