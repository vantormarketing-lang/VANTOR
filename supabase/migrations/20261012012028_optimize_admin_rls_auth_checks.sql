DROP POLICY IF EXISTS "Authenticated admins manage clients" ON public.clients;
CREATE POLICY "Authenticated admins manage clients" ON public.clients
FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'))
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'));

DROP POLICY IF EXISTS "Authenticated admins manage offers" ON public.offers;
CREATE POLICY "Authenticated admins manage offers" ON public.offers
FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'))
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'));

DROP POLICY IF EXISTS "Authenticated admins manage projects" ON public.projects;
CREATE POLICY "Authenticated admins manage projects" ON public.projects
FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'))
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'));

DROP POLICY IF EXISTS "Authenticated admins manage services" ON public.services;
CREATE POLICY "Authenticated admins manage services" ON public.services
FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'))
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'));

DROP POLICY IF EXISTS "Authenticated admins manage testimonials" ON public.testimonials;
CREATE POLICY "Authenticated admins manage testimonials" ON public.testimonials
FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'))
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'));

DROP POLICY IF EXISTS "Authenticated admins read orders" ON public.orders;
CREATE POLICY "Authenticated admins read orders" ON public.orders
FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'));

DROP POLICY IF EXISTS "Authenticated admins update orders" ON public.orders;
CREATE POLICY "Authenticated admins update orders" ON public.orders
FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'))
WITH CHECK (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'));

DROP POLICY IF EXISTS "Authenticated admins delete orders" ON public.orders;
CREATE POLICY "Authenticated admins delete orders" ON public.orders
FOR DELETE TO authenticated
USING (EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = (SELECT auth.uid()) AND p.role = 'admin'));