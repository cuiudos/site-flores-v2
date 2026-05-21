# Publicar o site na Vercel

Repositório: [github.com/cuiudos/site-flores-v2](https://github.com/cuiudos/site-flores-v2)

---

## 1. Criar conta e importar o projeto

1. Acesse [vercel.com](https://vercel.com) e entre com **GitHub**.
2. **Add New… → Project**.
3. Escolha o repositório **`site-flores-v2`**.
4. Configuração do projeto:

| Campo | Valor |
|-------|--------|
| Framework Preset | **Other** |
| Root Directory | `.` (raiz) |
| Build Command | `npm run build` |
| Output Directory | `.` |

O arquivo `vercel.json` na raiz já define isso automaticamente.

5. **Não clique em Deploy ainda** — configure as variáveis abaixo.

---

## 2. Variáveis de ambiente (Environment Variables)

Em **Environment Variables**, adicione:

| Nome | Valor | Onde achar |
|------|--------|------------|
| `SUPABASE_URL` | `https://vpxgbkxqwiktdqigrpmx.supabase.co` | Supabase → Settings → API |
| `SUPABASE_ANON_KEY` | `eyJ...` (chave **anon public**) | Supabase → Settings → API |
| `SITE_URL` | *(deixe vazio no 1º deploy)* | Depois você preenche com a URL da Vercel |

Marque **Production**, **Preview** e **Development**.

Clique em **Deploy**.

---

## 3. Depois do primeiro deploy

A Vercel mostra uma URL, por exemplo:

`https://site-flores-v2.vercel.app`

### 3.1 Atualizar SEO no código

1. Edite `js/seo-config.js` → troque `siteUrl` pela URL da Vercel.
2. Faça commit e push (a Vercel publica de novo sozinha).

Ou na Vercel: **Settings → Environment Variables** → defina:

`SITE_URL` = `https://site-flores-v2.vercel.app`

e rode **Redeploy**.

### 3.2 Supabase — URLs permitidas

**Authentication → URL Configuration**

| Campo | Valor |
|-------|--------|
| Site URL | `https://SEU-PROJETO.vercel.app` |
| Redirect URLs | `https://SEU-PROJETO.vercel.app/**` |

Salve.

### 3.3 SQL (se ainda não rodou)

No Supabase SQL Editor, execute na ordem:

1. `migrations/20260521000000_admin_auth.sql`
2. `migrations/002_store_catalog.sql`
3. `migrations/003_storage_flower_images.sql`
4. `rodar_de_novo.sql` (permissão admin)

---

## 4. URLs do site na Vercel

| Página | URL |
|--------|-----|
| Loja | `https://SEU-PROJETO.vercel.app/` |
| Catálogo | `https://SEU-PROJETO.vercel.app/catalogo` |
| Produto | `https://SEU-PROJETO.vercel.app/produto/1-nome` |
| Admin | `https://SEU-PROJETO.vercel.app/admin-verdo.html` |

---

## 5. Domínio próprio (opcional)

1. Vercel → **Settings → Domains**
2. Adicione `verdoflores.com.br` (ou o domínio que tiver)
3. Configure DNS no Registro.br conforme a Vercel indicar
4. Atualize `SITE_URL` e `js/seo-config.js` com o domínio novo
5. Atualize URLs no Supabase Auth

---

## 6. Netlify e Vercel ao mesmo tempo?

Pode manter os dois apontando para o mesmo GitHub, mas use **uma URL principal** no `seo-config.js` e no Supabase para não confundir SEO e login.

Recomendação: escolha **Vercel ou Netlify** como site oficial.

---

## 7. Problemas comuns

| Problema | Solução |
|----------|---------|
| `/catalogo` dá 404 | Confirme que `vercel.json` está no repositório |
| Sitemap sem produtos | Defina `SUPABASE_ANON_KEY` e faça Redeploy |
| Admin não loga | Adicione URL da Vercel no Supabase Auth |
| Build falha | Veja **Deployments → Build Logs** |

---

## Checklist

- [ ] Projeto importado na Vercel
- [ ] `SUPABASE_ANON_KEY` configurada
- [ ] Deploy com sucesso
- [ ] `SITE_URL` atualizada
- [ ] Supabase Auth com URL da Vercel
- [ ] Admin salva flor e aparece na loja
- [ ] `sitemap.xml` abre no navegador
