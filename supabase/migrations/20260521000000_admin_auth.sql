-- Perfis de administrador (ligados ao auth.users do Supabase)
CREATE TABLE IF NOT EXISTS public.admin_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  can_access_admin BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.admin_profiles ENABLE ROW LEVEL SECURITY;

-- Usuário autenticado só lê o próprio perfil
DROP POLICY IF EXISTS "admin_profiles_select_own" ON public.admin_profiles;
CREATE POLICY "admin_profiles_select_own"
  ON public.admin_profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- RPC: e-mail pode ver a tela de login? (antes de autenticar)
CREATE OR REPLACE FUNCTION public.admin_login_allowed(p_email TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.admin_profiles
    WHERE lower(email) = lower(trim(p_email))
      AND can_access_admin = true
  );
$$;

-- RPC: usuário logado pode usar o painel?
CREATE OR REPLACE FUNCTION public.can_access_admin_panel()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.admin_profiles
    WHERE id = auth.uid()
      AND can_access_admin = true
  );
$$;

REVOKE ALL ON FUNCTION public.admin_login_allowed(TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.can_access_admin_panel() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.admin_login_allowed(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.can_access_admin_panel() TO authenticated;

-- Cria perfil automaticamente quando um usuário se cadastra no Auth
CREATE OR REPLACE FUNCTION public.handle_new_admin_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.admin_profiles (id, email, can_access_admin)
  VALUES (NEW.id, NEW.email, false)
  ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_admin_user();

-- Índice para busca por e-mail na RPC
CREATE INDEX IF NOT EXISTS admin_profiles_email_lower_idx
  ON public.admin_profiles (lower(email));
