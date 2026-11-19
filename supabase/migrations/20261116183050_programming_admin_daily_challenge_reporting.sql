
alter function public.programming_admin_student_report(uuid)
  rename to programming_admin_student_report_base;

create function public.programming_admin_student_report(p_student_id uuid default null)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_result jsonb;
  v_report jsonb;
begin
  v_result := public.programming_admin_student_report_base(p_student_id);

  if p_student_id is null then
    return v_result;
  end if;

  select coalesce(v_result->'report','{}'::jsonb) ||
    jsonb_build_object(
      'daily_challenge_attempts',
      (select count(*) from public.programming_exercise_submissions s
       join public.programming_exercises e on e.id=s.exercise_id
       where s.student_id=p_student_id and e.daily_challenge_day is not null),
      'daily_challenges_attempted',
      (select count(distinct s.exercise_id) from public.programming_exercise_submissions s
       join public.programming_exercises e on e.id=s.exercise_id
       where s.student_id=p_student_id and e.daily_challenge_day is not null),
      'daily_challenge_average_score',
      coalesce((select round(avg(s.score)) from public.programming_exercise_submissions s
       join public.programming_exercises e on e.id=s.exercise_id
       where s.student_id=p_student_id and e.daily_challenge_day is not null
         and s.score is not null),0)
    )
  into v_report;

  return jsonb_set(v_result,'{report}',v_report,true);
end;
$$;

revoke all on function public.programming_admin_student_report(uuid) from public;
grant execute on function public.programming_admin_student_report(uuid) to authenticated;

