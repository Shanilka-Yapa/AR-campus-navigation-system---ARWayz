import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'qr_scanner_page.dart';
import 'package:flutter/services.dart';
import 'splash_page.dart';
import 'ar_camera_page.dart';
import 'building_areas_page.dart';
import 'outdoor_navigation_page.dart';
import 'navigation_selector_page.dart';
import 'Building_Details_page.dart';

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

  // Unified Submit Logic
  void _onSubmit() {
    final buildingId = _buildingIdController.text.trim();

    if (buildingId.toUpperCase() == 'B001') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuildingDetailsPage(
            building: sampleBuilding,
            onStartArNavigation: () {
              Navigator.pop(context); // Close details
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuildingAreasPage(buildingId: buildingId),
                ),
              );
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Building ID')),
      );
    }
  }

  @override
  void dispose() {
    _buildingIdController.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (result != null) {
      print("Got QR code: $result");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          // 1. Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/building_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Destination Info Button (Bottom Left) — Hirushi's Feature
          // Locate this button in your main.dart inside the Stack
          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton.extended(
              heroTag: 'newFeatureBtn',
              backgroundColor: const Color(0xFF4ECDC4),
              onPressed: () {
                // CHANGE: Navigate to the List of Buildings instead of a single one
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CampusSelectorPage(),
                  ),
                );
              },
              icon: const Icon(Icons.list_alt_rounded, color: Color(0xFF1A2D33)), // Changed icon to 'list'
              label: const Text(
                "All Buildings", // Changed label for clarity
                style: TextStyle(
                  color: Color(0xFF1A2D33),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 3. Navigation Buttons (Bottom Right) — unchanged
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'btn1',
                  backgroundColor: Colors.green.shade700,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NavigationSelectorPage(),
                      ),
                    );
                  },
                  tooltip: 'AR Navigation',
                  child: const Icon(
                    Icons.compass_calibration,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'btn2',
                  backgroundColor: const Color(0xFF1A2D33),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OutdoorNavigationPage(),
                      ),
                    );
                  },
                  tooltip: 'Navigate to University',
                  child: const Icon(Icons.navigation, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'btn3',
                  backgroundColor: const Color(0xFF1A2D33),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ARCameraPage(),
                      ),
                    );
                  },
                  tooltip: 'Open Camera',
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ],
            ),
          ),

          // 4. Back button — unchanged
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () {
                SystemNavigator.pop();
              },
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

          // 5. Foreground content (Input and Search) — unchanged
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 20),
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
                        prefixIcon: const Icon(
                          Icons.location_city,
                          color: Color(0xFF1A2D33),
                        ),
                        hintText: 'Enter Building ID',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _onSubmit,
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2D33),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _openCamera,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 6,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.qr_code_scanner,
                            color: Color(0xFF1A2D33),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Scan QR Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}