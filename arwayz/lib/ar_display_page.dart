import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ARDisplayPage extends StatefulWidget {
  final String qrCode;

  const ARDisplayPage({super.key, required this.qrCode});

  @override
  State<ARDisplayPage> createState() => _ARDisplayPageState();
}

class _ARDisplayPageState extends State<ARDisplayPage> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _modelExists = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _checkModelExists();
  }

  Future<void> _checkModelExists() async {
    try {
      final assetPath = 'assets/models/university_logo.glb';
      final data = await rootBundle.load(assetPath);
      setState(() {
        _modelExists = true;
      });
      print('✓ Local GLB model found! (${data.lengthInBytes} bytes)');
    } catch (e) {
      setState(() {
        _modelExists = false;
      });
      print('✗ Local model not found: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isNotEmpty) {
        final cameraDesc = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );

        _cameraController = CameraController(
          cameraDesc,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
            _isLoading = false;
          });
          print('✓ Camera initialized successfully!');
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        print('✗ No cameras found on device');
      }
    } catch (e) {
      print('❌ Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getHtmlContent() async {
    String modelSrc =
        'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

    // Try to load local GLB file if it exists
    if (_modelExists) {
      try {
        final data = await rootBundle.load('assets/models/university_logo.glb');
        final base64Data = base64Encode(data.buffer.asUint8List());
        modelSrc = 'data:model/gltf-binary;base64,$base64Data';
        print('✓ Loaded GLB as base64 data URL (${data.lengthInBytes} bytes)');
      } catch (e) {
        print('⚠ Failed to load GLB as data URL: $e');
      }
    }

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script async src="https://cdn.jsdelivr.net/npm/@google/model-viewer@3.3.0/dist/model-viewer.min.js"></script>
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      font-family: Arial, sans-serif;
    }
    body {
      background: transparent;
    }
    model-viewer {
      width: 100%;
      height: 100%;
      background: transparent;
      --progress-bar-height: 0px;
    }
    #loading {
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      background: rgba(0, 0, 0, 0.6);
      color: white;
      padding: 20px;
      border-radius: 8px;
      z-index: 100;
      font-size: 14px;
      text-align: center;
    }
  </style>
</head>
<body>
  <div id="loading">Loading 3D Model...</div>
  
  <model-viewer
    id="viewer"
    src="$modelSrc"
    alt="3D Model"
    camera-controls
    touch-action="manipulation"
    auto-rotate
    rotation-per-second="15deg"
    exposure="0.8"
    environment-image="neutral"
  ></model-viewer>

  <script>
    const viewer = document.querySelector('model-viewer');
    const loading = document.getElementById('loading');
    
    // Wait for model-viewer to be defined
    if (customElements.get('model-viewer')) {
      initViewer();
    } else {
      document.addEventListener('DOMContentLoaded', () => {
        setTimeout(initViewer, 500);
      });
    }
    
    function initViewer() {
      if (!viewer) {
        if (loading) loading.textContent = 'Error: model-viewer element not found';
        return;
      }
      
      viewer.addEventListener('load', () => {
        console.log('✓ Model loaded successfully');
        if (loading) loading.style.display = 'none';
      });
      
      viewer.addEventListener('error', (e) => {
        console.error('Model error:', e);
        if (loading) loading.textContent = 'Failed to load model';
      });
      
      // Fallback timeout - hide loading after 4 seconds anyway
      setTimeout(() => {
        if (loading) loading.style.display = 'none';
      }, 4000);
    }
  </script>
</body>
</html>
    ''';
  }

  @override
  void dispose() {
    if (_isCameraInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Camera Experience'),
        backgroundColor: const Color.fromARGB(255, 9, 126, 139),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 9, 126, 139),
                ),
              ),
            )
          : _isCameraInitialized
          ? _buildARView()
          : _buildNoCameraUI(),
    );
  }

  Widget _buildNoCameraUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Camera Not Available',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Please check camera permissions or try on a physical device',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 9, 126, 139),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildARView() {
    return Stack(
      children: [
        // Camera Feed Background
        SizedBox.expand(child: CameraPreview(_cameraController)),

        // 3D Model Overlay using WebView
        Center(
          child: FutureBuilder<String>(
            future: _getHtmlContent(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: 280,
                  height: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withAlpha(100),
                        blurRadius: 20,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 9, 126, 139),
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  width: 280,
                  height: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red, width: 2),
                    color: Colors.red.withAlpha(50),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error loading model:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),
                );
              }

              final htmlContent = snapshot.data ?? '';
              return Container(
                width: 280,
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withAlpha(100),
                      blurRadius: 20,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..setBackgroundColor(Colors.transparent)
                      ..loadHtmlString(htmlContent),
                  ),
                ),
              );
            },
          ),
        ),

        // Top Info Panel
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(220),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.teal, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'ARWayz Campus AR View',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'QR: ${widget.qrCode}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (!_modelExists)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(150),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '⚠️ Using Demo Model - Add GLB to assets/models/',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(150),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '✓ Your GLB Model Loaded & Spinning',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Bottom Controls Panel
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(220),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 8),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📱 AR Controls',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '• Model spins slowly automatically\n• Pinch to zoom • Drag to rotate\n• Move device to view from different angles',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text(
                      'Exit AR Experience',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 9, 126, 139),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
