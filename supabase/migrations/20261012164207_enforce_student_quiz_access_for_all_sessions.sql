DO $migration$
DECLARE
  fn record;
  def text;
BEGIN
  FOR fn IN
    SELECT p.oid, p.proname
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname IN ('doma_get_quiz_questions', 'doma_quiz_start_gate', 'doma_submit_quiz')
  LOOP
    def := pg_get_functiondef(fn.oid);
    IF position('IF NOT public.doma_is_staff() THEN' IN def) = 0 THEN
      RAISE EXCEPTION 'Expected staff bypass not found in function %', fn.proname;
    END IF;
    def := replace(def, 'IF NOT public.doma_is_staff() THEN', 'IF true THEN');
    EXECUTE def;
  END LOOP;

  SELECT pg_get_functiondef(p.oid) INTO def
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public' AND p.proname = 'doma_get_question_bank';

  IF def IS NULL OR position('public.doma_is_staff()' IN def) = 0 THEN
    RAISE EXCEPTION 'Expected staff bypass not found in doma_get_question_bank';
  END IF;
  def := replace(def, 'public.doma_is_staff()', 'false');
  EXECUTE def;
END;
$migration$;