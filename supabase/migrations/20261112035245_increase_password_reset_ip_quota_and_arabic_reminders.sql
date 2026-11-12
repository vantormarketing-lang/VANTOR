-- Give students sharing school/mobile carrier IPs a less restrictive recovery quota.
CREATE OR REPLACE FUNCTION public.doma_allow_password_reset_ip(p_ip text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'private', 'public', 'pg_temp'
AS $function$
declare
  v_ip inet;
  v_count integer;
begin
  begin
    v_ip := nullif(btrim(p_ip),'')::inet;
  exception when others then
    return false;
  end;
  if v_ip is null then return false; end if;

  insert into private.password_reset_ip_limits(ip,window_started_at,request_count,updated_at)
  values(v_ip,now(),1,now())
  on conflict(ip) do update
  set request_count = case
        when private.password_reset_ip_limits.window_started_at <= now() - interval '15 minutes' then 1
        else private.password_reset_ip_limits.request_count + 1
      end,
      window_started_at = case
        when private.password_reset_ip_limits.window_started_at <= now() - interval '15 minutes' then now()
        else private.password_reset_ip_limits.window_started_at
      end,
      updated_at = now()
  returning request_count into v_count;

  delete from private.password_reset_ip_limits
  where updated_at < now() - interval '24 hours';

  return v_count <= 30;
end;
$function$
;

-- Keep all scheduled student reminders in Arabic.
CREATE OR REPLACE FUNCTION public.doma_generate_all_student_reminders()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_inserted integer := 0;
  v_count integer := 0;
begin
  insert into public.notifications(student_id,title,message,event_key)
  select p.id, 'تذكير بحصة مباشرة',
         'حصتك المباشرة "'||lc.title||'" تبدأ قريبًا.',
         'live-class:'||lc.id::text
  from public.profiles p
  join public.live_classes lc
    on lc.is_published = true
   and (lc.grade_id is null or lc.grade_id = p.grade_id)
  where p.role = 'student'
    and lc.starts_at > now()
    and lc.starts_at <= now() + interval '24 hours'
  on conflict (student_id,event_key) where event_key is not null do nothing;
  get diagnostics v_count = row_count;
  v_inserted := v_inserted + v_count;

  insert into public.notifications(student_id,title,message,event_key)
  select p.id, 'موعد تسليم الواجب',
         'الواجب "'||h.title||'" موعد تسليمه خلال 48 ساعة.',
         'homework:'||h.id::text
  from public.profiles p
  join public.homework h on h.grade_id = p.grade_id
  where p.role = 'student'
    and h.is_published = true
    and h.due_at > now()
    and h.due_at <= now() + interval '48 hours'
    and not exists (
      select 1 from public.homework_submissions hs
      where hs.homework_id = h.id and hs.student_id = p.id
    )
  on conflict (student_id,event_key) where event_key is not null do nothing;
  get diagnostics v_count = row_count;
  v_inserted := v_inserted + v_count;

  insert into public.notifications(student_id,title,message,event_key)
  select s.student_id, 'اشتراكك يقترب من الانتهاء',
         'اشتراكك في '||s.plan||' ينتهي خلال 7 أيام.',
         'grade-subscription:'||s.id::text
  from public.subscriptions s
  join public.profiles p on p.id=s.student_id and p.role='student'
  where lower(s.status)='active'
    and s.expires_at > now()
    and s.expires_at <= now() + interval '7 days'
  on conflict (student_id,event_key) where event_key is not null do nothing;
  get diagnostics v_count = row_count;
  v_inserted := v_inserted + v_count;

  insert into public.notifications(student_id,title,message,event_key)
  select s.student_id, 'اشتراك كورس الإنجليزي يقترب من الانتهاء',
         'اشتراك Mr. Fluent English ينتهي خلال 7 أيام.',
         'english-subscription:'||s.id::text
  from public.mrfluent_english_course_subscriptions s
  join public.profiles p on p.id=s.student_id and p.role='student'
  where lower(s.status)='active'
    and s.expires_at > now()
    and s.expires_at <= now() + interval '7 days'
  on conflict (student_id,event_key) where event_key is not null do nothing;
  get diagnostics v_count = row_count;
  v_inserted := v_inserted + v_count;

  insert into public.notifications(student_id,title,message,event_key)
  select s.user_id, 'اشتراك كورس الأطفال يقترب من الانتهاء',
         'اشتراك Mr. Fluent Kids ينتهي خلال 7 أيام.',
         'kids-subscription:'||s.id::text
  from public.mrfluent_kids_subscriptions s
  join public.profiles p on p.id=s.user_id and p.role='student'
  where lower(s.status)='active'
    and s.expires_at > now()
    and s.expires_at <= now() + interval '7 days'
  on conflict (student_id,event_key) where event_key is not null do nothing;
  get diagnostics v_count = row_count;
  v_inserted := v_inserted + v_count;

  insert into public.notifications(student_id,title,message,event_key)
  select s.student_id, 'اشتراك أكاديمية البرمجة يقترب من الانتهاء',
         'اشتراك أكاديمية البرمجة ينتهي خلال 7 أيام.',
         'programming-subscription:'||s.id::text
  from public.programming_course_subscriptions s
  join public.profiles p on p.id=s.student_id and p.role='student'
  where lower(s.status)='active'
    and s.expires_at > now()
    and s.expires_at <= now() + interval '7 days'
  on conflict (student_id,event_key) where event_key is not null do nothing;
  get diagnostics v_count = row_count;
  v_inserted := v_inserted + v_count;

  return v_inserted;
end;
$function$
;
