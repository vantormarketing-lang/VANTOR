-- Applied to the live project after verification found zero questions.
-- The mock exam stays in the database but is hidden until content is added.
UPDATE public.quizzes
SET is_published = false
WHERE id = '8d73ec09-1537-4f75-a570-6b0d8427ee2e'
  AND title = '3rd Secondary Comprehensive Mock Exam'
  AND is_published = true
  AND NOT EXISTS (
    SELECT 1 FROM public.quiz_questions qq WHERE qq.quiz_id = public.quizzes.id
  );
