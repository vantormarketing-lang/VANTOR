-- DOMA Production Excellence: optimize programming-course RLS and FK lookups.
-- Non-destructive: adds indexes and recreates only the four policies identified
-- by the Supabase performance advisor. This file is reviewed in GitHub only;
-- it is NOT applied to the production database automatically.

begin;

create index if not exists programming_course_payment_requests_reviewed_by_idx
  on public.programming_course_payment_requests (reviewed_by);

create index if not exists programming_lesson_progress_lesson_id_idx
  on public.programming_lesson_progress (lesson_id);

drop policy if exists "Students read own programming progress"
  on public.programming_lesson_progress;
create policy "Students read own programming progress"
  on public.programming_lesson_progress
  for select
  to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Staff manage programming lessons"
  on public.programming_lessons;
create policy "Staff manage programming lessons"
  on public.programming_lessons
  for all
  to authenticated
  using (
    exists (
      select 1
      from public.profiles p
      where p.id = (select auth.uid())
        and p.role in ('admin', 'teacher')
    )
  )
  with check (
    exists (
      select 1
      from public.profiles p
      where p.id = (select auth.uid())
        and p.role in ('admin', 'teacher')
    )
  );

drop policy if exists "Staff manage programming modules"
  on public.programming_modules;
create policy "Staff manage programming modules"
  on public.programming_modules
  for all
  to authenticated
  using (
    exists (
      select 1
      from public.profiles p
      where p.id = (select auth.uid())
        and p.role in ('admin', 'teacher')
    )
  )
  with check (
    exists (
      select 1
      from public.profiles p
      where p.id = (select auth.uid())
        and p.role in ('admin', 'teacher')
    )
  );

drop policy if exists "Staff manage programming tracks"
  on public.programming_tracks;
create policy "Staff manage programming tracks"
  on public.programming_tracks
  for all
  to authenticated
  using (
    exists (
      select 1
      from public.profiles p
      where p.id = (select auth.uid())
        and p.role in ('admin', 'teacher')
    )
  )
  with check (
    exists (
      select 1
      from public.profiles p
      where p.id = (select auth.uid())
        and p.role in ('admin', 'teacher')
    )
  );

commit;
