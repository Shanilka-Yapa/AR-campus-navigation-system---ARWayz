import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'qr_scanner_page.dart';
import 'package:flutter/services.dart';
import 'splash_page.dart';
import 'ar_camera_page.dart';


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
  bool _showList = false;

  final List<String> _areas = [
    'Dining area 01',
    'Dining area 02',
    'Bookshop',
    'Study area 01',
    'Carrom room',
    'Art room',
    'Gym',
    'Washroom',
  ];

  void _onSubmit() {
    final buildingId = _buildingIdController.text.trim();
    setState(() {
      _showList = buildingId.toUpperCase() == 'B001';
    });
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
      // You can handle the scanned code here
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:null,
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
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF1A2D33),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ARCameraPage(),
                  ),
                );
              },
              child: const Icon(Icons.camera_alt, color: Colors.white),
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
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.black),
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
                    TextField(
                      textAlign: TextAlign.center,
                      controller: _buildingIdController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20), //round corners
                          borderSide: BorderSide.none, //remove the default border
                        ),
                        prefixIcon: Icon(Icons.location_city, color: Color(0xFF1A2D33)),
                        label: Center(
                          child:
                          Text(
                              'Building ID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2D33),
                                fontSize: 20,
                              )),
                        ),
                        hintText: 'Enter the building ID',
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _onSubmit,
                      icon: Icon(
                        Icons.send, // Example icon
                        color: Colors.white, // Icon color
                      ),
                      label: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A2D33), // Button background color
                        foregroundColor: Colors.white,       // Default color for text & icon (optional, already set above)
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Rounded corners
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
                        mainAxisSize: MainAxisSize.min,       // Row only takes the space it needs
                        mainAxisAlignment: MainAxisAlignment.center, // Centers content
                        children: const [
                          Icon(Icons.qr_code_scanner, color: Color(0xFF1A2D33)), // Icon at start
                          SizedBox(width: 10),                                   // Space between icon and text
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

                    if (_showList) ...[
                      const SizedBox(height: 32),
                      const Text(
                        'Main Cafeteria',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_areas.length, (index) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              _areas[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing:
                            const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              print('Selected area: ${_areas[index]}');
                            },
                          ),
                        );
                      }),
                    ],
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
