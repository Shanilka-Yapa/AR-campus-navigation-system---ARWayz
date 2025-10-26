# ARWayz – AR Navigation App

**Author:** EG/2022/5435  
**Date:** 23-10-2025  
**Version:** 1.0

---

## 1. Introduction

**Purpose:**  
The purpose of this document is to define the functional and non-functional requirements of ARWayz, an AR-based navigation application for indoor and outdoor use.

**Scope:**  
ARWayz aims to provide seamless navigation using AR overlays for users in campuses, cities, or buildings, helping them find locations quickly and intuitively.

---

## 2. Research Findings

| App                  | Core Features                                 | UX Strengths                                | UX Pain Points                                   |
|---------------------|-----------------------------------------------|---------------------------------------------|-------------------------------------------------|
| AR City              | Outdoor AR navigation, route visualization  | Clear AR markers, intuitive map UI         | AR markers can be hard to read in sunlight    |
| ARWay                | Indoor navigation, AR overlays, building maps| Accurate indoor positioning                 | Requires strong Wi-Fi; limited map coverage    |
| Google Maps Live View| Outdoor walking directions with AR guidance  | Reliable data, familiar UI                  | Limited indoor support; occasional GPS errors  |

**Summary of Findings:**  
- Existing apps work well for outdoor navigation, with clear AR markers and real-time updates.  
- Indoor navigation is still limited and often requires Wi-Fi or BLE beacons.  
- Users face issues with marker visibility, slow AR updates, and difficulty finding specific rooms or smaller landmarks.

---

## 3. User Problems / Needs

- Difficulty navigating indoors and finding specific rooms/buildings.  
- Delays in AR marker rendering causing confusion.  
- Inconsistent accuracy for indoor positioning.  
- Lack of personalization, such as saving frequently visited locations.  

---

## 4. Functional Requirements

1. The app shall provide AR-based navigation for **indoor and outdoor locations**.  
2. The app shall allow users to **search for buildings, rooms, or landmarks**.  
3. The app shall **update routes in real-time** if the user deviates.  
4. The app shall allow users to **save favorite locations or “wishlist”**.  
5. The app shall provide **step-by-step navigation directions**.  
6. The app shall support **both GPS (outdoor) and QR (indoor) positioning**.   

---

## 5. Non-Functional Requirements

1. The app shall **provide a clean, intuitive, and consistent user interface for easy navigation**.  
2. The app shall **use a responsive design that adapts to different screen sizes and resolutions**.  
3. The app shall be **compatible with Android devices**.  
4. The app shall maintain **user privacy**, collecting only necessary data.  
5. The app shall provide **smooth AR rendering without lag**.  
6. The app shall handle **up to 500 concurrent users** without performance issues.  
7. The app shall support **maintain a modern and visually appealing UI following consistent color schemes and icons**.  

---

## 6. Optional Features

- User **sign-in** with email or social login (optional)  
- Personalized **favorites / recent locations / wishlist**  
- Notifications for **nearby points of interest**  
- Option to **download maps for offline use**  

---

## 7. References

- AR City App: [https://www.arcity.com](https://www.arcity.com)  
- ARWay App: [https://www.arway.io](https://www.arway.io)  
- Google Maps Live View: [https://www.google.com/maps](https://www.google.com/maps)  
- AR Navigation Research Paper: “Augmented Reality Indoor Navigation,” IEEE 2022
