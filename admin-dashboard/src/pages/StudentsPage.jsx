import { useEffect, useMemo, useState } from 'react';
import {
  collection,
  deleteDoc,
  doc,
  onSnapshot,
  serverTimestamp,
  updateDoc,
} from 'firebase/firestore';

import { STUDENTS_COLLECTION, db } from '../firebase.js';

const TABS = [
  { key: 'pending', label: 'Requests' },
  { key: 'approved', label: 'Approved' },
  { key: 'blocked', label: 'Blocked' },
];

function mapStudent(docSnapshot) {
  const data = docSnapshot.data();
  return {
    uid: docSnapshot.id,
    name: data.name || 'Unnamed',
    indexNumber: data.indexNumber || '',
    email: data.email || '',
    status: data.status || 'pending',
    createdAt: data.createdAt?.toDate?.() || null,
  };
}

/**
 * Registration review and moderation.
 *
 * A student can sign in as soon as they register, but stays `pending` and
 * cannot comment or like until approved here. Blocking is enforced by the
 * Firestore rules, not just by hiding UI.
 */
export default function StudentsPage() {
  const [students, setStudents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState('');
  const [tab, setTab] = useState('pending');
  const [search, setSearch] = useState('');
  const [busyId, setBusyId] = useState('');
  const [actionError, setActionError] = useState('');

  useEffect(() => {
    return onSnapshot(
      collection(db, STUDENTS_COLLECTION),
      (snapshot) => {
        setStudents(snapshot.docs.map(mapStudent));
        setLoading(false);
      },
      (error) => {
        setLoadError(error.message);
        setLoading(false);
      },
    );
  }, []);

  const counts = useMemo(() => {
    return students.reduce(
      (acc, student) => {
        acc[student.status] = (acc[student.status] || 0) + 1;
        return acc;
      },
      { pending: 0, approved: 0, blocked: 0 },
    );
  }, [students]);

  const visible = useMemo(() => {
    const needle = search.trim().toLowerCase();
    return students
      .filter((student) => student.status === tab)
      .filter((student) => {
        if (!needle) return true;
        return (
          student.name.toLowerCase().includes(needle) ||
          student.indexNumber.toLowerCase().includes(needle) ||
          student.email.toLowerCase().includes(needle)
        );
      })
      .sort((a, b) => {
        if (a.createdAt && b.createdAt) return b.createdAt - a.createdAt;
        return a.name.localeCompare(b.name);
      });
  }, [students, tab, search]);

  async function setStatus(student, status) {
    setActionError('');
    setBusyId(student.uid);
    try {
      await updateDoc(doc(db, STUDENTS_COLLECTION, student.uid), {
        status,
        reviewedAt: serverTimestamp(),
      });
    } catch (error) {
      setActionError(`Could not update ${student.name}: ${error.message}`);
    } finally {
      setBusyId('');
    }
  }

  async function handleReject(student) {
    const confirmed = window.confirm(
      `Reject ${student.name} (${student.indexNumber})? ` +
        'Their registration record is removed. Their sign-in account still ' +
        'exists in Firebase Authentication and must be deleted there if you ' +
        'want it gone entirely.',
    );
    if (!confirmed) return;

    setActionError('');
    setBusyId(student.uid);
    try {
      await deleteDoc(doc(db, STUDENTS_COLLECTION, student.uid));
    } catch (error) {
      setActionError(`Could not reject ${student.name}: ${error.message}`);
    } finally {
      setBusyId('');
    }
  }

  return (
    <div className="page">
      <div className="toolbar">
        <div className="tabs">
          {TABS.map((entry) => (
            <button
              key={entry.key}
              type="button"
              className={`tab ${tab === entry.key ? 'active' : ''}`}
              onClick={() => setTab(entry.key)}
            >
              {entry.label}
              {counts[entry.key] ? ` (${counts[entry.key]})` : ''}
            </button>
          ))}
        </div>

        <input
          type="search"
          placeholder="Search name, index or email"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={{ width: 260 }}
        />
      </div>

      {actionError ? <div className="banner error">{actionError}</div> : null}

      {loadError ? (
        <div className="banner error">
          Could not load students: {loadError}
          <div style={{ marginTop: 6 }}>
            If this says permission denied, republish firestore.rules — it now
            needs a students block.
          </div>
        </div>
      ) : null}

      {loading ? <div className="empty">Loading students...</div> : null}

      {!loading && !loadError && visible.length === 0 ? (
        <div className="empty">
          {tab === 'pending'
            ? 'No registration requests waiting.'
            : `No ${tab} students.`}
        </div>
      ) : null}

      {visible.map((student) => {
        const busy = busyId === student.uid;
        return (
          <div key={student.uid} className="row-card">
            <div className="row-card-body">
              <h3>{student.name}</h3>
              <div className="meta">Index: {student.indexNumber || '—'}</div>
              <div className="meta">{student.email}</div>
              {student.createdAt ? (
                <div className="meta subtle">
                  Registered {student.createdAt.toLocaleString()}
                </div>
              ) : null}
            </div>

            <div className="row-card-actions">
              {student.status === 'pending' ? (
                <>
                  <button
                    type="button"
                    disabled={busy}
                    onClick={() => setStatus(student, 'approved')}
                  >
                    Approve
                  </button>
                  <button
                    type="button"
                    className="danger"
                    disabled={busy}
                    onClick={() => handleReject(student)}
                  >
                    Reject
                  </button>
                </>
              ) : null}

              {student.status === 'approved' ? (
                <button
                  type="button"
                  className="danger"
                  disabled={busy}
                  onClick={() => setStatus(student, 'blocked')}
                >
                  Block
                </button>
              ) : null}

              {student.status === 'blocked' ? (
                <button
                  type="button"
                  disabled={busy}
                  onClick={() => setStatus(student, 'approved')}
                >
                  Unblock
                </button>
              ) : null}
            </div>
          </div>
        );
      })}
    </div>
  );
}
