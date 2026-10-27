import { useEffect, useState } from 'react';
import { collection, getDocs } from 'firebase/firestore';

import { BUILDINGS_COLLECTION, db } from '../firebase.js';

/**
 * Lets the admin attach an event to an existing building from the `buildings`
 * collection, so events reference real navigation destinations instead of a
 * second, disconnected building list.
 *
 * Choosing "Outdoor venue" instead reveals manual coordinate inputs, for
 * venues that are not inside any mapped building.
 */
export default function VenuePicker({ form, errors, onPatch }) {
  const [buildings, setBuildings] = useState([]);
  const [loadError, setLoadError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      try {
        const snapshot = await getDocs(collection(db, BUILDINGS_COLLECTION));
        if (cancelled) return;
        const rows = snapshot.docs
          .map((doc) => ({
            id: doc.id,
            name: doc.data().name || doc.id,
            latitude: doc.data().latitude,
            longitude: doc.data().longitude,
          }))
          .sort((a, b) => a.name.localeCompare(b.name));
        setBuildings(rows);
      } catch (error) {
        if (!cancelled) setLoadError(error.message);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, []);

  const selected = buildings.find((b) => b.id === form.buildingId);
  const missingCoordinates =
    selected &&
    (typeof selected.latitude !== 'number' ||
      typeof selected.longitude !== 'number');

  function handleBuildingChange(event) {
    const buildingId = event.target.value;
    const building = buildings.find((b) => b.id === buildingId);
    // Pre-fill the venue name with the building name as a starting point; a
    // venue is often a room inside the building, so it stays editable.
    const patch = { buildingId };
    if (building && !form.venueName.trim()) {
      patch.venueName = building.name;
    }
    onPatch(patch);
  }

  return (
    <>
      <div className="field">
        <label htmlFor="venueMode">Venue type</label>
        <select
          id="venueMode"
          value={form.outdoorOnly ? 'outdoor' : 'building'}
          onChange={(e) =>
            onPatch({
              outdoorOnly: e.target.value === 'outdoor',
              ...(e.target.value === 'outdoor'
                ? { buildingId: '', floor: '', indoorPointId: '' }
                : { venueLatitude: '', venueLongitude: '' }),
            })
          }
        >
          <option value="building">Inside a campus building</option>
          <option value="outdoor">Outdoor venue (enter coordinates)</option>
        </select>
      </div>

      {form.outdoorOnly ? (
        <div className="field-row">
          <div className="field">
            <label htmlFor="venueLatitude">Latitude</label>
            <input
              id="venueLatitude"
              type="number"
              step="any"
              placeholder="6.078071"
              value={form.venueLatitude}
              onChange={(e) => onPatch({ venueLatitude: e.target.value })}
            />
            {errors.venueLatitude ? (
              <div className="field-error">{errors.venueLatitude}</div>
            ) : null}
          </div>
          <div className="field">
            <label htmlFor="venueLongitude">Longitude</label>
            <input
              id="venueLongitude"
              type="number"
              step="any"
              placeholder="80.191551"
              value={form.venueLongitude}
              onChange={(e) => onPatch({ venueLongitude: e.target.value })}
            />
            {errors.venueLongitude ? (
              <div className="field-error">{errors.venueLongitude}</div>
            ) : null}
          </div>
        </div>
      ) : (
        <>
          <div className="field">
            <label htmlFor="buildingId">Building</label>
            <select
              id="buildingId"
              value={form.buildingId}
              onChange={handleBuildingChange}
              disabled={loading || buildings.length === 0}
            >
              <option value="">
                {loading ? 'Loading buildings...' : 'Select a building'}
              </option>
              {buildings.map((building) => (
                <option key={building.id} value={building.id}>
                  {building.name}
                </option>
              ))}
            </select>
            {errors.buildingId ? (
              <div className="field-error">{errors.buildingId}</div>
            ) : null}
            {loadError ? (
              <div className="field-error">
                Could not load buildings: {loadError}
              </div>
            ) : null}
            {!loading && !loadError && buildings.length === 0 ? (
              <div className="hint">
                No buildings exist yet. Add one in the Flutter app&apos;s building
                admin, or use an outdoor venue.
              </div>
            ) : null}
            {missingCoordinates ? (
              <div className="field-error">
                This building has no coordinates, so students will not be able to
                navigate to it.
              </div>
            ) : null}
          </div>

          <div className="field-row">
            <div className="field">
              <label htmlFor="floor">Floor (optional)</label>
              <input
                id="floor"
                type="number"
                placeholder="0"
                value={form.floor}
                onChange={(e) => onPatch({ floor: e.target.value })}
              />
              {errors.floor ? (
                <div className="field-error">{errors.floor}</div>
              ) : null}
            </div>
            <div className="field">
              <label htmlFor="indoorPointId">Indoor point ID (optional)</label>
              <input
                id="indoorPointId"
                type="text"
                placeholder="auditorium_entrance"
                value={form.indoorPointId}
                onChange={(e) => onPatch({ indoorPointId: e.target.value })}
              />
              <div className="hint">
                Shown to students alongside the in-building QR hint.
              </div>
            </div>
          </div>
        </>
      )}
    </>
  );
}
