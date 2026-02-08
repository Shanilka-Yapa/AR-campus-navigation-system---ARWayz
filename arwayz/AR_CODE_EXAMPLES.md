# 💡 AR Navigation Code Examples & Snippets

## Quick Copy-Paste Examples

### 1. Add a New Campus Location

**File**: [lib/models/location_model.dart](lib/models/location_model.dart)

```dart
// Add this to the campusLocations map:
'sports_center': LocationModel(
  id: 'sports_center',
  name: 'Sports Center',
  description: 'Athletic Facilities & Gymnasium',
  coordinates: const LatLng(6.0810, 80.1900),  // Your coordinates
  radius: 150,  // Geofence radius in meters
  isIndoor: false,  // Indoor or outdoor
),
```

### 2. Update Library Coordinates

Find and replace in [lib/models/location_model.dart](lib/models/location_model.dart):

```dart
// BEFORE:
'library': LocationModel(
  id: 'library',
  name: 'University Library',
  description: 'Main Library Building',
  coordinates: const LatLng(6.0785, 80.1925),  // ← Default
  radius: 150,
  isIndoor: true,
),

// AFTER (replace with actual coordinates):
'library': LocationModel(
  id: 'library',
  name: 'University Library',
  description: 'Main Library Building',
  coordinates: const LatLng(6.079456, 80.192345),  // ← Actual coordinates
  radius: 150,
  isIndoor: true,
),
```

### 3. Change Geofence Radius for Faculty

```dart
// Original (200m):
radius: 200,

// More sensitive (100m):
radius: 100,

// Less sensitive (300m):
radius: 300,

// Very relaxed (500m):
radius: 500,
```

### 4. Enable Debug Mode

Add this to [lib/helpers/ar_navigation_helper.dart](lib/helpers/ar_navigation_helper.dart):

```dart
class ARNavigationHelper {
  static const bool DEBUG = true;  // Set to true for debugging

  static double calculateBearing(LatLng from, LatLng to) {
    final bearing = /* ... calculation ... */;
    
    if (DEBUG) {
      debugPrint('Bearing from $from to $to: $bearing°');
    }
    return bearing;
  }

  static double calculateDistance(LatLng from, LatLng to) {
    final distance = /* ... calculation ... */;
    
    if (DEBUG) {
      debugPrint('Distance: ${distance.toStringAsFixed(1)}m');
    }
    return distance;
  }
}
```

### 5. Adjust Location Update Frequency

**File**: [lib/outdoor_navigation_page.dart](lib/outdoor_navigation_page.dart)

```dart
// Current (every 10 meters):
_positionStreamSubscription = Geolocator.getPositionStream(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,  // ← Change this value
  ),
).listen(/* ... */);

// More frequent (every 5 meters):
distanceFilter: 5,

// Less frequent (every 20 meters):
distanceFilter: 20,

// More accurate (best):
accuracy: LocationAccuracy.best,

// Less battery drain (medium):
accuracy: LocationAccuracy.medium,
```

---

## 🔧 Common Modifications

### Change Faculty Card Button Text

**File**: [lib/widgets/faculty_location_card.dart](lib/widgets/faculty_location_card.dart)

```dart
// Current buttons:
Expanded(
  child: ElevatedButton.icon(
    onPressed: onNavigatePressed,
    icon: const Icon(Icons.directions),
    label: const Text('Directions'),  // ← Change this
    // ...
  ),
),

// Example modifications:
label: const Text('Navigate'),
label: const Text('Map View'),
label: const Text('Google Maps'),
```

### Change AR Camera Colors

**File**: [lib/pages/ar_camera_navigation_page.dart](lib/pages/ar_camera_navigation_page.dart)

```dart
// Navigation arrow circle color:
// Current (blue):
color: Colors.blue.withOpacity(0.3),
border: Border.all(color: Colors.blue, width: 2),

// Alternative (green):
color: Colors.green.withOpacity(0.3),
border: Border.all(color: Colors.green, width: 2),

// Alternative (orange):
color: Colors.orange.withOpacity(0.3),
border: Border.all(color: Colors.orange, width: 2),

// Arrow color:
// Current (cyan):
Icon(Icons.arrow_upward, size: 60, color: Colors.cyan),

// Alternative (white):
Icon(Icons.arrow_upward, size: 60, color: Colors.white),

// Alternative (green):
Icon(Icons.arrow_upward, size: 60, color: Colors.green),
```

### Customize Faculty Card Colors

**File**: [lib/widgets/faculty_location_card.dart](lib/widgets/faculty_location_card.dart)

```dart
// Current gradient (blue):
gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.blue.withOpacity(0.8),        // ← Top color
    Colors.blueAccent.withOpacity(0.6),  // ← Bottom color
  ],
),

// Alternative gradient (purple):
colors: [
  Colors.purple.withOpacity(0.8),
  Colors.purpleAccent.withOpacity(0.6),
],

// Alternative gradient (teal):
colors: [
  Colors.teal.withOpacity(0.8),
  Colors.tealAccent.withOpacity(0.6),
],

// Alternative gradient (green):
colors: [
  Colors.green.withOpacity(0.8),
  Colors.greenAccent.withOpacity(0.6),
],
```

---

## 📍 How to Find Coordinates

### Using Google Maps
1. Go to maps.google.com
2. Right-click on location
3. Copy the latitude, longitude shown
4. Format: `LatLng(6.0785, 80.1925)`

### Using Plus Codes
Plus Code: **·35HR+QJ9**
- Look up using Google Maps
- Convert to coordinates
- Use in LatLng format

### GPS Coordinates Format
```dart
// Standard format (Decimal Degrees):
LatLng(latitude, longitude)
// Example:
LatLng(6.0793684, 80.1919646)

// Negative for South/West:
LatLng(-34.052234, -118.243685)  // Los Angeles

// Positive for North/East:
LatLng(40.712776, -74.005974)    // New York
```

---

## 🔍 Testing Code Snippets

### Print Current Location
Add to [lib/outdoor_navigation_page.dart](lib/outdoor_navigation_page.dart):

```dart
void _debugPrintLocation() {
  if (_currentLocation != null) {
    debugPrint('Current Location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}');
    debugPrint('Current Faculty: ${_currentFaculty?.name}');
    
    if (_currentFaculty != null) {
      final distance = _currentFaculty!.distanceTo(_currentLocation!);
      debugPrint('Distance to center: $distance meters');
    }
  }
}

// Call in initState or onMapCreated:
_debugPrintLocation();
```

### Calculate Distance to Any Location
```dart
void calculateDistanceTo(LatLng targetLocation) {
  if (_currentLocation != null) {
    final distance = ARNavigationHelper.calculateDistance(
      _currentLocation!,
      targetLocation,
    );
    debugPrint('Distance to target: ${distance.toStringAsFixed(1)} meters');
  }
}
```

### Get Bearing to Any Location
```dart
void getBearingTo(LatLng targetLocation) {
  if (_currentLocation != null) {
    final bearing = ARNavigationHelper.calculateBearing(
      _currentLocation!,
      targetLocation,
    );
    final direction = ARNavigationHelper.getDirectionText(bearing);
    debugPrint('Bearing: $bearing°, Direction: $direction');
  }
}
```

---

## 🎨 UI Customization Examples

### Change AR View Text Color
**File**: [lib/pages/ar_camera_navigation_page.dart](lib/pages/ar_camera_navigation_page.dart)

```dart
// Navigation title color (white):
Text(
  'Navigate to ${widget.targetLocation.name}',
  style: const TextStyle(
    color: Colors.white,  // ← Change this
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

// Direction text color (white):
Text(
  ARNavigationHelper.getDirectionText(_bearingToTarget),
  style: const TextStyle(
    color: Colors.white,  // ← Change this
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),
```

### Change Button Colors
```dart
// AR Navigation button (orange):
FloatingActionButton(
  onPressed: () => _openARNavigation(campusLocations['faculty_engineering']!),
  backgroundColor: Colors.orange,  // ← Change this
  child: const Icon(Icons.camera_alt),
),

// Alternative colors:
backgroundColor: Colors.red,
backgroundColor: Colors.purple,
backgroundColor: Colors.teal,
backgroundColor: const Color(0xFF1A2D33),  // Custom color
```

---

## 📊 Location Reference Template

Use this template to add locations:

```dart
'location_id': LocationModel(
  id: 'location_id',                    // Unique identifier
  name: 'Location Name',                // Display name
  description: 'Location Description',  // Details
  coordinates: const LatLng(
    6.079368,   // Latitude (North/South: -90 to 90)
    80.191965,  // Longitude (East/West: -180 to 180)
  ),
  radius: 200,        // Geofence radius in meters (50-500 typical)
  isIndoor: true,     // Indoor location? (affects display)
),
```

### Example Locations to Add:

```dart
// Hostel
'hostel': LocationModel(
  id: 'hostel',
  name: 'Student Hostel',
  description: 'On-campus Student Accommodation',
  coordinates: const LatLng(6.0775, 80.1935),
  radius: 150,
  isIndoor: true,
),

// Parking lot
'parking': LocationModel(
  id: 'parking',
  name: 'Main Parking',
  description: 'Vehicle Parking Area',
  coordinates: const LatLng(6.0805, 80.1910),
  radius: 200,
  isIndoor: false,
),

// Medical center
'medical': LocationModel(
  id: 'medical',
  name: 'Medical Center',
  description: 'Campus Health Clinic',
  coordinates: const LatLng(6.0780, 80.1920),
  radius: 100,
  isIndoor: true,
),
```

---

## 🚀 Advanced Customizations

### Custom Geofence Shape (Advanced)
If you want complex shapes instead of circles:

```dart
// Current: Simple circle
bool isWithinGeofence(LatLng userLocation) {
  return distanceTo(userLocation) <= radius;
}

// Advanced: Polygon (requires additional logic)
bool isWithinPolygon(LatLng point, List<LatLng> polygon) {
  // Ray casting algorithm
  // More complex but supports any shape
}
```

### Custom Distance Units
```dart
// Current: Meters
double getDistanceInMeters() => _distance;

// Kilometers:
double getDistanceInKm() => _distance / 1000;

// Miles:
double getDistanceInMiles() => _distance / 1609.34;

// Display:
Text('${getDistanceInMeters().toStringAsFixed(0)}m')
```

### Custom Direction Format
```dart
// Current: Cardinal (N, NE, E, etc.)
String getDirectionText(double bearing) {
  // 8-point compass
}

// Alternative: 16-point compass
String get16PointDirection(double bearing) {
  if (bearing < 11.25) return 'N';
  if (bearing < 33.75) return 'NNE';
  // ... more options
  return 'NNW';
}
```

---

## ✅ Verification Checklist

After making changes, verify:

```
□ Code compiles without errors
□ App runs on device
□ Location permission granted
□ Camera permission granted
□ Blue dot appears on map
□ Location updates as you move
□ Geofence triggers correctly
□ Faculty card appears when inside
□ AR camera opens without crash
□ Arrow displays in AR view
□ Distance updates in real-time
□ Buttons respond to taps
□ No memory leaks (check logs)
□ Performance is smooth (60 FPS)
```

---

## 🔗 Useful Links & Resources

### Documentation
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- [Camera Plugin](https://pub.dev/packages/camera)
- [Geolocator](https://pub.dev/packages/geolocator)
- [Dart Math Library](https://api.dart.dev/stable/dart-math/dart-math-library.html)

### Coordinate Tools
- [Google Maps](https://maps.google.com)
- [Plus Codes](https://plus.codes)
- [GeoLocation](https://www.latlong.net)

### Learning Resources
- [Haversine Formula](https://en.wikipedia.org/wiki/Haversine_formula)
- [Bearing Calculation](https://www.movable-type.co.uk/scripts/latlong.html)
- [GPS Accuracy](https://en.wikipedia.org/wiki/Dilution_of_precision)

---

## 📞 Quick Help

| Problem | Solution |
|---------|----------|
| "Can't find location_model" | Check import: `import 'models/location_model.dart';` |
| "Can't find ar_navigation_helper" | Check import: `import 'helpers/ar_navigation_helper.dart';` |
| Coordinates not working | Verify format: `LatLng(latitude, longitude)` |
| Geofence too small | Increase radius: `radius: 300,` |
| Geofence too large | Decrease radius: `radius: 100,` |

---

**Happy Coding! 🎉**

For more details, see:
- [AR_FEATURES_GUIDE.md](AR_FEATURES_GUIDE.md)
- [AR_IMPLEMENTATION_SUMMARY.md](AR_IMPLEMENTATION_SUMMARY.md)
- [QUICK_START_AR.md](QUICK_START_AR.md)
