import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'qr_scanner_page.dart';
import 'package:flutter/services.dart';
import 'splash_page.dart';
import 'ar_camera_page.dart';
import 'building_areas_page.dart';
import 'outdoor_navigation_page.dart';
import 'google_map_page.dart';
import 'insidefac.dart'; // Fixed: Added missing semicolon
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARWayz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 9, 126, 139),
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _buildingIdController = TextEditingController();

  void _onSubmit() {
    final buildingId = _buildingIdController.text.trim();
    if (buildingId.toUpperCase() == 'B001') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuildingAreasPage(buildingId: buildingId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Building ID')),
      );
    }
  }

  Future<void> _handleMapNavigation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GoogleMapPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permission is required for the map.')),
      );
    }
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );
    if (result != null) debugPrint("Got QR code: $result");
  }

  Widget _buildBottomIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Icon(icon, color: const Color(0xFF1A2D33), size: 26),
      ),
    );
  }

  @override
  void dispose() {
    _buildingIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/building_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () => SystemNavigator.pop(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),

          // Main UI
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      textAlign: TextAlign.center,
                      controller: _buildingIdController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.location_city,
                            color: Color(0xFF1A2D33)),
                        hintText: 'Enter Building ID',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _onSubmit,
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text('Submit',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2D33),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _openCamera,
                      icon: const Icon(Icons.qr_code_scanner,
                          color: Color(0xFF1A2D33)),
                      label: const Text('Scan QR Code',
                          style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation Row
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomIconButton(
                  icon: Icons.navigation,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const OutdoorNavigationPage())),
                ),
                _buildBottomIconButton(
                  icon: Icons.camera_alt,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ARCameraPage())),
                ),
                _buildBottomIconButton(
                  icon: Icons.near_me,
                  onTap: _handleMapNavigation,
                ),
                _buildBottomIconButton(
                  icon: Icons.map,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FacultyMapPage()), // Using GoogleMapPage or your custom insidefac class
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}