import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

// Convert DMS to Decimal: 6°04'44.2"N = 6 + 4/60 + 44.2/3600
double _dmsToDecimal(
  int degrees,
  int minutes,
  double seconds,
  String direction,
) {
  double decimal = degrees + minutes / 60 + seconds / 3600;
  if (direction == 'S' || direction == 'W') {
    decimal = -decimal;
  }
  return decimal;
}

// Route: Canteen to Admin Building (11 waypoints)
final List<List<double>> ROUTE_CANTEEN_TO_ADMIN = [
  [_dmsToDecimal(6, 4, 44.2, 'N'), _dmsToDecimal(80, 11, 32.2, 'E')], // Point 1
  [_dmsToDecimal(6, 4, 44.5, 'N'), _dmsToDecimal(80, 11, 32.3, 'E')], // Point 2
  [_dmsToDecimal(6, 4, 44.7, 'N'), _dmsToDecimal(80, 11, 32.4, 'E')], // Point 3
  [_dmsToDecimal(6, 4, 44.8, 'N'), _dmsToDecimal(80, 11, 32.4, 'E')], // Point 4
  [_dmsToDecimal(6, 4, 44.9, 'N'), _dmsToDecimal(80, 11, 32.2, 'E')], // Point 5
  [_dmsToDecimal(6, 4, 45.2, 'N'), _dmsToDecimal(80, 11, 32.2, 'E')], // Point 6
  [_dmsToDecimal(6, 4, 45.5, 'N'), _dmsToDecimal(80, 11, 32.1, 'E')], // Point 7
  [_dmsToDecimal(6, 4, 45.7, 'N'), _dmsToDecimal(80, 11, 31.9, 'E')], // Point 8
  [_dmsToDecimal(6, 4, 45.7, 'N'), _dmsToDecimal(80, 11, 31.7, 'E')], // Point 9
  [
    _dmsToDecimal(6, 4, 45.6, 'N'),
    _dmsToDecimal(80, 11, 31.6, 'E'),
  ], // Point 10
  [
    _dmsToDecimal(6, 4, 45.6, 'N'),
    _dmsToDecimal(80, 11, 31.6, 'E'),
  ], // Point 11 (Admin Building)
];

// Route: Canteen to Library (will be added by user)
final List<List<double>> ROUTE_CANTEEN_TO_LIBRARY = [
  // TODO: Add waypoints from user
  [6.0789, 80.1922], // Placeholder: Canteen
];

// Route: Cafeteria to Main Hall (10 waypoints)
final List<List<double>> ROUTE_CAFETERIA_TO_MAINHALL = [
  [6.078935, 80.192276], // Point 1
  [_dmsToDecimal(6, 4, 44.0, 'N'), _dmsToDecimal(80, 11, 32.1, 'E')], // Point 2
  [_dmsToDecimal(6, 4, 43.9, 'N'), _dmsToDecimal(80, 11, 32.1, 'E')], // Point 3
  [_dmsToDecimal(6, 4, 44.0, 'N'), _dmsToDecimal(80, 11, 31.6, 'E')], // Point 4
  [6.078972349057248, 80.19197054812855], // Point 5
  [_dmsToDecimal(6, 4, 44.4, 'N'), _dmsToDecimal(80, 11, 30.6, 'E')], // Point 6
  [_dmsToDecimal(6, 4, 44.3, 'N'), _dmsToDecimal(80, 11, 30.2, 'E')], // Point 7
  [_dmsToDecimal(6, 4, 44.1, 'N'), _dmsToDecimal(80, 11, 29.9, 'E')], // Point 8
  [_dmsToDecimal(6, 4, 43.7, 'N'), _dmsToDecimal(80, 11, 29.6, 'E')], // Point 9
  [6.078883681945198, 80.19143698248683], // Point 10 (Main Hall)
];

// Available Routes
const Map<String, String> ROUTES = {
  'Canteen → Admin Building': 'canteen_admin',
  'Canteen → Library': 'canteen_library',
  'Cafeteria → Main Hall': 'cafeteria_mainhall',
};

// ==================== Path Painter for Connecting Lines ====================
class PathPainter extends CustomPainter {
  final List<List<double>> waypoints;
  final Position currentLocation;
  final int currentWaypointIndex;
  final double deviceHeading;
  final Function(double, double) projectWaypoint;

  PathPainter({
    required this.waypoints,
    required this.currentLocation,
    required this.currentWaypointIndex,
    required this.deviceHeading,
    required this.projectWaypoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;

    // Draw dashed line connecting all upcoming waypoints
    for (int i = currentWaypointIndex; i < waypoints.length - 1; i++) {
      final waypoint1 = waypoints[i];
      final waypoint2 = waypoints[i + 1];

      // Project both waypoints to screen coordinates
      final pos1 = projectWaypoint(waypoint1[0], waypoint1[1]);
      final pos2 = projectWaypoint(waypoint2[0], waypoint2[1]);

      // Color: current path = bright green, future = fading
      final opacity = (0.8 - (i - currentWaypointIndex) * 0.2).clamp(0.2, 0.8);
      final color = i == currentWaypointIndex
          ? Colors.greenAccent.withValues(alpha: opacity)
          : Colors.cyanAccent.withValues(alpha: opacity * 0.6);

      paint.color = color;

      // Draw dashed line
      _drawDashedLine(canvas, pos1, pos2, paint, dashWidth: 10, dashSpace: 5);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashWidth = 10,
    double dashSpace = 5,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final steps = (distance / (dashWidth + dashSpace)).toInt();

    for (int i = 0; i < steps; i++) {
      final progress1 = (i * (dashWidth + dashSpace)) / distance;
      final progress2 = ((i * (dashWidth + dashSpace)) + dashWidth) / distance;

      final p1 = Offset(start.dx + dx * progress1, start.dy + dy * progress1);
      final p2 = Offset(
        start.dx + dx * progress2.clamp(0, 1),
        start.dy + dy * progress2.clamp(0, 1),
      );

      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => true;
}

class ARCameraPage extends StatefulWidget {
  const ARCameraPage({super.key});

  @override
  State<ARCameraPage> createState() => _ARCameraPageState();
}

class _ARCameraPageState extends State<ARCameraPage> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;

  // Location & Compass
  Position? currentLocation;
  double deviceHeading = 0.0;
  double bearing = 0.0;
  double distance = 0.0;

  // Route Navigation
  String? selectedRoute;
  List<List<double>> currentWaypoints = [];
  int currentWaypointIndex = 0;
  int totalWaypoints = 0;

  // UI State
  String arStatus = "Initializing...";
  bool isNavigating = false;
  final double WAYPOINT_THRESHOLD = 5.0; // meters - auto-advance when within 5m

  @override
  void initState() {
    super.initState();
    _initCamera();
    _requestLocationPermission();
    _startCompassListener();
    _startLocationListener();
  }

  // ==================== Camera Setup ====================
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  // ==================== Location Setup ====================
  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await _getCurrentLocation();
      }
    } catch (e) {
      debugPrint("Location permission error: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      if (mounted) {
        setState(() {
          currentLocation = position;
          _updateArStatus();
        });
      }
    } catch (e) {
      debugPrint("Get location error: $e");
    }
  }

  void _startLocationListener() {
    try {
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 2, // Update every 2 meters
        ),
      ).listen((Position position) {
        if (mounted) {
          setState(() {
            currentLocation = position;
            _updateArStatus();
            _checkWaypointProximity(); // Auto-advance waypoint
          });
        }
      });
    } catch (e) {
      debugPrint("Location stream error: $e");
    }
  }

  // ==================== Compass Setup ====================
  void _startCompassListener() {
    try {
      FlutterCompass.events?.listen((event) {
        if (mounted) {
          setState(() {
            deviceHeading = event.heading ?? 0.0;
          });
        }
      });
    } catch (e) {
      debugPrint("Compass error: $e");
    }
  }

  // ==================== Bearing Calculation ====================
  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = lon2 - lon1;
    final y = math.sin(dLon * math.pi / 180) * math.cos(lat2 * math.pi / 180);
    final x =
        math.cos(lat1 * math.pi / 180) * math.sin(lat2 * math.pi / 180) -
        math.sin(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.cos(dLon * math.pi / 180);

    var bearing = math.atan2(y, x) * 180 / math.pi;
    bearing = (bearing + 360) % 360;
    return bearing;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  void _updateArStatus() {
    if (currentLocation == null || !isNavigating || currentWaypoints.isEmpty) {
      setState(() {
        arStatus = "Select a route to start navigation";
      });
      return;
    }

    final waypoint = currentWaypoints[currentWaypointIndex];

    bearing = _calculateBearing(
      currentLocation!.latitude,
      currentLocation!.longitude,
      waypoint[0],
      waypoint[1],
    );

    distance = _calculateDistance(
      currentLocation!.latitude,
      currentLocation!.longitude,
      waypoint[0],
      waypoint[1],
    );

    setState(() {
      arStatus =
          "Route: $selectedRoute\n"
          "Waypoint ${currentWaypointIndex + 1}/$totalWaypoints\n"
          "Distance: ${(distance * 1000).toStringAsFixed(0)}m\n"
          "Bearing: ${bearing.toStringAsFixed(0)}°";
    });
  }

  void _checkWaypointProximity() {
    if (!isNavigating || currentWaypoints.isEmpty) return;

    // If within threshold, advance to next waypoint
    if (distance * 1000 < WAYPOINT_THRESHOLD &&
        currentWaypointIndex < currentWaypoints.length - 1) {
      setState(() {
        currentWaypointIndex++;
        _updateArStatus();
        _showWaypointReachedNotification();
      });
    } else if (currentWaypointIndex == currentWaypoints.length - 1 &&
        distance * 1000 < WAYPOINT_THRESHOLD) {
      // Reached final destination
      _showNavigationCompleteDialog();
    }
  }

  void _showWaypointReachedNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Waypoint ${currentWaypointIndex + 1}/$totalWaypoints reached! Moving to next...',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.greenAccent.withValues(alpha: 0.8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _extractDestinationName(String routeName) {
    // Extract destination name from route (e.g., "Cafeteria → Main Hall" → "MAIN HALL")
    if (routeName.contains('→')) {
      return routeName.split('→').last.trim().toUpperCase();
    }
    return routeName.toUpperCase();
  }

  void _showNavigationCompleteDialog() {
    final destinationName = _extractDestinationName(selectedRoute ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main destination card
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.greenAccent.withValues(alpha: 0.3),
                      Colors.cyanAccent.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Checkmark icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.greenAccent, Colors.cyanAccent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withValues(alpha: 0.6),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 70,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // "Destination Reached" text
                      Text(
                        'DESTINATION REACHED',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Destination name (Large & Prominent)
                      Text(
                        destinationName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.w900,
                              fontSize: 48,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  color: Colors.greenAccent.withValues(
                                    alpha: 0.7,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 30),
                      // Decorative line
                      Container(
                        height: 2,
                        width: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.greenAccent,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Details text
                      Text(
                        'You have successfully navigated to your destination',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Close button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _stopNavigation();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.greenAccent, Colors.cyanAccent],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            'CONTINUE',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startNavigation(String routeId) {
    List<List<double>> waypoints = [];
    String routeName = '';

    if (routeId == 'canteen_admin') {
      waypoints = ROUTE_CANTEEN_TO_ADMIN;
      routeName = 'Canteen → Admin Building';
    } else if (routeId == 'canteen_library') {
      waypoints = ROUTE_CANTEEN_TO_LIBRARY;
      routeName = 'Canteen → Library';
    } else if (routeId == 'cafeteria_mainhall') {
      waypoints = ROUTE_CAFETERIA_TO_MAINHALL;
      routeName = 'Cafeteria → Main Hall';
    }

    if (waypoints.isNotEmpty) {
      setState(() {
        selectedRoute = routeName;
        currentWaypoints = waypoints;
        currentWaypointIndex = 0;
        totalWaypoints = waypoints.length;
        isNavigating = true;
        _updateArStatus();
      });
    }
  }

  void _stopNavigation() {
    setState(() {
      isNavigating = false;
      selectedRoute = null;
      currentWaypoints = [];
      currentWaypointIndex = 0;
      totalWaypoints = 0;
      arStatus = "Navigation stopped";
    });
  }

  // ==================== 3D Path Visualization ====================
  /// Project waypoint GPS to screen coordinates for AR overlay
  Offset _projectWaypointToScreen(double waypointLat, double waypointLon) {
    if (currentLocation == null) return const Offset(0, 0);

    // Calculate bearing and distance from current location to waypoint
    double bearing = _calculateBearing(
      currentLocation!.latitude,
      currentLocation!.longitude,
      waypointLat,
      waypointLon,
    );

    double distance = _calculateDistance(
      currentLocation!.latitude,
      currentLocation!.longitude,
      waypointLat,
      waypointLon,
    );

    // Convert bearing relative to device heading for screen projection
    double relativeAngle = bearing - deviceHeading;
    double angleRad = relativeAngle * math.pi / 180;

    // Get screen center
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;

    // Project 3D world coordinate to 2D screen
    // Use distance as vertical offset (further = lower on screen)
    // Use angle for horizontal positioning
    const pixelsPerMeter = 50; // Adjust for zoom effect
    double projectedX =
        centerX + math.sin(angleRad) * distance * pixelsPerMeter;
    double projectedY =
        centerY + math.cos(angleRad) * distance * pixelsPerMeter * 0.7;

    return Offset(projectedX, projectedY);
  }

  /// Build AR path arrows for all upcoming waypoints
  Widget _buildPathArrows() {
    if (!isNavigating || currentWaypoints.isEmpty || currentLocation == null) {
      return Container();
    }

    List<Widget> arrowWidgets = [];

    // Draw arrows for current and all future waypoints
    for (int i = currentWaypointIndex; i < currentWaypoints.length; i++) {
      final waypoint = currentWaypoints[i];
      final position = _projectWaypointToScreen(waypoint[0], waypoint[1]);

      // Skip waypoints that are off-screen or behind user
      final distance = _calculateDistance(
        currentLocation!.latitude,
        currentLocation!.longitude,
        waypoint[0],
        waypoint[1],
      );

      if (distance > 0.5) {
        // Only show waypoints within reasonable distance
        final opacity =
            math.pow(0.95, (i - currentWaypointIndex).toDouble()) as double;
        final scale = 1.0 - ((i - currentWaypointIndex) * 0.15);
        final distanceMeters = distance * 1000;

        // Color gradient: current = bright green, future = fading cyan
        Color arrowColor;
        if (i == currentWaypointIndex) {
          arrowColor = Colors.greenAccent;
        } else if (i < currentWaypointIndex + 3) {
          arrowColor = Colors.cyanAccent;
        } else {
          arrowColor = Colors.blueAccent;
        }

        arrowWidgets.add(
          Positioned(
            left: position.dx - 20,
            top: position.dy - 20,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale.clamp(0.3, 1.0),
                child: GestureDetector(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Arrow icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: arrowColor.withValues(alpha: 0.3),
                          border: Border.all(color: arrowColor, width: 1.5),
                        ),
                        child: Icon(
                          Icons.navigation,
                          color: arrowColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Distance label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: arrowColor, width: 0.5),
                        ),
                        child: Text(
                          '${distanceMeters.toStringAsFixed(0)}m',
                          style: TextStyle(
                            color: arrowColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Stack(children: arrowWidgets);
  }

  /// Draw connecting lines between waypoints (path breadcrumbs)
  Widget _buildPathLines() {
    if (!isNavigating || currentWaypoints.isEmpty || currentLocation == null) {
      return Container();
    }

    return CustomPaint(
      painter: PathPainter(
        waypoints: currentWaypoints,
        currentLocation: currentLocation!,
        currentWaypointIndex: currentWaypointIndex,
        deviceHeading: deviceHeading,
        projectWaypoint: _projectWaypointToScreen,
      ),
      size: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                arStatus,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final relativeAngle = bearing - deviceHeading;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          CameraPreview(_cameraController!),

          // ==================== AR Path Visualization (All Waypoints) ====================
          if (isNavigating) _buildPathLines(),
          if (isNavigating) _buildPathArrows(),

          // ==================== AR Navigation Arrow ====================
          if (isNavigating)
            Center(
              child: Opacity(
                opacity: 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rotating Navigation Arrow
                    Transform.rotate(
                      angle: relativeAngle * math.pi / 180,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withValues(alpha: 0.3),
                          border: Border.all(
                            color: Colors.cyanAccent,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.navigation,
                          size: 120,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Waypoint Info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.greenAccent),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Waypoint ${currentWaypointIndex + 1}/$totalWaypoints',
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(distance * 1000).toStringAsFixed(0)}m away',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ==================== AR Status Panel ====================
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isNavigating
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isNavigating
                        ? "🧭 AR Navigation Active"
                        : "📍 Select Route",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    arStatus,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isNavigating
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                  ),
                  if (currentLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Lat: ${currentLocation!.latitude.toStringAsFixed(4)}, Lon: ${currentLocation!.longitude.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.cyanAccent,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ==================== Route Selection ====================
          if (!isNavigating)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Select Route:",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...ROUTES.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => _startNavigation(entry.value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.greenAccent),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.greenAccent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          // ==================== Navigation Controls ====================
          if (isNavigating)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                  onTap: _stopNavigation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stop_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        "Stop Navigation",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ==================== Control Buttons ====================
          Positioned(
            top: 40,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Recenter button
                GestureDetector(
                  onTap: _getCurrentLocation,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_searching,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Back button
                GestureDetector(
                  onTap: () {
                    if (isNavigating) _stopNavigation();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
