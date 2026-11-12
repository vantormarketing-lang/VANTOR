create or replace function public.programming_get_projects()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v_uid uuid := auth.uid(); v_result jsonb;
begin
  if v_uid is null then raise exception 'Sign in to view Programming Academy projects.'; end if;
  if not public.mrfluent_english_is_staff() and not exists (
    select 1 from public.programming_course_subscriptions s where s.student_id=v_uid and s.status='active' and s.starts_at<=now() and s.expires_at>now()
  ) then raise exception 'An active Programming Academy subscription is required.'; end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'id',p.id,'track_id',p.track_id,'title',p.title,'brief',p.brief,'requirements',p.requirements,
    'latest_submission',(select jsonb_build_object('status',s.status,'score',s.score,'feedback',s.feedback,'submitted_at',s.submitted_at)
      from public.programming_project_submissions s where s.project_id=p.id and s.student_id=v_uid order by s.submitted_at desc limit 1)
  ) order by p.sort_order),'[]'::jsonb)
  into v_result from public.programming_projects p where p.is_published=true;
  return v_result;
end; $$;

create or replace function public.programming_get_my_learning_progress()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare v_uid uuid := auth.uid(); v_result jsonb;
begin
  if v_uid is null then raise exception 'Sign in to view your learning progress.'; end if;
  if not public.mrfluent_english_is_staff() and not exists (
    select 1 from public.programming_course_subscriptions s where s.student_id=v_uid and s.status='active' and s.starts_at<=now() and s.expires_at>now()
  ) then raise exception 'An active Programming Academy subscription is required.'; end if;
  select jsonb_build_object(
    'completed_lessons',(select count(*) from public.programming_lesson_progress where user_id=v_uid),
    'total_lessons',(select count(*) from public.programming_lessons where published=true),
    'quiz_attempts',(select count(*) from public.programming_quiz_attempts where student_id=v_uid),
    'passed_quizzes',(select count(*) from public.programming_quiz_attempts where student_id=v_uid and passed=true),
    'average_quiz_score',(select coalesce(round(avg(score)),0) from public.programming_quiz_attempts where student_id=v_uid),
    'exercise_submissions',(select count(*) from public.programming_exercise_submissions where student_id=v_uid),
    'reviewed_exercises',(select count(*) from public.programming_exercise_submissions where student_id=v_uid and status='reviewed'),
    'project_submissions',(select count(*) from public.programming_project_submissions where student_id=v_uid),
    'reviewed_projects',(select count(*) from public.programming_project_submissions where student_id=v_uid and status='reviewed')
  ) into v_result;
  return v_result;
end; $$;

create or replace function public.programming_submit_exercise(p_exercise_id uuid,p_language text,p_source_code text,p_notes text default '')
returns uuid language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := auth.uid(); v_id uuid;
begin
  if v_uid is null then raise exception 'Sign in before submitting your solution.'; end if;
  if not public.mrfluent_english_is_staff() and not exists (
    select 1 from public.programming_course_subscriptions s where s.student_id=v_uid and s.status='active' and s.starts_at<=now() and s.expires_at>now()
  ) then raise exception 'An active Programming Academy subscription is required.'; end if;
  if p_language not in ('python','javascript','html','cpp','java','csharp') then raise exception 'Unsupported exercise language.'; end if;
  if nullif(btrim(coalesce(p_source_code,'')),'') is null or length(p_source_code)>16000 then raise exception 'Enter a solution up to 16,000 characters.'; end if;
  if not exists(select 1 from public.programming_exercises e where e.id=p_exercise_id and e.is_published=true) then raise exception 'Published exercise not found.'; end if;
  insert into public.programming_exercise_submissions(exercise_id,student_id,language,source_code,notes)
  values(p_exercise_id,v_uid,p_language,p_source_code,left(coalesce(p_notes,''),2000)) returning id into v_id;
  return v_id;
end; $$;

create or replace function public.programming_submit_project(p_project_id uuid,p_repository_url text,p_demo_url text,p_notes text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := auth.uid(); v_id uuid;
begin
  if v_uid is null then raise exception 'Sign in before submitting your project.'; end if;
  if not public.mrfluent_english_is_staff() and not exists (
    select 1 from public.programming_course_subscriptions s where s.student_id=v_uid and s.status='active' and s.starts_at<=now() and s.expires_at>now()
  ) then raise exception 'An active Programming Academy subscription is required.'; end if;
  if not exists(select 1 from public.programming_projects p where p.id=p_project_id and p.is_published=true) then raise exception 'Published project not found.'; end if;
  if length(coalesce(p_repository_url,''))>500 or length(coalesce(p_demo_url,''))>500 or length(coalesce(p_notes,''))>3000 then raise exception 'Project details are too long.'; end if;
  if nullif(btrim(coalesce(p_repository_url,'')),'') is null and nullif(btrim(coalesce(p_demo_url,'')),'') is null and nullif(btrim(coalesce(p_notes,'')),'') is null then
    raise exception 'Add a project link or a short description before submitting.';
  end if;
  insert into public.programming_project_submissions(project_id,student_id,repository_url,demo_url,notes)
  values(p_project_id,v_uid,coalesce(p_repository_url,''),coalesce(p_demo_url,''),coalesce(p_notes,'')) returning id into v_id;
  return v_id;
end; $$;

revoke all on function public.programming_get_projects() from public, anon;
revoke all on function public.programming_get_my_learning_progress() from public, anon;
revoke all on function public.programming_submit_exercise(uuid,text,text,text) from public, anon;
revoke all on function public.programming_submit_project(uuid,text,text,text) from public, anon;
grant execute on function public.programming_get_projects() to authenticated;
grant execute on function public.programming_get_my_learning_progress() to authenticated;
grant execute on function public.programming_submit_exercise(uuid,text,text,text) to authenticated;
grant execute on function public.programming_submit_project(uuid,text,text,text) to authenticated;
