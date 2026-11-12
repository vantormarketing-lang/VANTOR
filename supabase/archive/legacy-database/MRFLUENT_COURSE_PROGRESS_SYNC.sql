-- Creates the per-account Mr. Fluent progress backup table and keeps it owner-only.
-- Safe to run repeatedly: it preserves existing progress rows.
CREATE TABLE IF NOT EXISTS public.mrfluent_course_progress_v1 (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  level_code text NOT NULL CHECK (level_code IN ('A1','A2','B1','B2','C1','C2')),
  data jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT mrfluent_course_progress_v1_pkey PRIMARY KEY (user_id, level_code)
);

ALTER TABLE public.mrfluent_course_progress_v1 ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS mrfluent_course_progress_v1_select_own ON public.mrfluent_course_progress_v1;
CREATE POLICY mrfluent_course_progress_v1_select_own
  ON public.mrfluent_course_progress_v1 FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS mrfluent_course_progress_v1_insert_own ON public.mrfluent_course_progress_v1;
CREATE POLICY mrfluent_course_progress_v1_insert_own
  ON public.mrfluent_course_progress_v1 FOR INSERT TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS mrfluent_course_progress_v1_update_own ON public.mrfluent_course_progress_v1;
CREATE POLICY mrfluent_course_progress_v1_update_own
  ON public.mrfluent_course_progress_v1 FOR UPDATE TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS mrfluent_course_progress_v1_delete_own ON public.mrfluent_course_progress_v1;
CREATE POLICY mrfluent_course_progress_v1_delete_own
  ON public.mrfluent_course_progress_v1 FOR DELETE TO authenticated
  USING ((SELECT auth.uid()) = user_id);

REVOKE ALL ON TABLE public.mrfluent_course_progress_v1 FROM anon;
REVOKE REFERENCES, TRIGGER ON TABLE public.mrfluent_course_progress_v1 FROM authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.mrfluent_course_progress_v1 TO authenticated;
