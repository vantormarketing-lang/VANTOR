create extension if not exists pg_cron;

create or replace function public.doma_generate_all_student_reminders()
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_inserted integer := 0;
  v_count integer := 0;
begin
  insert into public.notifications(student_id,title,message,event_key)
  select p.id, 'Live class reminder',
         'Your live class "'||lc.title||'" starts soon.',
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
  select p.id, 'Homework deadline',
         'Homework "'||h.title||'" is due within 48 hours.',
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
  select s.student_id, 'Subscription ending soon',
         'Your subscription for '||s.plan||' expires within 7 days.',
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
  select s.student_id, 'English course ending soon',
         'Your Mr. Fluent English subscription expires within 7 days.',
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
  select s.user_id, 'Kids course ending soon',
         'Your Mr. Fluent Kids subscription expires within 7 days.',
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
  select s.student_id, 'Programming course ending soon',
         'Your Programming Academy subscription expires within 7 days.',
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
$function$;

revoke all on function public.doma_generate_all_student_reminders() from public, anon, authenticated;
grant execute on function public.doma_generate_all_student_reminders() to postgres, service_role;

select cron.schedule(
  'doma-student-reminders-daily',
  '0 7 * * *',
  $$select public.doma_generate_all_student_reminders();$$
);
