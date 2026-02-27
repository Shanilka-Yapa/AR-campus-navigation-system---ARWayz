# Code Reference & Customization Guide

## File Structure Overview

```
arwayz/
├── lib/
│   ├── ar_display_page.dart      ← AR 3D model viewer (NEW)
│   ├── qr_scanner_page.dart      ← QR code scanner (UPDATED)
│   ├── main.dart                 ← Home page (UPDATED)
│   ├── ar_camera_page.dart       ← Existing AR camera
│   ├── building_areas_page.dart  ← Existing building navigation
│   ├── splash_page.dart          ← Existing splash
│   └── qr_scanner_page.dart      ← Existing QR scanner
├── assets/
│   ├── images/                   ← Logo, backgrounds
│   └── models/                   ← 3D models (GLB files) - NEW FOLDER
└── pubspec.yaml                  ← Dependencies (UPDATED)
```

---

## Key Code Changes

### 1️⃣ pubspec.yaml (Dependencies Added)

```yaml
dependencies:
  # ... existing packages ...
  model_viewer: ^1.12.9 # 3D model viewer with AR
  webview_flutter: ^4.10.0 # WebView for rendering

flutter:
  assets:
    - assets/images/
    - assets/models/ # NEW: 3D model files
```

---

### 2️⃣ main.dart (AR Demo Button Added)

**Import Added:**

```dart
import 'ar_display_page.dart';
```

**Button Code Added:**

```dart
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ARDisplayPage(qrCode: 'AR_DEMO_MODE'),
      ),
    );
  },
  icon: const Icon(Icons.view_in_ar),
  label: const Text('AR Demo'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF1A2D33),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: 40,
      vertical: 14,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
),
```

---

### 3️⃣ qr_scanner_page.dart (AR View Button Added)

**Import Added:**

```dart
import 'ar_display_page.dart';
```

**Button Code Added to QR Results:**

```dart
// View in AR
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ARDisplayPage(
          qrCode: scannedCode,
        ),
      ),
    );
  },
  icon: const Icon(Icons.view_in_ar),
  label: const Text('AR View'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 9, 126, 139),
    foregroundColor: Colors.white,
  ),
),
```

---

### 4️⃣ ar_display_page.dart (NEW FILE)

**Key Components:**

```dart
// Model fallback logic
const String DEMO_MODEL_URL =
  'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

// Check if local model exists
Future<void> _checkModelExists() async {
  try {
    await rootBundle.load('assets/models/university_logo.glb');
    setState(() { _modelExists = true; });
  } catch (e) {
    setState(() { _modelExists = false; });
  }
}

// Model viewer widget
ModelViewer(
  backgroundColor: const Color.fromARGB(255, 20, 20, 20),
  src: src,  // Local file or URL
  alt: 'University Logo',
  ar: true,  // Enable AR mode
  autoPlay: true,  // Play animations
  autoRotate: true,  // Spin effect
  cameraControls: true,  // Touch controls
  disableZoom: false,  // Pinch to zoom
)
```

---

## Customization Examples

### 1. Change Demo Model URL

Edit `ar_display_page.dart` line 21:

```dart
// Use a different 3D model
static const String DEMO_MODEL_URL =
  'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb';
```

### 2. Change Auto-Rotation Speed

Edit `ar_display_page.dart` line 28:

```dart
// Faster rotation (5 seconds per full turn)
_animationController = AnimationController(
  duration: const Duration(seconds: 5),  // Change this
  vsync: this,
)..repeat();
```

### 3. Different AR Colors

Edit `ar_display_page.dart`:

```dart
// Change background color
Container(
  color: Colors.black,  // Change to other color
  child: _buildModelViewer(...)
)

// Change info card colors
Container(
  decoration: BoxDecoration(
    color: Colors.black.withAlpha(200),  // Change alpha/color
    borderRadius: BorderRadius.circular(8),
  ),
)
```

### 4. Map QR Codes to Different Models

Modify `ar_display_page.dart` to detect QR code and load different models:

```dart
String _getModelPath() {
  switch(widget.qrCode) {
    case 'BUILDING_001':
      return 'assets/models/building_001.glb';
    case 'BUILDING_002':
      return 'assets/models/building_002.glb';
    case 'CAMPUS_LOGO':
      return 'assets/models/campus_logo.glb';
    default:
      return 'assets/models/university_logo.glb';
  }
}
```

### 5. Add Model Loading State

Show loading spinner while model loads:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: _modelExists
        ? _buildModelViewer(_modelPath)
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading AR Model...'),
              ],
            ),
          ),
  );
}
```

---

## How to Add More Features

### Feature 1: Add Labels/Hotspots on 3D Model

```dart
// Add text overlay on AR view
Positioned(
  top: 50,
  right: 20,
  child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.orange,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text(
      'Main Building\nBuilt: 1995',
      style: TextStyle(color: Colors.white),
    ),
  ),
)
```

### Feature 2: Capture Screenshot of AR View

```dart
RenderRepaintBoundary repaintBoundary =
    globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

ui.Image image = await repaintBoundary.toImage(pixelRatio: 3.0);
ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
Uint8List pngBytes = byteData!.buffer.asUint8List();

// Save or share
```

### Feature 3: Add Sound Effects

```dart
import 'package:audioplayers/audioplayers.dart';

final audioPlayer = AudioPlayer();

// Play sound when entering AR view
await audioPlayer.play(AssetSource('sounds/ar_activate.mp3'));
```

### Feature 4: Add AR Animations

```dart
// Make model do specific animations
ModelViewer(
  src: modelPath,
  ar: true,
  autoPlay: true,  // Plays default animations
  // Add timeline controls:
  // animationName: 'Idle',  // Specific animation
  // animationDuration: 2000,
)
```

---

## Color Theme Reference

Current colors in your app:

```dart
// Primary teal color
Color(0xFF097e8b)  // RGB(9, 126, 139)
Color.fromARGB(255, 9, 126, 139)

// Dark variant
Color(0xFF1A2D33)

// Use these in AR page for consistency
AppBar: Color.fromARGB(255, 9, 126, 139)
Buttons: Color(0xFF1A2D33) or Color.fromARGB(255, 9, 126, 139)
```

---

## Common Customizations

| Change      | Where                           | How                    |
| ----------- | ------------------------------- | ---------------------- |
| 3D Model    | `ar_display_page.dart` line 23  | Change `src` path      |
| Speed       | `ar_display_page.dart` line 28  | Change Duration        |
| Color       | `ar_display_page.dart` line ~60 | Change backgroundColor |
| QR Display  | `ar_display_page.dart` line ~90 | Modify text display    |
| Button Text | `qr_scanner_page.dart` line ~45 | Change label           |

---

## Debugging Tips

### Check if model loads:

```bash
# Run with verbose logging
flutter run -v

# Look for messages:
# - "Local model found" = your file loaded
# - "Using demo model" = fallback active
```

### Test model file:

```bash
# Check file exists
flutter pub get
ls arwayz/assets/models/university_logo.glb

# Verify it's valid GLB
file university_logo.glb
# Should show: "glb, 3D Model"
```

### Debug AR on device:

```bash
# Only physical devices support AR
# Use: iPhone 6s+ or Android with ARCore

# Connect device
adb devices

# Run app
flutter run -d [device_id]
```

---

## File Size Reference

Keep your 3D models:

- ✅ Under 10MB (recommended)
- ✅ Under 20MB (acceptable)
- ❌ Over 50MB (will cause lag)

---

## Next Development Ideas

1. **Multiple Models** - Different buildings, different QR codes
2. **Model Loading** - Load models from server/cloud
3. **AR Navigation Path** - Show route overlay on AR
4. **Campus Map** - Show 2D map alongside AR
5. **Building Info** - Display info panels in AR
6. **Photo Capture** - Screenshot/video of AR view
7. **Multiplayer** - Share AR view with others
8. **Analytics** - Track which models users view

---

## Support Resources

- **ModelViewer Docs**: https://modelviewer.dev
- **Flutter AR**: https://flutter.dev/docs/development/packages-and-plugins/plugins
- **Blender Tutorials**: https://www.blender.org/support/
- **3D Model Sites**:
  - Sketchfab: https://sketchfab.com
  - TurboSquid: https://www.turbosquid.com
  - CGTrader: https://www.cgtrader.com

---

**Ready to customize your AR feature!** 🚀
