import { useRef, useState } from 'react';

import {
  ACCEPTED_TYPES,
  MAX_SOURCE_BYTES,
  compressPoster,
  formatBytes,
  toDataUrl,
} from '../posterImage.js';

/**
 * Picks a poster image, resizes and compresses it in the browser, and hands
 * the base64 result back to the form.
 *
 * The bytes are stored in Firestore (collection `event_posters`, one document
 * per event) rather than Cloud Storage, so no billing plan is needed. The
 * Flutter app decodes them with Image.memory.
 */
export default function PosterUpload({ poster, onChange, error }) {
  const inputRef = useRef(null);
  const [busy, setBusy] = useState(false);
  const [localError, setLocalError] = useState('');

  async function handleFile(event) {
    const file = event.target.files?.[0];
    if (!file) return;

    setLocalError('');

    if (!ACCEPTED_TYPES.includes(file.type)) {
      setLocalError('Choose a JPG or PNG image.');
      event.target.value = '';
      return;
    }
    if (file.size > MAX_SOURCE_BYTES) {
      setLocalError(
        `That image is ${formatBytes(file.size)}. Pick one under ` +
          `${formatBytes(MAX_SOURCE_BYTES)}.`,
      );
      event.target.value = '';
      return;
    }

    setBusy(true);
    try {
      const result = await compressPoster(file);
      onChange(result);
    } catch (caught) {
      setLocalError(caught.message);
      if (inputRef.current) inputRef.current.value = '';
    } finally {
      setBusy(false);
    }
  }

  function handleRemove() {
    onChange(null);
    setLocalError('');
    if (inputRef.current) inputRef.current.value = '';
  }

  return (
    <div className="field">
      <label htmlFor="poster">Event poster (optional)</label>

      <input
        id="poster"
        ref={inputRef}
        type="file"
        accept="image/jpeg,image/png"
        onChange={handleFile}
        disabled={busy}
      />
      <div className="hint">
        JPG or PNG. Resized to 800px and compressed automatically before saving.
      </div>

      {busy ? (
        <div className="banner info" style={{ marginTop: 10 }}>
          Compressing image...
        </div>
      ) : null}

      {localError ? <div className="field-error">{localError}</div> : null}
      {error ? <div className="field-error">{error}</div> : null}

      {poster && !busy ? (
        <div className="poster-preview">
          <img
            src={toDataUrl(poster.contentType, poster.data)}
            alt="Event poster preview"
          />
          <div>
            <div className="hint" style={{ marginTop: 0 }}>
              {poster.width} x {poster.height}, {formatBytes(poster.bytes)}
            </div>
            <button
              type="button"
              className="secondary"
              onClick={handleRemove}
              style={{ marginTop: 8 }}
            >
              Remove poster
            </button>
          </div>
        </div>
      ) : null}
    </div>
  );
}
