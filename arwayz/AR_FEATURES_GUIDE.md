# AR Campus Navigation - Enhanced Features Guide

## ✅ Features Implemented

### 1. **AR Camera Navigation Button**

- **Location**: Floating action button in the outdoor navigation page (orange camera icon)
- **Function**: Opens AR navigation view with camera feed
- **Availability**: Only shows when user's current location is detected

### 2. **Navigation Arrows for Faculty**

- **Inside AR Camera View**:
  - Large rotating arrow showing direction to target
  - Arrow rotates based on device bearing
  - Real-time distance display
  - Cardinal direction text (North, Northeast, East, etc.)
  - Bearing angle in degrees

### 3. **Faculty Premises Detection (Geofencing)**

- **Radius**: 200 meters around faculty coordinates
- **Trigger**: When user enters faculty premises:
  - Blue pop-up card appears at bottom
  - Shows "You are in Faculty of Engineering"
  - Provides directions and AR navigation options
  - Auto-hides when leaving premises

### 4. **AR Pop-up Card**

- Shows location name and premises status
- Displays two action buttons:
  - **Directions**: Opens Google Maps for outdoor navigation
  - **AR Nav**: Opens AR camera navigation to nearby locations

### 5. **Indoor Navigation System**

- **Library Navigation**: Tile "·35HR+QJ9" location support
- AR guidance from faculty to library
- Real-time distance updates
- Bearing-based arrow guidance

### 6. **Campus Location System**

- Defined locations:
  - Faculty of Engineering (200m radius)
  - Library (150m radius)
  - Student Center (150m radius)
  - Cafeteria (100m radius)

## 🚀 How to Use

### For Users:

#### **Standard Navigation (Outdoor)**

1. Open the app and wait for location permission
2. See your location on Google Maps
3. Click the orange camera button to switch to AR mode

#### **AR Navigation Mode**

1. Click the orange camera icon
2. Point camera at target direction
3. Follow the rotating arrow
4. Watch the distance decrease as you approach target

#### **Faculty Premises Navigation**

1. Walk into faculty (within 200m)
2. Blue card automatically appears
3. Click "AR Nav" for visual arrow guidance
4. OR click "Directions" for Google Maps directions

#### **Navigate to Library from Faculty**

1. When inside faculty premises, card shows AR Nav button
2. Click "AR Nav" to navigate to library with camera
3. Follow the AR arrows and distance indicators

## 📁 New Files Created

```
lib/
├── models/
│   └── location_model.dart          # Location data models & geofencing
├── helpers/
│   └── ar_navigation_helper.dart    # Bearing, distance calculations
├── pages/
│   └── ar_camera_navigation_page.dart # AR camera interface
└── widgets/
    └── faculty_location_card.dart    # Faculty premises card UI
```

## 🔧 Configuration

### Edit Campus Locations

Open [lib/models/location_model.dart](lib/models/location_model.dart)

```dart
final Map<String, LocationModel> campusLocations = {
  'faculty_engineering': LocationModel(
    id: 'faculty_engineering',
    name: 'Faculty of Engineering',
    coordinates: const LatLng(6.0793684, 80.1919646),
    radius: 200, // Change geofence radius in meters
    isIndoor: true,
  ),
  // Add more locations here...
};
```

### Adjust Geofence Radius

- Change `radius` value in meters
- Smaller radius = more precise location detection
- Larger radius = earlier alerts

### Add New Campus Locations

```dart
'new_location': LocationModel(
  id: 'new_location',
  name: 'Location Name',
  description: 'Description',
  coordinates: const LatLng(latitude, longitude),
  radius: 150,
  isIndoor: true,
),
```

## 🎥 AR Navigation Features

### Bearing Calculation

- Automatically calculates direction to target
- Updates in real-time as you move
- Shows cardinal directions (N, NE, E, etc.)

### Distance Tracking

- Live distance update in meters
- Updates every 10 meters of movement
- Shows when you're getting closer/farther

### Visual Indicators

- Blue circle with arrow
- Arrow rotates to point toward target
- Size of circle indicates proximity

## 📍 Location Detection System

### How Geofencing Works

1. App tracks user location every 10 meters
2. Compares with defined campus locations
3. If within radius, shows faculty card
4. Automatically hides when leaving

### Multiple Locations

- System checks all campus locations
- Finds which location user is in
- Shows appropriate card for that location

## 🎯 Target Location (Library)

- **Code**: ·35HR+QJ9 (Plus Code)
- **Coordinates**: ~6.0785°N, 80.1925°E
- **Indoor**: Yes
- **Geofence Radius**: 150m

**Note**: Adjust library coordinates in [location_model.dart](lib/models/location_model.dart) if actual location differs.

## 📱 Required Permissions

The app automatically requests:

- **Location**: For GPS tracking and geofencing
- **Camera**: For AR navigation mode

## 🐛 Troubleshooting

### AR Navigation Not Showing

- Check if camera permission is granted
- Ensure location permission is "While Using App"
- Verify camera hardware is available

### Faculty Card Not Appearing

- Check if coordinates are correct
- Verify geofence radius is appropriate
- Ensure location tracking is active (check green dot on map)

### Inaccurate Bearing/Direction

- This is normal GPS/compass limitation
- Use camera to adjust your phone orientation
- More accurate indoors with calibration

### Arrow Pointing Wrong Direction

- Calibrate device compass by rotating figure-8
- Ensure phone isn't near magnetic objects
- GPS accuracy improves over time

## 🔄 Real-time Updates

- Location updates: Every 10 meters
- Bearing updates: Every new location
- UI refresh: Automatic via `setState()`

## 💾 Future Enhancements

Potential additions:

1. Indoor floor maps
2. WiFi-based indoor positioning
3. BLE beacon support for accuracy
4. Path history tracking
5. Offline map support
6. Voice navigation
7. Speed calculation
8. ETA estimation

## ✨ Key Technologies Used

- **Google Maps Flutter**: Outdoor mapping
- **Camera Package**: AR visualization
- **Geolocator**: GPS tracking
- **Geofencing**: Location boundary detection
- **Bearing Calculations**: Mathematical direction finding

---

**Status**: ✅ Fully Implemented
**Last Updated**: 2026-01-31
**Version**: 1.0.0
