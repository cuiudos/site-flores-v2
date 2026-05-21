function getSupabase() {
  const cfg = window.VERDO_SUPABASE;
  if (!cfg?.url || !cfg?.anonKey) return null;
  if (cfg.url.includes('SEU_PROJETO') || cfg.anonKey.includes('SUA_CHAVE') || cfg.anonKey.includes('COLE_AQUI')) return null;
  if (!window.supabase?.createClient) return null;
  return window.supabase.createClient(cfg.url, cfg.anonKey);
}

async function rpcCanAccessPanel(sb) {
  const { data, error } = await sb.rpc('can_access_admin_panel');
  if (error) {
    console.error('can_access_admin_panel:', error);
    return false;
  }
  return data === true;
}

async function rpcAdminLoginAllowed(sb, email) {
  const { data, error } = await sb.rpc('admin_login_allowed', { p_email: email });
  if (error) {
    console.error('admin_login_allowed:', error);
    return false;
  }
  return data === true;
}
