import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

class ARCameraPage extends StatefulWidget {
  const ARCameraPage({super.key});

  @override
  State<ARCameraPage> createState() => _ARCameraPageState();
}

class _ARCameraPageState extends State<ARCameraPage> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;

  double? _deviceHeading;
  Position? _currentPosition;
  double? _targetBearing;
  double? _distance;

  bool _showBuildingCards = true;
  String? _selectedBuilding;

  final Map<String, List<double>> buildings = {
    "CEE": [6.078164889030307, 80.1914069593956],
    "MME": [6.07859285299213, 80.19170316455609],
    "EIE": [6.078235704870035, 80.19216766168712],
    "Main Cafeteria": [6.078713286039461, 80.19253361063727],
    "Faculty Library": [6.079367213340776, 80.19153075282063],
    "Faculty Auditorium": [6.0791364229092055, 80.19126639090263],
  };

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initLocation();
    _initCompass();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _cameraController =
        CameraController(_cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  void _initCompass() {
    FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        setState(() {
          _deviceHeading = event.heading;
        });
      }
    });
  }

  void _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    Geolocator.getPositionStream().listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  void _selectBuilding(String name) {
    if (_currentPosition == null) return;

    final coords = buildings[name]!;

    final bearing = Geolocator.bearingBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      coords[0],
      coords[1],
    );

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      coords[0],
      coords[1],
    );

    setState(() {
      _selectedBuilding = name;
      _targetBearing = bearing;
      _distance = distance;
      _showBuildingCards = false;
    });
  }

  void _resetSelection() {
    setState(() {
      _showBuildingCards = true;
      _selectedBuilding = null;
      _targetBearing = null;
      _distance = null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_cameraController!),

          /// 🔄 Rotating Arrow
          if (!_showBuildingCards &&
              _deviceHeading != null &&
              _targetBearing != null)
            Center(
              child: Transform.rotate(
                angle: ((_targetBearing! - _deviceHeading!) * (pi / 180)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.navigation,
                      size: 140,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedBuilding ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_distance != null)
                      Text(
                        "${_distance!.toStringAsFixed(0)} m",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _resetSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.6),
                      ),
                      child: const Text("Change Destination"),
                    )
                  ],
                ),
              ),
            ),

          /// 🏢 Glassmorphism Building Cards
          if (_showBuildingCards)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: buildings.keys
                      .map((name) => _buildCard(name))
                      .toList(),
                ),
              ),
            ),

          /// 🔙 Back Button
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String name) {
    return GestureDetector(
      onTap: () => _selectBuilding(name),
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 18),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getBuildingIcon(name),
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBuildingIcon(String name) {
    switch (name) {
      case "CEE":
      case "MME":
      case "EIE":
        return Icons.engineering;
      case "Main Cafeteria":
        return Icons.restaurant;
      case "Faculty Library":
        return Icons.local_library;
      case "Faculty Auditorium":
        return Icons.theater_comedy;
      default:
        return Icons.location_on;
    }
  }
}