-- Add the nine public-schema foreign-key indexes identified by the database audit.
-- IF NOT EXISTS makes the file safe to rerun.
CREATE INDEX IF NOT EXISTS idx_battle_answers_question_id ON public.doma_battle_session_answers (question_id);
CREATE INDEX IF NOT EXISTS idx_battle_answers_student_id ON public.doma_battle_session_answers (student_id);
CREATE INDEX IF NOT EXISTS idx_battle_sessions_grade_id ON public.doma_battle_sessions (grade_id);
CREATE INDEX IF NOT EXISTS idx_battle_sessions_guest_id ON public.doma_battle_sessions (guest_id);
CREATE INDEX IF NOT EXISTS idx_battle_sessions_host_id ON public.doma_battle_sessions (host_id);
CREATE INDEX IF NOT EXISTS idx_battle_sessions_quiz_id ON public.doma_battle_sessions (quiz_id);
CREATE INDEX IF NOT EXISTS idx_sub_renewal_grade_id ON public.subscription_renewal_history (grade_id);
CREATE INDEX IF NOT EXISTS idx_sub_renewal_student_id ON public.subscription_renewal_history (student_id);
CREATE INDEX IF NOT EXISTS idx_sub_renewal_subscription_id ON public.subscription_renewal_history (subscription_id);
