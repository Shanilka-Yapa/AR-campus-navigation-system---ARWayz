# 🧪 AR Compass Navigation - Testing Guide

## ✅ Pre-Test Checklist

Before you start testing, verify:

- [ ] Android device with API 24+
- [ ] USB debugging enabled
- [ ] USB cable connected
- [ ] `flutter devices` shows your device
- [ ] Flutter installed and updated
- [ ] Campus coordinates updated in code

---

## 🚀 Step-by-Step Testing

### Step 1: Initial Build

```bash
# Navigate to project
cd c:\flutter_new\AR-campus-navigation-system---ARWayz\arwayz

# Clean old builds
flutter clean

# Get dependencies
flutter pub get

# Build and run
flutter run
```

**Expected Result:** App starts, shows main screen with buttons

---

### Step 2: Verify New Button Appears

**What to look for:**

- 📱 App main screen visible
- 🟢 **Green compass button** at top of right FABs
- 📍 Navigation button (existing)
- 📷 Camera button (existing)

**If not visible:**

- Force stop app: `flutter run --release`
- Check imports in `main.dart`

---

### Step 3: Test Navigation Selector

**Action:** Tap the green compass button

**Expected Result:**

- ✅ Navigation Selector page opens
- ✅ Shows 2 options:
  - 🧭 AR Compass Arrow (with destination buttons)
  - 🗺️ Google Maps
- ✅ Info card at bottom

**If crashes:**

- Check `navigation_selector_page.dart` imports
- Verify file exists in `lib/` folder

---

### Step 4: Test AR Compass Navigation

**Action:**

1. Tap "🧭 AR Compass Arrow"
2. Tap a destination (e.g., "Admin Building")

**Expected Result:**

- ✅ Camera feed appears (shows surroundings)
- ✅ Green arrow in center of screen
- ✅ Arrow has glow effect
- ✅ Destination info card shows (black background, white text)
- ✅ Distance shows (e.g., "250m away")
- ✅ Top panel shows: HEADING, BEARING, ANGLE
- ✅ Close button at bottom

**If camera is black:**

- Check camera permission in settings
- Restart app
- Try a different device

---

### Step 5: Test Arrow Rotation

**Action:**

1. Point device toward a fixed direction
2. Keep still for 5 seconds
3. Arrow should stabilize pointing in one direction
4. Slowly rotate device side-to-side

**Expected Result:**

- ✅ Arrow rotates smoothly as device rotates
- ✅ Arrow continues pointing in same compass direction
- ✅ No lag or stuttering

**If arrow doesn't rotate:**

- Ensure compass is calibrated (do figure-8 motion)
- Restart app
- Test with different device

---

### Step 6: Test Distance Updates

**Action:**

1. Note current distance (e.g., "250m")
2. Walk 50 meters toward destination
3. Watch distance update

**Expected Result:**

- ✅ Distance decreases (e.g., "200m")
- ✅ Updates happen within 2 seconds
- ✅ Change is proportional to distance walked

**If distance doesn't update:**

- Wait 30 seconds for GPS lock
- Ensure GPS is enabled (Settings → Location)
- Test in open outdoor area
- Try moving further (50m+)

---

### Step 7: Test Arrival Detection

**Action:**

1. Navigate to within 20 meters of destination
2. Keep watching screen

**Expected Result:**

- ✅ Green popup appears: "You have arrived!"
- ✅ Popup stays visible
- ✅ Close button still works

**If no popup:**

- Get closer to destination (<15m)
- Wait for GPS to stabilize
- Check destination coordinates are correct

---

### Step 8: Test Close Button

**Action:** Tap the "Close" button

**Expected Result:**

- ✅ Returns to Navigation Selector page
- ✅ No crashes
- ✅ Can reopen AR compass

**If button doesn't work:**

- Tap again (sometimes needs 2 taps)
- Use device back button
- Force close and reopen app

---

## 🔄 Repeat Tests

Run through Steps 3-8 with **different destinations**:

1. **Test 1:** Admin Building
   - [ ] Arrow points correctly
   - [ ] Distance updates
   - [ ] Close works

2. **Test 2:** Library
   - [ ] Arrow points correctly
   - [ ] Distance updates
   - [ ] Close works

3. **Test 3:** Main Hall
   - [ ] Arrow points correctly
   - [ ] Distance updates
   - [ ] Close works

4. **Test 4:** Cafeteria
   - [ ] Arrow points correctly
   - [ ] Distance updates
   - [ ] Close works

---

## 📊 Accuracy Testing

### In-Field Accuracy Test

**Setup:**

1. Stand at known location A (e.g., main gate)
2. Know exact location B (target building)
3. Know distance A→B (use GPS/maps)

**Test:**

1. Open AR compass → Select destination B
2. Follow arrow to building
3. Record final distance when arrived
4. Compare recorded distance vs expected

**Acceptable Results:**

- ✅ Arrived within 20m: Excellent
- ✅ Arrived within 30m: Good
- ✅ Arrived within 50m: Acceptable
- ❌ More than 50m: Coordinate issue

---

## 🆘 Common Issues During Testing

### Issue 1: App Won't Build

```
Error: "Cannot find lib/ar_compass_navigation_page.dart"
```

**Solution:**

```bash
flutter pub get
flutter clean
flutter run
```

---

### Issue 2: Camera Shows Black Screen

```
Permission required message
```

**Solution:**

- Settings → Apps → ARWayz → Permissions
- Enable: Camera, Location
- Restart app

---

### Issue 3: GPS Not Updating

```
Distance stays same, doesn't change when moving
```

**Solution:**

- Go outside (GPS works better outdoors)
- Wait 30 seconds for GPS lock
- Enable GPS in settings
- Try moving 100+ meters
- Restart app

---

### Issue 4: Arrow Points Wrong Direction

```
Arrow points opposite direction
```

**Solution:**

- Calibrate compass (move device in figure-8)
- Wait 10 seconds for compass to settle
- Verify destination coordinates are correct
- Try moving closer to destination

---

### Issue 5: Compass Drifts

```
Arrow gradually points more wrong direction
```

**Solution:**

- Do compass calibration (figure-8 motion)
- Avoid using app near metal objects
- Restart app
- Try different location on campus

---

### Issue 6: App Crashes on Startup

```
"Unhandled Exception in main.dart"
```

**Solution:**

1. Check `main.dart` imports
2. Verify both new files exist:
   - `lib/ar_compass_navigation_page.dart`
   - `lib/navigation_selector_page.dart`
3. Run:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## 📋 Acceptance Criteria

Your AR navigation is **production ready** when:

- ✅ App builds without errors
- ✅ Green compass button appears
- ✅ Navigation selector page opens
- ✅ AR camera opens and shows live feed
- ✅ Green arrow visible and rotates
- ✅ Distance updates within 2 seconds
- ✅ Distance accuracy ±20 meters
- ✅ No crashes during testing
- ✅ Close button works
- ✅ Tested on 2+ devices

---

## 📊 Test Results Template

```
Date: _________
Device: _________
Android Version: _________

Test 1: Navigation Selector
- Button appears: [ ] Yes [ ] No
- Page opens: [ ] Yes [ ] No
- AR option visible: [ ] Yes [ ] No

Test 2: AR Camera
- Camera opens: [ ] Yes [ ] No
- Green arrow visible: [ ] Yes [ ] No
- Info card shows: [ ] Yes [ ] No

Test 3: Arrow Rotation
- Rotates smoothly: [ ] Yes [ ] No
- No lag: [ ] Yes [ ] No
- Accurate: [ ] Yes [ ] No

Test 4: Distance
- Updates: [ ] Yes [ ] No
- Accuracy: ±___m
- Updates within: ____ seconds

Test 5: Arrival
- Popup shows: [ ] Yes [ ] No
- At correct distance: [ ] Yes [ ] No

Test 6: Performance
- No crashes: [ ] Yes [ ] No
- No freezes: [ ] Yes [ ] No
- Battery drain: [ ] Normal [ ] High

Notes: _________________________
```

---

## 🎉 Success Indicators

When you see these, you know it's working:

1. ✅ **Green arrow in camera** - AR system working
2. ✅ **Arrow rotates with device** - Compass working
3. ✅ **Distance decreases when moving** - GPS working
4. ✅ **Arrives at destination** - Navigation working
5. ✅ **No crashes** - Code is stable

---

## 🚀 Next Steps After Successful Testing

1. **Deploy to Play Store**
   - Build release APK
   - Create developer account
   - Upload to Google Play

2. **Add More Features**
   - Favorite destinations
   - Route history
   - Multiple route options

3. **Improve User Experience**
   - Settings page for preferences
   - User feedback form
   - Navigation tips

4. **Add Indoor Navigation**
   - QR codes at building entrances
   - Floor plans
   - Indoor waypoints

---

**Test and report back! You've got this! 🚀**
