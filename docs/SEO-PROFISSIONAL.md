# SEO 100% profissional — roadmap Verdô Flores

## Situação atual (~70%)

| Já tem | Falta para 100% |
|--------|------------------|
| Meta tags, Open Graph | Catálogo só no localStorage de cada navegador |
| URLs `/catalogo`, `/produto/id-slug` | Google não vê produtos novos automaticamente |
| JSON-LD Florist + Product | Imagens em base64 (ruim para velocidade e SEO) |
| robots.txt + sitemap (parcial) | Domínio próprio + Search Console |
| Admin com `noindex` | Imagens em Supabase Storage (URLs públicas) |

---

## Arquitetura alvo

```
Admin salva flor
    → Supabase (store_flowers, store_sizes, store_images)
    → Loja lê get_store_catalog()
    → Deploy Netlify gera sitemap.xml com todos os produtos
    → Google indexa cada URL de produto
```

---

## Passos (ordem)

### 1. Banco — rodar migration (você)

No Supabase SQL Editor, execute:

`supabase/migrations/002_store_catalog.sql`

### 2. Sincronizar catálogo (você)

1. Entre no admin logado
2. Salve ou edite qualquer flor (isso envia o catálogo para a nuvem)
3. Ou rode um sync manual depois que implementarmos botão "Publicar na loja"

### 3. Netlify — variável de ambiente

**Site settings → Environment variables**

| Nome | Valor |
|------|--------|
| `SUPABASE_ANON_KEY` | sua chave anon public |

Cada deploy roda `npm run build` e regenera `sitemap.xml` com todos os produtos.

### 4. Google Search Console

1. [search.google.com/search-console](https://search.google.com/search-console)
2. Propriedade: `https://siteflores-v2.netlify.app`
3. Sitemap: `https://siteflores-v2.netlify.app/sitemap.xml`

### 5. Domínio próprio (recomendado)

- Compre domínio (ex: `verdoflores.com.br`)
- Aponte DNS para Netlify
- Atualize `js/seo-config.js` → `siteUrl`
- Atualize `netlify.toml` → `SITE_URL`

### 6. Imagens na nuvem (implementado)

Rode no SQL Editor: `supabase/migrations/003_storage_flower_images.sql`

- Bucket **flower-images** (público)
- Admin envia fotos ao salvar → URL `https://....supabase.co/storage/v1/object/public/flower-images/...`
- Loja e Google usam URLs reais (melhor SEO e velocidade)

**Republique** cada produto no admin (editar + salvar) para migrar fotos antigas em base64 para Storage.

### 7. Opcional avançado

- **Google Analytics 4**
- **Prerender** para bots (Netlify plugin)
- Páginas estáticas por produto no build (SSG)
- Blog “Como cuidar de rosas” para tráfego orgânico

---

## Como saber se está 100%

- [ ] `get_store_catalog()` retorna produtos no SQL/API
- [ ] Loja em outro celular mostra os mesmos produtos do admin
- [ ] `sitemap.xml` lista todos os `/produto/...`
- [ ] Search Console sem erros de indexação
- [ ] Busca `site:siteflores-v2.netlify.app` mostra páginas no Google (leva dias/semanas)
