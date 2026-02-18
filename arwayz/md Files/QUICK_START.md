# Quick Setup Checklist - Google Maps Navigation

## 📱 What's Been Created

### New Files:

1. **`outdoor_navigation_page.dart`** - Complete map interface with:
   - Google Maps display
   - Current location tracking
   - University destination marker
   - "Get Directions" button that opens Google Maps

2. **`GOOGLE_MAPS_SETUP.md`** - Full setup guide

### Modified Files:

1. **`pubspec.yaml`** - Added dependencies:
   - google_maps_flutter
   - geolocator
2. **`main.dart`** - Added navigation button with compass icon

3. **`AndroidManifest.xml`** - Added location permissions

---

## ⚡ Quick Start (4 Steps)

### Step 1️⃣: Install Dependencies

```bash
cd arwayz
flutter pub get
```

### Step 2️⃣: Get Google Maps API Key

1. Go to: https://console.cloud.google.com/
2. Create new project
3. Search for "Maps SDK for Android" → Enable
4. Search for "Maps SDK for iOS" → Enable
5. Go to Credentials → Create API Key
6. Copy your API Key

### Step 3️⃣: Add API Key

**For Android** - Add to `android/app/src/main/AndroidManifest.xml` inside `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**For iOS** - Add to `ios/Runner/Info.plist`:

```xml
<key>google_maps_ios_api_key</key>
<string>YOUR_API_KEY_HERE</string>
<key>io.flutter.embedded_views_preview</key>
<true/>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to show directions</string>
```

### Step 4️⃣: Update University Coordinates

Edit `lib/outdoor_navigation_page.dart` line 16:

```dart
// Find the exact coordinates of Faculty of Engineering
static const LatLng DESTINATION = LatLng(6.9271, 80.7789); // CHANGE THIS
```

**How to find coordinates:**

- Open Google Maps
- Right-click on Faculty of Engineering location
- Click on the coordinates that appear
- They'll be copied automatically
- Paste into the code above

---

## 🎯 How It Works

### When User Clicks Navigation Button:

```
1. App requests location permission
2. Shows Google Map with 2 markers:
   - Blue pin = User's current location
   - Red pin = University of Ruhuna
3. User clicks "Get Directions"
4. Opens Google Maps showing:
   - Shortest walking route
   - Distance & time to arrive
   - Turn-by-turn navigation
   - Multiple route options
```

---

## 📸 UI Layout

The navigation page shows:

```
┌─────────────────────────────┐
│    Google Map Display       │
│  (Blue pin = You)           │
│  (Red pin = University)     │
│                             │
│     [Map with Route]        │
│                             │
│  ┌─────────────────────┐   │
│  │ University Location │   │
│  │ [Get Directions BTN]│   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

---

## 🧪 Testing on Device

### Android:

```bash
flutter run
```

- Grant location permission when prompted
- See current location blue marker
- Click "Get Directions"
- Google Maps should open

### iOS:

- May need to build and run in Xcode
- Grant location permission when prompted
- Same testing steps as Android

---

## 🔧 Troubleshooting

### Map doesn't show?

- ❌ Check: Did you add API key?
- ❌ Check: Did you enable Maps APIs?
- ❌ Check: Is internet connection active?

### Location not showing?

- ❌ Check: Is permission granted?
- ❌ Check: Device has GPS enabled?
- ❌ Check: Emulator configured for location?

### Google Maps won't open?

- ❌ Check: Google Maps app installed?
- ❌ Check: Internet connection?

---

## 🎨 Customization Options

### Change Map Style:

```dart
// In outdoor_navigation_page.dart
GoogleMap(
  mapType: MapType.satellite, // or .terrain, .normal
)
```

### Change Button Colors:

```dart
ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF1A2D33), // Change color
)
```

### Add More Waypoints:

```dart
// In _addMarkers() method
Marker(
  markerId: const MarkerId('waypoint_1'),
  position: LatLng(6.93, 80.77),
  infoWindow: const InfoWindow(title: 'Library'),
)
```

---

## ✅ Verification Checklist

After completing setup:

- [ ] `flutter pub get` runs successfully
- [ ] API key obtained from Google Cloud Console
- [ ] API key added to AndroidManifest.xml
- [ ] API key added to Info.plist (iOS)
- [ ] University coordinates updated
- [ ] `flutter run` builds without errors
- [ ] App shows Google Map with markers
- [ ] Location permission popup appears
- [ ] "Get Directions" opens Google Maps
- [ ] Routes display correctly in Google Maps

---

## 📞 Still Stuck?

Check these files for examples:

- `GOOGLE_MAPS_SETUP.md` - Detailed step-by-step guide
- `outdoor_navigation_page.dart` - Complete implementation
- `main.dart` - How to integrate the button

---

## 🚀 Next Features to Add (Optional)

1. **Walking time calculation** - Show ETA on map
2. **Multiple routes** - Display 3 best routes
3. **Offline maps** - Cache map data
4. **Route waypoints** - Add intermediate stops
5. **Weather info** - Show weather along route
