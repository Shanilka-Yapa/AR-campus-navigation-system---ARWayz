import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
} from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';

import { ADMINS_COLLECTION, auth, db } from '../firebase.js';

const AuthContext = createContext(null);

/**
 * A signed-in account only counts as an administrator if a document exists at
 * admins/{uid}. Only the document's existence matters, so the console can
 * grant access by creating an empty-ish document.
 *
 * Hiding UI is not security: the same check is enforced server-side by the
 * Firestore rules in firestore.rules, which is what actually blocks writes.
 */
async function isAllowlistedAdmin(uid) {
  const snapshot = await getDoc(doc(db, ADMINS_COLLECTION, uid));
  return snapshot.exists();
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [rejectionReason, setRejectionReason] = useState('');

  useEffect(() => {
    return onAuthStateChanged(auth, async (account) => {
      if (!account) {
        setUser(null);
        setLoading(false);
        return;
      }

      try {
        const allowed = await isAllowlistedAdmin(account.uid);
        if (!allowed) {
          setRejectionReason(
            'This account is not an administrator. Ask for your user ID to be ' +
              'added to the admins collection.',
          );
          setUser(null);
          await firebaseSignOut(auth);
          return;
        }
        setRejectionReason('');
        setUser(account);
      } catch (error) {
        // A permission-denied here usually means the security rules have not
        // been published yet.
        setRejectionReason(`Could not verify admin access: ${error.message}`);
        setUser(null);
        await firebaseSignOut(auth);
      } finally {
        setLoading(false);
      }
    });
  }, []);

  const value = useMemo(
    () => ({
      user,
      loading,
      rejectionReason,
      clearRejection: () => setRejectionReason(''),
      signIn: (email, password) =>
        signInWithEmailAndPassword(auth, email.trim(), password),
      signOut: () => firebaseSignOut(auth),
    }),
    [user, loading, rejectionReason],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used inside an AuthProvider');
  }
  return context;
}
