(function () {
  const cfg = () => window.VERDO_SEO || {};

  function absUrl(path) {
    const base = (cfg().siteUrl || '').replace(/\/$/, '');
    if (!path) return base + '/';
    if (/^https?:\/\//i.test(path)) return path;
    return base + (path.startsWith('/') ? path : '/' + path);
  }

  function slugify(text) {
    return String(text || '')
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '') || 'produto';
  }

  function setMeta(attr, key, value) {
    if (!value) return;
    let el = document.querySelector(`meta[${attr}="${key}"]`);
    if (!el) {
      el = document.createElement('meta');
      el.setAttribute(attr, key);
      document.head.appendChild(el);
    }
    el.setAttribute('content', value);
  }

  function setLink(rel, href) {
    if (!href) return;
    let el = document.querySelector(`link[rel="${rel}"]`);
    if (!el) {
      el = document.createElement('link');
      el.setAttribute('rel', rel);
      document.head.appendChild(el);
    }
    el.setAttribute('href', href);
  }

  window.setPageSEO = function (opts) {
    const c = cfg();
    const title = opts.title || c.defaultTitle;
    const desc = (opts.description || c.defaultDescription || '').slice(0, 160);
    const url = absUrl(opts.path || '/');
    const image = absUrl(opts.image || c.ogImage || '/flores-frescas.jpg');
    const type = opts.type || 'website';

    document.title = title;
    setMeta('name', 'description', desc);
    setMeta('name', 'robots', opts.robots || 'index, follow');
    setLink('canonical', url);

    setMeta('property', 'og:type', type);
    setMeta('property', 'og:site_name', c.siteName || 'Verdô Flores');
    setMeta('property', 'og:title', title);
    setMeta('property', 'og:description', desc);
    setMeta('property', 'og:url', url);
    setMeta('property', 'og:image', image);
    setMeta('property', 'og:locale', c.locale || 'pt_BR');

    setMeta('name', 'twitter:card', 'summary_large_image');
    setMeta('name', 'twitter:title', title);
    setMeta('name', 'twitter:description', desc);
    setMeta('name', 'twitter:image', image);
  };

  window.productPath = function (p) {
    return '/produto/' + p.id + '-' + slugify(p.name);
  };

  window.injectFloristJsonLd = function () {
    const c = cfg();
    const data = {
      '@context': 'https://schema.org',
      '@type': 'Florist',
      name: c.siteName || 'Verdô Flores',
      description: c.defaultDescription,
      url: absUrl('/'),
      image: absUrl(c.ogImage),
      telephone: c.phone,
      address: {
        '@type': 'PostalAddress',
        addressLocality: c.city || 'Betim',
        addressRegion: c.region || 'MG',
        addressCountry: c.country || 'BR'
      },
      areaServed: { '@type': 'City', name: 'Betim' },
      priceRange: '$$'
    };
    let el = document.getElementById('jsonld-business');
    if (!el) {
      el = document.createElement('script');
      el.id = 'jsonld-business';
      el.type = 'application/ld+json';
      document.head.appendChild(el);
    }
    el.textContent = JSON.stringify(data);
  };

  window.injectProductJsonLd = function (p) {
    if (!p) return;
    const c = cfg();
    const price = p.sizes?.[0]?.price;
    const data = {
      '@context': 'https://schema.org',
      '@type': 'Product',
      name: p.name,
      description: p.desc,
      image: (p.imgs || []).map(img => absUrl(img)),
      category: p.cat,
      brand: { '@type': 'Brand', name: c.siteName },
      offers: {
        '@type': 'AggregateOffer',
        priceCurrency: 'BRL',
        lowPrice: price,
        availability: 'https://schema.org/InStock',
        url: absUrl(productPath(p))
      }
    };
    let el = document.getElementById('jsonld-product');
    if (!el) {
      el = document.createElement('script');
      el.id = 'jsonld-product';
      el.type = 'application/ld+json';
      document.head.appendChild(el);
    }
    el.textContent = JSON.stringify(data);
  };

  window.clearProductJsonLd = function () {
    const el = document.getElementById('jsonld-product');
    if (el) el.remove();
  };

  window.parseRoute = function () {
    const path = (location.pathname || '/').replace(/\/$/, '') || '/';
    const m = path.match(/^\/produto\/(\d+)/);
    if (m) return { page: 'product', id: parseInt(m[1], 10) };
    if (path === '/catalogo') return { page: 'catalog' };
    return { page: 'home' };
  };

  window.slugify = slugify;
})();
