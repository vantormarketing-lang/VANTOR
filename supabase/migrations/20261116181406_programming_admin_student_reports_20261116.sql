create or replace function public.programming_admin_student_report(p_student_id uuid default null)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_students jsonb;
  v_report jsonb := null;
begin
  if auth.uid() is null or not public.mrfluent_english_is_staff() then
    raise exception 'Admin or teacher access required.';
  end if;

  select coalesce(jsonb_agg(x.item order by x.student_name), '[]'::jsonb)
  into v_students
  from (
    select p.id as student_id, coalesce(nullif(p.full_name,''), 'طالب') as student_name,
      jsonb_build_object(
        'student_id', p.id,
        'student_name', coalesce(nullif(p.full_name,''), 'طالب'),
        'phone', p.phone,
        'email', p.email,
        'lessons_completed', (select count(*) from public.programming_lesson_progress lp where lp.user_id=p.id),
        'quiz_attempts', (select count(*) from public.programming_quiz_attempts qa where qa.student_id=p.id),
        'exercise_submissions', (select count(*) from public.programming_exercise_submissions es where es.student_id=p.id),
        'project_submissions', (select count(*) from public.programming_project_submissions ps where ps.student_id=p.id)
      ) as item
    from public.profiles p
    where p.role not in ('admin','teacher')
      and (
        exists(select 1 from public.programming_lesson_progress lp where lp.user_id=p.id)
        or exists(select 1 from public.programming_quiz_attempts qa where qa.student_id=p.id)
        or exists(select 1 from public.programming_exercise_submissions es where es.student_id=p.id)
        or exists(select 1 from public.programming_project_submissions ps where ps.student_id=p.id)
      )
  ) x;

  if p_student_id is not null then
    if not exists (
      select 1 from public.profiles p
      where p.id=p_student_id and p.role not in ('admin','teacher')
    ) then
      raise exception 'Student not found.';
    end if;

    select jsonb_build_object(
      'student_id', p.id,
      'student_name', coalesce(nullif(p.full_name,''),'طالب'),
      'phone', p.phone,
      'email', p.email,
      'joined_at', p.created_at,
      'lessons_completed', (select count(*) from public.programming_lesson_progress lp where lp.user_id=p.id),
      'published_lessons', (select count(*) from public.programming_lessons l where l.published=true),
      'quiz_attempts', (select count(*) from public.programming_quiz_attempts qa where qa.student_id=p.id),
      'passed_quizzes', (select count(*) from public.programming_quiz_attempts qa where qa.student_id=p.id and qa.passed=true),
      'average_quiz_score', coalesce((select round(avg(qa.score)) from public.programming_quiz_attempts qa where qa.student_id=p.id),0),
      'exercise_submissions', (select count(*) from public.programming_exercise_submissions es where es.student_id=p.id),
      'reviewed_exercises', (select count(*) from public.programming_exercise_submissions es where es.student_id=p.id and es.status in ('reviewed','needs_revision')),
      'average_exercise_score', coalesce((select round(avg(es.score)) from public.programming_exercise_submissions es where es.student_id=p.id and es.score is not null),0),
      'project_submissions', (select count(*) from public.programming_project_submissions ps where ps.student_id=p.id),
      'reviewed_projects', (select count(*) from public.programming_project_submissions ps where ps.student_id=p.id and ps.status in ('reviewed','needs_revision')),
      'average_project_score', coalesce((select round(avg(ps.score)) from public.programming_project_submissions ps where ps.student_id=p.id and ps.score is not null),0),
      'recent_quizzes', (select coalesce(jsonb_agg(q.item order by q.submitted_at desc),'[]'::jsonb) from (
        select jsonb_build_object('title',z.title,'score',a.score,'passed',a.passed,'submitted_at',a.submitted_at) as item,a.submitted_at
        from public.programming_quiz_attempts a join public.programming_quizzes z on z.id=a.quiz_id
        where a.student_id=p.id order by a.submitted_at desc limit 15
      ) q),
      'recent_exercises', (select coalesce(jsonb_agg(q.item order by q.submitted_at desc),'[]'::jsonb) from (
        select jsonb_build_object('title',e.title,'status',s.status,'score',s.score,'feedback',s.feedback,'submitted_at',s.submitted_at) as item,s.submitted_at
        from public.programming_exercise_submissions s join public.programming_exercises e on e.id=s.exercise_id
        where s.student_id=p.id order by s.submitted_at desc limit 15
      ) q),
      'recent_projects', (select coalesce(jsonb_agg(q.item order by q.submitted_at desc),'[]'::jsonb) from (
        select jsonb_build_object('title',pr.title,'status',s.status,'score',s.score,'feedback',s.feedback,'submitted_at',s.submitted_at) as item,s.submitted_at
        from public.programming_project_submissions s join public.programming_projects pr on pr.id=s.project_id
        where s.student_id=p.id order by s.submitted_at desc limit 15
      ) q)
    ) into v_report
    from public.profiles p
    where p.id=p_student_id;
  end if;

  return jsonb_build_object('students',v_students,'report',v_report);
end;
$function$;

revoke all on function public.programming_admin_student_report(uuid) from public, anon;
grant execute on function public.programming_admin_student_report(uuid) to authenticated;
