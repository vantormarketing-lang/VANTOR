create unique index if not exists mrfluent_kids_levels_id_track_unique
  on public.mrfluent_kids_levels(id, track_id);

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'mrfluent_kids_subs_level_track_fk') then
    alter table public.mrfluent_kids_subscriptions
      add constraint mrfluent_kids_subs_level_track_fk
      foreign key (level_id, track_id)
      references public.mrfluent_kids_levels(id, track_id)
      on delete restrict;
  end if;
  if not exists (select 1 from pg_constraint where conname = 'mrfluent_kids_requests_level_track_fk') then
    alter table public.mrfluent_kids_enrollment_requests
      add constraint mrfluent_kids_requests_level_track_fk
      foreign key (requested_level_id, track_id)
      references public.mrfluent_kids_levels(id, track_id)
      on delete restrict;
  end if;
end $$;

drop policy if exists "kids submit own pending enrollment request" on public.mrfluent_kids_enrollment_requests;
create policy "kids submit own pending enrollment request"
on public.mrfluent_kids_enrollment_requests for insert to authenticated
with check (
  user_id = (select auth.uid())
  and status = 'pending'
  and reviewed_by is null
  and reviewed_at is null
  and exists (
    select 1 from public.mrfluent_kids_tracks t
    where t.id = mrfluent_kids_enrollment_requests.track_id and t.is_published = true
  )
  and exists (
    select 1 from public.mrfluent_kids_levels l
    where l.id = mrfluent_kids_enrollment_requests.requested_level_id
      and l.track_id = mrfluent_kids_enrollment_requests.track_id
      and l.is_published = true
  )
);

drop policy if exists "kids save own placement result" on public.mrfluent_kids_placement_results;
create policy "kids save own placement result"
on public.mrfluent_kids_placement_results for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1 from public.mrfluent_kids_tracks t
    where t.id = mrfluent_kids_placement_results.track_id and t.is_published = true
  )
  and exists (
    select 1 from public.mrfluent_kids_levels l
    where l.id = mrfluent_kids_placement_results.recommended_level_id
      and l.track_id = mrfluent_kids_placement_results.track_id
      and l.is_published = true
  )
);

drop policy if exists "kids units only for assigned active level" on public.mrfluent_kids_units;
create policy "kids units only for assigned active level"
on public.mrfluent_kids_units for select to authenticated
using (
  (select public.mrfluent_english_is_staff())
  or (
    is_published = true
    and exists (
      select 1
      from public.mrfluent_kids_levels lv
      join public.mrfluent_kids_subscriptions s
        on s.level_id = lv.id and s.track_id = lv.track_id
      where lv.id = mrfluent_kids_units.level_id
        and s.user_id = (select auth.uid())
        and s.status = 'active'
        and s.starts_at <= now()
        and s.expires_at > now()
    )
  )
);

drop policy if exists "kids lessons only for assigned active level" on public.mrfluent_kids_lessons;
create policy "kids lessons only for assigned active level"
on public.mrfluent_kids_lessons for select to authenticated
using (
  (select public.mrfluent_english_is_staff())
  or (
    is_published = true
    and exists (
      select 1
      from public.mrfluent_kids_units u
      join public.mrfluent_kids_levels lv on lv.id = u.level_id
      join public.mrfluent_kids_subscriptions s
        on s.level_id = lv.id and s.track_id = lv.track_id
      where u.id = mrfluent_kids_lessons.unit_id
        and u.is_published = true
        and s.user_id = (select auth.uid())
        and s.status = 'active'
        and s.starts_at <= now()
        and s.expires_at > now()
    )
  )
);

drop policy if exists "kids create progress for accessible lessons" on public.mrfluent_kids_progress;
create policy "kids create progress for accessible lessons"
on public.mrfluent_kids_progress for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1
    from public.mrfluent_kids_lessons l
    join public.mrfluent_kids_units u on u.id = l.unit_id
    join public.mrfluent_kids_levels lv on lv.id = u.level_id
    join public.mrfluent_kids_subscriptions s
      on s.level_id = lv.id and s.track_id = lv.track_id
    where l.id = mrfluent_kids_progress.lesson_id
      and l.is_published = true and u.is_published = true
      and s.user_id = (select auth.uid()) and s.status = 'active'
      and s.starts_at <= now() and s.expires_at > now()
  )
);

drop policy if exists "kids update own progress for accessible lessons" on public.mrfluent_kids_progress;
create policy "kids update own progress for accessible lessons"
on public.mrfluent_kids_progress for update to authenticated
using (
  user_id = (select auth.uid())
  and exists (
    select 1
    from public.mrfluent_kids_lessons l
    join public.mrfluent_kids_units u on u.id = l.unit_id
    join public.mrfluent_kids_levels lv on lv.id = u.level_id
    join public.mrfluent_kids_subscriptions s
      on s.level_id = lv.id and s.track_id = lv.track_id
    where l.id = mrfluent_kids_progress.lesson_id
      and l.is_published = true and u.is_published = true
      and s.user_id = (select auth.uid()) and s.status = 'active'
      and s.starts_at <= now() and s.expires_at > now()
  )
)
with check (
  user_id = (select auth.uid())
  and exists (
    select 1
    from public.mrfluent_kids_lessons l
    join public.mrfluent_kids_units u on u.id = l.unit_id
    join public.mrfluent_kids_levels lv on lv.id = u.level_id
    join public.mrfluent_kids_subscriptions s
      on s.level_id = lv.id and s.track_id = lv.track_id
    where l.id = mrfluent_kids_progress.lesson_id
      and l.is_published = true and u.is_published = true
      and s.user_id = (select auth.uid()) and s.status = 'active'
      and s.starts_at <= now() and s.expires_at > now()
  )
);