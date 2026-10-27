// Shared event helpers: date conversion for <input type="datetime-local">,
// display formatting, and the form validation rules.

const MONTHS = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const pad = (value) => String(value).padStart(2, '0');

/** Date -> `2026-11-04T09:00`, the value format datetime-local expects. */
export function toDateTimeLocal(date) {
  if (!date) return '';
  return (
    `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}` +
    `T${pad(date.getHours())}:${pad(date.getMinutes())}`
  );
}

/** `2026-11-04T09:00` -> Date in local time, or null when unparseable. */
export function fromDateTimeLocal(value) {
  if (!value) return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

export function formatDate(date) {
  return `${date.getDate()} ${MONTHS[date.getMonth()]} ${date.getFullYear()}`;
}

export function formatShortMonth(date) {
  return MONTHS[date.getMonth()].slice(0, 3);
}

export function formatTime(date) {
  return `${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

export function formatTimeRange(start, end) {
  const sameDay =
    start.getFullYear() === end.getFullYear() &&
    start.getMonth() === end.getMonth() &&
    start.getDate() === end.getDate();
  if (sameDay) {
    return `${formatTime(start)} - ${formatTime(end)}`;
  }
  return `${formatDate(start)} ${formatTime(start)} - ${formatDate(end)} ${formatTime(end)}`;
}

export function isPast(event, now = new Date()) {
  return event.endAt < now;
}

export function isInProgress(event, now = new Date()) {
  return event.startAt <= now && event.endAt > now;
}

export const emptyForm = {
  title: '',
  caption: '',
  description: '',
  startAt: '',
  endAt: '',
  venueName: '',
  buildingId: '',
  floor: '',
  indoorPointId: '',
  venueLatitude: '',
  venueLongitude: '',
  // { data, contentType, width, height, bytes } from compressPoster, or null.
  poster: null,
  outdoorOnly: false,
};

/**
 * Validates the create/edit form.
 *
 * Returns `{ errors, payload }`. When `errors` has any key the caller must not
 * submit. `payload` is the Firestore-shaped object (Dates, not Timestamps -
 * the caller converts those) and is only meaningful when there are no errors.
 */
export function validateEventForm(form) {
  const errors = {};

  const title = form.title.trim();
  const caption = form.caption.trim();
  const description = form.description.trim();
  const venueName = form.venueName.trim();

  if (caption.length > 140) {
    errors.caption = 'Keep the caption to 140 characters or fewer.';
  }

  if (!title) errors.title = 'Event name is required.';
  if (!description) errors.description = 'Description is required.';
  if (!venueName) errors.venueName = 'Venue name is required.';

  const startAt = fromDateTimeLocal(form.startAt);
  const endAt = fromDateTimeLocal(form.endAt);

  if (!startAt) errors.startAt = 'Start date and time are required.';
  if (!endAt) errors.endAt = 'End date and time are required.';
  if (startAt && endAt && endAt <= startAt) {
    errors.endAt = 'End time must be later than the start time.';
  }

  let floor = null;
  if (form.floor !== '' && form.floor !== null) {
    if (!/^-?\d+$/.test(String(form.floor).trim())) {
      errors.floor = 'Floor must be a whole number.';
    } else {
      floor = Number.parseInt(form.floor, 10);
    }
  }

  let venueLatitude = null;
  let venueLongitude = null;

  if (form.outdoorOnly) {
    const hasLat = form.venueLatitude !== '';
    const hasLng = form.venueLongitude !== '';

    if (!hasLat || !hasLng) {
      errors.venueLatitude =
        'An outdoor venue needs both a latitude and a longitude.';
    } else {
      venueLatitude = Number.parseFloat(form.venueLatitude);
      venueLongitude = Number.parseFloat(form.venueLongitude);

      if (Number.isNaN(venueLatitude) || venueLatitude < -90 || venueLatitude > 90) {
        errors.venueLatitude = 'Invalid latitude (-90 to 90).';
      }
      if (
        Number.isNaN(venueLongitude) ||
        venueLongitude < -180 ||
        venueLongitude > 180
      ) {
        errors.venueLongitude = 'Invalid longitude (-180 to 180).';
      }
    }
  } else if (!form.buildingId) {
    errors.buildingId =
      'Pick a building, or switch to an outdoor venue and enter coordinates.';
  }

  const payload = {
    title,
    caption: caption || null,
    description,
    startAt,
    endAt,
    venueName,
    buildingId: form.outdoorOnly ? null : form.buildingId || null,
    floor: form.outdoorOnly ? null : floor,
    indoorPointId: form.outdoorOnly
      ? null
      : form.indoorPointId.trim() || null,
    venueLatitude,
    venueLongitude,
    // Written to the separate `event_posters` collection, not onto the event.
    poster: form.poster ?? null,
  };

  return { errors, payload };
}
