-- Make the intended student-facing RPC permissions explicit in version control.
-- Production was inspected before adding this migration: anon and PUBLIC cannot execute
-- these functions there; authenticated can. This migration documents and preserves that state.
revoke all on function public.doma_submit_quiz(uuid, jsonb) from public, anon;
revoke all on function public.doma_issue_certificate_if_eligible(uuid, uuid) from public, anon;
revoke all on function public.submit_quiz_attempt(uuid, uuid, jsonb) from public, anon;
revoke all on function public.doma_student_leaderboard(uuid, integer) from public, anon;

grant execute on function public.doma_submit_quiz(uuid, jsonb) to authenticated;
grant execute on function public.doma_issue_certificate_if_eligible(uuid, uuid) to authenticated;
grant execute on function public.submit_quiz_attempt(uuid, uuid, jsonb) to authenticated;
grant execute on function public.doma_student_leaderboard(uuid, integer) to authenticated;
