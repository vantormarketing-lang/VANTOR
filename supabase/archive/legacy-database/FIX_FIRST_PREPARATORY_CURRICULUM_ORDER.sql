-- Fix first preparatory grade course ordering in place.
-- Keeps lesson IDs, progress, questions and video URLs; does not delete rows.
BEGIN;

UPDATE public.lessons l
SET lesson_type = CASE
      WHEN l.title = 'An Email to a Friend' THEN 'grammar'
      WHEN l.title = 'Present Simple and Adverbs of Frequency' THEN 'grammar'
      ELSE l.lesson_type
    END,
    title = CASE
      WHEN l.title = 'An Email to a Friend'
        THEN 'Present Simple and Adverbs of Frequency'
      ELSE l.title
    END,
    description = CASE
      WHEN l.title IN ('An Email to a Friend','Present Simple and Adverbs of Frequency')
        THEN 'Practise the present simple, questions, negatives and adverbs of frequency to describe daily routines.'
      WHEN l.title = 'An Interview with an Athlete'
        THEN 'Read an interview about healthy routines and identify advice, reasons and supporting details.'
      ELSE l.description
    END,
    sort_order = CASE
      WHEN l.title IN ('An Email to a Friend','Present Simple and Adverbs of Frequency')
        OR l.lesson_type = 'grammar' THEN 2
      WHEN l.title = 'An Interview with an Athlete' THEN 3
      WHEN l.lesson_type = 'vocabulary' THEN 3
      WHEN l.title ILIKE 'Lesson 4:%' THEN 4
      WHEN l.lesson_type = 'reading' THEN 4
      WHEN l.lesson_type = 'writing' THEN 5
      WHEN l.lesson_type = 'listening' THEN 6
      WHEN l.lesson_type = 'lesson' THEN 1
      ELSE l.sort_order
    END
FROM public.units u
JOIN public.grades g ON g.id = u.grade_id
WHERE l.unit_id = u.id
  AND g.name = '1st Preparatory'
  AND u.unit_number BETWEEN 1 AND 6
  AND u.title ~* '^Unit[[:space:]]*[0-9]+[[:space:]]*:'
  AND l.is_published = true;

UPDATE public.lessons l
SET sort_order = 3
FROM public.units u
JOIN public.grades g ON g.id = u.grade_id
WHERE l.unit_id = u.id
  AND g.name = '1st Preparatory'
  AND u.unit_number = 4
  AND u.title = 'Unit 4: Smart Choices'
  AND l.title = 'An Interview with an Athlete'
  AND l.is_published = true;

-- Shift units 7-12 from zero-based positions once only.
-- Re-run is safe because the first lesson is no longer at position 0.
DO $fix_first_prep_order$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM public.lessons l
    JOIN public.units u ON u.id = l.unit_id
    JOIN public.grades g ON g.id = u.grade_id
    WHERE g.name = '1st Preparatory'
      AND u.unit_number BETWEEN 7 AND 12
      AND l.is_published
      AND l.sort_order = 0
  ) THEN
    UPDATE public.lessons l
    SET sort_order = l.sort_order + 1
    FROM public.units u
    JOIN public.grades g ON g.id = u.grade_id
    WHERE l.unit_id = u.id
      AND g.name = '1st Preparatory'
      AND u.unit_number BETWEEN 7 AND 12
      AND l.is_published
      AND l.sort_order BETWEEN 0 AND 5;
  END IF;
END
$fix_first_prep_order$;

COMMIT;

-- Expected: each of the 12 grade units has six published lessons,
-- with distinct sort_order values from 1 to 6.
SELECT u.unit_number, u.title,
       count(l.id) FILTER (WHERE l.is_published) AS published_lessons,
       count(DISTINCT l.sort_order) FILTER (WHERE l.is_published) AS distinct_positions,
       min(l.sort_order) FILTER (WHERE l.is_published) AS first_position,
       max(l.sort_order) FILTER (WHERE l.is_published) AS last_position
FROM public.units u
JOIN public.grades g ON g.id = u.grade_id
LEFT JOIN public.lessons l ON l.unit_id = u.id
WHERE g.name = '1st Preparatory'
  AND EXISTS (SELECT 1 FROM public.lessons visible WHERE visible.unit_id = u.id AND visible.is_published)
GROUP BY u.id, u.unit_number, u.title
ORDER BY u.unit_number, u.title;
