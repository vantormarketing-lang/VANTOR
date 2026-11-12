-- Server-derived state for the Mr. Fluent Kids learning journey.
-- Keep student RLS row ownership; remove table-wide operations that bypass RLS.
REVOKE TRUNCATE, TRIGGER, REFERENCES ON TABLE public.mrfluent_kids_journey_progress FROM authenticated, anon;

CREATE OR REPLACE FUNCTION public.mrfluent_kids_journey_progress_derive()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, public
AS $function$
DECLARE
  v_word_count integer := 0;
  v_speaking_count integer := 0;
  v_activity_count integer := 0;
  v_has_pass boolean := false;
  v_eligible boolean := false;
BEGIN
  IF TG_OP = 'UPDATE' AND (
    NEW.user_id IS DISTINCT FROM OLD.user_id OR
    NEW.level_code IS DISTINCT FROM OLD.level_code
  ) THEN
    RAISE EXCEPTION 'A learning journey record cannot be reassigned';
  END IF;

  NEW.checkpoint_keys := COALESCE(NEW.checkpoint_keys, ARRAY[]::text[]);
  NEW.words_seen := COALESCE(NEW.words_seen, ARRAY[]::text[]);
  NEW.wrong_answers := COALESCE(NEW.wrong_answers, '[]'::jsonb);
  NEW.final_quiz_best := GREATEST(0, LEAST(5, COALESCE(NEW.final_quiz_best, 0)));
  NEW.final_quiz_attempts := GREATEST(0, COALESCE(NEW.final_quiz_attempts, 0));

  IF cardinality(NEW.checkpoint_keys) > 300 THEN
    RAISE EXCEPTION 'Too many learning checkpoints';
  END IF;
  IF cardinality(NEW.words_seen) > 100 THEN
    RAISE EXCEPTION 'Too many saved vocabulary items';
  END IF;
  IF jsonb_typeof(NEW.wrong_answers) IS DISTINCT FROM 'array'
     OR jsonb_array_length(NEW.wrong_answers) > 40
     OR pg_column_size(NEW.wrong_answers) > 65536 THEN
    RAISE EXCEPTION 'Invalid review list size';
  END IF;

  SELECT count(DISTINCT item) INTO v_word_count
  FROM unnest(NEW.words_seen) AS t(item)
  WHERE NULLIF(btrim(item), '') IS NOT NULL;

  SELECT count(DISTINCT item) INTO v_speaking_count
  FROM unnest(NEW.checkpoint_keys) AS t(item)
  WHERE item ~ '^speaking:[A-Za-z0-9_-]+$';

  SELECT count(DISTINCT item) INTO v_activity_count
  FROM unnest(NEW.checkpoint_keys) AS t(item)
  WHERE item ~ '^(activity:|speaking:|final:)';

  v_has_pass := NEW.checkpoint_keys @> ARRAY['final:passed']::text[];
  NEW.speaking_completed := v_speaking_count >= 3;

  v_eligible := v_word_count >= 5
    AND v_speaking_count >= 3
    AND NEW.final_quiz_best >= 4
    AND v_has_pass;

  NEW.certificate_earned := v_eligible;
  IF v_eligible THEN
    IF TG_OP = 'UPDATE' AND OLD.certificate_earned AND OLD.certificate_code IS NOT NULL THEN
      NEW.certificate_code := OLD.certificate_code;
      NEW.certified_at := COALESCE(OLD.certified_at, now());
    ELSE
      NEW.certificate_code := 'MF-' || NEW.level_code || '-' ||
        upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10));
      NEW.certified_at := now();
    END IF;
  ELSE
    NEW.certificate_code := NULL;
    NEW.certified_at := NULL;
  END IF;

  NEW.stars := LEAST(
    20,
    (v_word_count / 4)
      + LEAST(3, v_activity_count)
      + CASE WHEN NEW.speaking_completed THEN 2 ELSE 0 END
      + CASE WHEN NEW.final_quiz_best >= 4 THEN 2 ELSE 0 END
      + CASE WHEN NEW.certificate_earned THEN 2 ELSE 0 END
  );

  NEW.badges := ARRAY[]::text[];
  IF v_word_count >= 3 THEN
    NEW.badges := array_append(NEW.badges, 'first-steps');
  END IF;
  IF v_word_count >= 8 THEN
    NEW.badges := array_append(NEW.badges, 'practice-explorer');
  END IF;
  IF v_speaking_count >= 2 THEN
    NEW.badges := array_append(NEW.badges, 'steady-learner');
  END IF;
  IF NEW.certificate_earned THEN
    NEW.badges := array_append(NEW.badges, 'learning-champion');
  END IF;

  NEW.updated_at := now();
  RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS mrfluent_kids_journey_progress_derive_before_write
  ON public.mrfluent_kids_journey_progress;
CREATE TRIGGER mrfluent_kids_journey_progress_derive_before_write
BEFORE INSERT OR UPDATE ON public.mrfluent_kids_journey_progress
FOR EACH ROW
EXECUTE FUNCTION public.mrfluent_kids_journey_progress_derive();

COMMENT ON FUNCTION public.mrfluent_kids_journey_progress_derive()
IS 'Derives display stats and certificate fields on the server; clients cannot directly set those derived values.';
