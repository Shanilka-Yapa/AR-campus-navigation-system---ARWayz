import { NavLink, Navigate, Outlet } from 'react-router-dom';

import { useAuth } from '../context/AuthContext.jsx';

/**
 * Gate for every admin route. Renders the shared header and the matched page
 * only once an allowlisted admin is signed in.
 *
 * This is a convenience, not a security boundary - the Firestore rules are
 * what actually prevent non-admins from writing events.
 */
export default function ProtectedRoute() {
  const { user, loading, signOut } = useAuth();

  if (loading) {
    return <div className="empty">Checking access...</div>;
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  return (
    <>
      <header className="app-header">
        <h1>ARWayz &middot; Campus Events Admin</h1>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <span className="who">{user.email}</span>
          <button type="button" className="secondary" onClick={signOut}>
            Sign out
          </button>
        </div>
      </header>

      <nav className="app-nav">
        <NavLink to="/" end>
          Events
        </NavLink>
        <NavLink to="/comments">Comments</NavLink>
        <NavLink to="/students">Students</NavLink>
      </nav>

      <Outlet />
    </>
  );
}
