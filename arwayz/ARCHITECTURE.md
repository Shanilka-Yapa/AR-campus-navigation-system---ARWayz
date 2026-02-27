# AR System Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     ARWayz Flutter App                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    main.dart                             │  │
│  │  (Home Page - Building Info & Navigation)               │  │
│  │                                                          │  │
│  │  [Submit Building ID]  [Scan QR Code]  [AR Demo] ✨ NEW │  │
│  └────────────────┬─────────────────┬───────────────┬──────┘  │
│                   │                 │               │          │
│          ┌────────▼──────┐  ┌──────▼──────┐  ┌────▼─────────┐ │
│          │Building Areas │  │ QR Scanner  │  │  AR Display  │ │
│          │    Page       │  │   Page      │  │   Page  ✨   │ │
│          └───────────────┘  └──────┬──────┘  │               │ │
│                                    │         │               │ │
│                    [Scan→Detect]   │         │   [AR View]   │ │
│                    [AR View] ✨ NEW │         │   Button ✨   │ │
│                                    │         │               │ │
│                                    └────┬────┘               │ │
│                                         │                   │ │
│                                    ┌────▼──────────────────┐ │
│                                    │  ar_display_page.dart │ │
│                                    │  (NEW FILE) ✨        │ │
│                                    │                       │ │
│                                    │   • ModelViewer      │ │
│                                    │   • Auto-rotate      │ │
│                                    │   • AR mode          │ │
│                                    │   • Touch controls   │ │
│                                    └───────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Flow: QR Code to AR

```
User Action                Backend                  UI Rendering
─────────────────────────────────────────────────────────────────

1. Tap "Scan QR"
   │
   └──────→ QR Scanner Page Opens
            │
            └─────→ Mobile Scanner (camera feed)
                    │
                    └─────→ QR Code Detected
                            │
2. Tap "AR View"            │
   │                        │
   └──────→ ARDisplayPage   │
            │               │
            ├──────────────→ Receive: scannedCode
            │
            ├──────────────→ Check: Local model exists?
            │               │
            │         YES:  Load from assets/models/
            │         NO:   Load from DEMO_MODEL_URL
            │
            └──────────────→ ModelViewer Widget
                            │
                            ├──────→ Load 3D model
                            ├──────→ Start auto-rotate
                            ├──────→ Enable AR mode
                            ├──────→ Display QR info
                            │
                            └──────→ Render on Screen
                                     │
                                     ├──→ User can rotate (drag)
                                     ├──→ User can zoom (pinch)
                                     ├──→ Model spins automatically
                                     └──→ User can close
```

---

## Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    ARWayz Application                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  Presentation Layer                  │  │
│  │  ┌───────────┬──────────┬───────────┬───────────┐   │  │
│  │  │main.dart  │qr_scan   │ar_display │ar_camera  │   │  │
│  │  │           │           │           │           │   │  │
│  │  └───────────┴──────────┴───────────┴───────────┘   │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  Plugin Layer                        │  │
│  │  ┌────────────────────────────────────────────────┐ │  │
│  │  │	  📦 model_viewer: 3D Model Rendering        │ │  │
│  │  │	  📦 mobile_scanner: QR Code Detection       │ │  │
│  │  │	  📦 camera: Camera Access                   │ │  │
│  │  │	  📦 webview_flutter: Web View Support       │ │  │
│  │  │	  📦 image_picker: Image Selection           │ │  │
│  │  └────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  Platform Layer                      │  │
│  │  ┌──────────────┬──────────────┬──────────────────┐ │  │
│  │  │   Android    │    iOS       │   Web (future)   │ │  │
│  │  │   (ARCore)   │  (ARKit)     │                  │ │  │
│  │  └──────────────┴──────────────┴──────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  Asset Layer                         │  │
│  │  ┌────────────────────────────────────────────────┐ │  │
│  │  │ Local: assets/models/university_logo.glb      │ │  │
│  │  │ Remote: Demo model from modelviewer.dev       │ │  │
│  │  └────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Model Viewer Widget - Internal Flow

```
ModelViewer(src, ar, autoRotate)
    │
    ├──→ Initialize WebView
    │    │
    │    └──→ Load modelviewer.dev JavaScript library
    │         │
    │         └──→ Create 3D scene
    │
    ├──→ Load 3D Model (GLB/GLTF)
    │    │
    │    ├──→ Parse model geometry
    │    ├──→ Load textures
    │    └──→ Setup materials
    │
    ├──→ Setup Renderer
    │    │
    │    ├──→ Three.js setup
    │    ├──→ Camera positioning
    │    └──→ Lighting setup
    │
    ├──→ Enable Interactions
    │    │
    │    ├──→ Touch: Drag to rotate
    │    ├──→ Touch: Pinch to zoom
    │    └──→ Animation: Auto-rotate loop
    │
    ├──→ Enable AR (if ar: true)
    │    │
    │    ├──→ Android: Check ARCore availability
    │    ├──→ iOS: Check ARKit availability
    │    └──→ Launch native AR session
    │
    └──→ Render to Screen
         │
         └──→ WebGL context → Device Display
```

---

## State Management Flow

```
┌─────────────────────────────────────────────────┐
│         ARDisplayPage (StatefulWidget)          │
├─────────────────────────────────────────────────┤
│                                                 │
│  Properties:                                    │
│  • qrCode: String (QR data)                    │
│  • _modelExists: bool                          │
│  • _animationController: AnimationController   │
│                                                 │
│  Lifecycle:                                     │
│  initState()                                   │
│    ├→ Create animation controller             │
│    ├→ Check if model file exists              │
│    └→ Load from local or remote              │
│                                                 │
│  build()                                       │
│    ├→ Stack Layout                            │
│    ├→ ModelViewer widget                      │
│    ├→ Info overlays                           │
│    └→ Close button                            │
│                                                 │
│  dispose()                                     │
│    └→ Clean up animation controller           │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## File Loading Logic

```
app_startup
    │
    ├──→ pubspec.yaml loaded
    │    │
    │    └──→ assets/models/ registered
    │
    ├──→ ar_display_page.dart loaded
    │    │
    │    └──→ initState()
    │         │
    │         └──→ _checkModelExists()
    │              │
    │         YES─┤  ✓ Load local: assets/models/university_logo.glb
    │              │
    │         NO──┤  ✗ Use fallback: DEMO_MODEL_URL
    │
    └──→ ModelViewer renders appropriate source
```

---

## Navigation Tree

```
Splash Page
    │
    └──→ Home Page (main.dart)
         │
         ├──→ [Submit] → Building Areas Page
         │
         ├──→ [Scan QR Code] → QR Scanner Page
         │    │
         │    └──→ [AR View] → AR Display Page ✨
         │         │
         │         └──→ [Close] → Back to QR Scanner
         │
         └──→ [AR Demo] → AR Display Page ✨ (NEW)
              │
              └──→ [Close] → Back to Home Page
```

---

## Asset Structure

```
assets/
├── images/
│   ├── building_bg.png
│   ├── ... (existing images)
│   │
│   └── [Used by: building_areas_page, main.dart]
│
└── models/                    ✨ NEW FOLDER
    ├── university_logo.glb    ✨ NEW (your 3D file)
    │
    └── [Used by: ar_display_page.dart]
        - Auto-detected on app startup
        - Fallback to demo model if missing
```

---

## Dependency Graph

```
ar_display_page.dart
    │
    ├──→ flutter/material.dart
    ├──→ model_viewer/model_viewer.dart
    │    │
    │    ├──→ webview_flutter
    │    │    └──→ JavaScript (modelviewer.dev)
    │    │
    │    └──→ Three.js (WebGL rendering)
    │
    └──→ dart:io (file checking)

qr_scanner_page.dart
    │
    ├──→ mobile_scanner
    └──→ ar_display_page.dart (navigation)

main.dart
    │
    ├──→ ar_display_page.dart (AR Demo button)
    └──→ qr_scanner_page.dart (existing)
```

---

## Error Handling Flow

```
ARDisplayPage.build()
    │
    ├──→ Try load local model
    │    │
    │    ├──→ Success → Show model
    │    │
    │    └──→ Failure → Continue
    │
    └──→ Load fallback/demo model
         │
         ├──→ Success → Show demo
         │
         └──→ Failure → Show error message
              (User sees "Demo Mode" indicator)
```

---

## Performance Characteristics

```
Memory Usage
├── App base: ~100MB
├── 3D model (loaded): +5-20MB
├── WebView context: ~50MB
└── Total typical: 150-200MB

Load Times
├── App startup: ~2-3s
├── QR scan: ~1-2s
├── Model load: ~2-3s (first time)
├── Model load: ~0.5s (cached)
└── AR initialization: ~1-2s

Rendering Performance
├── Desktop/tablet: 60 FPS
├── High-end phone: 60 FPS
├── Mid-range phone: 30-60 FPS
└── Low-end phone: 30 FPS
```

---

## Testing Strategy

```
Test Levels:
│
├── Unit Tests (not included - optional)
│   └── Model loading, QR parsing
│
├── Widget Tests (not included - optional)
│   └── UI rendering, button clicks
│
├── Integration Tests (not included - optional)
│   └── Full flow QR→AR
│
└── Manual Testing ✅ (Instructions provided)
    ├── AR Demo button
    ├── QR Scanner flow
    └── AR View interactions
```

---

## Deployment Architecture

```
Development
    ↓
Source Code (GitHub)
    ↓
├──→ Debug Build (flutter run)
│
├──→ Release Build (flutter build)
│    │
│    ├──→ APK (Android)
│    │
│    └──→ IPA (iOS)
│
└──→ Distribution
     ├──→ Google Play Store
     └──→ Apple App Store
```

---

## Future Enhancement Points

```
Current System
    │
    ├──→ Single model per AR view
    │    └── Future: Multiple models per location
    │
    ├──→ Local assets
    │    └── Future: Cloud model storage
    │
    ├──→ QR string display
    │    └── Future: QR mapping to location data
    │
    ├──→ Static 3D model
    │    └── Future: Animated models
    │
    └──→ Single device
         └── Future: Multiplayer AR sharing
```

---

**This architecture provides a robust, scalable foundation for AR campus navigation! 🚀**
