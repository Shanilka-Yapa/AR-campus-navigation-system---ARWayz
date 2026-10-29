import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Timestamp,
  collection,
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

import EventForm from '../components/EventForm.jsx';
import { EVENTS_COLLECTION, POSTERS_COLLECTION, db } from '../firebase.js';
import { emptyForm, toDateTimeLocal } from '../events.js';

/** Firestore document -> the shape EventForm holds in state. */
function toFormValues(data, poster) {
  const startAt = data.startAt?.toDate?.();
  const endAt = data.endAt?.toDate?.();
  const hasBuilding = Boolean(data.buildingId);

  return {
    title: data.title || '',
    caption: data.caption || '',
    description: data.description || '',
    startAt: startAt ? toDateTimeLocal(startAt) : '',
    endAt: endAt ? toDateTimeLocal(endAt) : '',
    venueName: data.venueName || '',
    buildingId: data.buildingId || '',
    floor:
      data.floor === null || data.floor === undefined ? '' : String(data.floor),
    indoorPointId: data.indoorPointId || '',
    venueLatitude:
      data.venueLatitude === null || data.venueLatitude === undefined
        ? ''
        : String(data.venueLatitude),
    venueLongitude:
      data.venueLongitude === null || data.venueLongitude === undefined
        ? ''
        : String(data.venueLongitude),
    poster,
    outdoorOnly: !hasBuilding,
  };
}

/** Validated form payload -> the Firestore event document body. */
function toDocument(payload) {
  return {
    title: payload.title,
    caption: payload.caption,
    description: payload.description,
    startAt: Timestamp.fromDate(payload.startAt),
    endAt: Timestamp.fromDate(payload.endAt),
    venueName: payload.venueName,
    buildingId: payload.buildingId,
    floor: payload.floor,
    indoorPointId: payload.indoorPointId,
    venueLatitude: payload.venueLatitude,
    venueLongitude: payload.venueLongitude,
    // `hasPoster` lets the student app skip a lookup for events without one.
    hasPoster: Boolean(payload.poster),
    updatedAt: serverTimestamp(),
  };
}

/** Writes or clears the poster document that belongs to an event. */
async function savePoster(eventId, poster) {
  const posterRef = doc(db, POSTERS_COLLECTION, eventId);

  if (!poster) {
    try {
      await deleteDoc(posterRef);
    } catch {
      // Nothing to remove, or already gone.
    }
    return;
  }

  await setDoc(posterRef, {
    data: poster.data,
    contentType: poster.contentType,
    width: poster.width,
    height: poster.height,
    updatedAt: serverTimestamp(),
  });
}

export default function EventEditPage() {
  const { eventId } = useParams();
  const navigate = useNavigate();
  const isEdit = Boolean(eventId);

  const [initialForm, setInitialForm] = useState(isEdit ? null : emptyForm);
  const [loadError, setLoadError] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');

  useEffect(() => {
    if (!isEdit) return;

    let cancelled = false;

    async function load() {
      try {
        const snapshot = await getDoc(doc(db, EVENTS_COLLECTION, eventId));
        if (cancelled) return;
        if (!snapshot.exists()) {
          setLoadError('That event no longer exists.');
          return;
        }

        let poster = null;
        try {
          const posterSnapshot = await getDoc(
            doc(db, POSTERS_COLLECTION, eventId),
          );
          if (posterSnapshot.exists()) {
            const posterData = posterSnapshot.data();
            poster = {
              data: posterData.data,
              contentType: posterData.contentType || 'image/jpeg',
              width: posterData.width || 0,
              height: posterData.height || 0,
              bytes: (posterData.data || '').length,
            };
          }
        } catch {
          // Treat an unreadable poster as "no poster" rather than failing
          // the whole edit screen.
        }

        if (!cancelled) setInitialForm(toFormValues(snapshot.data(), poster));
      } catch (error) {
        if (!cancelled) setLoadError(error.message);
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, [eventId, isEdit]);

  async function handleSubmit(payload) {
    setSubmitError('');
    setSubmitting(true);
    try {
      const body = toDocument(payload);

      if (isEdit) {
        await updateDoc(doc(db, EVENTS_COLLECTION, eventId), body);
        await savePoster(eventId, payload.poster);
      } else {
        // The id is generated up front so the poster can be written to a
        // matching document in the same save.
        const eventRef = doc(collection(db, EVENTS_COLLECTION));
        await setDoc(eventRef, {
          ...body,
          hidden: false,
          // Seed the manual order from the start time so new events slot in
          // chronologically until an admin moves them with the arrows.
          sortOrder: payload.startAt.getTime(),
          createdAt: serverTimestamp(),
        });
        await savePoster(eventRef.id, payload.poster);
      }

      navigate('/');
    } catch (error) {
      const denied = error.code === 'permission-denied';
      setSubmitError(
        denied
          ? 'Firestore rejected the write. Confirm your user ID is in the ' +
              'admins collection, and that the rules cover both the events ' +
              'and event_posters collections.'
          : `Could not save the event: ${error.message}`,
      );
      setSubmitting(false);
    }
  }

  return (
    <div className="page">
      <h2 style={{ marginTop: 0 }}>{isEdit ? 'Edit event' : 'New event'}</h2>

      {loadError ? (
        <div className="banner error">{loadError}</div>
      ) : initialForm === null ? (
        <div className="empty">Loading event...</div>
      ) : (
        <EventForm
          initialForm={initialForm}
          onSubmit={handleSubmit}
          onCancel={() => navigate('/')}
          submitting={submitting}
          submitError={submitError}
          submitLabel={isEdit ? 'Save changes' : 'Create event'}
        />
      )}
    </div>
  );
}
