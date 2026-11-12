-- Prevent temporary-password student sessions from using Storage or Realtime.
-- Keep public read policies and staff-only content policies unchanged.
-- Only student-facing authenticated policies are gated.

begin;

drop policy if exists "doma homework attachments delete own or staff" on storage.objects;
create policy "doma homework attachments delete own or staff"
on storage.objects for delete to authenticated
using (
  bucket_id = 'homework-submissions'
  and (
    (storage.foldername(name))[1] = (select auth.uid())::text
    or private.doma_is_staff()
  )
  and coalesce(auth.jwt()->'app_metadata'->>'must_change_password','false') <> 'true'
);

drop policy if exists "doma homework attachments read own or staff" on storage.objects;
create policy "doma homework attachments read own or staff"
on storage.objects for select to authenticated
using (
  bucket_id = 'homework-submissions'
  and (
    (storage.foldername(name))[1] = (select auth.uid())::text
    or private.doma_is_staff()
  )
  and coalesce(auth.jwt()->'app_metadata'->>'must_change_password','false') <> 'true'
);

drop policy if exists "doma homework attachments upload own folder" on storage.objects;
create policy "doma homework attachments upload own folder"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'homework-submissions'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and coalesce(auth.jwt()->'app_metadata'->>'must_change_password','false') <> 'true'
);

drop policy if exists "doma payment proof select own folder rlsfix" on storage.objects;
create policy "doma payment proof select own folder rlsfix"
on storage.objects for select to authenticated
using (
  bucket_id = 'payment-proofs'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and coalesce(auth.jwt()->'app_metadata'->>'must_change_password','false') <> 'true'
);

drop policy if exists "doma payment proof upload own folder rlsfix" on storage.objects;
create policy "doma payment proof upload own folder rlsfix"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'payment-proofs'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and coalesce(auth.jwt()->'app_metadata'->>'must_change_password','false') <> 'true'
);

drop policy if exists "kids delete unlinked payment proofs" on storage.objects;
create policy "kids delete unlinked payment proofs"
on storage.objects for delete to authenticated
using (
  bucket_id = 'payment-proofs'
  and (storage.foldername(name))[1] = (select auth.uid())::text
  and (storage.foldername(name))[2] = 'kids'
  and not exists (
    select 1
    from public.mrfluent_kids_enrollment_requests r
    where r.proof_path = objects.name
  )
  and coalesce(auth.jwt()->'app_metadata'->>'must_change_password','false') <> 'true'
);

drop policy if exists "doma battle participants receive private broadcasts" on realtime.messages;
create policy "doma battle participants receive private broadcasts"
on realtime.messages for select to authenticated
using (
  extension = any (array['broadcast'::text, 'presence'::text])
  and doma_is_battle_participant(
    substring((select realtime.topic()), '^doma-academy-battle-(DOMA-[A-Z0-9]{4}-[A-Z0-9]{2})$')
  )
  and coalesce(auth.jwt()->'app_metadata'->>'must_change_password','false') <> 'true'
);

drop policy if exists "doma battle participants send private broadcasts" on realtime.messages;
create policy "doma battle participants send private broadcasts"
on realtime.messages for insert to authenticated
with check (
  extension = any (array['broadcast'::text, 'presence'::text])
  and doma_is_battle_participant(
    substring((select realtime.topic()), '^doma-academy-battle-(DOMA-[A-Z0-9]{4}-[A-Z0-9]{2})$')
  )
  and coalesce(auth.jwt()->'app_metadata'->>'must_change_password','false') <> 'true'
);

commit;
