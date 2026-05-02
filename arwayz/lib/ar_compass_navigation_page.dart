import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'Building_Details_page.dart';

/// AR Compass Navigation - Shows green arrow pointing to destination
/// Works outdoors and indoors without GPS waypoint accuracy issues
class ARCompassNavigationPage extends StatefulWidget {
  final double destLat;
  final double destLon;
  final String destName;
  final String locationType;

  const ARCompassNavigationPage({
    required this.destLat,
    required this.destLon,
    required this.destName,
    required this.locationType,
    super.key,
  });

  @override
  State<ARCompassNavigationPage> createState() =>
      _ARCompassNavigationPageState();
}

class _ARCompassNavigationPageState extends State<ARCompassNavigationPage>
    with TickerProviderStateMixin {
  late CameraController _cameraController;
  double _heading = 0;
  double _bearing = 0;
  double _distance = 0;
  Position? _currentLocation;
  bool _isInitialized = false;
  String? _error;
  bool _hasArrivedAtDestination = false;
  late AnimationController _celebrationAnimationController;
  late Animation<double> _celebrationScaleAnimation;
  late Animation<double> _celebrationOpacityAnimation;
  final VoiceNavigationService _voice = VoiceNavigationService(); // ✅ voice field

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startHeadingUpdates();
    _startLocationUpdates();

    // Initialize celebration animations
    _celebrationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _celebrationScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationAnimationController, curve: Curves.elasticOut),
    );

    _celebrationOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationAnimationController, curve: Curves.easeIn),
    );
  }

  // ✅ FIXED: dispose() is correctly INSIDE the class
  @override
  void dispose() {
    _voice.dispose();                          // ✅ stop TTS
    _cameraController.dispose();
    _celebrationAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No camera found');
        return;
      }

      final backCamera = cameras.first;
      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController.initialize();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Camera error: $e');
      }
    }
  }

  void _startHeadingUpdates() {
    FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          _heading = event.heading ?? 0;
        });
      }
    });
  }

  void _startLocationUpdates() async {
    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() => _error = 'Location permission denied');
      }
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentLocation = position;
          _calculateBearingAndDistance();
        });
      }
    });
  }

  /// Calculates bearing (direction) and distance to destination
  void _calculateBearingAndDistance() {
    if (_currentLocation == null) return;

    final lat1 = _currentLocation!.latitude * math.pi / 180;
    final lon1 = _currentLocation!.longitude * math.pi / 180;
    final lat2 = widget.destLat * math.pi / 180;
    final lon2 = widget.destLon * math.pi / 180;

    final y = math.sin(lon2 - lon1) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
            math.sin(lat1) * math.cos(lat2) * math.cos(lon2 - lon1);

    _bearing = (math.atan2(y, x) * 180 / math.pi + 360) % 360;

    const earthRadius = 6371000;
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
            math.cos(lat1) *
                math.cos(lat2) *
                math.sin(dLon / 2) *
                math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));
    _distance = earthRadius * c;

    if (_distance < 15 && !_hasArrivedAtDestination) {
      _hasArrivedAtDestination = true;
      _celebrationAnimationController.forward();
      _showArrivalCelebration();
    }
  }

  /// Calculate angle to rotate arrow (relative to device heading)
  double _getArrowAngle() {
    final angle = (_bearing - _heading) % 360;
    return angle * math.pi / 180;
  }

  // ✅ FIXED: single clean method — no nested function, no dead return statements
  /// Get direction instruction and speak via TTS when direction changes
  String _getDirectionInstruction() {
    final angle = ((_bearing - _heading) % 360);
    double normalizedAngle = angle > 180 ? angle - 360 : angle;

    NavigationDirection dir;
    String label;

    if (normalizedAngle > -20 && normalizedAngle < 20) {
      dir   = NavigationDirection.straight;
      label = "GO STRAIGHT";
    } else if (normalizedAngle >= 20 && normalizedAngle <= 180) {
      dir   = NavigationDirection.left;
      label = "TURN LEFT";
    } else {
      dir   = NavigationDirection.right;
      label = "TURN RIGHT";
    }

    // Speaks only when direction changes (debounced inside VoiceNavigationService)
    _voice.onDirectionUpdate(dir);

    return label;
  }

  /// Get color based on direction
  Color _getDirectionColor() {
    final instruction = _getDirectionInstruction();
    if (instruction == "GO STRAIGHT") {
      return Colors.green;
    } else if (instruction == "TURN LEFT") {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }

  /// Get emoji icon for direction
  String _getDirectionIcon() {
    final instruction = _getDirectionInstruction();
    if (instruction == "GO STRAIGHT") {
      return "⬆️";
    } else if (instruction == "TURN LEFT") {
      return "⬅️";
    } else {
      return "➡️";
    }
  }

  /// Get emoji icon for location type
  String _getLocationIcon() {
    switch (widget.locationType) {
      case 'admin':
        return '🏛️';
      case 'building':
        return '🏢';
      case 'cafeteria':
        return '🍽️';
      case 'library':
        return '📚';
      case 'auditorium':
        return '🎭';
      case 'playground':
        return '🎪';
      case 'hostel':
        return '🏠';
      case 'gym':
        return '🏋️';
      default:
        return '📍';
    }
  }

  /// Get color for location type
  Color _getLocationColor() {
    switch (widget.locationType) {
      case 'admin':
        return Colors.purple;
      case 'cafeteria':
        return Colors.orange;
      case 'library':
        return Colors.indigo;
      case 'auditorium':
        return Colors.red;
      case 'gym':
        return Colors.redAccent;
      case 'hostel':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  /// Get description for location type
  String _getLocationTypeLabel() {
    switch (widget.locationType) {
      case 'admin':
        return 'Administration';
      case 'cafeteria':
        return 'Cafeteria';
      case 'library':
        return 'Library';
      case 'auditorium':
        return 'Auditorium';
      case 'gym':
        return 'Gymnasium';
      case 'hostel':
        return 'Hostel';
      default:
        return 'Building';
    }
  }

  /// Format distance with appropriate units
  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)}km';
    }
  }

  /// Show arrival celebration pop-up
  void _showArrivalCelebration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _buildArrivalCelebration();
      },
    );
  }

  /// Build the animated arrival celebration dialog
  Widget _buildArrivalCelebration() {
    return ScaleTransition(
      scale: _celebrationScaleAnimation,
      child: FadeTransition(
        opacity: _celebrationOpacityAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getLocationColor().withOpacity(0.95),
                  _getLocationColor().withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getLocationColor().withOpacity(0.8),
                  blurRadius: 50,
                  spreadRadius: 20,
                ),
                BoxShadow(
                  color: _getLocationColor().withOpacity(0.4),
                  blurRadius: 100,
                  spreadRadius: 40,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getLocationIcon(),
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '🎉 YOU ARRIVED! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.destName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getLocationTypeLabel(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _getLocationColor(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.check_circle, size: 24),
                      label: const Text(
                        'Great! Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.destName),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorScreen();
    }

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_cameraController),

        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: _getDirectionColor().withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getDirectionColor().withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getDirectionInstruction(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDirectionIcon(),
                    style: const TextStyle(fontSize: 32),
                  ),
                ],
              ),
            ),
          ),
        ),

        Center(
          child: Transform.rotate(
            angle: _getArrowAngle(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.6),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_upward, size: 80, color: Colors.green),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _getLocationColor().withOpacity(0.8),
                        _getLocationColor().withOpacity(0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getLocationColor().withOpacity(0.7),
                        blurRadius: 40,
                        spreadRadius: 15,
                      ),
                      BoxShadow(
                        color: _getLocationColor().withOpacity(0.4),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getLocationColor().withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                      ),
                      Text(
                        _getLocationIcon(),
                        style: const TextStyle(fontSize: 50),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _getLocationColor().withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getLocationColor().withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    _getLocationTypeLabel(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.destName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDistance(_distance),
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 24,
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

        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoBox('HEADING', '${_heading.toStringAsFixed(0)}°'),
                _buildInfoBox('BEARING', '${_bearing.toStringAsFixed(0)}°'),
                _buildInfoBox(
                  'ANGLE',
                  '${(_bearing - _heading).toStringAsFixed(0)}°',
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                  backgroundColor: Colors.red.shade700,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Keep device level for best results',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_distance < 20)
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'You have arrived!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade700),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red.shade700),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}