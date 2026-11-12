-- Run against the LOCAL database after supabase db reset.
-- This file performs read-only assertions and raises an error if a baseline extra is missing.
do $$
declare
  expected_table text;
begin
  if not exists (select 1 from pg_extension where extname = 'pg_cron') then
    raise exception 'Baseline check failed: pg_cron extension is missing';
  end if;

  if not exists (
    select 1 from pg_roles
    where rolname = 'authenticator'
      and coalesce(rolconfig, array[]::text[])
          @> array['pgrst.db_pre_request=public.doma_guard_temp_password']
  ) then
    raise exception 'Baseline check failed: authenticator pre-request hook is missing';
  end if;

  if not exists (
    select 1 from cron.job
    where jobname = 'doma-student-reminders-daily'
      and schedule = '0 7 * * *'
      and command = 'select public.doma_generate_all_student_reminders();'
  ) then
    raise exception 'Baseline check failed: daily student reminder cron job is missing or incorrect';
  end if;

  foreach expected_table in array array[
    'mrfluent_english_course_requests',
    'mrfluent_english_course_subscriptions',
    'password_reset_requests',
    'profiles',
    'subscription_requests',
    'subscriptions'
  ]
  loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = expected_table
    ) then
      raise exception 'Baseline check failed: Realtime membership missing for public.%', expected_table;
    end if;
  end loop;

  if not exists (
    select 1 from storage.buckets
    where id = 'homework-submissions'
      and name = 'homework-submissions'
      and public = false
      and file_size_limit = 10485760
      and allowed_mime_types = array[
        'application/pdf','image/jpeg','image/png','image/webp',
        'image/gif','image/heic','image/heif'
      ]::text[]
  ) then
    raise exception 'Baseline check failed: homework-submissions bucket settings differ';
  end if;

  if not exists (
    select 1 from storage.buckets
    where id = 'payment-proofs'
      and name = 'payment-proofs'
      and public = false
      and file_size_limit = 5242880
      and allowed_mime_types = array[
        'application/pdf','image/heif','image/png','image/gif',
        'image/webp','image/heic','image/jpeg'
      ]::text[]
  ) then
    raise exception 'Baseline check failed: payment-proofs bucket settings differ';
  end if;
end
$$;

select 'OK: baseline extras verified' as result;
