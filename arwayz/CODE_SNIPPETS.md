# Code Snippets - Google Maps Integration

## 1. API Key Configuration

### AndroidManifest.xml

```xml
<application
    android:label="arwayz"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">

    <!-- Add this inside <application> tag -->
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY_HERE"/>

    <activity ...>
        ...
    </activity>
</application>
```

### Info.plist (iOS)

```xml
<dict>
    ...
    <key>io.flutter.embedded_views_preview</key>
    <true/>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs your location to show directions</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>This app needs your location to show directions</string>
    <key>google_maps_ios_api_key</key>
    <string>YOUR_API_KEY_HERE</string>
</dict>
```

---

## 2. Core Functions Explained

### Get Current Location

```dart
Future<void> _getCurrentLocation() async {
  // Request permission if not granted
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // Get high-accuracy position
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );

  setState(() {
    _currentLocation = LatLng(position.latitude, position.longitude);
  });
}
```

### Open Google Maps with Directions

```dart
void _openGoogleMapsNavigation() async {
  final String googleMapsUrl =
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${_currentLocation?.latitude},${_currentLocation?.longitude}'
      '&destination=${DESTINATION.latitude},${DESTINATION.longitude}'
      '&travelmode=walking';

  if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
    await launchUrl(
      Uri.parse(googleMapsUrl),
      mode: LaunchMode.externalApplication,
    );
  }
}
```

### Add Markers to Map

```dart
void _addMarkers() {
  Set<Marker> newMarkers = {
    // Current location - Blue marker
    if (_currentLocation != null)
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation!,
        infoWindow: const InfoWindow(
          title: 'Your Current Location',
          snippet: 'You are here',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      ),
    // Destination - Red marker
    Marker(
      markerId: const MarkerId('destination'),
      position: DESTINATION,
      infoWindow: const InfoWindow(
        title: 'University of Ruhuna',
        snippet: 'Faculty of Engineering',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
    ),
  };
  setState(() {
    markers = newMarkers;
  });
}
```

### Animate Camera to Show Both Locations

```dart
void _animateToDestination() {
  mapController.animateCamera(
    CameraUpdateOptions(
      bounds: _calculateBounds(),
      padding: const EdgeInsets.all(100),
    ),
  );
}

CameraUpdateOptions _calculateBounds() {
  double minLat = _currentLocation?.latitude ?? DESTINATION.latitude;
  double maxLat = DESTINATION.latitude;
  double minLng = _currentLocation?.longitude ?? DESTINATION.longitude;
  double maxLng = DESTINATION.longitude;

  if (_currentLocation != null) {
    minLat = minLat > maxLat ? maxLat : minLat;
    maxLat = maxLat < minLat ? minLat : maxLat;
    minLng = minLng > maxLng ? maxLng : minLng;
    maxLng = maxLng < minLng ? minLng : maxLng;
  }

  return CameraUpdateOptions(
    bounds: LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    ),
    padding: const EdgeInsets.all(100),
  );
}
```

---

## 3. UI Components

### Get Directions Button

```dart
ElevatedButton.icon(
  onPressed: _openGoogleMapsNavigation,
  icon: const Icon(Icons.directions),
  label: const Text('Get Directions'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF1A2D33),
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)
```

### Navigation Button (for main.dart)

```dart
FloatingActionButton(
  backgroundColor: const Color(0xFF1A2D33),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OutdoorNavigationPage(),
      ),
    );
  },
  child: const Icon(Icons.navigation, color: Colors.white),
  tooltip: 'Navigate to University',
)
```

### Map Container

```dart
GoogleMap(
  onMapCreated: (GoogleMapController controller) {
    mapController = controller;
    _animateToDestination();
  },
  initialCameraPosition: CameraPosition(
    target: _currentLocation ?? DESTINATION,
    zoom: 14.0,
  ),
  markers: markers,
  polylines: polylines,
  myLocationEnabled: true,
  myLocationButtonEnabled: false,
  zoomControlsEnabled: false,
  mapToolbarEnabled: false,
)
```

---

## 4. Different Travel Modes for Google Maps URL

### Walking

```dart
'&travelmode=walking'
```

### Driving

```dart
'&travelmode=driving'
```

### Bicycling

```dart
'&travelmode=bicycling'
```

### Transit (Public Transport)

```dart
'&travelmode=transit'
```

---

## 5. Error Handling Template

```dart
try {
  // Your Google Maps code here
} on PlatformException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${e.message}')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('An error occurred')),
  );
}
```

---

## 6. Permission Handling

### Check Permission Status

```dart
LocationPermission permission = await Geolocator.checkPermission();

if (permission == LocationPermission.denied) {
  // Not yet requested
  permission = await Geolocator.requestPermission();
} else if (permission == LocationPermission.deniedForever) {
  // User permanently denied
  Geolocator.openLocationSettings();
} else if (permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always) {
  // Permission granted
}
```

---

## 7. Testing Different Locations

### Emulator Location Simulation

```dart
// In AndroidStudio, set emulator location:
// Extended controls → Location → Set custom location
// Latitude: 6.9271
// Longitude: 80.7789
```

### Real Device Testing

```bash
# Build and deploy to real device
flutter run --device-id <device-id>

# Grant location permission when app prompts
# Use real GPS data from device location
```

---

## 8. Pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Google Maps
  google_maps_flutter: ^2.5.0

  # Location services
  geolocator: ^11.0.0

  # URL launching
  url_launcher: ^6.2.1
```

---

## 9. Constants You Might Need

```dart
// University of Ruhuna, Faculty of Engineering
static const LatLng DESTINATION = LatLng(6.9271, 80.7789);

// Zoom levels
const double INITIAL_ZOOM = 14.0;
const double DETAILED_ZOOM = 15.0;
const double OVERVIEW_ZOOM = 12.0;

// Colors
const Color PRIMARY_COLOR = Color(0xFF1A2D33);
const Color LOCATION_BLUE = Colors.blue;
const Color DESTINATION_RED = Colors.red;
```

---

## 10. Common Issues & Solutions

### Issue: "Unknown host exception"

```dart
// Solution: Check internet connection
// Ensure device/emulator has internet access
```

### Issue: "API Key not found"

```dart
// Solution: Check AndroidManifest.xml and Info.plist
// Verify API key is added in correct location
// Check for typos in API key
```

### Issue: "Location permission denied"

```dart
// Solution: In code - request permission
permission = await Geolocator.requestPermission();

// On device - grant permission in Settings
```

### Issue: "Failed to find GoogleMaps"

```dart
// Solution: Run flutter pub get
flutter pub get

// Clean build
flutter clean
flutter pub get
flutter run
```
