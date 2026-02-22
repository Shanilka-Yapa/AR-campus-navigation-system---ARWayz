import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class FacultyMapPage extends StatefulWidget {
  const FacultyMapPage({super.key});

  @override
  State<FacultyMapPage> createState() => _FacultyMapPageState();
}

class _FacultyMapPageState extends State<FacultyMapPage> {
  final MapController _mapController = MapController();
  final PageController _pageController = PageController(viewportFraction: 0.85);

  LatLng? _currentLocation;
  int? _selectedPlaceIndex;
  List<LatLng> _routePoints = [];
  bool _isInsideFaculty = false;

  // --------------------------------------------------------
  // 1. CONFIGURATION
  // --------------------------------------------------------

  final LatLng _securityEntrance = const LatLng(6.079587868284366, 80.19248463513672);
  final LatLng _facultyCenter = const LatLng(6.078800, 80.192000);
  final LatLng _mainRoadJunction = const LatLng(6.079000, 80.192000);

  final LatLngBounds _facultyBounds = LatLngBounds(
    const LatLng(6.0770, 80.1900),
    const LatLng(6.0820, 80.1940),
  );

  final List<Map<String, dynamic>> _facultyPlaces = [
    {
      'name': 'Security Room',
      'desc': 'Main Entrance Security',
      'pos': const LatLng(6.079587868284366, 80.19248463513672),
      'color': Colors.red,
      'icon': Icons.security,
    },
    {
      'name': 'Admin Building',
      'desc': 'Administration Office',
      'pos': const LatLng(6.079387959041607, 80.19195456024359),
      'color': Colors.redAccent,
      'icon': Icons.admin_panel_settings,
    },
    {
      'name': 'Playground',
      'desc': 'Sports Ground',
      'pos': const LatLng(6.0813036049542, 80.1908771516893),
      'color': Colors.lightGreen,
      'icon': Icons.sports_soccer,
    },
    {
      'name': 'Main Library',
      'desc': 'Faculty Library',
      'pos': const LatLng(6.079441318479151, 80.19159422228692),
      'color': Colors.green,
      'icon': Icons.menu_book,
    },
    {
      'name': 'Main Cafeteria',
      'desc': 'Student Canteen',
      'pos': const LatLng(6.078564478087978, 80.19235671396622),
      'color': Colors.orange,
      'icon': Icons.restaurant,
    },
    {
      'name': 'DMME Dept',
      'desc': 'Mechanical & Manufacturing Engineering',
      'pos': const LatLng(6.078419035928309, 80.19180745565212),
      'color': Colors.blue,
      'icon': Icons.engineering,
    },
    {
      'name': 'DEIE Dept',
      'desc': 'Electrical & Information Engineering',
      'pos': const LatLng(6.078174210477643, 80.19217524440813),
      'color': Colors.blue,
      'icon': Icons.electrical_services,
    },
    {
      'name': 'DCEE Dept',
      'desc': 'Civil & Environmental Engineering',
      'pos': const LatLng(6.078184917639603, 80.1913757454891),
      'color': Colors.blue,
      'icon': Icons.construction,
    },
    {
      'name': 'DMME Workshop',
      'desc': 'Engineering Workshop',
      'pos': const LatLng(6.07750153254501, 80.19094465795094),
      'color': Colors.blueGrey,
      'icon': Icons.build,
    },
    {
      'name': 'Basketball Court',
      'desc': 'Sports Area',
      'pos': const LatLng(6.0788110038925245, 80.19150907917387),
      'color': Colors.greenAccent,
      'icon': Icons.sports_basketball,
    },
    {
      'name': 'Buddha Statue',
      'desc': 'Religious Area',
      'pos': const LatLng(6.079499327781828, 80.19106611535531),
      'color': Colors.amber,
      'icon': Icons.self_improvement,
    },
    {
      'name': 'Guest House',
      'desc': 'University Guest House',
      'pos': const LatLng(6.078329836239884, 80.19086155237294),
      'color': Colors.purple,
      'icon': Icons.hotel,
    },
    {
      'name': 'Hostel A',
      'desc': 'Student Accommodation',
      'pos': const LatLng(6.07778475294792, 80.19305157146461),
      'color': Colors.indigo,
      'icon': Icons.bed,
    },
    {
      'name': 'Hostel B',
      'desc': 'Student Accommodation',
      'pos': const LatLng(6.078004432201199, 80.19282328635329),
      'color': Colors.indigo,
      'icon': Icons.bed,
    },
    {
      'name': 'Hostel C',
      'desc': 'Student Accommodation',
      'pos': const LatLng(6.078171176472731, 80.1932300580759),
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
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
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

      double dist = const Distance().as(LengthUnit.Meter, pos, _securityEntrance);

      if (dist < 50 && !_isInsideFaculty) {
        _enterFacultyMode();
      }

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
        content: Text("Entered Faculty Premises. Map Expanded."),
        backgroundColor: Color(0xFF1A2D33),
      ),
    );

    _mapController.move(_facultyCenter, 19.0);
  }

  List<LatLng> _calculateSmartPath(LatLng start, LatLng end) {
    if (_isInsideFaculty) {
      return [start, _mainRoadJunction, end];
    } else {
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
      _mapController.move(_facultyPlaces[index]['pos'], 20.0);
    } else {
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
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation!,
              initialZoom: 16.0,
              cameraConstraint: _isInsideFaculty
                  ? CameraConstraint.contain(bounds: _facultyBounds)
                  : const CameraConstraint.unconstrained(),
              minZoom: _isInsideFaculty ? 18.0 : 10.0,
              maxZoom: 22.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.arwayz',
              ),
              PolylineLayer<Object>(
                polylines: [
                  if (_routePoints.isNotEmpty)
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 6.0,
                      color: Colors.blueAccent.withOpacity(0.8),
                      // Fixed for flutter_map 8.x
                      pattern: StrokePattern.dashed(segments: const [1, 12]),
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
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
                  ..._facultyPlaces.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var place = entry.value;
                    bool isSelected = idx == _selectedPlaceIndex;
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
                                size: isSelected ? 45 : 35
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