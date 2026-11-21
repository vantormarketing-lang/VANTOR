create or replace function public.programming_get_lesson_content(p_lesson_id text)
 returns text
 language plpgsql
 stable security definer
 set search_path to ''
as $function$
declare
  v_content text;
begin
  if auth.uid() is null then
    raise exception 'Sign in to access Programming Academy lessons.';
  end if;

  if not public.mrfluent_english_is_staff()
     and not exists (
       select 1
       from public.programming_course_subscriptions s
       where s.student_id = auth.uid()
         and s.status = 'active'
         and s.starts_at <= now()
         and s.expires_at > now()
     )
     and not exists (
       select 1
       from public.doma_global_trials t
       where t.user_id = auth.uid()
         and t.started_at <= now()
         and t.expires_at > now()
     )
  then
    raise exception 'An active Programming Academy subscription or free trial is required.';
  end if;

  select l.content_md into v_content
  from public.programming_lessons l
  join public.programming_modules m on m.id = l.module_id and m.published = true
  join public.programming_tracks t on t.id = m.track_id and t.published = true
  where l.id = p_lesson_id and l.published = true;

  if not found then
    raise exception 'Published lesson not found.';
  end if;

  return v_content;
end;
$function$;
