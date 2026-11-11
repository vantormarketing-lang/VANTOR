-- Remove a redundant index; the existing programming_lessons_module_sort_idx covers the same columns.
drop index if exists public.programming_lessons_module_order_idx;
