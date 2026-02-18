# Firebase Backend Setup Documentation

## Project: ARWayz – AR Campus Navigation System

This document explains **how the backend database was created using Firebase Console**, without implementing the mobile application. It also describes the current database structure and sample data.

---

## 1. Overview

The ARWayz project uses **Firebase Firestore (NoSQL database)** as the backend.

The database supports:

* **Outdoor navigation** using GPS coordinates (buildings)
* **Indoor navigation** using **QR codes** (points of interest)

At this stage, the backend is implemented as a **prototype database** with sample data to demonstrate functionality and future scalability.

---

## 2. Tools and Technologies Used

* Firebase Console
* Firebase Firestore (Cloud Firestore – NoSQL)

---

## 3. Steps to Create Firebase Backend (Using Firebase Console)

### Step 1: Create Firebase Project

1. Go to **Firebase Console**: [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. Click **Add Project**
3. Enter project name: `ARWayz`
4. Disable Google Analytics (optional)
5. Click **Create Project**

---

### Step 2: Create Firestore Database

1. In Firebase Console, open the `ARWayz` project
2. Navigate to **Build → Firestore Database**
3. Click **Create Database**
4. Select **Start in Test Mode** (for development)
5. Choose the nearest database region
6. Click **Enable**

Firestore database is now created.

---

## 4. Database Design

The database is designed with two main collections:

```
Firestore Database
 ├── buildings
 └── pois
```

This structure separates **outdoor navigation data** from **indoor navigation data**.

---

## 5. `buildings` Collection (Outdoor Navigation)

### Purpose

Stores campus buildings used for **outdoor AR navigation** using GPS.

### Steps to Create

1. In Firestore → Data tab
2. Click **Start collection**
3. Collection ID: `buildings`
4. Add a document (Auto-ID or named ID)

### Sample Document Fields

| Field Name  | Type   | Description          |
| ----------- | ------ | -------------------- |
| name        | String | Building name        |
| latitude    | Number | GPS latitude         |
| longitude   | Number | GPS longitude        |
| description | String | Building description |
| floors      | Number | Number of floors     |

### Example Data

```
name: Faculty of Engineering
latitude: 6.0851
longitude: 80.1907
description: Main engineering faculty building
floors: 5
```

---

## 6. `pois` Collection (Indoor Navigation – QR Code Based)

### Purpose

Stores **Points of Interest (POIs)** such as labs, cafeterias, and offices.
Indoor navigation is handled using **QR codes**.

### Steps to Create

1. In Firestore → Data tab
2. Click **Start collection**
3. Collection ID: `pois`
4. Add a document

### Sample Document Fields

| Field Name | Type    | Description                  |
| ---------- | ------- | ---------------------------- |
| name       | String  | POI name                     |
| type       | String  | Category (lab, food, office) |
| isIndoor   | Boolean | Indoor or outdoor            |
| floor      | Number  | Floor number                 |
| buildingId | String  | Related building             |
| qrCodeId   | String  | Unique QR code value         |
| latitude   | Number  | Optional location            |
| longitude  | Number  | Optional location            |

### Example Data

```
name: Main Cafeteria
type: food
isIndoor: true
floor: 2
buildingId: eng_faculty
qrCodeId: CAF_F2
latitude: 6.08512
longitude: 80.19075
```

---

## 7. Indoor and Outdoor Navigation Logic

* **Outdoor Navigation**:

  * Uses `buildings` collection
  * GPS-based (latitude and longitude)

* **Indoor Navigation**:

  * Uses `pois` collection
  * User scans QR code
  * App fetches POI data using `qrCodeId`

 ---

## 8. Current Status

* Firebase backend successfully created
* Firestore database implemented
* One building and one POI added as sample data
* Application integration planned for next phase

---

## 9. Future Improvements

* Add more buildings and POIs
* Implement Firebase Authentication
* Integrate database with Flutter AR application
* Add indoor path mapping

---

## 10. Conclusion

This backend implementation demonstrates a scalable and structured Firebase Firestore database suitable for an AR-based campus navigation system supporting both indoor and outdoor navigation.
