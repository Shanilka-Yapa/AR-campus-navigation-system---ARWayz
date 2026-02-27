# Google Maps Outdoor Navigation Implementation Guide

## Overview

This guide will help you implement outdoor navigation using Google Maps API for the ARWayz app. Users can find directions from their current location to the University of Ruhuna, Faculty of Engineering.

---

## Step-by-Step Implementation

### ✅ Step 1: Dependencies Added

The following packages have been added to `pubspec.yaml`:

- **google_maps_flutter**: ^2.5.0 - For displaying interactive maps
- **geolocator**: ^11.0.0 - For getting user's current location
- **url_launcher**: ^6.2.1 - Already added, used for opening Google Maps

Run this command:

```bash
flutter pub get
```

---

### ✅ Step 2: Permissions Configured

Location permissions have been added to `AndroidManifest.xml`:

- `ACCESS_FINE_LOCATION` - High accuracy location
- `ACCESS_COARSE_LOCATION` - Network-based location
- `INTERNET` - For map API calls

---

### 📋 Step 3: Get Google Maps API Key

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

5. **Get Your Android SHA-1 Fingerprint**
   ```bash
   cd android
   ./gradlew signingReport
   ```

   - Copy the SHA1 fingerprint from output

---

### 📋 Step 4: Add API Key to Android

Edit `android/app/build.gradle.kts` and add this in the `<application>` tag of `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

---

### 📋 Step 5: Add API Key to iOS

Edit `ios/Runner/Info.plist` and add:

```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to show directions</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs your location to show directions</string>
<key>google_maps_ios_api_key</key>
<string>YOUR_GOOGLE_MAPS_API_KEY_HERE</string>
```

---

### ✅ Step 6: OutdoorNavigationPage Created

A new file `outdoor_navigation_page.dart` has been created with:

- **Google Map Display**: Shows current location and destination
- **Current Location Tracking**: Uses geolocator to get user's position
- **Get Directions Button**: Opens Google Maps with route information
- **Map Controls**: Center map and refresh location buttons
- **Location Markers**: Blue for current, red for destination

#### Key Features:

```dart
// University of Ruhuna coordinates (UPDATE THESE)
static const LatLng DESTINATION = LatLng(6.9271, 80.7789);

// Open Google Maps with directions
void _openGoogleMapsNavigation() async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=...'
    await launchUrl(Uri.parse(googleMapsUrl));
}
```

---

### 📋 Step 7: Update University Coordinates

Update the exact coordinates in `outdoor_navigation_page.dart`:

```dart
// Replace with actual Faculty of Engineering coordinates
static const LatLng DESTINATION = LatLng(6.9271, 80.7789);
```

**Find correct coordinates:**

- Use Google Maps: Right-click location → Copy coordinates
- Or search for "Faculty of Engineering, University of Ruhuna"

---

### 📋 Step 8: Add Button to Main Navigation

Edit `main.dart` or the appropriate navigation file to add the outdoor navigation button:

```dart
// Add to your main page
ElevatedButton(
    onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const OutdoorNavigationPage(),
            ),
        );
    },
    child: const Text('Find Location Outdoors'),
)
```

Or in your `building_areas_page.dart`, add this button to the header area:

```dart
// In your AppBar or top section
Positioned(
    top: 40,
    right: 16,
    child: GestureDetector(
        onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OutdoorNavigationPage(),
                ),
            );
        },
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.navigation, color: Colors.black),
        ),
    ),
)
```

---

## What Happens When User Clicks Button

1. **Map Loads** → Shows current location and university destination
2. **Shows Markers** → Blue pin = you, Red pin = destination
3. **"Get Directions" Button** → Opens Google Maps with:
   - Shortest route highlighted
   - Walking time/distance
   - Turn-by-turn directions
   - Multiple route options

---

## Testing Checklist

- [ ] Run `flutter pub get` successfully
- [ ] Add Google Maps API Key
- [ ] Permissions granted when app runs
- [ ] Map displays without errors
- [ ] Current location shows (blue marker)
- [ ] University location shows (red marker)
- [ ] "Get Directions" button opens Google Maps
- [ ] Routes and directions display in Google Maps

---

## Troubleshooting

### Map not loading

- Check Google Maps API Key is added correctly
- Verify APIs are enabled in Google Cloud Console
- Check internet connectivity

### Location not showing

- Grant location permission when prompted
- Check `location_accuracy.dart` for permission handling
- Ensure device has GPS enabled

### Opening Google Maps fails

- Check internet connection
- Verify Google Maps app is installed
- Check `url_launcher` configuration

---

## Next Steps

1. ✅ Install dependencies (`flutter pub get`)
2. ✅ Get Google Maps API Key
3. ✅ Add API Key to Android & iOS configurations
4. ✅ Add outdoor navigation button to your UI
5. ✅ Test the feature on Android/iOS device
6. Optional: Add walking time calculation
7. Optional: Add multiple route options display
