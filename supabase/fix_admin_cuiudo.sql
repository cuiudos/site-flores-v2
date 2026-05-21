-- Rode no SQL Editor do Supabase (corrige permissão do seu usuário)

INSERT INTO public.admin_profiles (id, email, can_access_admin)
SELECT id, email, true
FROM auth.users
WHERE lower(email) = lower('cuiudo@gmail.com')
ON CONFLICT (id) DO UPDATE
  SET can_access_admin = true,
      email = EXCLUDED.email;

-- Conferir:
SELECT email, can_access_admin FROM public.admin_profiles;
SELECT public.admin_login_allowed('cuiudo@gmail.com') AS pode_logar;
