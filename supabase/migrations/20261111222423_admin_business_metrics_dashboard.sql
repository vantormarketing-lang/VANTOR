create or replace function public.doma_admin_business_metrics()
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_revenue numeric := 0;
  v_expiring integer := 0;
  v_renewal_rate numeric := 0;
  v_abandoned jsonb := '[]'::jsonb;
  v_eligible integer := 0;
  v_renewed integer := 0;
begin
  if auth.uid() is null or not exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  ) then
    raise exception 'not authorized';
  end if;

  select
    coalesce((select sum(amount) from public.subscription_requests where lower(status) = 'approved'), 0) +
    coalesce((select sum(amount) from public.mrfluent_english_course_requests where lower(status) = 'approved'), 0) +
    coalesce((select sum(amount) from public.programming_course_payment_requests where lower(status) = 'approved'), 0) +
    coalesce((select sum(price_egp) from public.mrfluent_kids_subscriptions), 0)
  into v_revenue;

  select count(*) into v_expiring
  from (
    select id from public.subscriptions
      where lower(status) = 'active' and expires_at > now() and expires_at <= now() + interval '7 days'
    union all
    select id from public.mrfluent_english_course_subscriptions
      where lower(status) = 'active' and expires_at > now() and expires_at <= now() + interval '7 days'
    union all
    select id from public.mrfluent_kids_subscriptions
      where lower(status) = 'active' and expires_at > now() and expires_at <= now() + interval '7 days'
    union all
    select id from public.programming_course_subscriptions
      where lower(status) = 'active' and expires_at > now() and expires_at <= now() + interval '7 days'
  ) expiring_rows;

  with per_student as (
    select student_id, count(*) as approved_count
    from public.subscription_requests
    where lower(status) = 'approved'
    group by student_id
  )
  select count(*), count(*) filter (where approved_count >= 2)
  into v_eligible, v_renewed
  from per_student;

  v_renewal_rate := case when v_eligible > 0
    then round((v_renewed::numeric / v_eligible::numeric) * 100, 1)
    else 0 end;

  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_abandoned
  from (
    select l.id, l.title, count(*)::integer as students_started,
           round(avg(lp.progress_percent), 0)::integer as average_progress
    from public.lesson_progress lp
    join public.lessons l on l.id = lp.lesson_id
    where lp.completed = false and lp.progress_percent < 100
    group by l.id, l.title
    order by count(*) desc, l.title
    limit 5
  ) t;

  return jsonb_build_object(
    'revenue_egp', round(v_revenue, 2),
    'expiring_within_7_days', v_expiring,
    'grade_renewal_rate_percent', v_renewal_rate,
    'grade_students_with_approved_subscription', v_eligible,
    'grade_students_with_repeat_approved_request', v_renewed,
    'most_abandoned_lessons', v_abandoned,
    'generated_at', now()
  );
end;
$$;

revoke all on function public.doma_admin_business_metrics() from public, anon;
grant execute on function public.doma_admin_business_metrics() to authenticated;
