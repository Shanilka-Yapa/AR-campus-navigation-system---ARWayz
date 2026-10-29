# ARWayz — Campus Events Admin Dashboard

React + Vite admin dashboard for the ARWayz `events` Firestore collection.
Talks to Firebase directly through the Firebase JS SDK (Auth + Firestore) —
there is no separate backend server.

The student-facing side lives in the Flutter app under
`arwayz/lib/features/events/`.

---

## One-time Firebase setup

Nothing below works until these steps are done in the
[Firebase console](https://console.firebase.google.com/) for project
**`arwayz-c30b3`**.

### 1. Enable email/password sign-in

**Authentication → Sign-in method → Email/Password → Enable.**
This project has never used Firebase Auth, so the provider starts disabled.

### 2. Create your admin account

**Authentication → Users → Add user.** Enter an email and password, then
**copy the User UID**.

### 3. Add that UID to the admin allowlist

**Firestore Database → Start collection** named `admins`, with:

- Document ID: the UID you copied
- Any field, e.g. `email` (string)

Only the document's *existence* is checked, by both the dashboard and the
security rules.

### 4. Publish the security rules

Open [`firestore.rules`](./firestore.rules), copy the whole file, then
**Firestore Database → Rules → paste → Publish**.

> **Publishing replaces the entire ruleset.** The `buildings` block in that
> file must be kept — without it the app's existing building screens lose
> access to Firestore.

The rules are the only thing preventing a non-admin from writing events, since
there is no backend server in front of Firestore. Hiding buttons in the UI is
not security.

### 5. Local environment file

```powershell
cd D:\ARway\admin-dashboard
copy .env.example .env.local
```

`.env.example` already carries the project's public web config, copied from the
`web` block of `arwayz/lib/firebase_options.dart`.

The `events` collection does not need creating by hand — saving the first event
creates it.

---

## Running

```powershell
cd D:\ARway\admin-dashboard
npm install
npm run dev
```

Then open http://localhost:5173.

| Command | What it does |
|---|---|
| `npm run dev` | Dev server with hot reload |
| `npm run build` | Production build into `dist/` |
| `npm run preview` | Serve the production build locally |

---

## Collections

| Collection | Written by | Read by |
|---|---|---|
| `events` | admin | everyone |
| `event_posters` | admin | everyone |
| `students` | student (create only), admin (status) | that student, admins |
| `event_comments` | approved students | everyone |
| `event_likes` | approved students | everyone |
| `buildings` | existing building admin | everyone |

## Student registration and moderation

A student registers in the mobile app with name, index number, email and
password. That creates their Firebase Auth account **and** a `students/{uid}`
document with `status: 'pending'`.

They can sign in and browse straight away, but **cannot comment or like until
an admin approves them** — enforced by the Firestore rules, not by hiding UI.
The rules also stop a student writing `status` themselves, writing a comment as
someone else, or liking an event twice (the like document id is
`{eventId}_{uid}`, so a duplicate is impossible by construction).

**Students tab** — three sub-tabs with live counts:
- **Requests** — approve or reject new registrations
- **Approved** — block a student
- **Blocked** — unblock

**Comments tab** — every comment across every event, newest first, filterable
by event and searchable by text, author or index number. Delete a comment, or
block its author directly from it.

> Rejecting a student deletes their `students` record, which locks them out.
> Their Firebase Authentication account still exists; delete it under
> **Authentication → Users** if you want it gone entirely. The dashboard
> cannot do that — removing auth accounts needs the Admin SDK.

## What the dashboard does

- **Login** — Firebase Auth email/password, then an `admins/{uid}` allowlist
  check. A valid account that is not allowlisted is signed straight back out.
- **Event list** — live Firestore stream ordered by start time, split into
  Upcoming and Past, with client-side search over title, venue and description.
- **Create / edit** — all event fields, with validation that blocks saving
  unless the required fields are filled and **the end time is later than the
  start time**.
- **Delete** — confirmation dialog naming the event.
- **Venue picker** — the building dropdown is populated from the existing
  `buildings` collection, so events point at real navigation destinations
  instead of a second building list. Selecting a building pre-fills the venue
  name and records `buildingId`; the student app reads that building's
  coordinates at navigation time.
- **Outdoor venues** — switch venue type to enter latitude/longitude directly
  for a venue that is not inside a mapped building.

## Event document shape

Written to `events/{autoId}` — the document ID *is* the event ID.

| Field | Type | Required |
|---|---|---|
| `title` | string | ✅ |
| `caption` | string \| null | optional, max 140 chars |
| `description` | string | ✅ |
| `startAt` | Timestamp | ✅ |
| `endAt` | Timestamp | ✅ (must be after `startAt`) |
| `venueName` | string | ✅ |
| `buildingId` | string \| null | building venues |
| `floor` | number \| null | optional |
| `indoorPointId` | string \| null | optional |
| `venueLatitude` | number \| null | outdoor venues |
| `venueLongitude` | number \| null | outdoor venues |
| `hasPoster` | boolean | set automatically |
| `hidden` | boolean | toggled from the list |
| `sortOrder` | number | manual display order |
| `createdAt` | Timestamp | set on create |
| `updatedAt` | Timestamp | set on every save |

### Visibility and ordering

**Hide** keeps an event in Firestore and visible in this dashboard, but filters
it out of the student app. Hidden cards are dimmed with a dashed border.

**The arrows on each card** swap that event's `sortOrder` with its neighbour's,
written as a single batch so the two never disagree. New events seed
`sortOrder` from their start time, so the default order is chronological and
the arrows only affect what an admin has explicitly moved. Reordering is
disabled while a search is active, since moving an item within filtered results
would not mean what it appears to mean.

### Posters

Poster images are **not** stored in Cloud Storage, so no billing plan is
needed. The dashboard resizes each image to 800px on its longest edge and
re-encodes it as JPEG in the browser, stepping the quality down until the
result fits comfortably inside Firestore's 1 MiB document limit.

The bytes go to a **separate collection**, `event_posters/{eventId}`, with
fields `data` (base64), `contentType`, `width`, `height`, `updatedAt`. Keeping
them out of the event document matters: the student app streams the whole
`events` collection to build its list, and inlining posters there would make it
download every image up front. Instead the event carries a `hasPoster` flag and
the details page fetches the one poster it needs.

Deleting an event also deletes its poster document.

Dates and times are stored as two Timestamps rather than a separate date plus
`"09:00"`-style strings. That gives correct chronological sorting, a trivial
`endAt > startAt` check, and a clean upcoming/past split in which an event
running right now still counts as upcoming.

---

## Troubleshooting

| Symptom | Cause |
|---|---|
| "Email/password sign-in is not enabled…" | Step 1 not done |
| "This account is not an administrator." | Step 3 not done, or the UID does not match |
| "Could not verify admin access… permission denied" | Step 4 not done |
| "Firestore rejected the write." | UID missing from `admins`, or rules not published |
| Building dropdown is empty | No documents in `buildings` yet — add one in the app's building admin, or use an outdoor venue |
| Navigate is disabled in the Flutter app | The event's building has no `latitude`/`longitude`, and the event has no coordinates of its own |
