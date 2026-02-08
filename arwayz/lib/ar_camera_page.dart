import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ARCameraPage extends StatefulWidget {
  const ARCameraPage({super.key});

  @override
  State<ARCameraPage> createState() => _ARCameraPageState();
}

class _ARCameraPageState extends State<ARCameraPage> {
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;

      if (cameras.isEmpty) {
        debugPrint('No cameras available');
        return;
      }

      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      try {
        await _cameraController!.initialize();
      } catch (e) {
        debugPrint('Camera initialization error: $e');
        _cameraController?.dispose();
        _cameraController = null;
        if (mounted) {
          setState(() {});
        }
        return;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _cameraController?.dispose();
      _cameraController = null;
      if (mounted) {
        setState(() {});
      }
    }
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          CameraPreview(_cameraController!),

          // AR Arrow overlay
          Center(
            child: Icon(
              Icons.navigation,
              size: 120,
              color: Colors.greenAccent.withOpacity(0.85),
            ),
          ),

          // Back button
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
}
