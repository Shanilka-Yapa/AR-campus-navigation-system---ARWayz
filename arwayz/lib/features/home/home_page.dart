import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../qr_scanner/qr_scanner_page.dart';
import '../ar_navigation/ar_camera_page.dart';
import '../outdoor_navigation/outdoor_navigation_page.dart';
import '../destinations/navigation_selector_page.dart';
import '../admin/admin_login_page.dart';
import '../indoor_navigation/indoor_navigation_page.dart';
import '../../core/models/qr_payload.dart';
import '../indoor_navigation/building_3d_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (!mounted || result is! QrPayload) {
      return;
    }

    if (result.buildingId != IndoorNavigationPage.buildingId ||
        result.floor != IndoorNavigationPage.floor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan an IS Department ground-floor ARWayz QR code.'),
        ),
      );
      return;
    }

    context.push('/indoor', extra: result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/building_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          //Camera open for AR
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              children: [
                // NEW: AR Compass Navigation (Practical AR Solution)
                FloatingActionButton(
                  heroTag: 'ar-navigation',
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
                  heroTag: 'outdoor-navigation',
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
                  heroTag: 'building-3d',
                  backgroundColor: const Color(0xFFB7791F),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Building3DPage(),
                      ),
                    );
                  },
                  tooltip: 'Explore 3D Building',
                  child: const Icon(Icons.business, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'camera',
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
          //Back button
          Positioned(
            top: 40, //adjust for status bar
            left: 16,
            child: GestureDetector(
              onTap: () {
                SystemNavigator.pop(); // <- This exits the app
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),

          // Secret Admin Button (top right)
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginPage(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.grey.shade600,
                  size: 18,
                ),
              ),
            ),
          ),

          /* Dark overlay
          Container(
            color: Colors.black.withOpacity(0.45),
          ),*/

          // Foreground content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: () => context.push('/events'),
                      icon: const Icon(Icons.event, color: Colors.white),
                      label: const Text(
                        'Campus Events',
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
                        mainAxisSize: MainAxisSize
                            .min, // Row only takes the space it needs
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Centers content
                        children: const [
                          Icon(
                            Icons.qr_code_scanner,
                            color: Color(0xFF1A2D33),
                          ), // Icon at start
                          SizedBox(width: 10), // Space between icon and text
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
