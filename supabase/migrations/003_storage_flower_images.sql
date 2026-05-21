-- Bucket público para fotos dos produtos (SEO + performance)

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'flower-images',
  'flower-images',
  true,
  1572864,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Leitura pública (loja + Google)
DROP POLICY IF EXISTS "flower_images_public_read" ON storage.objects;
CREATE POLICY "flower_images_public_read"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'flower-images');

-- Admin autenticado com can_access_admin
DROP POLICY IF EXISTS "flower_images_admin_insert" ON storage.objects;
CREATE POLICY "flower_images_admin_insert"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'flower-images'
    AND public.can_access_admin_panel()
  );

DROP POLICY IF EXISTS "flower_images_admin_update" ON storage.objects;
CREATE POLICY "flower_images_admin_update"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'flower-images' AND public.can_access_admin_panel())
  WITH CHECK (bucket_id = 'flower-images' AND public.can_access_admin_panel());

DROP POLICY IF EXISTS "flower_images_admin_delete" ON storage.objects;
CREATE POLICY "flower_images_admin_delete"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'flower-images' AND public.can_access_admin_panel());
