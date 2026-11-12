-- Add a second, IP-based limit to public student password recovery requests.
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table if not exists private.password_reset_ip_limits (
  ip inet primary key,
  window_started_at timestamptz not null default now(),
  request_count integer not null default 0 check (request_count >= 0),
  updated_at timestamptz not null default now()
);
create index if not exists password_reset_ip_limits_updated_at_idx
  on private.password_reset_ip_limits(updated_at);

create or replace function public.doma_allow_password_reset_ip(p_ip text)
returns boolean
language plpgsql
security definer
set search_path = private, public, pg_temp
as $function$
declare
  v_ip inet;
  v_count integer;
begin
  begin
    v_ip := nullif(btrim(p_ip),'')::inet;
  exception when others then
    return false;
  end;
  if v_ip is null then return false; end if;

  insert into private.password_reset_ip_limits(ip,window_started_at,request_count,updated_at)
  values(v_ip,now(),1,now())
  on conflict(ip) do update
  set request_count = case
        when private.password_reset_ip_limits.window_started_at <= now() - interval '15 minutes' then 1
        else private.password_reset_ip_limits.request_count + 1
      end,
      window_started_at = case
        when private.password_reset_ip_limits.window_started_at <= now() - interval '15 minutes' then now()
        else private.password_reset_ip_limits.window_started_at
      end,
      updated_at = now()
  returning request_count into v_count;

  delete from private.password_reset_ip_limits
  where updated_at < now() - interval '24 hours';

  return v_count <= 10;
end;
$function$;

revoke all on function public.doma_allow_password_reset_ip(text) from public, anon, authenticated;
grant execute on function public.doma_allow_password_reset_ip(text) to service_role;
