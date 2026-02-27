# Quick Testing Guide - AR Feature

## Test Scenario 1: AR Demo (Fastest Test - 2 minutes)

### Steps:

1. **Start the app**

   ```bash
   cd arwayz
   flutter pub get
   flutter run
   ```

2. **On Home Screen**, click the **"AR Demo"** button
   - NEW button we added (teal colored)

3. **AR View Opens**
   - See spinning 3D astronaut (demo model)
   - Watch it rotate automatically
   - Try pinching to zoom
   - Try dragging to rotate manual
   - See QR code display at top: "AR_DEMO_MODE"

4. **Close** - Tap "Close AR View" button

✅ **Success Criteria:**

- 3D model visible and spinning
- Touch controls work (zoom, rotate)
- No crashes

---

## Test Scenario 2: QR Code to AR View (3 minutes)

### Steps:

1. **On Home Screen**, click **"Scan QR Code"** button

2. **QR Scanner Opens**
   - Point camera at QR code
   - Wait for detection (usually 1-2 seconds)

3. **QR Code Detected**
   - You'll see the code displayed in a white card
   - Shows buttons: [AR View] [Open] [Copy] [Share]

4. **Click "AR View" Button** (NEW button)
   - AR Display page opens
   - Shows demo 3D model with your QR code info

5. **Interact with AR**
   - Model spins automatically
   - Pinch to zoom
   - Drag to rotate

6. **Close** - Tap "Close AR View"

✅ **Success Criteria:**

- QR code scans correctly
- AR View button appears
- 3D model displays and animates

---

## Test Scenario 3: Using Real University Logo (After getting 3D model)

### Before These Steps:

1. Get university logo as 3D model (GLB format)
   - From Sketchfab, or
   - Convert using Blender

2. Place file: `arwayz/assets/models/university_logo.glb`

3. Run:
   ```bash
   flutter pub get
   flutter run
   ```

### Steps:

Same as Scenario 1 or 2, but now your university logo appears instead of demo model

---

## Expected Visuals

### Home Screen

```
┌────────────────────────────────┐
│     ARWayz Home Page          │
│                                │
│  Enter Building ID: [input]    │
│  [Submit] [Scan QR Code]      │
│  [AR Demo] ← NEW BUTTON        │
│                                │
│  Camera button (FAB) →         │
└────────────────────────────────┘
```

### AR Display Page

```
┌────────────────────────────────┐
│  ← AR View                     │
├────────────────────────────────┤
│                                │
│      🔄 ← Spinning 3D Model   │
│      AR View                   │
│                                │
│  [QR Code Info at top]         │
│  [Close button at bottom]      │
└────────────────────────────────┘
```

---

## Common Errors & Quick Fixes

### Error: "Model file not found"

**Fix:**

```bash
flutter clean
flutter pub get
flutter run
```

### Error: "ModelViewer not found"

**Fix:**

- Ensure `pubspec.yaml` has been saved
- Run `flutter pub get`
- Rebuild project

### App crashing on AR Demo

**Fix:**

- Check internet connection (demo model loads from URL)
- Try on physical device (not emulator recommended)

### 3D Model Not Spinning

**Fix:**

- Wait 2-3 seconds for model to load
- Try rotating manually with finger drag
- Check model file is valid GLB format

---

## Performance Notes

- **First Load**: May take 2-3 seconds to load 3D model
- **Demo Model**: 15MB demo astronaut (test only)
- **Your Model**: Recommend < 10MB for smooth performance
- **Physical Device**: Required for best AR experience

---

## Demo QR Code Generator

To test the QR Scanner → AR View flow:

1. Go to [qr-code-generator.com](https://www.qr-code-generator.com)

2. Enter text:

   ```
   AR_BUILDING_001
   ```

3. Download QR code image

4. Print or display on screen

5. Scan with "Scan QR Code" button

6. Click "AR View" to see in AR

---

## Share with Evaluators

For the evaluation, share these files:

- ✅ Source code (this repo)
- ✅ APK/IPA file (compiled app)
- ✅ These documentation files
- ✅ A 3D model file of your university logo

### To Build APK (Android):

```bash
cd arwayz
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### To Build IPA (iOS):

```bash
cd arwayz
flutter build ios --release
# Then use Xcode to build ipa
```

---

## Success Checklist for Evaluation

- [ ] App runs without errors
- [ ] Home page shows "AR Demo" button
- [ ] AR Demo button opens AR view instantly
- [ ] 3D model visible and spinning
- [ ] QR scanner works
- [ ] "AR View" button appears after scanning
- [ ] Model is interactive (zoom/rotate)
- [ ] All buttons close/navigate properly
- [ ] No crashes during interaction

✅ **If all checked, you're ready for evaluation!**

---

**Need help? Check the detailed guides:**

- `AR_SETUP_GUIDE.md` - How to add your own 3D model
- `IMPLEMENTATION_SUMMARY.md` - Technical overview
- `pubspec.yaml` - Dependencies and configuration
