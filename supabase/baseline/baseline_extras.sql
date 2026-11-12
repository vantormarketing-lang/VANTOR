-- Objects not reliably represented by a schema-only Supabase dump.
-- Reconcile these definitions against the read-only production queries in BASELINE.md.
-- Keep this file free of production data and credentials.

-- 1) Extension used for scheduled student reminders.
create extension if not exists pg_cron;

-- 2) PostgREST pre-request hook. Role settings are not part of a normal schema dump.
alter role authenticator
  set pgrst.db_pre_request = 'public.doma_guard_temp_password';
notify pgrst, 'reload config';

-- 3) Realtime publication membership.
-- Current production contains all six listed public tables.
do $$
declare
  t text;
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    foreach t in array array[
      'mrfluent_english_course_requests',
      'mrfluent_english_course_subscriptions',
      'password_reset_requests',
      'profiles',
      'subscription_requests',
      'subscriptions'
    ]
    loop
      if to_regclass('public.' || t) is not null
         and not exists (
           select 1
           from pg_publication_tables
           where pubname = 'supabase_realtime'
             and schemaname = 'public'
             and tablename = t
         ) then
        execute format('alter publication supabase_realtime add table public.%I', t);
      end if;
    end loop;
  end if;
end
$$;

-- 4) Daily student reminders. The named-job overload updates an existing job
-- with the same name rather than creating a second scheduled reminder.
select cron.schedule(
  'doma-student-reminders-daily',
  '0 7 * * *',
  'select public.doma_generate_all_student_reminders();'
);

-- 5) Private storage buckets.
insert into storage.buckets
  (id, name, public, file_size_limit, allowed_mime_types)
values
  (
    'homework-submissions',
    'homework-submissions',
    false,
    10485760,
    array[
      'application/pdf',
      'image/jpeg',
      'image/png',
      'image/webp',
      'image/gif',
      'image/heic',
      'image/heif'
    ]::text[]
  )
on conflict (id) do update
set name = excluded.name,
    public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

-- PAYMENT_PROOFS_BUCKET_PLACEHOLDER
