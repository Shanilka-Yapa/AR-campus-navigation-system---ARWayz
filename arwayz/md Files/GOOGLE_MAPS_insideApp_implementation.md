
---

# Google Maps In-App Integration Guide
---

## Overview

This guide explains how Google Maps was successfully integrated directly inside the ARWayz mobile application using a Google Maps API Key.

Instead of opening external Google Maps, the map is embedded inside the app using the `google_maps_flutter` package.

---

## Step-by-Step Implementation

---

### ✅ Step 1: Dependencies Added

Add this to `pubspec.yaml`:

```yaml
dependencies:
  google_maps_flutter: ^2.5.0
  geolocator: ^11.0.0
```
Then run:
```bash
flutter pub get
```
### ✅ Step 2: Google Cloud Setup


1. **Go to Google Cloud Console**
    - Visit: https://console.cloud.google.com/

2. **Create/Select a Project**
    - Click "Select a Project" → "New Project"
    - Enter project name (e.g., "ARWayz Navigation")

3. **Enable Required APIs**
    - In the search bar, type "Maps SDK for Android"
    - Click on it and press "Enable"
    - Do the same for "Maps SDK for iOS"
    - Enable "Directions API" and "Distance Matrix API"

4. **Create API Key**
    - Go to "Credentials" → "Create Credentials" → "API Key"
    - Copy your API Key
    - Click "Edit API Key" and restrict it to:
        - Android apps (add your SHA-1 fingerprint)
        - iOS apps

5. **Restrict API Key**
    - Restrict to Android apps (add SHA-1 fingerprint)
    - Restrict to iOS apps 
    - Restrict APIs to only Maps SDK

---

### ✅ Step 3: Get Android SHA-1

Inside in the project:
```bash
cd android
./gradlew signingReport
```
Copy the SHA-1 fingerprint and add it inside Google Cloud API key restrictions.

### ✅ Step 4: Add API Key to Android

Open:
```code
android/app/src/main/AndroidManifest.xml
```

Inside <application> tag, add:

```xml
<meta-data
android:name="com.google.android.geo.API_KEY"
android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

### ✅ Step 5: Add Permissions (Android)

Inside AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
```
### ✅ Step 6: Create Map Page

File: `google_map_page.dart` :

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;

  final LatLng _destination = const LatLng(6.0793684, 80.1919646); // FoE UoR
  final TextEditingController _searchController = TextEditingController();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final String googleApiKey = "YOUR_REAL_GOOGLE_MAPS_API_KEY";

  final List<Map<String, dynamic>> campusPlaces = [
    {'name': 'FoE UoR', 'lat': 6.0793684, 'lng': 80.1919646},
    {'name': 'Library', 'lat': 6.0805, 'lng': 80.1928},
    {'name': 'Canteen', 'lat': 6.0789, 'lng': 80.1905},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // 📍 GET CURRENT LOCATION
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId("current"),
            position: _currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
        _markers.add(
          Marker(
            markerId: const MarkerId("destination"),
            position: _destination,
          ),
        );
      });

      await _fetchRoute();
    }
  }

  // 🧭 FETCH REAL ROUTE
  Future<void> _fetchRoute() async {
    if (_currentLocation == null) return;

    final url =
        "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=${_currentLocation!.latitude},${_currentLocation!.longitude}"
        "&destination=${_destination.latitude},${_destination.longitude}"
        "&mode=walking"
        "&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['routes'].isNotEmpty) {
      final points = data['routes'][0]['overview_polyline']['points'];
      final decodedPoints = _decodePolyline(points);

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue.shade400,
            width: 6,
            points: decodedPoints,
          ),
        );
      });
    }
  }

  // 🔓 POLYLINE DECODER
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  // 🔍 SEARCH PLACE
  Future<void> _searchPlace(String query) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json"
        "?address=$query&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['results'].isNotEmpty) {
      final loc = data['results'][0]['geometry']['location'];
      final LatLng pos = LatLng(loc['lat'], loc['lng']);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(pos, 17),
      );
    }
  }

  // 📏 NEAREST 2 LOCATIONS
  List<Map<String, dynamic>> getNearestPlaces() {
    if (_currentLocation == null) return [];

    for (var place in campusPlaces) {
      place['distance'] = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        place['lat'],
        place['lng'],
      );
    }

    campusPlaces.sort((a, b) => a['distance'].compareTo(b['distance']));
    return campusPlaces.take(2).toList();
  }

  void _centerToDestination() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_destination, 17),
    );
  }

  void _centerToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 17),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nearestPlaces = getNearestPlaces();

    return Scaffold(
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // 🗺️ MAP
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation!,
              zoom: 16,
            ),
            myLocationEnabled: true,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          // 🔙 BACK BUTTON
          Positioned(
            top: 45,
            left: 16,
            child: FloatingActionButton(
              heroTag: "back",
              mini: true,
              backgroundColor: const Color(0xFF1A2D33),
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),

          // 🔍 SEARCH BAR
          Positioned(
            top: 45,
            left: 60,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: _searchPlace,
                decoration: const InputDecoration(
                  hintText: "Where are you going?",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),

          // 🪪 NEAREST CARDS
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: nearestPlaces.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _placeCard(
                      p['name'],
                      "${p['distance'].toStringAsFixed(0)} m",
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 🧭 NAV BUTTONS
          Positioned(
            bottom: 30,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "dest",
                  backgroundColor: const Color(0xFF1A2D33),
                  onPressed: _centerToDestination,
                  child: const Icon(Icons.navigation,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "curr",
                  backgroundColor: const Color(0xFF1A2D33),
                  onPressed: _centerToCurrentLocation,
                  child:
                  const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeCard(String name, String distance) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            distance,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
```

----
## Future Improvements
---
1. Search Bar Integration
2. Real-Time Nearest Locations Detection

---
