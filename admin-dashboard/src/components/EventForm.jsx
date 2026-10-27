import { useEffect, useRef, useState } from 'react';

import { validateEventForm } from '../events.js';
import PosterUpload from './PosterUpload.jsx';
import VenuePicker from './VenuePicker.jsx';

/**
 * Create/edit form for a campus event.
 *
 * Validation runs on submit and blocks the save; the end time must be later
 * than the start time, and every required field must be filled.
 */
export default function EventForm({
  initialForm,
  onSubmit,
  onCancel,
  submitting,
  submitError,
  submitLabel,
}) {
  const [form, setForm] = useState(initialForm);
  const [errors, setErrors] = useState({});
  const [localError, setLocalError] = useState('');
  const topRef = useRef(null);

  // The save banner renders at the top of a long form while the submit button
  // sits at the bottom, so bring it into view - otherwise a failed save looks
  // like nothing happened at all.
  useEffect(() => {
    if (submitError && topRef.current) {
      topRef.current.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }, [submitError]);

  function patch(changes) {
    setForm((current) => ({ ...current, ...changes }));
  }

  function handleSubmit(event) {
    event.preventDefault();

    let found;
    let payload;
    try {
      ({ errors: found, payload } = validateEventForm(form));
    } catch (error) {
      // Never let an unexpected error leave the click with no visible effect.
      setErrors({});
      setLocalError(`Could not read the form: ${error.message}`);
      return;
    }

    setLocalError('');
    setErrors(found);

    const problemFields = Object.keys(found);
    if (problemFields.length > 0) {
      // Every field input uses its error key as its DOM id, so the first
      // problem can be scrolled to and focused directly.
      const field = document.getElementById(problemFields[0]);
      if (field) {
        field.scrollIntoView({ behavior: 'smooth', block: 'center' });
        field.focus({ preventScroll: true });
      }
      return;
    }

    onSubmit(payload);
  }

  const problemCount = Object.keys(errors).length;

  return (
    <form className="card" onSubmit={handleSubmit} noValidate>
      <div ref={topRef} />
      {submitError ? <div className="banner error">{submitError}</div> : null}

      <div className="field">
        <label htmlFor="title">Event name</label>
        <input
          id="title"
          type="text"
          placeholder="Technology Exhibition"
          value={form.title}
          onChange={(e) => patch({ title: e.target.value })}
        />
        {errors.title ? <div className="field-error">{errors.title}</div> : null}
      </div>

      <div className="field">
        <label htmlFor="caption">Caption (optional)</label>
        <input
          id="caption"
          type="text"
          placeholder="One line shown under the title and in shared messages"
          value={form.caption}
          onChange={(e) => patch({ caption: e.target.value })}
        />
        {errors.caption ? (
          <div className="field-error">{errors.caption}</div>
        ) : null}
      </div>

      <div className="field">
        <label htmlFor="description">Description</label>
        <textarea
          id="description"
          rows={3}
          placeholder="Annual technology exhibition"
          value={form.description}
          onChange={(e) => patch({ description: e.target.value })}
        />
        {errors.description ? (
          <div className="field-error">{errors.description}</div>
        ) : null}
      </div>

      <div className="field-row">
        <div className="field">
          <label htmlFor="startAt">Starts</label>
          <input
            id="startAt"
            type="datetime-local"
            value={form.startAt}
            onChange={(e) => patch({ startAt: e.target.value })}
          />
          {errors.startAt ? (
            <div className="field-error">{errors.startAt}</div>
          ) : null}
        </div>
        <div className="field">
          <label htmlFor="endAt">Ends</label>
          <input
            id="endAt"
            type="datetime-local"
            value={form.endAt}
            onChange={(e) => patch({ endAt: e.target.value })}
          />
          {errors.endAt ? <div className="field-error">{errors.endAt}</div> : null}
        </div>
      </div>

      <div className="field">
        <label htmlFor="venueName">Venue name</label>
        <input
          id="venueName"
          type="text"
          placeholder="Main Auditorium"
          value={form.venueName}
          onChange={(e) => patch({ venueName: e.target.value })}
        />
        {errors.venueName ? (
          <div className="field-error">{errors.venueName}</div>
        ) : null}
      </div>

      <VenuePicker form={form} errors={errors} onPatch={patch} />

      <PosterUpload
        poster={form.poster}
        onChange={(poster) => patch({ poster })}
        error={errors.poster}
      />

      {problemCount > 0 ? (
        <div className="banner error">
          {problemCount === 1
            ? 'One field needs attention - it is highlighted above.'
            : `${problemCount} fields need attention - they are highlighted above.`}
        </div>
      ) : null}

      {submitError ? <div className="banner error">{submitError}</div> : null}
      {localError ? <div className="banner error">{localError}</div> : null}

      <div className="form-actions">
        <button type="submit" disabled={submitting}>
          {submitting ? 'Saving...' : submitLabel}
        </button>
        <button
          type="button"
          className="secondary"
          onClick={onCancel}
          disabled={submitting}
        >
          Cancel
        </button>
      </div>
    </form>
  );
}
