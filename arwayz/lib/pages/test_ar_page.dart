import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math' as math;

class TestARPage extends StatefulWidget {
  final LatLng currentLocation;

  const TestARPage({super.key, required this.currentLocation});

  @override
  State<TestARPage> createState() => _TestARPageState();
}

class _TestARPageState extends State<TestARPage> with TickerProviderStateMixin {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _cameraInitialized = false;

  // Animation for rotating arrow
  late AnimationController _rotationController;
  double _currentRotation = 0;
  double _distance = 150.5;

  // Test engineer quotes
  final List<String> _engineerQuotes = [
    '"Engineering is the practical application of science" - Unknown',
    '"To invent, you need a good imagination and a pile of junk" - Thomas Edison',
    '"The engineer has been, and will continue to be, a maker of history" - James Kip Finch',
    '"Engineering is not only study of 45 subjects for the semester, it\'s study of 45 ways to save a CGPA" - Student',
    '"We are the problem solvers" - Engineers',
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    // Setup rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _rotationController.addListener(() {
      setState(() {
        _currentRotation = _rotationController.value * 360;
        // Simulate distance decreasing
        _distance = 150.5 - (_rotationController.value * 50);
      });
    });
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No camera available')));
          // Still show AR without camera
          setState(() {
            _cameraInitialized = false;
          });
        }
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _cameraController.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _cameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      // Continue without camera - just show AR elements
      if (mounted) {
        setState(() {
          _cameraInitialized = false;
        });
      }
    }
  }

  String _getCardinalDirection(double degrees) {
    final normalizedDegrees = degrees % 360;
    if (normalizedDegrees < 22.5 || normalizedDegrees >= 337.5) return 'N';
    if (normalizedDegrees < 67.5) return 'NE';
    if (normalizedDegrees < 112.5) return 'E';
    if (normalizedDegrees < 157.5) return 'SE';
    if (normalizedDegrees < 202.5) return 'S';
    if (normalizedDegrees < 247.5) return 'SW';
    if (normalizedDegrees < 292.5) return 'W';
    return 'NW';
  }

  @override
  void dispose() {
    _rotationController.dispose();
    if (_cameraInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background - Camera or solid color
          if (_cameraInitialized)
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: CameraPreview(_cameraController),
                  );
                } else {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black87,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
              },
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black87,
              child: const Center(
                child: Text(
                  'Camera Demo Mode\n(Camera not available)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.yellow, fontSize: 16),
                ),
              ),
            ),

          // AR Overlay
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top info bar
                Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '🧪 TEST AR MODE 🧪',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Library - Engineering Faculty Navigation Demo',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Center: Rotating Arrow
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated rotating arrow
                    Transform.rotate(
                      angle: _currentRotation * math.pi / 180,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.3),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            '↑',
                            style: TextStyle(
                              fontSize: 80,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Direction text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Direction: ${_getCardinalDirection(_currentRotation)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bearing: ${_currentRotation.toStringAsFixed(1)}°',
                            style: const TextStyle(
                              color: Colors.cyan,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Bottom: Distance and Engineer Quote
                Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Distance display
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Distance: ${_distance.toStringAsFixed(1)} m',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Engineer Quote
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.purpleAccent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '💡 Engineer\'s Wisdom 💡',
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _engineerQuotes[_currentRotation.toInt() %
                                  _engineerQuotes.length],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Close button
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Close AR Test'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
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
