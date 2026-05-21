-- Execute no SQL Editor do Supabase DEPOIS de criar o usuário em Authentication → Users
-- Admin: cuiudospro@gmail.com (senha definida no painel Auth, não neste arquivo)

UPDATE public.admin_profiles
SET can_access_admin = true
WHERE lower(email) = lower('cuiudospro@gmail.com');

-- Conferir:
-- SELECT id, email, can_access_admin FROM public.admin_profiles;
