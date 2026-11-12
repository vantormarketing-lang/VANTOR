create table if not exists public.programming_certificates (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references auth.users(id) on delete cascade,
  track_id text not null references public.programming_tracks(id) on delete cascade,
  certificate_code text not null unique,
  issued_at timestamptz not null default now(),
  unique(student_id,track_id)
);
alter table public.programming_certificates enable row level security;
drop policy if exists "programming_certificates_own_or_staff_read" on public.programming_certificates;
create policy "programming_certificates_own_or_staff_read" on public.programming_certificates for select to authenticated
using (student_id=(select auth.uid()) or public.mrfluent_english_is_staff());
grant select on public.programming_certificates to authenticated;
create index if not exists programming_quiz_questions_quiz_order_idx on public.programming_quiz_questions(quiz_id,sort_order);
create index if not exists programming_projects_track_idx on public.programming_projects(track_id,sort_order);

create or replace function public.programming_get_my_learning_progress()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_completed integer;
  v_total integer;
  v_attempts integer;
  v_passed integer;
  v_average integer;
  v_exercises integer;
  v_reviewed_exercises integer;
  v_projects integer;
  v_reviewed_projects integer;
  v_points integer;
  v_result jsonb;
begin
  if v_uid is null then raise exception 'Sign in to view your learning progress.'; end if;
  if not public.mrfluent_english_is_staff() and not exists (
    select 1 from public.programming_course_subscriptions s where s.student_id=v_uid and s.status='active' and s.starts_at<=now() and s.expires_at>now()
  ) then raise exception 'An active Programming Academy subscription is required.'; end if;

  select count(*) into v_completed from public.programming_lesson_progress where user_id=v_uid;
  select count(*) into v_total from public.programming_lessons where published=true;
  select count(*),count(*) filter(where passed),coalesce(round(avg(score)),0)::integer
    into v_attempts,v_passed,v_average from public.programming_quiz_attempts where student_id=v_uid;
  select count(*),count(*) filter(where status='reviewed' and score>=70)
    into v_exercises,v_reviewed_exercises from public.programming_exercise_submissions where student_id=v_uid;
  select count(*),count(*) filter(where status='reviewed' and score>=70)
    into v_projects,v_reviewed_projects from public.programming_project_submissions where student_id=v_uid;

  insert into public.programming_certificates(student_id,track_id,certificate_code)
  select v_uid,t.id,'DOMA-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10))
  from public.programming_tracks t
  where t.published
    and exists(select 1 from public.programming_lessons l join public.programming_modules m on m.id=l.module_id where m.track_id=t.id and l.published=true)
    and not exists(
      select 1 from public.programming_lessons l
      join public.programming_modules m on m.id=l.module_id
      where m.track_id=t.id and l.published=true
        and not exists(select 1 from public.programming_lesson_progress lp where lp.user_id=v_uid and lp.lesson_id=l.id)
    )
    and exists(
      select 1 from public.programming_project_submissions ps
      join public.programming_projects pr on pr.id=ps.project_id
      where ps.student_id=v_uid and pr.track_id=t.id and ps.status='reviewed' and ps.score>=70
    )
  on conflict(student_id,track_id) do nothing;

  v_points := v_completed*10 + v_passed*15 + v_reviewed_exercises*20 + v_reviewed_projects*50;
  select jsonb_build_object(
    'completed_lessons',v_completed,
    'total_lessons',v_total,
    'quiz_attempts',v_attempts,
    'passed_quizzes',v_passed,
    'average_quiz_score',v_average,
    'exercise_submissions',v_exercises,
    'reviewed_exercises',v_reviewed_exercises,
    'project_submissions',v_projects,
    'reviewed_projects',v_reviewed_projects,
    'points',v_points,
    'badges',coalesce((
      select jsonb_agg(b.badge) from (
        select jsonb_build_object('title','أول خطوة','description','أكملت أول درس في رحلتك.','icon','✦') badge where v_completed>=1
        union all select jsonb_build_object('title','متعلم نشيط','description','أكملت خمسة دروس.','icon','📘') where v_completed>=5
        union all select jsonb_build_object('title','نجم الاختبارات','description','اجتزت ثلاثة اختبارات.','icon','★') where v_passed>=3
        union all select jsonb_build_object('title','صانع حلول','description','أرسلت تطبيقًا عمليًا وتم تقييمه.','icon','⌘') where v_reviewed_exercises>=1
        union all select jsonb_build_object('title','باني المشاريع','description','حصل مشروع لك على تقييم 70% أو أكثر.','icon','◆') where v_reviewed_projects>=1
      ) b
    ),'[]'::jsonb),
    'certificates',coalesce((
      select jsonb_agg(jsonb_build_object('track_title',t.title,'track_id',t.id,'certificate_code',c.certificate_code,'issued_at',c.issued_at) order by t.sort_order)
      from public.programming_certificates c join public.programming_tracks t on t.id=c.track_id
      where c.student_id=v_uid
    ),'[]'::jsonb)
  ) into v_result;
  return v_result;
end; $$;
revoke all on function public.programming_get_my_learning_progress() from public, anon;
grant execute on function public.programming_get_my_learning_progress() to authenticated;
