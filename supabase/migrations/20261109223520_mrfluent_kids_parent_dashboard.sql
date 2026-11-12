begin;

alter table public.profiles
  drop constraint if exists profiles_role_check;
alter table public.profiles
  add constraint profiles_role_check
  check (role = any (array['student'::text, 'parent'::text, 'admin'::text, 'teacher'::text]));

create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

create index if not exists parent_links_active_parent_idx
  on public.parent_links (parent_id)
  where is_active = true;

create or replace function private.mrfluent_kids_parent_dashboard()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_parent_id uuid := auth.uid();
  v_children jsonb;
begin
  if v_parent_id is null then
    raise exception 'Please sign in with the parent account.';
  end if;

  if not exists (
    select 1 from public.profiles p
    where p.id = v_parent_id and p.role = 'parent'
  ) then
    raise exception 'A parent account is required to view this report.';
  end if;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'student_id', child.id,
        'student_name', coalesce(nullif(btrim(child.full_name), ''), 'Student'),
        'grade_name', coalesce(child.grade_name, ''),
        'subscription_active', child.subscription_active,
        'last_activity_at', child.last_activity_at,
        'levels', child.levels
      ) order by child.student_name
    ), '[]'::jsonb
  )
  into v_children
  from (
    select
      student.id,
      student.full_name,
      grade.name as grade_name,
      exists (
        select 1
        from public.mrfluent_kids_subscriptions sub
        join public.mrfluent_kids_tracks track on track.id = sub.track_id
        where sub.user_id = student.id
          and track.code = 'KIDS_JOURNEY'
          and sub.status = 'active'
          and sub.starts_at <= now()
          and sub.expires_at > now()
      ) as subscription_active,
      (
        select max(progress.updated_at)
        from public.mrfluent_kids_journey_progress progress
        where progress.user_id = student.id
      ) as last_activity_at,
      (
        select coalesce(
          jsonb_agg(
            jsonb_build_object(
              'level_code', level.code,
              'stars', coalesce(progress.stars, 0),
              'words_learned', coalesce(cardinality(progress.words_seen), 0),
              'activity_count', coalesce(stats.activity_count, 0),
              'speaking_missions_completed', coalesce(stats.speaking_count, 0),
              'final_quiz_best', coalesce(progress.final_quiz_best, 0),
              'final_quiz_attempts', coalesce(progress.final_quiz_attempts, 0),
              'review_due_count', coalesce(reviews.due_count, 0),
              'certificate_earned', coalesce(progress.certificate_earned, false),
              'progress_percent',
                least(
                  100,
                  round(
                    least(coalesce(cardinality(progress.words_seen), 0)::numeric / 5, 1) * 35
                    + least(coalesce(stats.speaking_count, 0)::numeric / 3, 1) * 30
                    + least(coalesce(progress.final_quiz_best, 0)::numeric / 4, 1) * 35
                  )
                )::integer
            ) order by level.sort_order
          ), '[]'::jsonb
        )
        from (
          values
            ('A1'::text, 1), ('B1'::text, 2), ('C1'::text, 3),
            ('A2'::text, 4), ('B2'::text, 5), ('C2'::text, 6)
        ) as level(code, sort_order)
        left join public.mrfluent_kids_journey_progress progress
          on progress.user_id = student.id and progress.level_code = level.code
        left join lateral (
          select
            count(*) filter (where key like 'activity:%')::integer as activity_count,
            count(*) filter (where key ~ '^speaking:[A-Za-z0-9_-]+$')::integer as speaking_count
          from unnest(coalesce(progress.checkpoint_keys, array[]::text[])) as keys(key)
        ) stats on true
        left join lateral (
          select count(*)::integer as due_count
          from jsonb_array_elements(coalesce(progress.wrong_answers, '[]'::jsonb)) as item(value)
          where lower(coalesce(item.value ->> 'reviewed', 'false')) <> 'true'
             or (
               coalesce(item.value ->> 'nextReviewAt', item.value ->> 'next_review_at', '')
                 ~ '^\\d{4}-\\d{2}-\\d{2}T'
               and coalesce(item.value ->> 'nextReviewAt', item.value ->> 'next_review_at', '')::timestamptz <= now()
             )
        ) reviews on true
      ) as levels
    from public.parent_links link
    join public.profiles student on student.id = link.student_id
    left join public.grades grade on grade.id = student.grade_id
    where link.parent_id = v_parent_id
      and link.is_active = true
      and student.role = 'student'
  ) child;

  return jsonb_build_object('children', v_children, 'generated_at', now());
end;
$function$;

revoke all on function private.mrfluent_kids_parent_dashboard() from public, anon, authenticated;
grant execute on function private.mrfluent_kids_parent_dashboard() to authenticated;

create or replace function public.mrfluent_kids_parent_dashboard()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $function$
  select private.mrfluent_kids_parent_dashboard();
$function$;

revoke all on function public.mrfluent_kids_parent_dashboard() from public, anon;
grant execute on function public.mrfluent_kids_parent_dashboard() to authenticated;

notify pgrst, 'reload schema';
commit;
