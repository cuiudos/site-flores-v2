-- Cole no SQL Editor e clique RUN (pode rodar mais de uma vez sem erro)

DROP POLICY IF EXISTS "admin_profiles_select_own" ON public.admin_profiles;

CREATE POLICY "admin_profiles_select_own"
  ON public.admin_profiles FOR SELECT TO authenticated
  USING (auth.uid() = id);

CREATE OR REPLACE FUNCTION public.admin_login_allowed(p_email TEXT)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_profiles
    WHERE lower(email) = lower(trim(p_email)) AND can_access_admin = true
  );
$$;

CREATE OR REPLACE FUNCTION public.can_access_admin_panel()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_profiles
    WHERE id = auth.uid() AND can_access_admin = true
  );
$$;

GRANT EXECUTE ON FUNCTION public.admin_login_allowed(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.can_access_admin_panel() TO authenticated;

INSERT INTO public.admin_profiles (id, email, can_access_admin)
SELECT id, email, true FROM auth.users
WHERE lower(email) = lower('cuiudo@gmail.com')
ON CONFLICT (id) DO UPDATE SET can_access_admin = true, email = EXCLUDED.email;
