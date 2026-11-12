create or replace function public.mrfluent_admin_list_english_course_requests()
returns setof public.mrfluent_english_course_requests
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  if not public.mrfluent_english_is_staff() then
    raise exception 'Not authorized to view English Course payment requests';
  end if;

  return query
    select r.*
    from public.mrfluent_english_course_requests r
    order by r.created_at desc nulls last;
end;
$function$;

revoke all on function public.mrfluent_admin_list_english_course_requests() from public;
revoke all on function public.mrfluent_admin_list_english_course_requests() from anon;
grant execute on function public.mrfluent_admin_list_english_course_requests() to authenticated;