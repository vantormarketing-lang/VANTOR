create index if not exists programming_certificates_track_idx on public.programming_certificates(track_id);
create index if not exists programming_exercise_submissions_reviewed_by_idx on public.programming_exercise_submissions(reviewed_by);
create index if not exists programming_project_submissions_project_idx on public.programming_project_submissions(project_id);
create index if not exists programming_project_submissions_reviewed_by_idx on public.programming_project_submissions(reviewed_by);
create index if not exists programming_quiz_attempts_quiz_idx on public.programming_quiz_attempts(quiz_id);

drop policy if exists "programming_exercises_read_active" on public.programming_exercises;
create policy "programming_exercises_read_active" on public.programming_exercises for select to authenticated
using ((select public.mrfluent_english_is_staff()) or exists (select 1 from public.programming_course_subscriptions s where s.student_id=(select auth.uid()) and s.status='active' and s.starts_at<=now() and s.expires_at>now()));
drop policy if exists "programming_exercises_staff_manage" on public.programming_exercises;
create policy "programming_exercises_staff_manage" on public.programming_exercises for all to authenticated
using ((select public.mrfluent_english_is_staff())) with check ((select public.mrfluent_english_is_staff()));

drop policy if exists "programming_exercise_submissions_own_or_staff_read" on public.programming_exercise_submissions;
create policy "programming_exercise_submissions_own_or_staff_read" on public.programming_exercise_submissions for select to authenticated
using (student_id=(select auth.uid()) or (select public.mrfluent_english_is_staff()));
drop policy if exists "programming_exercise_submissions_staff_update" on public.programming_exercise_submissions;
create policy "programming_exercise_submissions_staff_update" on public.programming_exercise_submissions for update to authenticated
using ((select public.mrfluent_english_is_staff())) with check ((select public.mrfluent_english_is_staff()));

drop policy if exists "programming_quizzes_read_active" on public.programming_quizzes;
create policy "programming_quizzes_read_active" on public.programming_quizzes for select to authenticated
using ((select public.mrfluent_english_is_staff()) or exists (select 1 from public.programming_course_subscriptions s where s.student_id=(select auth.uid()) and s.status='active' and s.starts_at<=now() and s.expires_at>now()));
drop policy if exists "programming_quizzes_staff_manage" on public.programming_quizzes;
create policy "programming_quizzes_staff_manage" on public.programming_quizzes for all to authenticated
using ((select public.mrfluent_english_is_staff())) with check ((select public.mrfluent_english_is_staff()));

drop policy if exists "programming_quiz_questions_staff_only" on public.programming_quiz_questions;
create policy "programming_quiz_questions_staff_only" on public.programming_quiz_questions for all to authenticated
using ((select public.mrfluent_english_is_staff())) with check ((select public.mrfluent_english_is_staff()));

drop policy if exists "programming_quiz_attempts_own_or_staff_read" on public.programming_quiz_attempts;
create policy "programming_quiz_attempts_own_or_staff_read" on public.programming_quiz_attempts for select to authenticated
using (student_id=(select auth.uid()) or (select public.mrfluent_english_is_staff()));

drop policy if exists "programming_projects_read_active" on public.programming_projects;
create policy "programming_projects_read_active" on public.programming_projects for select to authenticated
using ((select public.mrfluent_english_is_staff()) or exists (select 1 from public.programming_course_subscriptions s where s.student_id=(select auth.uid()) and s.status='active' and s.starts_at<=now() and s.expires_at>now()));
drop policy if exists "programming_projects_staff_manage" on public.programming_projects;
create policy "programming_projects_staff_manage" on public.programming_projects for all to authenticated
using ((select public.mrfluent_english_is_staff())) with check ((select public.mrfluent_english_is_staff()));

drop policy if exists "programming_project_submissions_own_or_staff_read" on public.programming_project_submissions;
create policy "programming_project_submissions_own_or_staff_read" on public.programming_project_submissions for select to authenticated
using (student_id=(select auth.uid()) or (select public.mrfluent_english_is_staff()));
drop policy if exists "programming_project_submissions_staff_update" on public.programming_project_submissions;
create policy "programming_project_submissions_staff_update" on public.programming_project_submissions for update to authenticated
using ((select public.mrfluent_english_is_staff())) with check ((select public.mrfluent_english_is_staff()));

drop policy if exists "programming_certificates_own_or_staff_read" on public.programming_certificates;
create policy "programming_certificates_own_or_staff_read" on public.programming_certificates for select to authenticated
using (student_id=(select auth.uid()) or (select public.mrfluent_english_is_staff()));
