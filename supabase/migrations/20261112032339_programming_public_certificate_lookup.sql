create or replace function public.programming_lookup_certificate(p_code text)
returns table (
  certificate_code text,
  student_name text,
  track_title text,
  issued_at timestamptz
)
language sql
stable
security definer
set search_path = public, pg_temp
as $function$
  select c.certificate_code,
         coalesce(nullif(btrim(p.full_name), ''), 'DOMA Student') as student_name,
         t.title as track_title,
         c.issued_at
  from public.programming_certificates c
  join public.programming_tracks t on t.id = c.track_id
  left join public.profiles p on p.id = c.student_id
  where length(btrim(coalesce(p_code,''))) between 8 and 80
    and c.certificate_code = btrim(p_code)
  limit 1;
$function$;

revoke all on function public.programming_lookup_certificate(text) from public;
grant execute on function public.programming_lookup_certificate(text) to anon, authenticated;
