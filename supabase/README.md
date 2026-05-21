# Autenticação Admin (Supabase)

## 1. Criar projeto no Supabase

1. Acesse [supabase.com](https://supabase.com) e crie um projeto.
2. Em **Project Settings → API**, copie:
   - **Project URL**
   - **anon public** key

## 2. Rodar a migration

No painel Supabase: **SQL Editor → New query**, cole o conteúdo de:

`migrations/20260521000000_admin_auth.sql`

Clique em **Run**.

## 3. Configurar o site

Copie `js/supabase-config.example.js` para `js/supabase-config.js` e preencha URL e chave anon.

## 4. Criar usuário admin (cuiudospro@gmail.com)

1. **Authentication → Users → Add user → Create new user**
2. E-mail: `cuiudospro@gmail.com`
3. Senha: a que você escolher (ex.: a senha que você definiu no cadastro)
4. Marque **Auto Confirm User** (confirma o e-mail automaticamente)
5. Clique em **Create user**
6. No **SQL Editor**, rode o arquivo `seed_admin.sql` (ativa `can_access_admin` para esse e-mail)

**Importante:** a senha só é criada no passo 3 do Supabase Auth. Não coloque senha em arquivos do projeto.

## 5. Como funciona

| RPC | Quem chama | O que faz |
|-----|------------|-----------|
| `admin_login_allowed(email)` | Visitante (anon) | Retorna `true` só se o e-mail tem `can_access_admin = true` → libera a tela de senha |
| `can_access_admin_panel()` | Usuário logado | Retorna `true` só se o perfil logado tem permissão → libera o painel |

Na loja (`index.html`), o link **Admin** só aparece para quem está logado e passou na RPC `can_access_admin_panel`.
