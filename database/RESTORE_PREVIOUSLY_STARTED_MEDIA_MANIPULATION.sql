-- Preserve access to the single previously-started lesson while avoiding a duplicate Unit 5.
-- The old records are kept; the unit is labelled as legacy/supplemental and placed after the current ten units.
BEGIN;
UPDATE public.units u
SET unit_number=11,title='Previously Started: Media Manipulation',updated_at=now()
FROM public.grades g
WHERE g.id=u.grade_id AND g.name='2nd Secondary'
  AND u.unit_number=5 AND u.title='Media Manipulation';

UPDATE public.lessons l
SET is_published=true,updated_at=now()
WHERE l.unit_id IN (
  SELECT u.id FROM public.units u JOIN public.grades g ON g.id=u.grade_id
  WHERE g.name='2nd Secondary' AND u.title='Previously Started: Media Manipulation'
);
COMMIT;
