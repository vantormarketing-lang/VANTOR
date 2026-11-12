-- Return only the signed-in student's own programming subscription state.
-- SECURITY DEFINER avoids exposing the subscription tables to broad client reads.
create or replace function public.programming_get_my_membership_status()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_user_id uuid := auth.uid();
  v_subscription jsonb;
  v_pending_request jsonb;
begin
  if v_user_id is null then
    raise exception 'Authentication required.' using errcode = '42501';
  end if;

  select jsonb_build_object(
    'id', s.id,
    'amount', s.amount,
    'starts_at', s.starts_at,
    'expires_at', s.expires_at,
    'status', s.status
  )
  into v_subscription
  from public.programming_course_subscriptions s
  where s.student_id = v_user_id
    and s.status = 'active'
    and s.starts_at <= now()
    and s.expires_at > now()
  order by s.expires_at desc
  limit 1;

  select jsonb_build_object('id', r.id, 'status', r.status)
  into v_pending_request
  from public.programming_course_payment_requests r
  where r.student_id = v_user_id
    and r.status = 'pending'
  order by r.created_at desc
  limit 1;

  return jsonb_build_object(
    'subscription', v_subscription,
    'pending_request', v_pending_request
  );
end;
$function$;

revoke all on function public.programming_get_my_membership_status() from public, anon;
grant execute on function public.programming_get_my_membership_status() to authenticated, service_role;
