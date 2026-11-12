create or replace function public.programming_admin_learning_overview()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v_result jsonb;
begin
  if auth.uid() is null or not public.mrfluent_english_is_staff() then raise exception 'Admin or teacher access required.'; end if;
  select jsonb_build_object(
    'students', (select count(distinct student_id) from (
      select student_id from public.programming_exercise_submissions
      union select student_id from public.programming_quiz_attempts
      union select student_id from public.programming_project_submissions
      union select user_id as student_id from public.programming_lesson_progress
    ) learners),
    'exercise_submissions', (select count(*) from public.programming_exercise_submissions),
    'quiz_attempts', (select count(*) from public.programming_quiz_attempts),
    'project_submissions', (select count(*) from public.programming_project_submissions),
    'pending_reviews', (select count(*) from public.programming_exercise_submissions where status='submitted')
      + (select count(*) from public.programming_project_submissions where status='submitted'),
    'recent_exercises', (select coalesce(jsonb_agg(x.item),'[]'::jsonb) from (
      select jsonb_build_object(
        'id',s.id,'student_id',s.student_id,'student_name',coalesce(p.full_name,'طالب'),
        'exercise_title',e.title,'status',s.status,'score',s.score,'submitted_at',s.submitted_at,
        'kind','exercise','language',s.language,'source_code',s.source_code,'notes',s.notes,'feedback',s.feedback
      ) as item
      from public.programming_exercise_submissions s
      join public.programming_exercises e on e.id=s.exercise_id
      left join public.profiles p on p.id=s.student_id
      order by s.submitted_at desc limit 30
    ) x),
    'recent_projects', (select coalesce(jsonb_agg(x.item),'[]'::jsonb) from (
      select jsonb_build_object(
        'id',s.id,'student_id',s.student_id,'student_name',coalesce(p.full_name,'طالب'),
        'project_title',pr.title,'status',s.status,'score',s.score,'submitted_at',s.submitted_at,
        'kind','project','repository_url',s.repository_url,'demo_url',s.demo_url,'notes',s.notes,'feedback',s.feedback
      ) as item
      from public.programming_project_submissions s
      join public.programming_projects pr on pr.id=s.project_id
      left join public.profiles p on p.id=s.student_id
      order by s.submitted_at desc limit 30
    ) x)
  ) into v_result;
  return v_result;
end; $$;
revoke all on function public.programming_admin_learning_overview() from public, anon;
grant execute on function public.programming_admin_learning_overview() to authenticated;
