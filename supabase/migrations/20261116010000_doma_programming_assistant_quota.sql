-- Private daily usage accounting for the Programming Academy AI tutor.
-- The Pages Function verifies the user's Auth JWT and Programming Academy
-- subscription/staff role before calling this service-role-only RPC.

create table if not exists private.doma_assistant_usage (
  usage_day date not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  uses integer not null default 0 check (uses >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (usage_day, user_id)
);

create index if not exists doma_assistant_usage_user_day_idx
  on private.doma_assistant_usage (user_id, usage_day);

alter table private.doma_assistant_usage enable row level security;
revoke all on table private.doma_assistant_usage from public, anon, authenticated, service_role;
grant usage on schema private to service_role;

create or replace function public.doma_consume_assistant_quota(p_user_id uuid)
returns table (
  allowed boolean,
  remaining_user integer,
  remaining_global integer,
  reason text
)
language plpgsql
security definer
set search_path = pg_catalog, private
as $$
declare
  v_now timestamptz := pg_catalog.clock_timestamp();
  v_today date := (v_now at time zone 'UTC')::date;
  v_user_uses integer := 0;
  v_global_uses integer := 0;
begin
  if p_user_id is null then
    raise exception 'User id is required';
  end if;

  -- One transaction lock per UTC day serializes all requests so the
  -- platform-wide quota cannot be exceeded by concurrent calls.
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtext('doma_assistant_daily:' || v_today::text)
  );

  select coalesce(u.uses, 0)
    into v_user_uses
  from private.doma_assistant_usage u
  where u.user_id = p_user_id and u.usage_day = v_today;
  v_user_uses := coalesce(v_user_uses, 0);

  select coalesce(sum(u.uses), 0)::integer
    into v_global_uses
  from private.doma_assistant_usage u
  where u.usage_day = v_today;

  if v_user_uses >= 10 then
    return query select false, 0, greatest(0, 150 - v_global_uses), 'user_daily_limit'::text;
    return;
  end if;

  if v_global_uses >= 150 then
    return query select false, greatest(0, 10 - v_user_uses), 0, 'global_daily_limit'::text;
    return;
  end if;

  insert into private.doma_assistant_usage (usage_day, user_id, uses, created_at, updated_at)
  values (v_today, p_user_id, 1, v_now, v_now)
  on conflict (usage_day, user_id)
  do update set
    uses = private.doma_assistant_usage.uses + 1,
    updated_at = excluded.updated_at
  returning uses into v_user_uses;

  v_global_uses := v_global_uses + 1;
  return query select
    true,
    greatest(0, 10 - v_user_uses),
    greatest(0, 150 - v_global_uses),
    null::text;
end;
$$;

-- This is deliberately not an authenticated browser RPC. Only the trusted
-- Pages Function can call it with the server-side service-role key.
revoke all on function public.doma_consume_assistant_quota(uuid) from public, anon, authenticated;
grant execute on function public.doma_consume_assistant_quota(uuid) to service_role;

comment on function public.doma_consume_assistant_quota(uuid) is
  'Atomically consumes one Programming Academy AI assistant request. Service-role only; the caller must verify the user Auth JWT and active subscription first. Limits: 10 per user and 150 platform-wide per UTC day.';

notify pgrst, 'reload schema';
