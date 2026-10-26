-- Remove Supabase default table privileges that are broader than the intended client API.
revoke all on table public.mrfluent_kids_learning_activities from anon, public, authenticated;
grant select, insert, update, delete on table public.mrfluent_kids_learning_activities to authenticated;
grant all on table public.mrfluent_kids_learning_activities to service_role;
