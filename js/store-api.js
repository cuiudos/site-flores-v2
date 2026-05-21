function slugify(text) {
  return String(text || '')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'produto';
}

async function fetchStoreCatalog() {
  const sb = typeof createSupabaseClient === 'function' ? createSupabaseClient() : (typeof getSupabase === 'function' ? getSupabase() : null);
  if (!sb) return null;
  const { data, error } = await sb.rpc('get_store_catalog');
  if (error) {
    console.warn('get_store_catalog:', error.message);
    return null;
  }
  if (!Array.isArray(data)) return null;
  return data.map(row => ({
    id: row.id,
    slug: row.slug,
    name: row.name,
    cat: row.cat,
    badge: row.badge || '',
    desc: row.desc || '',
    imgs: row.imgs?.length ? row.imgs : [],
    sizes: (row.sizes || []).map(s => ({
      k: s.k,
      label: s.label,
      desc: s.desc || s.label,
      price: Number(s.price) || 0
    }))
  }));
}

async function pushStoreCatalog(catalog) {
  const sb = typeof createSupabaseClient === 'function' ? createSupabaseClient() : null;
  if (!sb) return { ok: false, error: 'Supabase não configurado' };
  const payload = catalog.map(p => ({
    slug: p.slug || ((typeof slugify === 'function' ? slugify(p.name) : 'produto') + '-' + p.id),
    name: p.name,
    cat: p.cat,
    badge: p.badge || '',
    desc: p.desc || '',
    stock: p.stock ?? 0,
    imgs: p.imgs || [],
    sizes: p.sizes || []
  }));
  const { error } = await sb.rpc('sync_store_catalog', { p_catalog: payload });
  if (error) return { ok: false, error: error.message };
  return { ok: true };
}
