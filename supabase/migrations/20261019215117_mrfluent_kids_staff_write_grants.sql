grant select on public.mrfluent_kids_tracks, public.mrfluent_kids_levels to anon;
grant select, insert, update, delete on public.mrfluent_kids_tracks, public.mrfluent_kids_levels to authenticated;
notify pgrst, 'reload schema';