import { writeFileSync } from 'fs';

const SITE =
  process.env.SITE_URL ||
  (process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : null) ||
  'https://siteflores-v2.netlify.app';
const SUPABASE_URL = process.env.SUPABASE_URL || 'https://vpxgbkxqwiktdqigrpmx.supabase.co';
const SUPABASE_ANON = process.env.SUPABASE_ANON_KEY || '';

const staticUrls = [
  { loc: '/', priority: '1.0', changefreq: 'weekly' },
  { loc: '/catalogo', priority: '0.9', changefreq: 'weekly' }
];

async function fetchProducts() {
  if (!SUPABASE_ANON) return [];
  try {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/get_store_catalog`, {
      method: 'POST',
      headers: {
        apikey: SUPABASE_ANON,
        Authorization: `Bearer ${SUPABASE_ANON}`,
        'Content-Type': 'application/json'
      },
      body: '{}'
    });
    if (!res.ok) return [];
    const data = await res.json();
    return Array.isArray(data) ? data : [];
  } catch {
    return [];
  }
}

function slugPath(p) {
  const slug = (p.slug || p.name || 'produto')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
  return `/produto/${p.id}-${slug}`;
}

const products = await fetchProducts();
const productUrls = products.map(p => ({
  loc: slugPath(p),
  priority: '0.8',
  changefreq: 'weekly'
}));

const all = [...staticUrls, ...productUrls];
const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${all.map(u => `  <url>
    <loc>${SITE.replace(/\/$/, '')}${u.loc}</loc>
    <changefreq>${u.changefreq}</changefreq>
    <priority>${u.priority}</priority>
  </url>`).join('\n')}
</urlset>
`;

writeFileSync('sitemap.xml', xml, 'utf8');
console.log(`sitemap.xml gerado com ${all.length} URLs (${products.length} produtos).`);
