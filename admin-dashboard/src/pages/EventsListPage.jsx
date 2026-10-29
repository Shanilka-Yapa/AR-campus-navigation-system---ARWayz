import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  onSnapshot,
  orderBy,
  query,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';

import { EVENTS_COLLECTION, POSTERS_COLLECTION, db } from '../firebase.js';
import {
  formatDate,
  formatTimeRange,
  isInProgress,
  isPast,
} from '../events.js';
import { toDataUrl } from '../posterImage.js';

/** Firestore document -> plain object with real Dates. */
function mapEvent(docSnapshot) {
  const data = docSnapshot.data();
  const startAt = data.startAt?.toDate?.();
  const endAt = data.endAt?.toDate?.();
  if (!startAt || !endAt) {
    return null;
  }
  return {
    id: docSnapshot.id,
    title: data.title || 'Untitled Event',
    caption: data.caption || '',
    description: data.description || '',
    venueName: data.venueName || 'Venue to be announced',
    buildingId: data.buildingId || null,
    hasPoster: Boolean(data.hasPoster),
    hidden: Boolean(data.hidden),
    startAt,
    endAt,
    // Events that have never been reordered fall back to their start time,
    // matching the Flutter app's effectiveSortOrder.
    sortOrder:
      typeof data.sortOrder === 'number' ? data.sortOrder : startAt.getTime(),
  };
}

export default function EventsListPage() {
  const navigate = useNavigate();

  const [events, setEvents] = useState([]);
  const [posters, setPosters] = useState({});
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState('');
  const [tab, setTab] = useState('upcoming');
  const [search, setSearch] = useState('');
  const [busyId, setBusyId] = useState('');
  const [actionError, setActionError] = useState('');

  useEffect(() => {
    const eventsQuery = query(
      collection(db, EVENTS_COLLECTION),
      orderBy('startAt'),
    );

    return onSnapshot(
      eventsQuery,
      (snapshot) => {
        setEvents(snapshot.docs.map(mapEvent).filter(Boolean));
        setLoading(false);
      },
      (error) => {
        setLoadError(error.message);
        setLoading(false);
      },
    );
  }, []);

  // Poster bytes live in their own collection, so fetch them for the events
  // on screen. The admin list is small, unlike the student list which
  // deliberately never loads posters.
  useEffect(() => {
    const missing = events.filter(
      (event) => event.hasPoster && posters[event.id] === undefined,
    );
    if (missing.length === 0) return;

    let cancelled = false;

    (async () => {
      const loaded = {};
      for (const event of missing) {
        try {
          const snapshot = await getDoc(doc(db, POSTERS_COLLECTION, event.id));
          const data = snapshot.data();
          loaded[event.id] = data?.data
            ? toDataUrl(data.contentType || 'image/jpeg', data.data)
            : null;
        } catch {
          loaded[event.id] = null;
        }
      }
      if (!cancelled) setPosters((current) => ({ ...current, ...loaded }));
    })();

    return () => {
      cancelled = true;
    };
  }, [events, posters]);

  const visible = useMemo(() => {
    const now = new Date();
    const needle = search.trim().toLowerCase();

    const filtered = events.filter((event) => {
      const matchesTab =
        tab === 'past' ? isPast(event, now) : !isPast(event, now);
      if (!matchesTab) return false;
      if (!needle) return true;
      return (
        event.title.toLowerCase().includes(needle) ||
        event.caption.toLowerCase().includes(needle) ||
        event.venueName.toLowerCase().includes(needle) ||
        event.description.toLowerCase().includes(needle)
      );
    });

    const ordered = [...filtered].sort((a, b) => a.sortOrder - b.sortOrder);
    // Most recent first for past events; manual order for upcoming.
    return tab === 'past' ? ordered.reverse() : ordered;
  }, [events, tab, search]);

  const searching = search.trim().length > 0;

  async function handleDelete(event) {
    const confirmed = window.confirm(
      `Delete "${event.title}"? This cannot be undone.`,
    );
    if (!confirmed) return;

    setActionError('');
    setBusyId(event.id);
    try {
      await deleteDoc(doc(db, EVENTS_COLLECTION, event.id));
      try {
        await deleteDoc(doc(db, POSTERS_COLLECTION, event.id));
      } catch {
        // No poster, or already removed.
      }
    } catch (error) {
      setActionError(`Could not delete the event: ${error.message}`);
    } finally {
      setBusyId('');
    }
  }

  async function handleToggleHidden(event) {
    setActionError('');
    setBusyId(event.id);
    try {
      await updateDoc(doc(db, EVENTS_COLLECTION, event.id), {
        hidden: !event.hidden,
      });
    } catch (error) {
      setActionError(`Could not update visibility: ${error.message}`);
    } finally {
      setBusyId('');
    }
  }

  /**
   * Moves an event one place within the list on screen by swapping its
   * sortOrder with its neighbour's.
   */
  async function handleMove(index, direction) {
    const target = index + direction;
    if (target < 0 || target >= visible.length) return;

    const current = visible[index];
    const neighbour = visible[target];

    setActionError('');
    setBusyId(current.id);
    try {
      // Identical values would make the swap a no-op, so nudge them apart.
      const a = current.sortOrder;
      const b = a === neighbour.sortOrder ? neighbour.sortOrder + 1 : neighbour.sortOrder;

      const batch = writeBatch(db);
      batch.update(doc(db, EVENTS_COLLECTION, current.id), { sortOrder: b });
      batch.update(doc(db, EVENTS_COLLECTION, neighbour.id), { sortOrder: a });
      await batch.commit();
    } catch (error) {
      setActionError(`Could not reorder: ${error.message}`);
    } finally {
      setBusyId('');
    }
  }

  return (
    <div className="page">
      <div className="toolbar">
        <div className="tabs">
          <button
            type="button"
            className={`tab ${tab === 'upcoming' ? 'active' : ''}`}
            onClick={() => setTab('upcoming')}
          >
            Upcoming
          </button>
          <button
            type="button"
            className={`tab ${tab === 'past' ? 'active' : ''}`}
            onClick={() => setTab('past')}
          >
            Past
          </button>
        </div>

        <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
          <input
            type="search"
            placeholder="Search events or venues"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            style={{ width: 230 }}
          />
          <button type="button" onClick={() => navigate('/events/new')}>
            + New event
          </button>
        </div>
      </div>

      {actionError ? <div className="banner error">{actionError}</div> : null}

      {loadError ? (
        <div className="banner error">
          Could not load events: {loadError}
          <div style={{ marginTop: 6 }}>
            If this says permission denied, publish the rules from
            firestore.rules in the Firebase console.
          </div>
        </div>
      ) : null}

      {searching && visible.length > 1 ? (
        <div className="banner info">
          Reordering is disabled while searching. Clear the search to move
          events.
        </div>
      ) : null}

      {loading ? <div className="empty">Loading events...</div> : null}

      {!loading && !loadError && visible.length === 0 ? (
        <div className="empty">
          {events.length === 0
            ? 'No events yet. Create the first one.'
            : searching
              ? 'No events match that search.'
              : `No ${tab} events.`}
        </div>
      ) : null}

      <div className="event-grid">
        {visible.map((event, index) => {
          const past = isPast(event);
          const poster = posters[event.id];
          const busy = busyId === event.id;

          return (
            <article
              key={event.id}
              className={`event-card ${event.hidden ? 'is-hidden' : ''}`}
            >
              <div className="event-card-media">
                {event.hasPoster && poster ? (
                  <img src={poster} alt="" />
                ) : (
                  <div className="event-card-noimage">
                    {event.hasPoster ? 'Loading poster...' : 'No poster'}
                  </div>
                )}

                <div className="order-controls">
                  <button
                    type="button"
                    className="order-btn"
                    title="Move earlier in the list"
                    aria-label="Move up"
                    disabled={busy || searching || index === 0}
                    onClick={() => handleMove(index, -1)}
                  >
                    ↑
                  </button>
                  <button
                    type="button"
                    className="order-btn"
                    title="Move later in the list"
                    aria-label="Move down"
                    disabled={
                      busy || searching || index === visible.length - 1
                    }
                    onClick={() => handleMove(index, 1)}
                  >
                    ↓
                  </button>
                </div>
              </div>

              <div className="event-card-body">
                <h3>{event.title}</h3>
                {event.caption ? (
                  <p className="caption">{event.caption}</p>
                ) : null}

                <div className="meta">{formatDate(event.startAt)}</div>
                <div className="meta">
                  {formatTimeRange(event.startAt, event.endAt)}
                </div>
                <div className="meta">{event.venueName}</div>

                <div className="pill-row">
                  {event.hidden ? (
                    <span className="pill grey">Hidden</span>
                  ) : null}
                  {isInProgress(event) ? (
                    <span className="pill">Happening now</span>
                  ) : null}
                  {past ? <span className="pill grey">Ended</span> : null}
                  {!event.buildingId ? (
                    <span className="pill outline">Outdoor</span>
                  ) : null}
                </div>
              </div>

              <div className="event-card-actions">
                <button
                  type="button"
                  className="secondary"
                  disabled={busy}
                  onClick={() => handleToggleHidden(event)}
                >
                  {event.hidden ? 'Show' : 'Hide'}
                </button>
                <button
                  type="button"
                  className="secondary"
                  disabled={busy}
                  onClick={() => navigate(`/events/${event.id}`)}
                >
                  Edit
                </button>
                <button
                  type="button"
                  className="danger"
                  disabled={busy}
                  onClick={() => handleDelete(event)}
                >
                  Delete
                </button>
              </div>
            </article>
          );
        })}
      </div>
    </div>
  );
}
