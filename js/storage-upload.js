const FLOWER_BUCKET = 'flower-images';

function isPublicImageUrl(src) {
  return typeof src === 'string' && /^https?:\/\//i.test(src);
}

async function dataUrlToBlob(dataUrl) {
  const res = await fetch(dataUrl);
  return await res.blob();
}

/**
 * Envia data URLs para Supabase Storage; mantém URLs já públicas.
 * @returns {Promise<string[]>} URLs públicas das imagens
 */
async function uploadFlowerImages(sb, flowerId, images) {
  if (!sb || !flowerId || !images?.length) return images || [];

  const urls = [];
  for (let i = 0; i < images.length; i++) {
    const src = images[i];
    if (isPublicImageUrl(src)) {
      urls.push(src);
      continue;
    }

    const blob = await dataUrlToBlob(src);
    const ext = blob.type === 'image/png' ? 'png' : 'jpg';
    const path = `flowers/${flowerId}/${Date.now()}-${i}.${ext}`;

    const { error } = await sb.storage.from(FLOWER_BUCKET).upload(path, blob, {
      cacheControl: '31536000',
      upsert: true,
      contentType: blob.type || 'image/jpeg'
    });
    if (error) throw new Error(error.message);

    const { data } = sb.storage.from(FLOWER_BUCKET).getPublicUrl(path);
    urls.push(data.publicUrl);
  }
  return urls;
}

async function deleteFlowerImagesFromStorage(sb, flowerId) {
  if (!sb || !flowerId) return;
  const prefix = `flowers/${flowerId}`;
  const { data: files, error } = await sb.storage.from(FLOWER_BUCKET).list(prefix);
  if (error || !files?.length) return;

  const paths = files
    .filter(f => f.name && f.id !== null)
    .map(f => `${prefix}/${f.name}`);

  if (paths.length) {
    await sb.storage.from(FLOWER_BUCKET).remove(paths);
  }
}
