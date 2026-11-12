-- Remove the duplicated generic appendix from the 64 current programming lessons.
-- The complete pre-change lesson content is preserved in
-- 20261112000000_snapshot_programming_curriculum.sql.
update public.programming_lessons
set content_md = left(
  content_md,
  position('## تعميق الفهم: افهم الفكرة من أكثر من زاوية' in content_md) - 1
),
updated_at = now()
where position('## تعميق الفهم: افهم الفكرة من أكثر من زاوية' in content_md) > 0;
