-- Live snapshot of Programming Academy RPC definitions and execute grants.
-- Extracted from production database on 2026-11-12. No student data is included.
BEGIN;

CREATE OR REPLACE FUNCTION public.programming_admin_learning_overview()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
end; $function$;

CREATE OR REPLACE FUNCTION public.programming_admin_list_payment_requests()
 RETURNS TABLE(id uuid, student_id uuid, student_name text, student_phone text, amount numeric, sender_phone text, proof_path text, status text, created_at timestamp with time zone)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if not public.mrfluent_english_is_staff() then
    raise exception 'Admin or teacher access required.';
  end if;
  return query
    select r.id,r.student_id,coalesce(p.full_name,''),coalesce(p.phone,''),
           r.amount,r.sender_phone,r.proof_path,r.status,r.created_at
    from public.programming_course_payment_requests r
    left join public.profiles p on p.id=r.student_id
    order by case when r.status='pending' then 0 else 1 end, r.created_at desc;
end;
$function$;

CREATE OR REPLACE FUNCTION public.programming_admin_review_submission(p_kind text, p_submission_id uuid, p_status text, p_score integer, p_feedback text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
end; $function$;

CREATE OR REPLACE FUNCTION public.programming_approve_payment_request(p_request_id uuid, p_note text DEFAULT 'Payment verified by admin.'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_req public.programming_course_payment_requests%rowtype;
  v_sub public.programming_course_subscriptions%rowtype;
  v_start timestamptz;
begin
  if not public.mrfluent_english_is_staff() then raise exception 'Admin or teacher access required.'; end if;
  select * into v_req from public.programming_course_payment_requests where id=p_request_id for update;
  if not found then raise exception 'Programming Academy payment request not found.'; end if;
  if v_req.status='approved' then
    select * into v_sub from public.programming_course_subscriptions where request_id=v_req.id;
    return jsonb_build_object('ok',true,'already_approved',true,'subscription_id',v_sub.id,'starts_at',v_sub.starts_at,'expires_at',v_sub.expires_at,'student_id',v_req.student_id,'amount',v_sub.amount);
  end if;
  if v_req.status<>'pending' then raise exception 'This request has already been rejected.'; end if;
  select greatest(now(),coalesce(max(s.expires_at),now())) into v_start
  from public.programming_course_subscriptions s
  where s.student_id=v_req.student_id and s.status='active' and s.expires_at>now();
  insert into public.programming_course_subscriptions(student_id,amount,starts_at,expires_at,status,request_id)
  values(v_req.student_id,100,v_start,v_start+interval '30 days','active',v_req.id)
  returning * into v_sub;
  update public.programming_course_payment_requests
  set status='approved',admin_note=nullif(btrim(coalesce(p_note,'')),''),reviewed_by=auth.uid(),reviewed_at=now()
  where id=v_req.id;
  return jsonb_build_object('ok',true,'subscription_id',v_sub.id,'starts_at',v_sub.starts_at,'expires_at',v_sub.expires_at,'student_id',v_req.student_id,'amount',100);
end;
$function$;

CREATE OR REPLACE FUNCTION public.programming_create_payment_request(p_sender_phone text, p_proof_path text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_id uuid;
begin
  if auth.uid() is null then raise exception 'Please sign in before requesting Programming Academy access.'; end if;
  if nullif(btrim(p_sender_phone),'') is null or length(btrim(p_sender_phone)) < 5 then
    raise exception 'Enter a valid Mobile Cash sender number.';
  end if;
  if p_proof_path is null or p_proof_path not like auth.uid()::text || '/programming/%' then
    raise exception 'Receipt path does not belong to this Programming Academy request.';
  end if;
  if not exists (
    select 1 from storage.objects o
    where o.bucket_id='payment-proofs' and o.name=p_proof_path
  ) then raise exception 'Uploaded payment receipt was not found.'; end if;
  if not exists (select 1 from public.profiles p where p.id=auth.uid()) then
    raise exception 'Student profile not found.';
  end if;
  if exists (
    select 1 from public.programming_course_subscriptions s
    where s.student_id=auth.uid() and s.status='active'
      and s.starts_at <= now() and s.expires_at > now()
  ) then raise exception 'Programming Academy access is already active.'; end if;
  if exists (
    select 1 from public.programming_course_payment_requests r
    where r.student_id=auth.uid() and r.status='pending'
  ) then raise exception 'A Programming Academy payment request is already pending.'; end if;
  insert into public.programming_course_payment_requests(student_id,amount,sender_phone,proof_path,status)
  values(auth.uid(),100,btrim(p_sender_phone),p_proof_path,'pending')
  returning id into v_id;
  return v_id;
end;
$function$;

CREATE OR REPLACE FUNCTION public.programming_get_lesson_activities(p_lesson_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
end; $function$;

CREATE OR REPLACE FUNCTION public.programming_get_lesson_content(p_lesson_id text)
 RETURNS text
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_content text;
begin
  if auth.uid() is null then raise exception 'Sign in to access Programming Academy lessons.'; end if;
  if not public.mrfluent_english_is_staff() and not exists (
    select 1 from public.programming_course_subscriptions s
    where s.student_id=auth.uid() and s.status='active'
      and s.starts_at<=now() and s.expires_at>now()
  ) then raise exception 'An active Programming Academy subscription is required.'; end if;
  select l.content_md into v_content
  from public.programming_lessons l
  join public.programming_modules m on m.id=l.module_id and m.published=true
  join public.programming_tracks t on t.id=m.track_id and t.published=true
  where l.id=p_lesson_id and l.published=true;
  if not found then raise exception 'Published lesson not found.'; end if;
  return v_content;
end;
$function$;

CREATE OR REPLACE FUNCTION public.programming_get_my_learning_progress()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
end; $function$;

CREATE OR REPLACE FUNCTION public.programming_get_projects()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
end; $function$;

CREATE OR REPLACE FUNCTION public.programming_reject_payment_request(p_request_id uuid, p_note text DEFAULT 'Payment receipt could not be verified.'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_req public.programming_course_payment_requests%rowtype;
begin
  if not public.mrfluent_english_is_staff() then raise exception 'Admin or teacher access required.'; end if;
  select * into v_req from public.programming_course_payment_requests where id=p_request_id for update;
  if not found then raise exception 'Programming Academy payment request not found.'; end if;
  if v_req.status<>'pending' then raise exception 'This request has already been reviewed.'; end if;
  update public.programming_course_payment_requests
  set status='rejected',admin_note=nullif(btrim(coalesce(p_note,'')),''),reviewed_by=auth.uid(),reviewed_at=now()
  where id=v_req.id;
  return jsonb_build_object('ok',true,'request_id',v_req.id,'student_id',v_req.student_id,'status','rejected');
end;
$function$;

CREATE OR REPLACE FUNCTION public.programming_submit_exercise(p_exercise_id uuid, p_language text, p_source_code text, p_notes text DEFAULT ''::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
end; $function$;

CREATE OR REPLACE FUNCTION public.programming_submit_project(p_project_id uuid, p_repository_url text, p_demo_url text, p_notes text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
end; $function$;

CREATE OR REPLACE FUNCTION public.programming_submit_quiz(p_quiz_id uuid, p_answers jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
end; $function$;

REVOKE ALL ON FUNCTION programming_admin_learning_overview() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_admin_learning_overview() TO "authenticated";
REVOKE ALL ON FUNCTION programming_admin_list_payment_requests() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_admin_list_payment_requests() TO "authenticated";
REVOKE ALL ON FUNCTION programming_admin_review_submission(text,uuid,text,integer,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_admin_review_submission(text,uuid,text,integer,text) TO "authenticated";
REVOKE ALL ON FUNCTION programming_approve_payment_request(uuid,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_approve_payment_request(uuid,text) TO "authenticated";
REVOKE ALL ON FUNCTION programming_create_payment_request(text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_create_payment_request(text,text) TO "authenticated";
REVOKE ALL ON FUNCTION programming_get_lesson_activities(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_get_lesson_activities(text) TO "authenticated";
REVOKE ALL ON FUNCTION programming_get_lesson_content(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_get_lesson_content(text) TO "authenticated";
REVOKE ALL ON FUNCTION programming_get_my_learning_progress() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_get_my_learning_progress() TO "authenticated";
REVOKE ALL ON FUNCTION programming_get_projects() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_get_projects() TO "authenticated";
REVOKE ALL ON FUNCTION programming_reject_payment_request(uuid,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_reject_payment_request(uuid,text) TO "authenticated";
REVOKE ALL ON FUNCTION programming_submit_exercise(uuid,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_submit_exercise(uuid,text,text,text) TO "authenticated";
REVOKE ALL ON FUNCTION programming_submit_project(uuid,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_submit_project(uuid,text,text,text) TO "authenticated";
REVOKE ALL ON FUNCTION programming_submit_quiz(uuid,jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION programming_submit_quiz(uuid,jsonb) TO "authenticated";

COMMIT;
