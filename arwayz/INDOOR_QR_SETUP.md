# IS Building QR Wayfinder

Select a destination in the IS Building QR Wayfinder, then scan the QR code for the floor where you are standing. The app uses that floor and the destination's floor and wing to provide the next direction.

## Floor QR Codes

```text
ARWAYZ|building=IS_BUILDING|floor=0|point=floor_0
ARWAYZ|building=IS_BUILDING|floor=1|point=floor_1
ARWAYZ|building=IS_BUILDING|floor=2|point=floor_2
ARWAYZ|building=IS_BUILDING|floor=3|point=floor_3
```

Create exactly four QR codes, one for each floor. Place each code at a known position on its floor, such as the main stair or lift landing.

`floor=0` is the ground floor, `floor=1` is the first floor, `floor=2` is the second floor, and `floor=3` is the third floor. The `point` value must match the floor number exactly.

## Destinations

The wayfinder destination list contains these building spaces:

| Floor | Space | Wing |
|---|---|---|
| 0 | Central Reception & Lobby | Center |
| 0 | Meeting Room | Left Wing |
| 0 | Board Room | Right Wing |
| 1 | Dean's Office Suite | Center |
| 1 | EEC (Engineering Education Center) | Left Wing |
| 1 | Classroom A | Left Wing |
| 1 | Finance Office | Left Wing |
| 1 | Assistant Registrar Office | Right Wing |
| 1 | Dean's Office | Right Wing |
| 1 | Staff & Faculty Lounge | Right Wing |
| 2 | IS Seminar Room | Left Wing |
| 2 | Academic Wing & Faculty Suites | Right & Center |
| 3 | Computer Center | Left Wing |
| 3 | NCC (New Computer Center) | Right Wing |

## Where To Place Them

1. `floor_0`: a known location on the ground floor.
2. `floor_1`: a known location on the first floor.
3. `floor_2`: a known location on the second floor.
4. `floor_3`: a known location on the third floor.

Place each code at eye level, with a label such as `ARWayz Indoor Checkpoint - Scan Here`. Avoid glass, glare, direct sunlight, and locations where people can block the code.

## How To Generate The Images

Use any QR generator that accepts plain text. Paste one payload at a time, generate a PNG, and print it. Do not add a URL prefix and do not change the pipe or equals characters.

Before printing, scan each image using the app and confirm that the displayed payload is exactly the value above. A second phone can display the code during early testing.

## How To Find The Outdoor Building Location

Open Google Maps and search for the IS Department building. Long-press or right-click the building entrance, copy the latitude and longitude, and use those coordinates for the outdoor destination. Do not guess coordinates from another building.

For the current fixed Google Maps page, update the destination in `lib/outdoor_navigation_page.dart`. The better next step is to make that page accept the selected IS building destination rather than using a hard-coded constant.

## User Demonstration

1. Open ARWayz and open the IS Building 3D view.
2. Tap `QR Wayfinder`.
3. Select a destination, such as `IS Seminar Room`.
4. Tap `Scan QR Location`.
5. Scan the QR code for the floor where you are currently standing.
6. The app displays the current floor and direction to the destination floor and wing.

For example, if `IS Seminar Room` is selected and the `floor_1` QR code is scanned, the app directs the user to go up to Floor 2 and then follow signs to the Left Wing.

## Changing The Real Route

Walk the building before printing codes. If the physical route differs, update the checkpoint names and instructions in `lib/indoor_navigation_page.dart`, then regenerate only the payloads if an ID changes. The `point` values in the QR codes and the checkpoint `id` values in Dart must match exactly.

This is QR-assisted indoor navigation, not GPS indoor positioning. The four QR scans identify the user's current floor; the selected destination data provides floor and wing guidance.
