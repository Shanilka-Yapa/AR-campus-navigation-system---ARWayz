import { useState } from 'react';
import { Navigate } from 'react-router-dom';

import { useAuth } from '../context/AuthContext.jsx';

/** Maps Firebase Auth error codes onto something an operator can act on. */
function describeAuthError(code, fallback) {
  switch (code) {
    case 'auth/invalid-email':
      return 'That email address is not valid.';
    case 'auth/missing-password':
      return 'Enter your password.';
    case 'auth/invalid-credential':
    case 'auth/wrong-password':
    case 'auth/user-not-found':
      return 'Incorrect email or password.';
    case 'auth/too-many-requests':
      return 'Too many attempts. Wait a moment and try again.';
    case 'auth/network-request-failed':
      return 'Network error. Check your connection.';
    case 'auth/operation-not-allowed':
      return 'Email/password sign-in is not enabled for this Firebase project yet.';
    default:
      return fallback;
  }
}

export default function LoginPage() {
  const { user, loading, signIn, rejectionReason, clearRejection } = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  if (!loading && user) {
    return <Navigate to="/" replace />;
  }

  async function handleSubmit(event) {
    event.preventDefault();
    setError('');
    clearRejection();
    setSubmitting(true);
    try {
      await signIn(email, password);
      // On success the auth listener verifies the admin allowlist and either
      // lets the redirect above happen or signs the account back out.
    } catch (caught) {
      setError(describeAuthError(caught.code, caught.message));
    } finally {
      setSubmitting(false);
    }
  }

  const message = error || rejectionReason;

  return (
    <div className="login-wrap">
      <form className="login-card" onSubmit={handleSubmit}>
        <h1>Campus Events Admin</h1>
        <p className="sub">Sign in with your ARWayz administrator account.</p>

        {message ? <div className="banner error">{message}</div> : null}

        <div className="field">
          <label htmlFor="email">Email</label>
          <input
            id="email"
            type="email"
            autoComplete="username"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>

        <div className="field">
          <label htmlFor="password">Password</label>
          <input
            id="password"
            type="password"
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>

        <button type="submit" disabled={submitting} style={{ width: '100%' }}>
          {submitting ? 'Signing in...' : 'Sign in'}
        </button>
      </form>
    </div>
  );
}
