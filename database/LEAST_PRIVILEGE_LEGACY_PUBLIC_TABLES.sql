-- Applied to Supabase by migration least_privilege_legacy_public_tables.
-- Public client fields are limited to portfolio-safe data; contact details are
-- not granted to anon. Form workflows retain insert-only access where required.
REVOKE INSERT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLE public.offers FROM anon;
REVOKE INSERT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLE public.projects FROM anon;
REVOKE INSERT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLE public.services FROM anon;

REVOKE ALL PRIVILEGES ON TABLE public.clients FROM anon;
GRANT SELECT (id, name, company, image, created_at) ON TABLE public.clients TO anon;

REVOKE SELECT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLE public.messages FROM anon;
GRANT INSERT ON TABLE public.messages TO anon;

REVOKE SELECT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLE public.orders FROM anon;
GRANT INSERT ON TABLE public.orders TO anon;

REVOKE UPDATE, DELETE, REFERENCES, TRIGGER ON TABLE public.testimonials FROM anon;
