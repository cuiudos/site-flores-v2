-- Catálogo público na nuvem (SEO + loja + admin)

CREATE TABLE IF NOT EXISTS public.store_flowers (
  id SERIAL PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  category TEXT,
  description TEXT,
  badge TEXT,
  stock INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.store_sizes (
  id SERIAL PRIMARY KEY,
  flower_id INTEGER NOT NULL REFERENCES public.store_flowers(id) ON DELETE CASCADE,
  size_key TEXT NOT NULL,
  label TEXT NOT NULL,
  size_desc TEXT,
  price NUMERIC NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.store_images (
  id SERIAL PRIMARY KEY,
  flower_id INTEGER NOT NULL REFERENCES public.store_flowers(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS store_flowers_stock_idx ON public.store_flowers (stock) WHERE stock > 0;

ALTER TABLE public.store_flowers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_sizes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_images ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_flowers_public_read" ON public.store_flowers;
CREATE POLICY "store_flowers_public_read" ON public.store_flowers
  FOR SELECT TO anon, authenticated USING (stock > 0);

DROP POLICY IF EXISTS "store_sizes_public_read" ON public.store_sizes;
CREATE POLICY "store_sizes_public_read" ON public.store_sizes
  FOR SELECT TO anon, authenticated
  USING (EXISTS (SELECT 1 FROM public.store_flowers f WHERE f.id = flower_id AND f.stock > 0));

DROP POLICY IF EXISTS "store_images_public_read" ON public.store_images;
CREATE POLICY "store_images_public_read" ON public.store_images
  FOR SELECT TO anon, authenticated
  USING (EXISTS (SELECT 1 FROM public.store_flowers f WHERE f.id = flower_id AND f.stock > 0));

DROP POLICY IF EXISTS "store_flowers_admin" ON public.store_flowers;
CREATE POLICY "store_flowers_admin" ON public.store_flowers
  FOR ALL TO authenticated
  USING (public.can_access_admin_panel())
  WITH CHECK (public.can_access_admin_panel());

DROP POLICY IF EXISTS "store_sizes_admin" ON public.store_sizes;
CREATE POLICY "store_sizes_admin" ON public.store_sizes
  FOR ALL TO authenticated
  USING (public.can_access_admin_panel())
  WITH CHECK (public.can_access_admin_panel());

DROP POLICY IF EXISTS "store_images_admin" ON public.store_images;
CREATE POLICY "store_images_admin" ON public.store_images
  FOR ALL TO authenticated
  USING (public.can_access_admin_panel())
  WITH CHECK (public.can_access_admin_panel());

-- Loja: catálogo em JSON (anon)
CREATE OR REPLACE FUNCTION public.get_store_catalog()
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', f.id,
        'slug', f.slug,
        'name', f.name,
        'cat', f.category,
        'badge', COALESCE(f.badge, ''),
        'desc', COALESCE(f.description, ''),
        'imgs', COALESCE((
          SELECT jsonb_agg(i.image_url ORDER BY i.sort_order)
          FROM public.store_images i WHERE i.flower_id = f.id
        ), '[]'::jsonb),
        'sizes', COALESCE((
          SELECT jsonb_agg(
            jsonb_build_object(
              'k', s.size_key,
              'label', s.label,
              'desc', COALESCE(s.size_desc, s.label),
              'price', s.price::numeric
            ) ORDER BY s.sort_order
          )
          FROM public.store_sizes s WHERE s.flower_id = f.id
        ), '[]'::jsonb)
      ) ORDER BY f.name
    ),
    '[]'::jsonb
  )
  FROM public.store_flowers f
  WHERE f.stock > 0;
$$;

-- Admin: sincroniza catálogo completo (JSON do painel)
CREATE OR REPLACE FUNCTION public.sync_store_catalog(p_catalog JSONB)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  item JSONB;
  fid INTEGER;
  sz JSONB;
  img TEXT;
  i INTEGER;
BEGIN
  IF NOT public.can_access_admin_panel() THEN
    RAISE EXCEPTION 'Acesso negado';
  END IF;

  DELETE FROM public.store_images;
  DELETE FROM public.store_sizes;
  DELETE FROM public.store_flowers;

  FOR item IN SELECT * FROM jsonb_array_elements(COALESCE(p_catalog, '[]'::jsonb))
  LOOP
    INSERT INTO public.store_flowers (slug, name, category, description, badge, stock)
    VALUES (
      COALESCE(NULLIF(item->>'slug', ''), regexp_replace(lower(item->>'name'), '[^a-z0-9]+', '-', 'g')),
      item->>'name',
      item->>'cat',
      item->>'desc',
      NULLIF(item->>'badge', ''),
      COALESCE((item->>'stock')::INTEGER, 0)
    )
    RETURNING id INTO fid;

    i := 0;
    FOR sz IN SELECT * FROM jsonb_array_elements(COALESCE(item->'sizes', '[]'::jsonb))
    LOOP
      INSERT INTO public.store_sizes (flower_id, size_key, label, size_desc, price, sort_order)
      VALUES (
        fid,
        sz->>'k',
        sz->>'label',
        COALESCE(sz->>'desc', sz->>'label'),
        COALESCE((sz->>'price')::NUMERIC, 0),
        i
      );
      i := i + 1;
    END LOOP;

    i := 0;
    FOR img IN SELECT jsonb_array_elements_text(COALESCE(item->'imgs', '[]'::jsonb))
    LOOP
      INSERT INTO public.store_images (flower_id, image_url, sort_order)
      VALUES (fid, img, i);
      i := i + 1;
    END LOOP;
  END LOOP;
END;
$$;

REVOKE ALL ON FUNCTION public.get_store_catalog() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.sync_store_catalog(JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_store_catalog() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.sync_store_catalog(JSONB) TO authenticated;
