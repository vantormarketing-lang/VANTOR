grant select (id, role) on table public.profiles to service_role;
grant select (id, student_id, status, starts_at, expires_at)
on table public.programming_course_subscriptions to service_role;