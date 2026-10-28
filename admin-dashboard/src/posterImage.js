// Poster compression.
//
// Posters are stored as base64 inside a Firestore document, so they must stay
// well under Firestore's 1 MiB per-document limit. The image is resized and
// re-encoded as JPEG in the browser before it is ever sent.

export const ACCEPTED_TYPES = ['image/jpeg', 'image/png'];

/** Largest file we will even attempt to read, before compression. */
export const MAX_SOURCE_BYTES = 10 * 1024 * 1024;

/** Longest edge of the stored image, in pixels. */
const MAX_EDGE = 800;

/**
 * Ceiling for the stored base64 string. Firestore's limit is 1 MiB for the
 * whole document; 400 KB leaves generous headroom for the other fields and
 * for Firestore's own overhead.
 */
const MAX_ENCODED_BYTES = 400 * 1024;

/** Quality steps tried in order until the result fits. */
const QUALITY_STEPS = [0.75, 0.6, 0.45, 0.3, 0.2];

/**
 * Resizes and compresses an image file.
 *
 * Returns `{ data, contentType, width, height, bytes }` where `data` is raw
 * base64 with no `data:` prefix. Throws an Error with a user-facing message
 * if the image cannot be made small enough.
 */
export async function compressPoster(file) {
  let bitmap;
  try {
    bitmap = await createImageBitmap(file);
  } catch {
    throw new Error('That file could not be read as an image.');
  }

  try {
    const scale = Math.min(1, MAX_EDGE / Math.max(bitmap.width, bitmap.height));
    const width = Math.max(1, Math.round(bitmap.width * scale));
    const height = Math.max(1, Math.round(bitmap.height * scale));

    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;

    const context = canvas.getContext('2d');
    if (!context) {
      throw new Error('This browser could not process the image.');
    }

    // PNGs may be transparent; flatten onto white so the JPEG does not get a
    // black background where the transparency was.
    context.fillStyle = '#ffffff';
    context.fillRect(0, 0, width, height);
    context.drawImage(bitmap, 0, 0, width, height);

    for (const quality of QUALITY_STEPS) {
      const dataUrl = canvas.toDataURL('image/jpeg', quality);
      const data = dataUrl.slice(dataUrl.indexOf(',') + 1);
      // base64 is ASCII, so one character is one stored byte.
      if (data.length <= MAX_ENCODED_BYTES) {
        return {
          data,
          contentType: 'image/jpeg',
          width,
          height,
          bytes: data.length,
        };
      }
    }

    throw new Error(
      'This image is too detailed to store even after compression. ' +
        'Try a smaller or simpler poster.',
    );
  } finally {
    bitmap.close?.();
  }
}

/** `data:image/jpeg;base64,...` for use as an <img> src. */
export function toDataUrl(contentType, data) {
  return `data:${contentType};base64,${data}`;
}

export function formatBytes(bytes) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}
