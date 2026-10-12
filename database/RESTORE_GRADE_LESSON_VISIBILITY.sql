-- Restore missing published lessons and ensure every 2nd Preparatory unit has a free preview.
-- Safe to run repeatedly; hidden lesson rows remain in place and are not deleted.

-- The 3rd Preparatory curriculum has 12 lessons per unit (sort_order 0-11).
-- Restore the six earlier rows per unit that were hidden during duplicate cleanup.
UPDATE public.lessons l
SET is_published = true
FROM public.grades g
JOIN public.units u ON u.grade_id = g.id
WHERE l.grade_id = g.id
  AND l.unit_id = u.id
  AND g.name = '3rd Preparatory'
  AND u.unit_number BETWEEN 1 AND 6
  AND l.sort_order BETWEEN 6 AND 11
  AND l.is_published = false;

-- The student page intentionally shows only is_free lessons until there is an
-- active grade subscription. 2nd Preparatory previously had zero free lessons,
-- so an unsubscribed student saw an empty lessons page even though all 72 lessons
-- were published. Make the first lesson in every unit a preview, without
-- unlocking the remaining paid lessons.
UPDATE public.lessons l
SET is_free = true
FROM public.units u
JOIN public.grades g ON g.id = u.grade_id
WHERE l.unit_id = u.id
  AND g.name = '2nd Preparatory'
  AND l.is_published = true
  AND l.sort_order = 1
  AND l.is_free = false;

-- Verification:
SELECT g.name AS grade,
       count(*) FILTER (WHERE l.is_published) AS published_lessons,
       count(*) FILTER (WHERE l.is_published AND l.is_free) AS free_preview_lessons,
       count(*) FILTER (WHERE NOT l.is_published) AS hidden_lessons
FROM public.lessons l
JOIN public.grades g ON g.id = l.grade_id
WHERE g.name IN ('2nd Preparatory', '3rd Preparatory')
GROUP BY g.name
ORDER BY g.name;

SELECT g.name AS grade, u.unit_number, u.title AS unit_title,
       count(*) FILTER (WHERE l.is_published) AS published_lessons,
       count(*) FILTER (WHERE l.is_published AND l.is_free) AS free_preview_lessons
FROM public.units u
JOIN public.grades g ON g.id = u.grade_id
JOIN public.lessons l ON l.unit_id = u.id
WHERE g.name = '2nd Preparatory'
GROUP BY g.name, u.unit_number, u.title
ORDER BY u.unit_number;
