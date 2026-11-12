-- Block temporary-password sessions from every Supabase Data API request.
-- The password-change endpoint uses the Auth Admin API and remains available.
create or replace function public.doma_guard_temp_password()
returns void language plpgsql security definer set search_path = public, pg_temp
as $function$
begin
  if coalesce(auth.jwt() -> 'app_metadata' ->> 'must_change_password', 'false') = 'true' then
    raise sqlstate 'PGRST' using
      message = json_build_object('code','PASSWORD_CHANGE_REQUIRED','message','Change your temporary password before accessing platform data.')::text,
      detail = json_build_object('status',403)::text;
  end if;
end;
$function$;
revoke all on function public.doma_guard_temp_password() from public, anon, authenticated;
grant execute on function public.doma_guard_temp_password() to authenticator, service_role;
alter role authenticator set pgrst.db_pre_request = 'public.doma_guard_temp_password';
notify pgrst, 'reload config';