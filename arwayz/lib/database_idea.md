# ARWayz Database Documentation

## 1. Overview
The ARWayz project uses **Firebase Firestore** as a backend database.  
The database stores information about campus locations for **AR-based navigation**.

- **Outdoor navigation:** Uses GPS coordinates of buildings.
- **Indoor navigation:** Uses QR codes linked to indoor POIs.

---

## 2. Firebase Console Setup (Steps)

1. Go to [Firebase Console](https://console.firebase.google.com/)  
2. Click **Add Project** → name it `ARWayz` → disable Google Analytics (optional) → Create  
3. In the Firebase project, go to **Build → Firestore Database**  
4. Click **Create Database** → Start in **Test Mode** → Choose nearest region → Create

---

## 3. Firestore Database Structure

### Collections:

### 3.1 `buildings` Collection
Stores campus buildings for **outdoor navigation**.

**Document Example:**

| Field Name  | Type   | Example                       |
|------------|--------|-------------------------------|
| name       | string | Faculty of Engineering        |
| latitude   | number | 6.0851                        |
| longitude  | number | 80.1907                       |
| description| string | Main engineering faculty      |
| floors     | number | 5                              |

---

### 3.2 `pois` Collection
Stores **points of interest**, including indoor and outdoor locations.

**Document Example:**

| Field Name  | Type   | Example                       |
|------------|--------|-------------------------------|
| name       | string | Main Cafeteria                |
| type       | string | food                          |
| isIndoor   | bool   | true                          |
| floor      | number | 2                             |
| buildingId | string | eng_faculty                   |
| qrCodeId   | string | CAF_F2                        |
| latitude   | number | 6.08512                       |
| longitude  | number | 80.19075                      |

---

## 4. Notes

- **Indoor navigation:** Each indoor POI has a **QR code** stored in `qrCodeId`.
- **Outdoor navigation:** Uses latitude and longitude fields from `buildings` collection.
- **Future Expansion:** More buildings and POIs can be added as needed.

---

## 5. Firebase Console Screenshot (Optional)
Add a screenshot of your `buildings` and `pois` collections to visually show the database.
