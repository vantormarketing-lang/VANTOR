create schema if not exists private;

revoke all on schema private from public, anon, authenticated;
grant usage on schema private to postgres, service_role;

create table if not exists private.programming_code_run_limits (
  user_id uuid not null,
  window_type text not null check (window_type in ('minute', 'day')),
  window_start timestamptz not null,
  request_count integer not null default 0 check (request_count >= 0),
  primary key (user_id, window_type, window_start)
);

create index if not exists programming_code_run_limits_window_start_idx
  on private.programming_code_run_limits (window_start);

alter table private.programming_code_run_limits enable row level security;
revoke all on table private.programming_code_run_limits from public, anon, authenticated, service_role;

create or replace function public.doma_consume_code_run_quota(p_user_id uuid)
returns table (
  allowed boolean,
  retry_after_seconds integer,
  limit_type text,
  remaining integer
)
language plpgsql
security definer
set search_path = pg_catalog, private
as $$
declare
  v_now timestamptz := clock_timestamp();
  v_minute_start timestamptz;
  v_day_start timestamptz;
  v_count integer;
  v_retry integer;
begin
  if p_user_id is null then
    raise exception 'User id is required';
  end if;

  v_minute_start := date_trunc('minute', v_now);
  v_day_start := date_trunc('day', v_now at time zone 'UTC') at time zone 'UTC';

  insert into private.programming_code_run_limits (user_id, window_type, window_start, request_count)
  values (p_user_id, 'day', v_day_start, 1)
  on conflict (user_id, window_type, window_start)
  do update set request_count = private.programming_code_run_limits.request_count + 1
  returning request_count into v_count;

  if v_count > 50 then
    v_retry := greatest(1, ceil(extract(epoch from ((v_day_start + interval '1 day') - v_now)))::integer);
    return query select false, v_retry, 'day'::text, 0;
    return;
  end if;

  insert into private.programming_code_run_limits (user_id, window_type, window_start, request_count)
  values (p_user_id, 'minute', v_minute_start, 1)
  on conflict (user_id, window_type, window_start)
  do update set request_count = private.programming_code_run_limits.request_count + 1
  returning request_count into v_count;

  if v_count > 5 then
    v_retry := greatest(1, ceil(extract(epoch from ((v_minute_start + interval '1 minute') - v_now)))::integer);
    return query select false, v_retry, 'minute'::text, 0;
    return;
  end if;

  delete from private.programming_code_run_limits
  where user_id = p_user_id
    and window_start < v_now - interval '2 days';

  return query select true, 0, null::text, least(50 - (select l.request_count
    from private.programming_code_run_limits l
    where l.user_id = p_user_id and l.window_type = 'day' and l.window_start = v_day_start),
    5 - (select l.request_count
    from private.programming_code_run_limits l
    where l.user_id = p_user_id and l.window_type = 'minute' and l.window_start = v_minute_start));
end;
$$;

revoke all on function public.doma_consume_code_run_quota(uuid) from public, anon, authenticated;
grant execute on function public.doma_consume_code_run_quota(uuid) to service_role;
