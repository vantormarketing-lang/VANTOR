-- Refund one reserved assistant request when every inference provider fails.
-- The function shares the same UTC-day advisory lock as the consume RPC.
create or replace function public.doma_refund_assistant_quota(p_user_id uuid)
returns boolean
language plpgsql
security definer
set search_path = pg_catalog, private
as $$
declare
  v_now timestamptz := pg_catalog.clock_timestamp();
  v_today date := (v_now at time zone 'UTC')::date;
  v_refunded boolean := false;
begin
  if p_user_id is null then
    return false;
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtext('doma_assistant_daily:' || v_today::text)
  );

  update private.doma_assistant_usage
  set uses = uses - 1,
      updated_at = v_now
  where user_id = p_user_id
    and usage_day = v_today
    and uses > 0;

  v_refunded := found;
  return v_refunded;
end;
$$;

revoke all on function public.doma_refund_assistant_quota(uuid)
  from public, anon, authenticated;
grant execute on function public.doma_refund_assistant_quota(uuid)
  to service_role;

comment on function public.doma_refund_assistant_quota(uuid) is
  'Service-role-only refund of one assistant quota reservation for the current UTC day after all inference providers fail. Caller must invoke at most once for each reservation.';

notify pgrst, 'reload schema';
