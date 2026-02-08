import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

import '../models/location_model.dart';
import '../helpers/ar_navigation_helper.dart';

class ARCameraNavigationPage extends StatefulWidget {
  final LatLng currentLocation;
  final LocationModel targetLocation;

  const ARCameraNavigationPage({
    super.key,
    required this.currentLocation,
    required this.targetLocation,
  });

  @override
  State<ARCameraNavigationPage> createState() => _ARCameraNavigationPageState();
}

class _ARCameraNavigationPageState extends State<ARCameraNavigationPage> {
  CameraController? _cameraController;
  bool _cameraInitialized = false;
  double _bearing = 0;

  final List<String> _engineerQuotes = [
    '"Engineering is the practical application of science" - Unknown',
    '"To invent, you need a good imagination and a pile of junk" - Thomas Edison',
    '"The engineer has been, and will continue to be, a maker of history" - James Kip Finch',
    '"We are the problem solvers" - Engineers',
    '"Navigation is the art and science of getting from point A to point B" - Engineers',
  ];

  @override
  void initState() {
    super.initState();
    try {
      debugPrint('AR Page initState - calculating bearing...');
      _calculateBearing();
      debugPrint('AR Page initState - bearing calculated: $_bearing');

      debugPrint('AR Page initState - initializing camera...');
      _initializeCamera();
      debugPrint('AR Page initState - complete');
    } catch (e) {
      debugPrint('Error in AR initState: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final cameraPermission = await Permission.camera.request();

      if (!cameraPermission.isGranted) {
        debugPrint('Camera permission denied');
        if (mounted) {
          setState(() {
            _cameraInitialized = false;
          });
        }
        return;
      }

      // Check if widget is still mounted after async operation
      if (!mounted) return;

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras available');
        if (mounted) {
          setState(() {
            _cameraInitialized = false;
          });
        }
        return;
      }

      // Check mounted again before accessing state
      if (!mounted) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      try {
        await _cameraController!.initialize();
      } catch (e) {
        debugPrint('Camera initialization error: $e');
        _cameraController?.dispose();
        _cameraController = null;
        if (mounted) {
          setState(() {
            _cameraInitialized = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _cameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      _cameraController?.dispose();
      _cameraController = null;
      if (mounted) {
        setState(() {
          _cameraInitialized = false;
        });
      }
    }
  }

  void _calculateBearing() {
    try {
      if (widget.currentLocation == null || widget.targetLocation == null) {
        debugPrint('Null location data');
        _bearing = 0;
        return;
      }
      _bearing = ARNavigationHelper.calculateBearing(
        widget.currentLocation,
        widget.targetLocation.coordinates,
      );
      debugPrint('Bearing calculated: $_bearing');
    } catch (e) {
      debugPrint('Bearing calculation error: $e');
      _bearing = 0;
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
    try {
      _cameraController?.dispose();
      _cameraController = null;
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: _cameraInitialized && _cameraController != null
                  ? CameraPreview(_cameraController!)
                  : const Center(
                      child: Text(
                        'AR Camera Demo',
                        style: TextStyle(color: Colors.yellow, fontSize: 16),
                      ),
                    ),
            ),

            // AR Overlay
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Info
                Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    bottom: false,
                    child: Text(
                      'Navigate to ${widget.targetLocation.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Center: Arrow
                Transform.rotate(
                  angle: _bearing * math.pi / 180,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.3),
                      border: Border.all(color: Colors.cyan, width: 3),
                    ),
                    child: const Center(
                      child: Text(
                        '↑',
                        style: TextStyle(
                          fontSize: 80,
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Direction
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    border: Border.all(color: Colors.cyan, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Direction: ${_getCardinalDirection(_bearing)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Bearing: ${_bearing.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom: Quote and Close
                Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.purpleAccent,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            _engineerQuotes[_bearing.toInt() %
                                _engineerQuotes.length],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
