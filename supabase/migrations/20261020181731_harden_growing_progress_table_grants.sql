revoke all on table public.mrfluent_growing_progress from anon, public, authenticated;
grant select, insert, update on table public.mrfluent_growing_progress to authenticated;
grant all on table public.mrfluent_growing_progress to service_role;