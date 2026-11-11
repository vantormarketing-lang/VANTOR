-- Restore the Programming Academy learning-system schema found in production.
-- This captures exercises, quizzes, quiz questions, projects, submissions and certificates.
-- Existing student submissions and certificate records are intentionally not exported.
BEGIN;

CREATE TABLE IF NOT EXISTS public."programming_exercises" (
  "id" uuid DEFAULT gen_random_uuid() NOT NULL,
  "lesson_id" text NOT NULL,
  "title" text NOT NULL,
  "instructions" text NOT NULL,
  "starter_code" text DEFAULT ''::text NOT NULL,
  "language" text DEFAULT 'python'::text NOT NULL,
  "is_published" boolean DEFAULT true NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "programming_exercises_lesson_id_fkey" FOREIGN KEY (lesson_id) REFERENCES programming_lessons(id) ON DELETE CASCADE,
  CONSTRAINT "programming_exercises_lesson_id_key" UNIQUE (lesson_id),
  CONSTRAINT "programming_exercises_pkey" PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public."programming_quizzes" (
  "id" uuid DEFAULT gen_random_uuid() NOT NULL,
  "lesson_id" text NOT NULL,
  "title" text NOT NULL,
  "pass_percent" integer DEFAULT 60 NOT NULL,
  "is_published" boolean DEFAULT true NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "programming_quizzes_lesson_id_fkey" FOREIGN KEY (lesson_id) REFERENCES programming_lessons(id) ON DELETE CASCADE,
  CONSTRAINT "programming_quizzes_lesson_id_key" UNIQUE (lesson_id),
  CONSTRAINT "programming_quizzes_pass_percent_check" CHECK (pass_percent >= 1 AND pass_percent <= 100),
  CONSTRAINT "programming_quizzes_pkey" PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public."programming_quiz_questions" (
  "id" uuid DEFAULT gen_random_uuid() NOT NULL,
  "quiz_id" uuid NOT NULL,
  "prompt" text NOT NULL,
  "options" jsonb NOT NULL,
  "correct_index" integer NOT NULL,
  "explanation" text DEFAULT ''::text NOT NULL,
  "sort_order" integer DEFAULT 0 NOT NULL,
  CONSTRAINT "programming_quiz_questions_correct_index_check" CHECK (correct_index >= 0),
  CONSTRAINT "programming_quiz_questions_options_check" CHECK (jsonb_typeof(options) = 'array'::text AND jsonb_array_length(options) >= 2),
  CONSTRAINT "programming_quiz_questions_pkey" PRIMARY KEY (id),
  CONSTRAINT "programming_quiz_questions_quiz_id_fkey" FOREIGN KEY (quiz_id) REFERENCES programming_quizzes(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public."programming_projects" (
  "id" uuid DEFAULT gen_random_uuid() NOT NULL,
  "track_id" text NOT NULL,
  "title" text NOT NULL,
  "brief" text NOT NULL,
  "requirements" jsonb DEFAULT '[]'::jsonb NOT NULL,
  "is_published" boolean DEFAULT true NOT NULL,
  "sort_order" integer DEFAULT 0 NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "programming_projects_pkey" PRIMARY KEY (id),
  CONSTRAINT "programming_projects_track_id_fkey" FOREIGN KEY (track_id) REFERENCES programming_tracks(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public."programming_exercise_submissions" (
  "id" uuid DEFAULT gen_random_uuid() NOT NULL,
  "exercise_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "language" text NOT NULL,
  "source_code" text NOT NULL,
  "notes" text DEFAULT ''::text NOT NULL,
  "status" text DEFAULT 'submitted'::text NOT NULL,
  "score" integer,
  "feedback" text,
  "submitted_at" timestamp with time zone DEFAULT now() NOT NULL,
  "reviewed_at" timestamp with time zone,
  "reviewed_by" uuid,
  CONSTRAINT "programming_exercise_submissions_exercise_id_fkey" FOREIGN KEY (exercise_id) REFERENCES programming_exercises(id) ON DELETE CASCADE,
  CONSTRAINT "programming_exercise_submissions_pkey" PRIMARY KEY (id),
  CONSTRAINT "programming_exercise_submissions_reviewed_by_fkey" FOREIGN KEY (reviewed_by) REFERENCES auth.users(id),
  CONSTRAINT "programming_exercise_submissions_score_check" CHECK (score >= 0 AND score <= 100),
  CONSTRAINT "programming_exercise_submissions_status_check" CHECK (status = ANY (ARRAY['submitted'::text, 'reviewed'::text, 'needs_revision'::text])),
  CONSTRAINT "programming_exercise_submissions_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public."programming_quiz_attempts" (
  "id" uuid DEFAULT gen_random_uuid() NOT NULL,
  "quiz_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "score" integer NOT NULL,
  "correct_answers" integer NOT NULL,
  "total_questions" integer NOT NULL,
  "passed" boolean NOT NULL,
  "answers" jsonb DEFAULT '{}'::jsonb NOT NULL,
  "submitted_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "programming_quiz_attempts_pkey" PRIMARY KEY (id),
  CONSTRAINT "programming_quiz_attempts_quiz_id_fkey" FOREIGN KEY (quiz_id) REFERENCES programming_quizzes(id) ON DELETE CASCADE,
  CONSTRAINT "programming_quiz_attempts_score_check" CHECK (score >= 0 AND score <= 100),
  CONSTRAINT "programming_quiz_attempts_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public."programming_project_submissions" (
  "id" uuid DEFAULT gen_random_uuid() NOT NULL,
  "project_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "repository_url" text DEFAULT ''::text NOT NULL,
  "demo_url" text DEFAULT ''::text NOT NULL,
  "notes" text DEFAULT ''::text NOT NULL,
  "status" text DEFAULT 'submitted'::text NOT NULL,
  "score" integer,
  "feedback" text,
  "submitted_at" timestamp with time zone DEFAULT now() NOT NULL,
  "reviewed_at" timestamp with time zone,
  "reviewed_by" uuid,
  CONSTRAINT "programming_project_submissions_pkey" PRIMARY KEY (id),
  CONSTRAINT "programming_project_submissions_project_id_fkey" FOREIGN KEY (project_id) REFERENCES programming_projects(id) ON DELETE CASCADE,
  CONSTRAINT "programming_project_submissions_reviewed_by_fkey" FOREIGN KEY (reviewed_by) REFERENCES auth.users(id),
  CONSTRAINT "programming_project_submissions_score_check" CHECK (score >= 0 AND score <= 100),
  CONSTRAINT "programming_project_submissions_status_check" CHECK (status = ANY (ARRAY['submitted'::text, 'reviewed'::text, 'needs_revision'::text])),
  CONSTRAINT "programming_project_submissions_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS public."programming_certificates" (
  "id" uuid DEFAULT gen_random_uuid() NOT NULL,
  "student_id" uuid NOT NULL,
  "track_id" text NOT NULL,
  "certificate_code" text NOT NULL,
  "issued_at" timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT "programming_certificates_certificate_code_key" UNIQUE (certificate_code),
  CONSTRAINT "programming_certificates_pkey" PRIMARY KEY (id),
  CONSTRAINT "programming_certificates_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE,
  CONSTRAINT "programming_certificates_student_id_track_id_key" UNIQUE (student_id, track_id),
  CONSTRAINT "programming_certificates_track_id_fkey" FOREIGN KEY (track_id) REFERENCES programming_tracks(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS programming_certificates_certificate_code_key ON public.programming_certificates USING btree (certificate_code);
CREATE UNIQUE INDEX IF NOT EXISTS programming_certificates_pkey ON public.programming_certificates USING btree (id);
CREATE UNIQUE INDEX IF NOT EXISTS programming_certificates_student_id_track_id_key ON public.programming_certificates USING btree (student_id, track_id);
CREATE INDEX IF NOT EXISTS programming_certificates_track_idx ON public.programming_certificates USING btree (track_id);
CREATE INDEX IF NOT EXISTS programming_exercise_submissions_exercise_idx ON public.programming_exercise_submissions USING btree (exercise_id, submitted_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS programming_exercise_submissions_pkey ON public.programming_exercise_submissions USING btree (id);
CREATE INDEX IF NOT EXISTS programming_exercise_submissions_reviewed_by_idx ON public.programming_exercise_submissions USING btree (reviewed_by);
CREATE INDEX IF NOT EXISTS programming_exercise_submissions_student_idx ON public.programming_exercise_submissions USING btree (student_id, submitted_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS programming_exercises_lesson_id_key ON public.programming_exercises USING btree (lesson_id);
CREATE UNIQUE INDEX IF NOT EXISTS programming_exercises_pkey ON public.programming_exercises USING btree (id);
CREATE UNIQUE INDEX IF NOT EXISTS programming_project_submissions_pkey ON public.programming_project_submissions USING btree (id);
CREATE INDEX IF NOT EXISTS programming_project_submissions_project_idx ON public.programming_project_submissions USING btree (project_id);
CREATE INDEX IF NOT EXISTS programming_project_submissions_reviewed_by_idx ON public.programming_project_submissions USING btree (reviewed_by);
CREATE INDEX IF NOT EXISTS programming_project_submissions_student_idx ON public.programming_project_submissions USING btree (student_id, submitted_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS programming_projects_pkey ON public.programming_projects USING btree (id);
CREATE INDEX IF NOT EXISTS programming_projects_track_idx ON public.programming_projects USING btree (track_id, sort_order);
CREATE UNIQUE INDEX IF NOT EXISTS programming_quiz_attempts_pkey ON public.programming_quiz_attempts USING btree (id);
CREATE INDEX IF NOT EXISTS programming_quiz_attempts_quiz_idx ON public.programming_quiz_attempts USING btree (quiz_id);
CREATE INDEX IF NOT EXISTS programming_quiz_attempts_student_idx ON public.programming_quiz_attempts USING btree (student_id, submitted_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS programming_quiz_questions_pkey ON public.programming_quiz_questions USING btree (id);
CREATE INDEX IF NOT EXISTS programming_quiz_questions_quiz_order_idx ON public.programming_quiz_questions USING btree (quiz_id, sort_order);
CREATE UNIQUE INDEX IF NOT EXISTS programming_quizzes_lesson_id_key ON public.programming_quizzes USING btree (lesson_id);
CREATE UNIQUE INDEX IF NOT EXISTS programming_quizzes_pkey ON public.programming_quizzes USING btree (id);

ALTER TABLE public."programming_certificates" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."programming_exercise_submissions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."programming_exercises" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."programming_project_submissions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."programming_projects" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."programming_quiz_attempts" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."programming_quiz_questions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."programming_quizzes" ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "programming_certificates_own_or_staff_read" ON public."programming_certificates";
CREATE POLICY "programming_certificates_own_or_staff_read" ON public."programming_certificates" AS PERMISSIVE FOR SELECT TO "authenticated"
USING (((student_id = ( SELECT auth.uid() AS uid)) OR ( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff)));

DROP POLICY IF EXISTS "programming_exercise_submissions_active_insert" ON public."programming_exercise_submissions";
CREATE POLICY "programming_exercise_submissions_active_insert" ON public."programming_exercise_submissions" AS PERMISSIVE FOR INSERT TO "authenticated"
WITH CHECK (((student_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM programming_course_subscriptions s
  WHERE ((s.student_id = ( SELECT auth.uid() AS uid)) AND (s.status = 'active'::text) AND (s.starts_at <= now()) AND (s.expires_at > now()))))));

DROP POLICY IF EXISTS "programming_exercise_submissions_own_or_staff_read" ON public."programming_exercise_submissions";
CREATE POLICY "programming_exercise_submissions_own_or_staff_read" ON public."programming_exercise_submissions" AS PERMISSIVE FOR SELECT TO "authenticated"
USING (((student_id = ( SELECT auth.uid() AS uid)) OR ( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff)));

DROP POLICY IF EXISTS "programming_exercise_submissions_staff_update" ON public."programming_exercise_submissions";
CREATE POLICY "programming_exercise_submissions_staff_update" ON public."programming_exercise_submissions" AS PERMISSIVE FOR UPDATE TO "authenticated"
USING (( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff))
WITH CHECK (( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff));

DROP POLICY IF EXISTS "programming_exercises_read_active" ON public."programming_exercises";
CREATE POLICY "programming_exercises_read_active" ON public."programming_exercises" AS PERMISSIVE FOR SELECT TO "authenticated"
USING ((( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff) OR (EXISTS ( SELECT 1
   FROM programming_course_subscriptions s
  WHERE ((s.student_id = ( SELECT auth.uid() AS uid)) AND (s.status = 'active'::text) AND (s.starts_at <= now()) AND (s.expires_at > now()))))));

DROP POLICY IF EXISTS "programming_exercises_staff_manage" ON public."programming_exercises";
CREATE POLICY "programming_exercises_staff_manage" ON public."programming_exercises" AS PERMISSIVE FOR ALL TO "authenticated"
USING (( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff))
WITH CHECK (( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff));

DROP POLICY IF EXISTS "programming_project_submissions_active_insert" ON public."programming_project_submissions";
CREATE POLICY "programming_project_submissions_active_insert" ON public."programming_project_submissions" AS PERMISSIVE FOR INSERT TO "authenticated"
WITH CHECK (((student_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM programming_course_subscriptions s
  WHERE ((s.student_id = ( SELECT auth.uid() AS uid)) AND (s.status = 'active'::text) AND (s.starts_at <= now()) AND (s.expires_at > now()))))));

DROP POLICY IF EXISTS "programming_project_submissions_own_or_staff_read" ON public."programming_project_submissions";
CREATE POLICY "programming_project_submissions_own_or_staff_read" ON public."programming_project_submissions" AS PERMISSIVE FOR SELECT TO "authenticated"
USING (((student_id = ( SELECT auth.uid() AS uid)) OR ( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff)));

DROP POLICY IF EXISTS "programming_project_submissions_staff_update" ON public."programming_project_submissions";
CREATE POLICY "programming_project_submissions_staff_update" ON public."programming_project_submissions" AS PERMISSIVE FOR UPDATE TO "authenticated"
USING (( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff))
WITH CHECK (( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff));

DROP POLICY IF EXISTS "programming_projects_read_active" ON public."programming_projects";
CREATE POLICY "programming_projects_read_active" ON public."programming_projects" AS PERMISSIVE FOR SELECT TO "authenticated"
USING ((( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff) OR (EXISTS ( SELECT 1
   FROM programming_course_subscriptions s
  WHERE ((s.student_id = ( SELECT auth.uid() AS uid)) AND (s.status = 'active'::text) AND (s.starts_at <= now()) AND (s.expires_at > now()))))));

DROP POLICY IF EXISTS "programming_projects_staff_manage" ON public."programming_projects";
CREATE POLICY "programming_projects_staff_manage" ON public."programming_projects" AS PERMISSIVE FOR ALL TO "authenticated"
USING (( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff))
WITH CHECK (( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff));

DROP POLICY IF EXISTS "programming_quiz_attempts_own_or_staff_read" ON public."programming_quiz_attempts";
CREATE POLICY "programming_quiz_attempts_own_or_staff_read" ON public."programming_quiz_attempts" AS PERMISSIVE FOR SELECT TO "authenticated"
USING (((student_id = ( SELECT auth.uid() AS uid)) OR ( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff)));

DROP POLICY IF EXISTS "programming_quiz_questions_staff_only" ON public."programming_quiz_questions";
CREATE POLICY "programming_quiz_questions_staff_only" ON public."programming_quiz_questions" AS PERMISSIVE FOR ALL TO "authenticated"
USING (( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff))
WITH CHECK (( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff));

DROP POLICY IF EXISTS "programming_quizzes_read_active" ON public."programming_quizzes";
CREATE POLICY "programming_quizzes_read_active" ON public."programming_quizzes" AS PERMISSIVE FOR SELECT TO "authenticated"
USING ((( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff) OR (EXISTS ( SELECT 1
   FROM programming_course_subscriptions s
  WHERE ((s.student_id = ( SELECT auth.uid() AS uid)) AND (s.status = 'active'::text) AND (s.starts_at <= now()) AND (s.expires_at > now()))))));

DROP POLICY IF EXISTS "programming_quizzes_staff_manage" ON public."programming_quizzes";
CREATE POLICY "programming_quizzes_staff_manage" ON public."programming_quizzes" AS PERMISSIVE FOR ALL TO "authenticated"
USING (( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff))
WITH CHECK (( SELECT mrfluent_english_is_staff() AS mrfluent_english_is_staff));

-- Remove default broad table grants, then restore only required app access.
REVOKE ALL ON TABLE public."programming_exercises" FROM anon, authenticated, service_role;
REVOKE ALL ON TABLE public."programming_quizzes" FROM anon, authenticated, service_role;
REVOKE ALL ON TABLE public."programming_quiz_questions" FROM anon, authenticated, service_role;
REVOKE ALL ON TABLE public."programming_projects" FROM anon, authenticated, service_role;
REVOKE ALL ON TABLE public."programming_exercise_submissions" FROM anon, authenticated, service_role;
REVOKE ALL ON TABLE public."programming_quiz_attempts" FROM anon, authenticated, service_role;
REVOKE ALL ON TABLE public."programming_project_submissions" FROM anon, authenticated, service_role;
REVOKE ALL ON TABLE public."programming_certificates" FROM anon, authenticated, service_role;

GRANT SELECT ON TABLE public."programming_certificates" TO "authenticated";
GRANT INSERT, SELECT ON TABLE public."programming_exercise_submissions" TO "authenticated";
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."programming_exercise_submissions" TO "service_role";
GRANT SELECT ON TABLE public."programming_exercises" TO "authenticated";
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."programming_exercises" TO "service_role";
GRANT INSERT, SELECT ON TABLE public."programming_project_submissions" TO "authenticated";
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."programming_project_submissions" TO "service_role";
GRANT SELECT ON TABLE public."programming_projects" TO "authenticated";
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."programming_projects" TO "service_role";
GRANT SELECT ON TABLE public."programming_quiz_attempts" TO "authenticated";
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."programming_quiz_attempts" TO "service_role";
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."programming_quiz_questions" TO "service_role";
GRANT SELECT ON TABLE public."programming_quizzes" TO "authenticated";
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."programming_quizzes" TO "service_role";

COMMIT;
