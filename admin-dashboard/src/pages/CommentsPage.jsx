import { useEffect, useMemo, useState } from 'react';
import {
  collection,
  deleteDoc,
  doc,
  onSnapshot,
  serverTimestamp,
  updateDoc,
} from 'firebase/firestore';

import {
  COMMENTS_COLLECTION,
  EVENTS_COLLECTION,
  STUDENTS_COLLECTION,
  db,
} from '../firebase.js';

function mapComment(docSnapshot) {
  const data = docSnapshot.data();
  return {
    id: docSnapshot.id,
    eventId: data.eventId || '',
    uid: data.uid || '',
    studentName: data.studentName || 'Student',
    indexNumber: data.indexNumber || '',
    text: data.text || '',
    createdAt: data.createdAt?.toDate?.() || null,
  };
}

/**
 * Comment moderation: every comment across every event, newest first, with
 * the option to delete one or block its author.
 */
export default function CommentsPage() {
  const [comments, setComments] = useState([]);
  const [eventTitles, setEventTitles] = useState({});
  const [studentStatus, setStudentStatus] = useState({});
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState('');
  const [search, setSearch] = useState('');
  const [eventFilter, setEventFilter] = useState('all');
  const [busyId, setBusyId] = useState('');
  const [actionError, setActionError] = useState('');

  useEffect(() => {
    return onSnapshot(
      collection(db, COMMENTS_COLLECTION),
      (snapshot) => {
        setComments(snapshot.docs.map(mapComment));
        setLoading(false);
      },
      (error) => {
        setLoadError(error.message);
        setLoading(false);
      },
    );
  }, []);

  // Event titles, so a comment shows which post it belongs to.
  useEffect(() => {
    return onSnapshot(collection(db, EVENTS_COLLECTION), (snapshot) => {
      const titles = {};
      snapshot.docs.forEach((entry) => {
        titles[entry.id] = entry.data().title || 'Untitled event';
      });
      setEventTitles(titles);
    });
  }, []);

  // Author status, so the Block action can be hidden for already-blocked
  // students.
  useEffect(() => {
    return onSnapshot(collection(db, STUDENTS_COLLECTION), (snapshot) => {
      const statuses = {};
      snapshot.docs.forEach((entry) => {
        statuses[entry.id] = entry.data().status || 'pending';
      });
      setStudentStatus(statuses);
    });
  }, []);

  const visible = useMemo(() => {
    const needle = search.trim().toLowerCase();
    return comments
      .filter((comment) =>
        eventFilter === 'all' ? true : comment.eventId === eventFilter,
      )
      .filter((comment) => {
        if (!needle) return true;
        return (
          comment.text.toLowerCase().includes(needle) ||
          comment.studentName.toLowerCase().includes(needle) ||
          comment.indexNumber.toLowerCase().includes(needle)
        );
      })
      .sort((a, b) => {
        // A comment still awaiting its server timestamp was just written.
        if (!a.createdAt) return -1;
        if (!b.createdAt) return 1;
        return b.createdAt - a.createdAt;
      });
  }, [comments, search, eventFilter]);

  async function handleDelete(comment) {
    const confirmed = window.confirm(
      `Delete this comment by ${comment.studentName}?\n\n"${comment.text}"`,
    );
    if (!confirmed) return;

    setActionError('');
    setBusyId(comment.id);
    try {
      await deleteDoc(doc(db, COMMENTS_COLLECTION, comment.id));
    } catch (error) {
      setActionError(`Could not delete the comment: ${error.message}`);
    } finally {
      setBusyId('');
    }
  }

  async function handleBlockAuthor(comment) {
    const confirmed = window.confirm(
      `Block ${comment.studentName} (${comment.indexNumber})? ` +
        'They stay signed in but can no longer comment or like. ' +
        'Their existing comments are not removed.',
    );
    if (!confirmed) return;

    setActionError('');
    setBusyId(comment.id);
    try {
      await updateDoc(doc(db, STUDENTS_COLLECTION, comment.uid), {
        status: 'blocked',
        reviewedAt: serverTimestamp(),
      });
    } catch (error) {
      setActionError(`Could not block the author: ${error.message}`);
    } finally {
      setBusyId('');
    }
  }

  const eventOptions = Object.entries(eventTitles).sort((a, b) =>
    a[1].localeCompare(b[1]),
  );

  return (
    <div className="page">
      <div className="toolbar">
        <select
          value={eventFilter}
          onChange={(e) => setEventFilter(e.target.value)}
          style={{ width: 260 }}
        >
          <option value="all">All events</option>
          {eventOptions.map(([id, title]) => (
            <option key={id} value={id}>
              {title}
            </option>
          ))}
        </select>

        <input
          type="search"
          placeholder="Search comments or authors"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={{ width: 260 }}
        />
      </div>

      {actionError ? <div className="banner error">{actionError}</div> : null}

      {loadError ? (
        <div className="banner error">
          Could not load comments: {loadError}
          <div style={{ marginTop: 6 }}>
            If this says permission denied, republish firestore.rules — it now
            needs an event_comments block.
          </div>
        </div>
      ) : null}

      {loading ? <div className="empty">Loading comments...</div> : null}

      {!loading && !loadError && visible.length === 0 ? (
        <div className="empty">
          {comments.length === 0
            ? 'No comments yet.'
            : 'No comments match that filter.'}
        </div>
      ) : null}

      {visible.map((comment) => {
        const busy = busyId === comment.id;
        const authorBlocked = studentStatus[comment.uid] === 'blocked';

        return (
          <div key={comment.id} className="row-card">
            <div className="row-card-body">
              <h3>
                {comment.studentName}
                {comment.indexNumber ? (
                  <span className="subtle"> · {comment.indexNumber}</span>
                ) : null}
                {authorBlocked ? (
                  <span className="pill grey" style={{ marginLeft: 8 }}>
                    Blocked
                  </span>
                ) : null}
              </h3>

              <p className="comment-text">{comment.text}</p>

              <div className="meta subtle">
                on {eventTitles[comment.eventId] || 'a deleted event'}
                {comment.createdAt
                  ? ` · ${comment.createdAt.toLocaleString()}`
                  : ' · just now'}
              </div>
            </div>

            <div className="row-card-actions">
              {!authorBlocked && comment.uid ? (
                <button
                  type="button"
                  className="secondary"
                  disabled={busy}
                  onClick={() => handleBlockAuthor(comment)}
                >
                  Block author
                </button>
              ) : null}
              <button
                type="button"
                className="danger"
                disabled={busy}
                onClick={() => handleDelete(comment)}
              >
                Delete
              </button>
            </div>
          </div>
        );
      })}
    </div>
  );
}
