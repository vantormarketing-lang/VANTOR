-- Protect public certificate verification behind a server-side IP quota.
create table if not exists private.programming_certificate_lookup_limits (
  ip inet primary key,
  window_started_at timestamptz not null default now(),
  request_count integer not null default 0 check (request_count >= 0),
  updated_at timestamptz not null default now()
);
create index if not exists programming_certificate_lookup_limits_updated_at_idx
  on private.programming_certificate_lookup_limits(updated_at);
alter table private.programming_certificate_lookup_limits enable row level security;
revoke all on table private.programming_certificate_lookup_limits from public, anon, authenticated;

create or replace function public.doma_allow_certificate_lookup(p_ip text)
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
    v_ip := nullif(btrim(p_ip), '')::inet;
  exception when others then
    return false;
  end;
  if v_ip is null then return false; end if;
  insert into private.programming_certificate_lookup_limits(ip, window_started_at, request_count, updated_at)
  values(v_ip, now(), 1, now())
  on conflict(ip) do update
  set request_count = case when private.programming_certificate_lookup_limits.window_started_at <= now() - interval '15 minutes' then 1 else private.programming_certificate_lookup_limits.request_count + 1 end,
      window_started_at = case when private.programming_certificate_lookup_limits.window_started_at <= now() - interval '15 minutes' then now() else private.programming_certificate_lookup_limits.window_started_at end,
      updated_at = now()
  returning request_count into v_count;
  delete from private.programming_certificate_lookup_limits where updated_at < now() - interval '24 hours';
  return v_count <= 15;
end;
$function$;
revoke all on function public.doma_allow_certificate_lookup(text) from public, anon, authenticated;
grant execute on function public.doma_allow_certificate_lookup(text) to service_role;

create or replace function public.programming_lookup_certificate(p_code text)
returns table(certificate_code text, student_name text, track_title text, issued_at timestamptz)
language sql stable security definer
set search_path = public, pg_temp
as $function$
  select c.certificate_code,
         case
           when nullif(btrim(p.full_name), '') is null then 'DOMA Student'
           when cardinality(regexp_split_to_array(btrim(p.full_name), '\s+')) > 1
             then (regexp_split_to_array(btrim(p.full_name), '\s+'))[1] || ' ' ||
                  left((regexp_split_to_array(btrim(p.full_name), '\s+'))[
                    cardinality(regexp_split_to_array(btrim(p.full_name), '\s+'))
                  ], 1) || '.'
           else left(btrim(p.full_name), 1) || '***'
         end as student_name,
         t.title as track_title,
         c.issued_at
  from public.programming_certificates c
  join public.programming_tracks t on t.id = c.track_id
  left join public.profiles p on p.id = c.student_id
  where length(btrim(coalesce(p_code,''))) between 8 and 80
    and c.certificate_code = btrim(p_code)
  limit 1;
$function$;
revoke all on function public.programming_lookup_certificate(text) from public, anon, authenticated;
grant execute on function public.programming_lookup_certificate(text) to service_role;
