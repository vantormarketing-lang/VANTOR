-- RETIRED ON 2026-10-19.
-- This file previously included Mr. Fluent lesson text and assessment content in the public repository.
-- The active lessons and protected runtime payloads are already stored in Supabase.
-- Course runtime is now served from public.mrfluent_course_runtime_payloads under RLS:
-- only staff or a signed-in student with an active subscription and matching current level can read it.
-- Do not add lesson text, quizzes, answer keys, or runtime JavaScript to this public repository.
-- Existing lesson rows and student progress are not deleted or modified by this file.
select 'Retired public content seed. Mr. Fluent course content is managed in Supabase.' as status;
