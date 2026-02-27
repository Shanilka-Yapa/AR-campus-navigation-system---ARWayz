# AR Display Setup Guide - ARWayz

## What We Added

1. **AR Display Page** (`ar_display_page.dart`) - Displays 3D models with AR capabilities
2. **AR Demo Button** - Quick access to AR view from home screen
3. **QR Code to AR View** - Scan QR code and view in AR
4. **Dependencies** - Added `model_viewer` and `webview_flutter` for 3D model support

## Getting Your 3D Model

You need a 3D model of your university logo in **GLB** or **GLTF** format.

### Option 1: Use an Existing 3D Model

1. Search for pre-made 3D university logos on:
   - [Sketchfab.com](https://sketchfab.com) (filter by GLB format)
   - [TurboSquid](https://www.turbosquid.com)
   - [CGTrader](https://www.cgtrader.com)

### Option 2: Convert Your Logo to 3D

1. **From 2D Logo:**
   - Use Blender (free) to extrude your 2D logo
   - Or use online converters like [convertio.co](https://convertio.co)
   - Export as GLB format

2. **Using Blender (Recommended):**
   - Download [Blender](https://www.blender.org) (free)
   - Import your logo image
   - Create a simple 3D shape
   - Export → Glcore Binary (.glb)

### Option 3: Use a Default Cube (Temporary)

If you need to test quickly, I'll create a simple cube model:

```bash
# Run this command in the arwayz directory
flutter pub get
```

Then create a simple fallback model in the code.

## Setup Instructions

### Step 1: Add Your 3D Model File

1. Create folder: `arwayz/assets/models/`
2. Place your 3D model file: `university_logo.glb`

Your file structure should look like:

```
arwayz/
├── assets/
│   ├── images/
│   └── models/
│       └── university_logo.glb  ← Your 3D model here
├── lib/
│   ├── ar_display_page.dart     ← NEW
│   ├── main.dart                ← UPDATED
│   ├── qr_scanner_page.dart     ← UPDATED
│   └── ...
└── pubspec.yaml                 ← UPDATED
```

### Step 2: Update pubspec.yaml Assets

Update the assets section in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/models/ # Add this line
```

### Step 3: Run the App

```bash
cd arwayz
flutter pub get
flutter run
```

## Features Implemented

### 1. **AR Demo Button** (Home Page)

- Click "AR Demo" to see the spinning 3D model
- No QR code needed - instant AR preview

### 2. **Scan & View in AR** (QR Scanner)

- Scan a QR code
- Click "AR View" button
- See the 3D model in AR mode
- Use pinch to zoom, drag to rotate

### 3. **AR View Controls**

- **Tap & Drag**: Rotate the model
- **Pinch**: Zoom in/out
- **Auto Rotate**: Model spins automatically
- **AR Mode**: View on real-world surfaces (if device supports)

## Model Viewer Widget Features

The `ModelViewer` widget supports:

- ✅ Auto-rotate (spinning effect)
- ✅ AR viewing (on supported devices)
- ✅ Camera controls (pinch, drag)
- ✅ Customizable background
- ✅ Full 3D interaction

## Testing Without a Model

If you don't have a model yet, edit `ar_display_page.dart` and change:

```dart
src: 'assets/models/university_logo.glb',
```

To use a public 3D model URL:

```dart
src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
```

## Common Issues & Solutions

### Issue: "Model file not found"

**Solution:**

1. Check file path is correct: `assets/models/university_logo.glb`
2. Update `pubspec.yaml` assets section
3. Run `flutter pub get`

### Issue: "AR not working on iOS/Android"

**Solution:**

- AR requires physical device (not emulator)
- iOS: XCode build needed
- Android: Native build required
- Check camera permissions in manifest files

### Issue: "Model doesn't spin"

**Solution:**

- Ensure `autoRotate: true` in model viewer
- Check model file is valid GLB
- Model might be too large, try scaling in Blender

## Next Steps for Production

1. **Get Professional 3D Model**
   - Hire 3D designer (Fiverr, Upwork)
   - Cost: $100-500 depending on complexity

2. **Optimize Model**
   - Keep under 10MB
   - Use compressed LOD (Level of Detail)
   - Target 30 FPS on mobile devices

3. **Add More Campus Locations**
   - Create different 3D models for different buildings
   - Map QR codes to specific models

4. **Deploy Models**
   - Host on CDN (AWS S3, Firebase Storage)
   - Load from network instead of local assets

## Example QR Code Setup

Generate QR codes pointing to:

- `AR_BUILDING_B001` → Shows Building 1 model
- `AR_CAMPUS` → Shows campus logo
- `AR_LOCATION_LIBRARY` → Shows library model

Then in `ar_display_page.dart`, you can add logic to load different models based on QR code.

## Support & Resources

- [Model Viewer Docs](https://modelviewer.dev)
- [Blender Tutorials](https://www.blender.org/support/)
- [Flutter Camera Documentation](https://pub.dev/packages/camera)

---

**Your AR navigation system is ready for the evaluation! Just add your university logo as a 3D model and you're good to go!**
