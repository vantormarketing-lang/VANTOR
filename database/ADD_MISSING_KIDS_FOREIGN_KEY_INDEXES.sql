-- Non-destructive index additions for foreign keys flagged by Supabase advisors.
-- Reviewed on 2026-10-25 for project VANTOR (dtptxhkcogpoleftguas).
-- Run through the normal database change workflow, then rerun Supabase advisors.
-- This file intentionally contains no DROP, ALTER POLICY, or data-changing statements.

CREATE INDEX IF NOT EXISTS doma_fkidx_kids_enroll_req_level
  ON public.mrfluent_kids_enrollment_requests (requested_level_id);

CREATE INDEX IF NOT EXISTS doma_fkidx_kids_enroll_req_reviewed
  ON public.mrfluent_kids_enrollment_requests (reviewed_by);

CREATE INDEX IF NOT EXISTS doma_fkidx_kids_enroll_req_track
  ON public.mrfluent_kids_enrollment_requests (track_id);

CREATE INDEX IF NOT EXISTS doma_fkidx_kids_enroll_level_track
  ON public.mrfluent_kids_enrollment_requests (requested_level_id, track_id);

CREATE INDEX IF NOT EXISTS doma_fkidx_kids_place_recommended
  ON public.mrfluent_kids_placement_results (recommended_level_id);

CREATE INDEX IF NOT EXISTS doma_fkidx_kids_place_track
  ON public.mrfluent_kids_placement_results (track_id);

CREATE INDEX IF NOT EXISTS doma_fkidx_kids_place_user
  ON public.mrfluent_kids_placement_results (user_id);

CREATE INDEX IF NOT EXISTS doma_fkidx_kids_progress_lesson
  ON public.mrfluent_kids_progress (lesson_id);

CREATE INDEX IF NOT EXISTS doma_fkidx_kids_subs_level_track
  ON public.mrfluent_kids_subscriptions (level_id, track_id);

CREATE INDEX IF NOT EXISTS doma_fkidx_kids_subs_created_by
  ON public.mrfluent_kids_subscriptions (created_by);

CREATE INDEX IF NOT EXISTS doma_fkidx_kids_subs_level
  ON public.mrfluent_kids_subscriptions (level_id);

CREATE INDEX IF NOT EXISTS doma_fkidx_kids_subs_track
  ON public.mrfluent_kids_subscriptions (track_id);
