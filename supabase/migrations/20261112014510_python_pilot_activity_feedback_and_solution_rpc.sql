-- Secure quiz feedback and exercise solution access for Programming Academy.
begin;
alter table public.programming_exercises add column if not exists test_cases jsonb not null default '[]'::jsonb;
alter table public.programming_exercises add column if not exists hints jsonb not null default '[]'::jsonb;
alter table public.programming_exercises add column if not exists solution_code text not null default '';
alter table public.programming_exercises add column if not exists grading_mode text not null default 'manual';
alter table public.programming_quiz_questions add column if not exists explanation text not null default '';
CREATE OR REPLACE FUNCTION public.programming_get_exercise_solution(p_exercise_id uuid)
 RETURNS text
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_solution text;
begin
  if v_uid is null then raise exception 'Sign in to view the model solution.'; end if;
  if not public.mrfluent_english_is_staff() and not exists (
    select 1 from public.programming_course_subscriptions s
    where s.student_id=v_uid and s.status='active' and s.starts_at<=now() and s.expires_at>now()
  ) then raise exception 'An active Programming Academy subscription is required.'; end if;
  if not exists (
    select 1 from public.programming_exercise_submissions es
    where es.exercise_id=p_exercise_id and es.student_id=v_uid
  ) and not public.mrfluent_english_is_staff() then
    raise exception 'Submit an attempt before viewing the model solution.';
  end if;
  select e.solution_code into v_solution
  from public.programming_exercises e
  where e.id=p_exercise_id and e.is_published=true;
  if not found then raise exception 'Published exercise not found.'; end if;
  return coalesce(v_solution,'');
end;
$function$
;

CREATE OR REPLACE FUNCTION public.programming_get_lesson_activities(p_lesson_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_result jsonb;
begin
  if v_uid is null then raise exception 'Sign in to access lesson activities.'; end if;
  if not public.mrfluent_english_is_staff() and not exists (
    select 1 from public.programming_course_subscriptions s
    where s.student_id=v_uid and s.status='active' and s.starts_at<=now() and s.expires_at>now()
  ) then raise exception 'An active Programming Academy subscription is required.'; end if;
  if not exists (select 1 from public.programming_lessons l where l.id=p_lesson_id and l.published=true) then
    raise exception 'Published lesson not found.';
  end if;

  select jsonb_build_object(
    'exercise', (
      select jsonb_build_object(
        'id',e.id,'title',e.title,'instructions',e.instructions,
        'starter_code',e.starter_code,'language',e.language,
        'test_cases',e.test_cases,'hints',e.hints
      )
      from public.programming_exercises e
      where e.lesson_id=p_lesson_id and e.is_published=true
      limit 1
    ),
    'quiz', (
      select jsonb_build_object(
        'id',q.id,'title',q.title,'pass_percent',q.pass_percent,
        'questions',coalesce((
          select jsonb_agg(jsonb_build_object(
            'id',qq.id,'prompt',qq.prompt,'options',qq.options,'sort_order',qq.sort_order
          ) order by qq.sort_order)
          from public.programming_quiz_questions qq where qq.quiz_id=q.id
        ),'[]'::jsonb)
      )
      from public.programming_quizzes q
      where q.lesson_id=p_lesson_id and q.is_published=true
      limit 1
    ),
    'exercise_submission', (
      select jsonb_build_object('id',es.id,'status',es.status,'score',es.score,'feedback',es.feedback,'submitted_at',es.submitted_at)
      from public.programming_exercise_submissions es
      join public.programming_exercises e on e.id=es.exercise_id
      where e.lesson_id=p_lesson_id and es.student_id=v_uid
      order by es.submitted_at desc limit 1
    ),
    'quiz_attempt', (
      select jsonb_build_object('id',qa.id,'score',qa.score,'passed',qa.passed,'submitted_at',qa.submitted_at)
      from public.programming_quiz_attempts qa
      join public.programming_quizzes q on q.id=qa.quiz_id
      where q.lesson_id=p_lesson_id and qa.student_id=v_uid
      order by qa.submitted_at desc limit 1
    )
  ) into v_result;
  return v_result;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.programming_submit_quiz(p_quiz_id uuid, p_answers jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_total integer;
  v_correct integer;
  v_score integer;
  v_pass integer;
  v_attempt uuid;
  v_passed boolean;
  v_feedback jsonb;
begin
  if v_uid is null then raise exception 'Sign in before submitting a quiz.'; end if;
  if not public.mrfluent_english_is_staff() and not exists (
    select 1 from public.programming_course_subscriptions s
    where s.student_id=v_uid and s.status='active' and s.starts_at<=now() and s.expires_at>now()
  ) then raise exception 'An active Programming Academy subscription is required.'; end if;
  if jsonb_typeof(coalesce(p_answers,'{}'::jsonb)) <> 'object' then raise exception 'Answers must be an object.'; end if;

  select q.pass_percent into v_pass
  from public.programming_quizzes q
  where q.id=p_quiz_id and q.is_published=true;
  if not found then raise exception 'Published quiz not found.'; end if;

  select count(*),count(*) filter (where
    case when coalesce(p_answers->>qq.id::text,'') ~ '^[0-9]+$'
      then (p_answers->>qq.id::text)::integer = qq.correct_index else false end
  ) into v_total,v_correct
  from public.programming_quiz_questions qq where qq.quiz_id=p_quiz_id;
  if v_total=0 then raise exception 'This quiz has no questions yet.'; end if;

  v_score := floor((v_correct::numeric/v_total::numeric)*100)::integer;
  v_passed := v_score >= v_pass;

  select coalesce(jsonb_agg(jsonb_build_object(
    'question_id',qq.id,
    'prompt',qq.prompt,
    'selected_index',case when coalesce(p_answers->>qq.id::text,'') ~ '^[0-9]+$'
      then (p_answers->>qq.id::text)::integer else null end,
    'correct_index',qq.correct_index,
    'is_correct',case when coalesce(p_answers->>qq.id::text,'') ~ '^[0-9]+$'
      then (p_answers->>qq.id::text)::integer = qq.correct_index else false end,
    'explanation',qq.explanation
  ) order by qq.sort_order),'[]'::jsonb)
  into v_feedback
  from public.programming_quiz_questions qq
  where qq.quiz_id=p_quiz_id;

  insert into public.programming_quiz_attempts(quiz_id,student_id,score,correct_answers,total_questions,passed,answers)
  values(p_quiz_id,v_uid,v_score,v_correct,v_total,v_passed,coalesce(p_answers,'{}'::jsonb))
  returning id into v_attempt;

  return jsonb_build_object(
    'attempt_id',v_attempt,'score',v_score,'correct',v_correct,'total',v_total,
    'passed',v_passed,'pass_percent',v_pass,'feedback',v_feedback
  );
end;
$function$
;
revoke all on function public.programming_get_lesson_activities(text) from public, anon;
revoke all on function public.programming_submit_quiz(uuid,jsonb) from public, anon;
revoke all on function public.programming_get_exercise_solution(uuid) from public, anon;
grant execute on function public.programming_get_lesson_activities(text) to authenticated, service_role;
grant execute on function public.programming_submit_quiz(uuid,jsonb) to authenticated, service_role;
grant execute on function public.programming_get_exercise_solution(uuid) to authenticated, service_role;
commit;