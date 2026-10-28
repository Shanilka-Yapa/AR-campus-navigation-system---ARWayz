import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);

export const EVENTS_COLLECTION = 'events';
export const BUILDINGS_COLLECTION = 'buildings';
export const ADMINS_COLLECTION = 'admins';

/**
 * Poster images, one document per event, keyed by the event's own id.
 *
 * Kept out of the `events` documents so that listing events stays light - the
 * list never downloads poster bytes, only the details page does.
 */
export const POSTERS_COLLECTION = 'event_posters';

/** Registered students, keyed by their Firebase Auth uid. */
export const STUDENTS_COLLECTION = 'students';

/** Student comments on events. */
export const COMMENTS_COLLECTION = 'event_comments';

/** One document per student per event they liked. */
export const LIKES_COLLECTION = 'event_likes';
