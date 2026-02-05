/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // OSM Widget
import 'package:latlong2/latlong.dart';      // OSM Coordinates
import 'package:geolocator/geolocator.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  // Controller to move the map
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  // TRIGGER POINT: Security Room
  final LatLng _facultyTriggerPoint = const LatLng(6.079587, 80.192484);

  // State: Are we inside?
  bool _isInsideFaculty = false;

  // 1. HARDCODED ROUTE (Since we can't use Directions API for free)
  // This is a straight line. For a real demo, add a few more points in between
  // to match the road shape.
  List<LatLng> _routePoints = [];

  // 2. FACULTY PLACES (Using latlong2 package)
  final List<Map<String, dynamic>> _facultyInternalPlaces = [
    {'name': 'DMME Dept', 'pos': LatLng(6.078419, 80.191807), 'color': Colors.blue},
    {'name': 'Library', 'pos': LatLng(6.079441, 80.191594), 'color': Colors.green},
    {'name': 'Canteen', 'pos': LatLng(6.078564, 80.192356), 'color': Colors.orange},
    {'name': 'Security', 'pos': LatLng(6.079587, 80.192484), 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _updateLocation(LatLng(position.latitude, position.longitude));
    });
  }

  void _updateLocation(LatLng pos) {
    if (!mounted) return;

    setState(() {
      _currentLocation = pos;

      // Update the "Fake" route to start from current location
      if (!_isInsideFaculty) {
        _routePoints = [
          pos, // Start
          // You can add intermediate points here if you know the road coords
          _facultyTriggerPoint // End
        ];
      }
    });

    double distance = const Distance().as(LengthUnit.Meter, pos, _facultyTriggerPoint);

    // Trigger Logic
    if (distance < 50 && !_isInsideFaculty) {
      _enterFacultyMode();
    }
  }

  void _enterFacultyMode() {
    setState(() {
      _isInsideFaculty = true;
      _routePoints.clear(); // Clear the line
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Welcome to Faculty! Switched to internal map.")),
    );

    // Zoom in
    _mapController.move(const LatLng(6.078419, 80.191807), 18.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation!,
              initialZoom: 16.0,
              // Keep the map constrained so users don't get lost
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(6.070, 80.180), // SouthWest
                  const LatLng(6.090, 80.200), // NorthEast
                ),
              ),
            ),
            children: [
              // 1. THE FREE MAP TILES (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.arwayz',
              ),

              // 2. THE BLUE NAVIGATION LINE
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 6.0,
                    color: Colors.blue.withOpacity(0.7),
                  ),
                ],
              ),

              // 3. MARKERS
              MarkerLayer(
                markers: [
                  // Current Location Marker
                  Marker(
                    point: _currentLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
                  ),

                  // Destination Marker (Outdoor Mode)
                  if (!_isInsideFaculty)
                    Marker(
                      point: _facultyTriggerPoint,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),

                  // Internal Faculty Markers (Indoor Mode)
                  if (_isInsideFaculty)
                    ..._facultyInternalPlaces.map((place) => Marker(
                      point: place['pos'],
                      width: 80, // Wide enough for text
                      height: 60,
                      child: Column(
                        children: [
                          Icon(Icons.location_on, color: place['color'], size: 30),
                          Container(
                            padding: const EdgeInsets.all(2),
                            color: Colors.white.withOpacity(0.8),
                            child: Text(
                              place['name'],
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),
                ],
              ),
            ],
          ),

          // BACK BUTTON
          Positioned(
            top: 45,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: const Color(0xFF1A2D33),
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),

          // ZOOM BUTTONS (Optional, OSM doesn't have built-in zoom buttons)
          Positioned(
            bottom: 30,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoom_in",
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom + 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                  child: const Icon(Icons.add, color: Colors.black),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoom_out",
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final zoom = _mapController.camera.zoom - 1;
                    _mapController.move(_mapController.camera.center, zoom);
                  },
                  child: const Icon(Icons.remove, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final MapController _mapController = MapController();
  final PageController _pageController = PageController(viewportFraction: 0.85);

  LatLng? _currentLocation;
  int? _selectedPlaceIndex;
  List<LatLng> _routePoints = [];
  bool _isInsideFaculty = false;

  // --------------------------------------------------------
  // 1. CONFIGURATION
  // --------------------------------------------------------

  // The trigger point (Security Room Entrance)
  final LatLng _securityEntrance = const LatLng(6.079587868284366, 80.19248463513672);

  // A "Main Junction" point to make paths look realistic (fake routing)
  final LatLng _mainRoadJunction = const LatLng(6.079000, 80.192000);

  // The Boundaries of the Faculty (User cannot zoom out past this)
  final LatLngBounds _facultyBounds = LatLngBounds(
    const LatLng(6.0770, 80.1900), // South-West corner
    const LatLng(6.0810, 80.1940), // North-East corner
  );

  // ALL FACULTY PLACES DATA
  final List<Map<String, dynamic>> _facultyPlaces = [
    {
      'name': 'Security Room',
      'desc': 'Main Entrance Security',
      'pos': LatLng(6.079587868284366, 80.19248463513672),
      'color': Colors.red,
      'icon': Icons.security,
    },
    {
      'name': 'Admin Building',
      'desc': 'Administration Office',
      'pos': LatLng(6.079603521339309, 80.19280274184622),
      'color': Colors.redAccent,
      'icon': Icons.admin_panel_settings,
    },
    {
      'name': 'Main Library',
      'desc': 'Faculty Library',
      'pos': LatLng(6.079441318479151, 80.19159422228692),
      'color': Colors.green,
      'icon': Icons.menu_book,
    },
    {
      'name': 'Main Cafeteria',
      'desc': 'Student Canteen',
      'pos': LatLng(6.078564478087978, 80.19235671396622),
      'color': Colors.orange,
      'icon': Icons.restaurant,
    },
    {
      'name': 'DMME Dept',
      'desc': 'Mechanical & Manufacturing Engineering',
      'pos': LatLng(6.078419035928309, 80.19180745565212),
      'color': Colors.blue,
      'icon': Icons.engineering,
    },
    {
      'name': 'DEIE Dept',
      'desc': 'Electrical & Information Engineering',
      'pos': LatLng(6.078174210477643, 80.19217524440813),
      'color': Colors.blue,
      'icon': Icons.electrical_services,
    },
    {
      'name': 'DCEE Dept',
      'desc': 'Civil & Environmental Engineering',
      'pos': LatLng(6.078184917639603, 80.1913757454891),
      'color': Colors.blue,
      'icon': Icons.construction,
    },
    {
      'name': 'DMME Workshop',
      'desc': 'Engineering Workshop',
      'pos': LatLng(6.07750153254501, 80.19094465795094),
      'color': Colors.blueGrey,
      'icon': Icons.build,
    },
    {
      'name': 'Basketball Court',
      'desc': 'Sports Area',
      'pos': LatLng(6.0788110038925245, 80.19150907917387),
      'color': Colors.greenAccent,
      'icon': Icons.sports_basketball,
    },
    {
      'name': 'Buddha Statue',
      'desc': 'Religious Area',
      'pos': LatLng(6.079499327781828, 80.19106611535531),
      'color': Colors.amber,
      'icon': Icons.self_improvement,
    },
    {
      'name': 'Guest House',
      'desc': 'University Guest House',
      'pos': LatLng(6.078329836239884, 80.19086155237294),
      'color': Colors.purple,
      'icon': Icons.hotel,
    },
    {
      'name': 'Hostel A',
      'desc': 'Student Accommodation',
      'pos': LatLng(6.07778475294792, 80.19305157146461),
      'color': Colors.indigo,
      'icon': Icons.bed,
    },
    {
      'name': 'Hostel B',
      'desc': 'Student Accommodation',
      'pos': LatLng(6.078004432201199, 80.19282328635329),
      'color': Colors.indigo,
      'icon': Icons.bed,
    },
    {
      'name': 'Hostel C',
      'desc': 'Student Accommodation',
      'pos': LatLng(6.078171176472731, 80.1932300580759),
      'color': Colors.indigo,
      'icon': Icons.bed,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    // Check location constantly
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2, // Update every 2 meters for smooth tracking
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _updateUserLocation(LatLng(position.latitude, position.longitude));
    });
  }

  void _updateUserLocation(LatLng pos) {
    if (!mounted) return;

    setState(() {
      _currentLocation = pos;

      // Check Distance to Security Room
      double dist = const Distance().as(LengthUnit.Meter, pos, _securityEntrance);

      // TRIGGER: If closer than 50m to Security, ENTER FACULTY MODE
      if (dist < 50 && !_isInsideFaculty) {
        _enterFacultyMode();
      }

      // Live Path Updates: Recalculate line as user moves
      if (_selectedPlaceIndex != null) {
        _routePoints = _calculateSmartPath(pos, _facultyPlaces[_selectedPlaceIndex!]['pos']);
      }
    });
  }

  void _enterFacultyMode() {
    setState(() {
      _isInsideFaculty = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Entered Faculty Premises. Map Locked."),
        backgroundColor: Color(0xFF1A2D33),
      ),
    );

    // Zoom IN and Lock Camera to the faculty center
    _mapController.move(_mainRoadJunction, 18.0);
  }

  // --------------------------------------------------------
  // 2. SMART ROUTING LOGIC
  // --------------------------------------------------------
  List<LatLng> _calculateSmartPath(LatLng start, LatLng end) {
    if (_isInsideFaculty) {
      // "Fake" Road Network: Go to Junction first, then to destination
      // This prevents the line from cutting straight through buildings
      return [
        start,
        _mainRoadJunction,
        end
      ];
    } else {
      // Outside faculty: Just straight line is fine
      return [start, end];
    }
  }

  void _onPlaceSelected(int index) {
    setState(() {
      _selectedPlaceIndex = index;
      if (_currentLocation != null) {
        _routePoints = _calculateSmartPath(_currentLocation!, _facultyPlaces[index]['pos']);
      }
    });

    if (_isInsideFaculty) {
      // If inside, just center on the destination with high zoom
      _mapController.move(_facultyPlaces[index]['pos'], 18.5);
    } else {
      // If outside, fit both user and dest
      _fitBounds(_currentLocation!, _facultyPlaces[index]['pos']);
    }
  }

  void _fitBounds(LatLng p1, LatLng p2) {
    double minLat = p1.latitude < p2.latitude ? p1.latitude : p2.latitude;
    double maxLat = p1.latitude > p2.latitude ? p1.latitude : p2.latitude;
    double minLng = p1.longitude < p2.longitude ? p1.longitude : p2.longitude;
    double maxLng = p1.longitude > p2.longitude ? p1.longitude : p2.longitude;

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng)),
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // ------------------------------------------
          // MAP LAYER
          // ------------------------------------------
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation!,
              initialZoom: 16.0,
              // DYNAMIC CONSTRAINT:
              // If inside faculty -> Restrict strictly to bounds
              // If outside -> Allow viewing the area
              cameraConstraint: _isInsideFaculty
                  ? CameraConstraint.contain(bounds: _facultyBounds)
                  : const CameraConstraint.unconstrained(),
              minZoom: _isInsideFaculty ? 17.0 : 10.0, // Force high zoom inside
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.arwayz',
              ),

              // NAVIGATION PATH
              PolylineLayer(
                polylines: [
                  if (_routePoints.isNotEmpty)
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 6.0,
                      color: Colors.blueAccent.withOpacity(0.8),
                      isDotted: true,
                    ),
                ],
              ),

              // MARKERS
              MarkerLayer(
                markers: [
                  // User (Blue Dot)
                  Marker(
                    point: _currentLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [BoxShadow(blurRadius: 5)],
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),

                  // Destination Markers
                  ..._facultyPlaces.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var place = entry.value;
                    bool isSelected = idx == _selectedPlaceIndex;

                    // Only show internal markers if inside faculty OR if it's the selected destination
                    bool shouldShow = _isInsideFaculty || isSelected;

                    if (!shouldShow) return const Marker(point: LatLng(0,0), child: SizedBox());

                    return Marker(
                      point: place['pos'],
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          _pageController.jumpToPage(idx);
                          _onPlaceSelected(idx);
                        },
                        child: Column(
                          children: [
                            Icon(
                                place['icon'],
                                color: isSelected ? Colors.red : place['color'],
                                size: isSelected ? 40 : 30
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(place['name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // ------------------------------------------
          // TOP UI (Back Button)
          // ------------------------------------------
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: const Color(0xFF1A2D33),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // ------------------------------------------
          // BOTTOM CARD LIST
          // ------------------------------------------
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            height: 150,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _facultyPlaces.length,
              onPageChanged: (index) => _onPlaceSelected(index),
              itemBuilder: (context, index) {
                final place = _facultyPlaces[index];
                final isSelected = _selectedPlaceIndex == index;

                return GestureDetector(
                  onTap: () => _onPlaceSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon Box
                        Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: place['color'].withOpacity(0.15),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: Icon(place['icon'], size: 35, color: place['color']),
                        ),

                        // Text Details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  place['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A2D33),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  place['desc'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                if (isSelected)
                                  Row(
                                    children: const [
                                      Icon(Icons.directions_walk, size: 14, color: Colors.blue),
                                      SizedBox(width: 4),
                                      Text(
                                        "FOLLOW PATH",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}