-- Keep grading data server-side and expose only a boolean to the lesson UI.
create schema if not exists private;
create table if not exists private.programming_exercise_tests (
  exercise_id uuid primary key references public.programming_exercises(id) on delete cascade,
  test_cases jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);
alter table private.programming_exercise_tests enable row level security;
revoke all on schema private from public, anon, authenticated;
revoke all on table private.programming_exercise_tests from public, anon, authenticated;
insert into private.programming_exercise_tests(exercise_id,test_cases)
select id,coalesce(test_cases,'[]'::jsonb)
from public.programming_exercises
on conflict(exercise_id) do update
set test_cases=excluded.test_cases,updated_at=now();

-- The first Python pilot uses multiple hidden inputs and exact expected output.
update private.programming_exercise_tests
set test_cases=jsonb_build_array(
  jsonb_build_object('label','اسم مختلف','stdin',E'Nour\n8\n5\n','expected_output',E'Welcome, Nour!\nSum: 13'),
  jsonb_build_object('label','قيم مختلفة','stdin',E'Omar\n20\n22\n','expected_output',E'Welcome, Omar!\nSum: 42'),
  jsonb_build_object('label','عدد سالب','stdin',E'Mona\n-3\n9\n','expected_output',E'Welcome, Mona!\nSum: 6')
),updated_at=now()
where exercise_id='03ae1982-b011-44a4-9c96-c248edeba507';

update public.programming_exercises
set title='تحدّي: بطاقة ترحيب ببيانات مختلفة',
    instructions=E'\n## هدف التدريب\nاكتب برنامجًا يستقبل اسم المتعلم ورقمين، ثم يعرض رسالة ترحيب ومجموع الرقمين.\n\n## المطلوب\n1. اقرأ الاسم من أول سطر إدخال باستخدام input().\n2. اقرأ رقمين صحيحين من السطرين التاليين وحوّلهما إلى int.\n3. اطبع Welcome, NAME! مع استبدال NAME بالاسم الذي أدخله المستخدم.\n4. اطبع Sum: RESULT مع حساب المجموع داخل البرنامج.\n\n## طريقة العمل\nاستخدم input() لقراءة القيم، ثم int() لتحويل الرقمين، وبعدها احسب المجموع. زر اختبار الحل يشغّل برنامجك على بيانات مختلفة مخفية عنك.\n\n## معايير النجاح\n- قراءة الاسم والرقمين من الإدخال بدل تثبيت القيم داخل الكود.\n- حساب المجموع بشكل صحيح لكل مجموعة بيانات.\n- مطابقة الإخراج المتوقع بدقة.',
    starter_code=E'# اقرأ الاسم والرقمين من الإدخال\nname = input().strip()\nfirst = int(input())\nsecond = int(input())\n\n# TODO: اطبع رسالة الترحيب ومجموع الرقمين\n',
    solution_code=E'name = input().strip()\nfirst = int(input())\nsecond = int(input())\nprint(f"Welcome, {name}!")\nprint(f"Sum: {first + second}")',
    test_cases='[]'::jsonb,
    updated_at=now()
where id='03ae1982-b011-44a4-9c96-c248edeba507';

-- Remove browser access to test definitions, solutions and grading rubrics.
revoke select on table public.programming_exercises from public, anon, authenticated;
grant select (id,lesson_id,title,instructions,starter_code,language,is_published,created_at,updated_at,hints,grading_mode)
  on table public.programming_exercises to authenticated;

-- The lesson payload now exposes has_auto_test, never the test data itself.
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
        'has_auto_test',exists (select 1 from private.programming_exercise_tests pt where pt.exercise_id=e.id and jsonb_typeof(pt.test_cases)='array' and exists (select 1 from jsonb_array_elements(pt.test_cases) tc where jsonb_typeof(tc->'stdin')='string' and jsonb_typeof(tc->'expected_output')='string')),'hints',e.hints
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

create or replace function public.doma_get_programming_exercise_tests(p_exercise_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = private, public, pg_temp
as $function$
  select coalesce(pt.test_cases,'[]'::jsonb)
  from private.programming_exercise_tests pt
  join public.programming_exercises e on e.id=pt.exercise_id
  where pt.exercise_id=p_exercise_id and e.is_published=true
  limit 1;
$function$;
revoke all on function public.doma_get_programming_exercise_tests(uuid) from public, anon, authenticated;
grant execute on function public.doma_get_programming_exercise_tests(uuid) to service_role;
