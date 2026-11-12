-- The authoritative tests were copied to private.programming_exercise_tests.
-- Empty the legacy public column as defense in depth so future grants cannot expose them.
update public.programming_exercises
set test_cases='[]'::jsonb,updated_at=now()
where test_cases is distinct from '[]'::jsonb;
