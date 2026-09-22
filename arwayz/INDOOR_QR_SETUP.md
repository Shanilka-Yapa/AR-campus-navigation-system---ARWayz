# New Computer Center Indoor Navigation

This prototype covers one practical route inside the IS Department building. GPS or Google Maps brings the user to the building; QR checkpoints then establish indoor position and advance the route.

## Route

```text
IS building entrance / outdoor GPS
  -> ground-floor entrance QR
  -> ground-floor lobby QR
  -> ground-floor corridor junction QR
  -> New Computer Center QR
```

The app implementation is in `lib/indoor_navigation_page.dart`.

## QR Payloads

Create four QR codes with these exact text values:

```text
ARWAYZ|building=IS_BUILDING|floor=0|point=ground_entrance
ARWAYZ|building=IS_BUILDING|floor=0|point=ground_lobby
ARWAYZ|building=IS_BUILDING|floor=0|point=ground_corridor
ARWAYZ|building=IS_BUILDING|floor=0|point=new_computer_center
```

`floor=0` means ground floor. Keep it the same in every code. The app requires the codes in this order.

## Where To Place Them

1. `ground_entrance`: inside the IS building ground-floor entrance.
2. `ground_lobby`: after the entrance, visible from the lobby.
3. `ground_corridor`: at the corridor turn or junction.
4. `new_computer_center`: beside the New Computer Center door.

Place each code at eye level, with a label such as `ARWayz Indoor Checkpoint - Scan Here`. Avoid glass, glare, direct sunlight, and locations where people can block the code.

## How To Generate The Images

Use any QR generator that accepts plain text. Paste one payload at a time, generate a PNG, and print it. Do not add a URL prefix and do not change the pipe or equals characters.

Before printing, scan each image using the app and confirm that the displayed payload is exactly the value above. A second phone can display the code during early testing.

## How To Find The Outdoor Building Location

Open Google Maps and search for the IS Department building. Long-press or right-click the building entrance, copy the latitude and longitude, and use those coordinates for the outdoor destination. Do not guess coordinates from another building.

For the current fixed Google Maps page, update the destination in `lib/outdoor_navigation_page.dart`. The better next step is to make that page accept the selected IS building destination rather than using a hard-coded constant.

## User Demonstration

1. Open ARWayz.
2. Use Google Maps/outdoor navigation to reach the IS Department building.
3. Tap `Scan QR Code`.
4. Scan the ground-floor entrance code.
5. The camera-based indoor navigation screen opens.
6. Walk to the location shown as `NEXT`.
7. Tap `SCAN NEXT CHECKPOINT` and scan the next code.
8. Repeat for the corridor code.
9. Scan the New Computer Center code.
10. The app shows `Arrival confirmed at New Computer Center`.

The app rejects a code from another building, another floor, or the wrong next checkpoint.

## Changing The Real Route

Walk the building before printing codes. If the physical route differs, update the checkpoint names and instructions in `lib/indoor_navigation_page.dart`, then regenerate only the payloads if an ID changes. The `point` values in the QR codes and the checkpoint `id` values in Dart must match exactly.

This is QR-assisted indoor navigation, not GPS indoor positioning. QR scans correct the user's known position at each checkpoint, while the camera screen provides the next instruction between checkpoints.
