-- Least-privilege grants for legacy public-facing tables.
-- Keep the expected public reads and form inserts, but do not grant unused
-- anonymous update/delete/reference/trigger privileges.
REVOKE INSERT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLE public.offers FROM anon;
REVOKE INSERT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLE public.projects FROM anon;
REVOKE INSERT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLE public.services FROM anon;

-- Public clients are not used by the current DOMA student/admin pages.
-- Retain only fields suitable for a public portfolio; never expose client
-- contact details or internal status through the anonymous Data API.
REVOKE ALL PRIVILEGES ON TABLE public.clients FROM anon;
GRANT SELECT (id, name, company, image, created_at) ON TABLE public.clients TO anon;

-- Contact forms and checkout can create rows, but anonymous users must not
-- be able to read or mutate the resulting personal data/order state.
REVOKE SELECT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLE public.messages FROM anon;
GRANT INSERT ON TABLE public.messages TO anon;

REVOKE SELECT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLE public.orders FROM anon;
GRANT INSERT ON TABLE public.orders TO anon;

-- Testimonials can still be submitted and public testimonials can still be
-- read; editing/deletion remains administrative.
REVOKE UPDATE, DELETE, REFERENCES, TRIGGER ON TABLE public.testimonials FROM anon;
