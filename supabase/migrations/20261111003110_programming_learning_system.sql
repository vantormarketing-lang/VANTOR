create table if not exists public.programming_exercises (
  id uuid primary key default gen_random_uuid(),
  lesson_id text not null unique references public.programming_lessons(id) on delete cascade,
  title text not null,
  instructions text not null,
  starter_code text not null default '',
  language text not null default 'python',
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.programming_exercise_submissions (
  id uuid primary key default gen_random_uuid(),
  exercise_id uuid not null references public.programming_exercises(id) on delete cascade,
  student_id uuid not null references auth.users(id) on delete cascade,
  language text not null,
  source_code text not null,
  notes text not null default '',
  status text not null default 'submitted' check (status in ('submitted','reviewed','needs_revision')),
  score integer check (score between 0 and 100),
  feedback text,
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id)
);
create index if not exists programming_exercise_submissions_student_idx on public.programming_exercise_submissions(student_id, submitted_at desc);
create index if not exists programming_exercise_submissions_exercise_idx on public.programming_exercise_submissions(exercise_id, submitted_at desc);

create table if not exists public.programming_quizzes (
  id uuid primary key default gen_random_uuid(),
  lesson_id text not null unique references public.programming_lessons(id) on delete cascade,
  title text not null,
  pass_percent integer not null default 60 check (pass_percent between 1 and 100),
  is_published boolean not null default true,
  created_at timestamptz not null default now()
);
create table if not exists public.programming_quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.programming_quizzes(id) on delete cascade,
  prompt text not null,
  options jsonb not null check (jsonb_typeof(options) = 'array' and jsonb_array_length(options) >= 2),
  correct_index integer not null check (correct_index >= 0),
  explanation text not null default '',
  sort_order integer not null default 0
);
create table if not exists public.programming_quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.programming_quizzes(id) on delete cascade,
  student_id uuid not null references auth.users(id) on delete cascade,
  score integer not null check (score between 0 and 100),
  correct_answers integer not null,
  total_questions integer not null,
  passed boolean not null,
  answers jsonb not null default '{}'::jsonb,
  submitted_at timestamptz not null default now()
);
create index if not exists programming_quiz_attempts_student_idx on public.programming_quiz_attempts(student_id, submitted_at desc);

create table if not exists public.programming_projects (
  id uuid primary key default gen_random_uuid(),
  track_id text not null references public.programming_tracks(id) on delete cascade,
  title text not null,
  brief text not null,
  requirements jsonb not null default '[]'::jsonb,
  is_published boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);
create table if not exists public.programming_project_submissions (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.programming_projects(id) on delete cascade,
  student_id uuid not null references auth.users(id) on delete cascade,
  repository_url text not null default '',
  demo_url text not null default '',
  notes text not null default '',
  status text not null default 'submitted' check (status in ('submitted','reviewed','needs_revision')),
  score integer check (score between 0 and 100),
  feedback text,
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id)
);
create index if not exists programming_project_submissions_student_idx on public.programming_project_submissions(student_id, submitted_at desc);

alter table public.programming_exercises enable row level security;
alter table public.programming_exercise_submissions enable row level security;
alter table public.programming_quizzes enable row level security;
alter table public.programming_quiz_questions enable row level security;
alter table public.programming_quiz_attempts enable row level security;
alter table public.programming_projects enable row level security;
alter table public.programming_project_submissions enable row level security;

drop policy if exists "programming_exercises_read_active" on public.programming_exercises;
create policy "programming_exercises_read_active" on public.programming_exercises for select to authenticated
using (public.mrfluent_english_is_staff() or exists (select 1 from public.programming_course_subscriptions s where s.student_id=(select auth.uid()) and s.status='active' and s.starts_at<=now() and s.expires_at>now()));
drop policy if exists "programming_exercises_staff_manage" on public.programming_exercises;
create policy "programming_exercises_staff_manage" on public.programming_exercises for all to authenticated
using (public.mrfluent_english_is_staff()) with check (public.mrfluent_english_is_staff());

drop policy if exists "programming_exercise_submissions_own_or_staff_read" on public.programming_exercise_submissions;
create policy "programming_exercise_submissions_own_or_staff_read" on public.programming_exercise_submissions for select to authenticated
using (student_id=(select auth.uid()) or public.mrfluent_english_is_staff());
drop policy if exists "programming_exercise_submissions_active_insert" on public.programming_exercise_submissions;
create policy "programming_exercise_submissions_active_insert" on public.programming_exercise_submissions for insert to authenticated
with check (student_id=(select auth.uid()) and exists (select 1 from public.programming_course_subscriptions s where s.student_id=(select auth.uid()) and s.status='active' and s.starts_at<=now() and s.expires_at>now()));
drop policy if exists "programming_exercise_submissions_staff_update" on public.programming_exercise_submissions;
create policy "programming_exercise_submissions_staff_update" on public.programming_exercise_submissions for update to authenticated
using (public.mrfluent_english_is_staff()) with check (public.mrfluent_english_is_staff());

drop policy if exists "programming_quizzes_read_active" on public.programming_quizzes;
create policy "programming_quizzes_read_active" on public.programming_quizzes for select to authenticated
using (public.mrfluent_english_is_staff() or exists (select 1 from public.programming_course_subscriptions s where s.student_id=(select auth.uid()) and s.status='active' and s.starts_at<=now() and s.expires_at>now()));
drop policy if exists "programming_quizzes_staff_manage" on public.programming_quizzes;
create policy "programming_quizzes_staff_manage" on public.programming_quizzes for all to authenticated
using (public.mrfluent_english_is_staff()) with check (public.mrfluent_english_is_staff());

drop policy if exists "programming_quiz_questions_staff_only" on public.programming_quiz_questions;
create policy "programming_quiz_questions_staff_only" on public.programming_quiz_questions for all to authenticated
using (public.mrfluent_english_is_staff()) with check (public.mrfluent_english_is_staff());

drop policy if exists "programming_quiz_attempts_own_or_staff_read" on public.programming_quiz_attempts;
create policy "programming_quiz_attempts_own_or_staff_read" on public.programming_quiz_attempts for select to authenticated
using (student_id=(select auth.uid()) or public.mrfluent_english_is_staff());

drop policy if exists "programming_projects_read_active" on public.programming_projects;
create policy "programming_projects_read_active" on public.programming_projects for select to authenticated
using (public.mrfluent_english_is_staff() or exists (select 1 from public.programming_course_subscriptions s where s.student_id=(select auth.uid()) and s.status='active' and s.starts_at<=now() and s.expires_at>now()));
drop policy if exists "programming_projects_staff_manage" on public.programming_projects;
create policy "programming_projects_staff_manage" on public.programming_projects for all to authenticated
using (public.mrfluent_english_is_staff()) with check (public.mrfluent_english_is_staff());

drop policy if exists "programming_project_submissions_own_or_staff_read" on public.programming_project_submissions;
create policy "programming_project_submissions_own_or_staff_read" on public.programming_project_submissions for select to authenticated
using (student_id=(select auth.uid()) or public.mrfluent_english_is_staff());
drop policy if exists "programming_project_submissions_active_insert" on public.programming_project_submissions;
create policy "programming_project_submissions_active_insert" on public.programming_project_submissions for insert to authenticated
with check (student_id=(select auth.uid()) and exists (select 1 from public.programming_course_subscriptions s where s.student_id=(select auth.uid()) and s.status='active' and s.starts_at<=now() and s.expires_at>now()));
drop policy if exists "programming_project_submissions_staff_update" on public.programming_project_submissions;
create policy "programming_project_submissions_staff_update" on public.programming_project_submissions for update to authenticated
using (public.mrfluent_english_is_staff()) with check (public.mrfluent_english_is_staff());

grant select on public.programming_exercises, public.programming_quizzes, public.programming_projects to authenticated;
grant insert, select on public.programming_exercise_submissions, public.programming_project_submissions to authenticated;
grant select on public.programming_quiz_attempts to authenticated;
grant all on public.programming_exercises, public.programming_exercise_submissions, public.programming_quizzes, public.programming_quiz_questions, public.programming_quiz_attempts, public.programming_projects, public.programming_project_submissions to service_role;

create or replace function public.programming_get_lesson_activities(p_lesson_id text)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v_uid uuid := auth.uid(); v_result jsonb;
begin
  if v_uid is null then raise exception 'Sign in to access lesson activities.'; end if;
  if not public.mrfluent_english_is_staff() and not exists (
    select 1 from public.programming_course_subscriptions s where s.student_id=v_uid and s.status='active' and s.starts_at<=now() and s.expires_at>now()
  ) then raise exception 'An active Programming Academy subscription is required.'; end if;
  if not exists (select 1 from public.programming_lessons l where l.id=p_lesson_id and l.published=true) then raise exception 'Published lesson not found.'; end if;
  select jsonb_build_object(
    'exercise', (select jsonb_build_object('id',e.id,'title',e.title,'instructions',e.instructions,'starter_code',e.starter_code,'language',e.language)
      from public.programming_exercises e where e.lesson_id=p_lesson_id and e.is_published=true limit 1),
    'quiz', (select jsonb_build_object('id',q.id,'title',q.title,'pass_percent',q.pass_percent,
      'questions',coalesce((select jsonb_agg(jsonb_build_object('id',qq.id,'prompt',qq.prompt,'options',qq.options,'sort_order',qq.sort_order) order by qq.sort_order)
        from public.programming_quiz_questions qq where qq.quiz_id=q.id),'[]'::jsonb))
      from public.programming_quizzes q where q.lesson_id=p_lesson_id and q.is_published=true limit 1),
    'exercise_submission', (select jsonb_build_object('id',es.id,'status',es.status,'score',es.score,'feedback',es.feedback,'submitted_at',es.submitted_at)
      from public.programming_exercise_submissions es join public.programming_exercises e on e.id=es.exercise_id
      where e.lesson_id=p_lesson_id and es.student_id=v_uid order by es.submitted_at desc limit 1),
    'quiz_attempt', (select jsonb_build_object('id',qa.id,'score',qa.score,'passed',qa.passed,'submitted_at',qa.submitted_at)
      from public.programming_quiz_attempts qa join public.programming_quizzes q on q.id=qa.quiz_id
      where q.lesson_id=p_lesson_id and qa.student_id=v_uid order by qa.submitted_at desc limit 1)
  ) into v_result;
  return v_result;
end; $$;

create or replace function public.programming_submit_quiz(p_quiz_id uuid, p_answers jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := auth.uid(); v_total integer; v_correct integer; v_score integer; v_pass integer; v_attempt uuid; v_passed boolean;
begin
  if v_uid is null then raise exception 'Sign in before submitting a quiz.'; end if;
  if not public.mrfluent_english_is_staff() and not exists (
    select 1 from public.programming_course_subscriptions s where s.student_id=v_uid and s.status='active' and s.starts_at<=now() and s.expires_at>now()
  ) then raise exception 'An active Programming Academy subscription is required.'; end if;
  if jsonb_typeof(coalesce(p_answers,'{}'::jsonb)) <> 'object' then raise exception 'Answers must be an object.'; end if;
  select q.pass_percent into v_pass from public.programming_quizzes q where q.id=p_quiz_id and q.is_published=true;
  if not found then raise exception 'Published quiz not found.'; end if;
  select count(*),count(*) filter (where
    case when coalesce(p_answers->>qq.id::text,'') ~ '^[0-9]+$'
      then (p_answers->>qq.id::text)::integer = qq.correct_index else false end
  ) into v_total,v_correct
  from public.programming_quiz_questions qq where qq.quiz_id=p_quiz_id;
  if v_total=0 then raise exception 'This quiz has no questions yet.'; end if;
  v_score := floor((v_correct::numeric/v_total::numeric)*100)::integer;
  v_passed := v_score >= v_pass;
  insert into public.programming_quiz_attempts(quiz_id,student_id,score,correct_answers,total_questions,passed,answers)
  values(p_quiz_id,v_uid,v_score,v_correct,v_total,v_passed,coalesce(p_answers,'{}'::jsonb)) returning id into v_attempt;
  return jsonb_build_object('attempt_id',v_attempt,'score',v_score,'correct',v_correct,'total',v_total,'passed',v_passed,'pass_percent',v_pass);
end; $$;

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
    'recent_exercises', (select coalesce(jsonb_agg(x),'[]'::jsonb) from (
      select jsonb_build_object('id',s.id,'student_id',s.student_id,'student_name',coalesce(p.full_name,'طالب'),'exercise_title',e.title,'status',s.status,'score',s.score,'submitted_at',s.submitted_at,'kind','exercise')
      from public.programming_exercise_submissions s join public.programming_exercises e on e.id=s.exercise_id left join public.profiles p on p.id=s.student_id
      order by s.submitted_at desc limit 30
    ) x),
    'recent_projects', (select coalesce(jsonb_agg(x),'[]'::jsonb) from (
      select jsonb_build_object('id',s.id,'student_id',s.student_id,'student_name',coalesce(p.full_name,'طالب'),'project_title',pr.title,'status',s.status,'score',s.score,'submitted_at',s.submitted_at,'kind','project')
      from public.programming_project_submissions s join public.programming_projects pr on pr.id=s.project_id left join public.profiles p on p.id=s.student_id
      order by s.submitted_at desc limit 30
    ) x)
  ) into v_result;
  return v_result;
end; $$;

create or replace function public.programming_admin_review_submission(p_kind text,p_submission_id uuid,p_status text,p_score integer,p_feedback text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_rows integer;
begin
  if auth.uid() is null or not public.mrfluent_english_is_staff() then raise exception 'Admin or teacher access required.'; end if;
  if p_kind not in ('exercise','project') then raise exception 'Invalid submission type.'; end if;
  if p_status not in ('reviewed','needs_revision') then raise exception 'Invalid review status.'; end if;
  if p_score is not null and (p_score<0 or p_score>100) then raise exception 'Score must be between 0 and 100.'; end if;
  if p_kind='exercise' then
    update public.programming_exercise_submissions set status=p_status,score=p_score,feedback=nullif(btrim(coalesce(p_feedback,'')),''),reviewed_at=now(),reviewed_by=auth.uid() where id=p_submission_id;
    get diagnostics v_rows = row_count;
  else
    update public.programming_project_submissions set status=p_status,score=p_score,feedback=nullif(btrim(coalesce(p_feedback,'')),''),reviewed_at=now(),reviewed_by=auth.uid() where id=p_submission_id;
    get diagnostics v_rows = row_count;
  end if;
  if v_rows=0 then raise exception 'Submission not found.'; end if;
  return jsonb_build_object('ok',true,'status',p_status,'score',p_score);
end; $$;

revoke all on function public.programming_get_lesson_activities(text) from public, anon;
revoke all on function public.programming_submit_quiz(uuid,jsonb) from public, anon;
revoke all on function public.programming_admin_learning_overview() from public, anon;
revoke all on function public.programming_admin_review_submission(text,uuid,text,integer,text) from public, anon;
grant execute on function public.programming_get_lesson_activities(text) to authenticated;
grant execute on function public.programming_submit_quiz(uuid,jsonb) to authenticated;
grant execute on function public.programming_admin_learning_overview() to authenticated;
grant execute on function public.programming_admin_review_submission(text,uuid,text,integer,text) to authenticated;

-- Seed a practical assignment from each lesson's existing practice section.
insert into public.programming_exercises(lesson_id,title,instructions,language)
select l.id,'تطبيق عملي: '||l.title,
  coalesce(nullif(btrim(split_part(split_part(l.content_md,'## تدريب',2),'## ',1)),''),l.summary)
  || E'\n\nارفع حلك من المحرر، واكتب ملاحظة قصيرة تشرح الفكرة والاختبار الذي أجريته.',
  case when m.track_id='web-development' then 'javascript' else 'python' end
from public.programming_lessons l
join public.programming_modules m on m.id=l.module_id
where l.published
on conflict (lesson_id) do update set title=excluded.title,instructions=excluded.instructions,updated_at=now();

-- Create a short comprehension quiz for every published lesson. Correct options are shuffled.
insert into public.programming_quizzes(lesson_id,title,pass_percent)
select l.id,'اختبار سريع: '||l.title,60
from public.programming_lessons l where l.published
on conflict (lesson_id) do nothing;

with lesson_quizzes as (
  select l.id lesson_id,l.title,l.summary,q.id quiz_id
  from public.programming_lessons l join public.programming_quizzes q on q.lesson_id=l.id
  where l.published
), choices as (
  select lesson_id,quiz_id,summary choice_text,true is_correct from lesson_quizzes
  union all
  select lq.lesson_id,lq.quiz_id,other.summary,false
  from lesson_quizzes lq
  cross join lateral (
    select l2.summary from public.programming_lessons l2
    where l2.published and l2.id<>lq.lesson_id and l2.summary<>lq.summary
    order by md5(lq.lesson_id||':'||l2.id) limit 3
  ) other
), ordered as (
  select lesson_id,quiz_id,choice_text,is_correct,
    row_number() over(partition by quiz_id order by md5(lesson_id||':'||choice_text)) - 1 option_index
  from choices
), grouped as (
  select lesson_id,quiz_id,
    jsonb_agg(to_jsonb(choice_text) order by option_index) options,
    max(option_index) filter(where is_correct) correct_index
  from ordered group by lesson_id,quiz_id
)
insert into public.programming_quiz_questions(quiz_id,prompt,options,correct_index,explanation,sort_order)
select g.quiz_id,'أي عبارة تلخص هدف درس «'||l.title||'»؟',g.options,g.correct_index,l.summary,1
from grouped g join public.programming_lessons l on l.id=g.lesson_id
where not exists(select 1 from public.programming_quiz_questions q where q.quiz_id=g.quiz_id);

-- One guided capstone brief for every published track.
insert into public.programming_projects(track_id,title,brief,requirements,sort_order)
select t.id,'مشروع تطبيقي: '||t.title,
  'ابنِ مشروعًا صغيرًا يطبق المهارات الأساسية في مسار '||t.title||'. '||t.description,
  jsonb_build_array(
    'اكتب المشكلة التي يحلها المشروع ومن سيستخدمه.',
    'ارسم مخططًا بسيطًا للحل أو مكوناته قبل التنفيذ.',
    'نفّذ نسخة أولية تستخدم المفاهيم التي تعلمتها في هذا المسار.',
    'اختبر المشروع بحالتين عاديتين وحالة حدية واحدة على الأقل.',
    'اكتب README يشرح الفكرة وطريقة التشغيل وما تعلمته.'
  ),1
from public.programming_tracks t where t.published
and not exists(select 1 from public.programming_projects p where p.track_id=t.id);
