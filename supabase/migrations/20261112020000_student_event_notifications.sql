alter table public.notifications
  add column if not exists event_key text;

create unique index if not exists notifications_student_event_key_uidx
  on public.notifications(student_id, event_key)
  where event_key is not null;

create or replace function public.doma_generate_student_reminders()
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := auth.uid();
  v_grade uuid;
  v_inserted integer := 0;
  v_count integer := 0;
begin
  if v_uid is null then raise exception 'authentication required'; end if;
  select grade_id into v_grade from public.profiles where id = v_uid and role = 'student';
  if not found then raise exception 'student account required'; end if;

  insert into public.notifications(student_id,title,message,event_key)
  select v_uid, 'Live class reminder', 'Your live class "'||lc.title||'" starts soon.', 'live-class:'||lc.id::text
  from public.live_classes lc
  where lc.is_published = true and lc.starts_at > now()
    and lc.starts_at <= now() + interval '24 hours'
    and (lc.grade_id is null or lc.grade_id = v_grade)
  on conflict (student_id,event_key) where event_key is not null do nothing;
  get diagnostics v_count = row_count; v_inserted := v_inserted + v_count;

  insert into public.notifications(student_id,title,message,event_key)
  select v_uid, 'Homework deadline', 'Homework "'||h.title||'" is due within 48 hours.', 'homework:'||h.id::text
  from public.homework h
  where h.is_published = true and h.grade_id = v_grade
    and h.due_at > now() and h.due_at <= now() + interval '48 hours'
    and not exists (select 1 from public.homework_submissions hs where hs.homework_id=h.id and hs.student_id=v_uid)
  on conflict (student_id,event_key) where event_key is not null do nothing;
  get diagnostics v_count = row_count; v_inserted := v_inserted + v_count;

  insert into public.notifications(student_id,title,message,event_key)
  select v_uid, 'Subscription ending soon', 'Your subscription for '||s.plan||' expires within 7 days.', 'grade-subscription:'||s.id::text
  from public.subscriptions s where s.student_id=v_uid and lower(s.status)='active'
    and s.expires_at>now() and s.expires_at<=now()+interval '7 days'
  on conflict (student_id,event_key) where event_key is not null do nothing;
  get diagnostics v_count = row_count; v_inserted := v_inserted + v_count;

  insert into public.notifications(student_id,title,message,event_key)
  select v_uid, 'English course ending soon', 'Your Mr. Fluent English subscription expires within 7 days.', 'english-subscription:'||s.id::text
  from public.mrfluent_english_course_subscriptions s where s.student_id=v_uid and lower(s.status)='active'
    and s.expires_at>now() and s.expires_at<=now()+interval '7 days'
  on conflict (student_id,event_key) where event_key is not null do nothing;
  get diagnostics v_count = row_count; v_inserted := v_inserted + v_count;

  insert into public.notifications(student_id,title,message,event_key)
  select v_uid, 'Kids course ending soon', 'Your Mr. Fluent Kids subscription expires within 7 days.', 'kids-subscription:'||s.id::text
  from public.mrfluent_kids_subscriptions s where s.user_id=v_uid and lower(s.status)='active'
    and s.expires_at>now() and s.expires_at<=now()+interval '7 days'
  on conflict (student_id,event_key) where event_key is not null do nothing;
  get diagnostics v_count = row_count; v_inserted := v_inserted + v_count;

  insert into public.notifications(student_id,title,message,event_key)
  select v_uid, 'Programming course ending soon', 'Your Programming Academy subscription expires within 7 days.', 'programming-subscription:'||s.id::text
  from public.programming_course_subscriptions s where s.student_id=v_uid and lower(s.status)='active'
    and s.expires_at>now() and s.expires_at<=now()+interval '7 days'
  on conflict (student_id,event_key) where event_key is not null do nothing;
  get diagnostics v_count = row_count; v_inserted := v_inserted + v_count;

  return v_inserted;
end;
$$;

revoke all on function public.doma_generate_student_reminders() from public, anon;
grant execute on function public.doma_generate_student_reminders() to authenticated;
