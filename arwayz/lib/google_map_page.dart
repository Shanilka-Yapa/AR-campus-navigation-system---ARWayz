import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_places_flutter/google_places_flutter.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;

  LatLng _destination = const LatLng(6.0793684, 80.1919646);
  final TextEditingController _searchController = TextEditingController();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final String googleApiKey = "YOUR_REAL_GOOGLE_MAPS_API_KEY";

  // Faculty circle boundary
  final LatLng _facultyCenter = LatLng(6.0793684, 80.1919646);
  final double _facultyRadius = 500; // meters

  // Campus places
  final List<Map<String, dynamic>> campusPlaces = [
    {'name': 'Administration Building', 'lat': 6.079416859527051, 'lng': 80.19201064963008},
    {'name': 'CEE', 'lat': 6.078164889030307, 'lng': 80.1914069593956, 'type': 'building'},
    {'name': 'MME', 'lat': 6.07859285299213, 'lng': 80.19170316455609, 'type': 'building'},
    {'name': 'EIE', 'lat': 6.078235704870035, 'lng': 80.19216766168712, 'type': 'building'},
    {'name': 'Main Cafeteria', 'lat': 6.078713286039461, 'lng': 80.19253361063727, 'type': 'cafeteria'},
    {'name': 'Faculty Library', 'lat': 6.079367213340776, 'lng': 80.19153075282063, 'type': 'library'},
    {'name': 'Faculty Auditorium', 'lat': 6.0791364229092055, 'lng': 80.19126639090263, 'type': 'auditorium'},
    {'name': 'Faculty Playground', 'lat': 6.081236252406866, 'lng': 80.19091511916912, 'type': 'playground'},
    {'name': 'FoE Quarters', 'lat': 6.080658084327748, 'lng': 80.19018714697019, 'type': 'hostel'},
    {'name': 'Hostel B', 'lat': 6.078065483420608, 'lng': 80.19276081564473, 'type': 'hostel'},
    {'name': 'Hostel A', 'lat': 6.077860310832621, 'lng': 80.19304316527848, 'type': 'hostel'},
    {'name': 'Boys Hostel D', 'lat': 6.081582404604873, 'lng': 80.18952163605634, 'type': 'hostel'},
    {'name': 'Gymnasium', 'lat': 6.0808828638193315, 'lng': 80.19118258134027, 'type': 'gym'},
    {'name': 'Bo Maluwa', 'lat': 6.079505589725185, 'lng': 80.19106937366881, 'type': 'building'},
    {'name': 'Hela Bojun Cafeteria', 'lat': 6.078723433792474, 'lng': 80.19283111418744, 'type': 'cafeteria'},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId("current"),
            position: _currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
        _markers.add(
          Marker(
            markerId: const MarkerId("destination"),
            position: _destination,
          ),
        );
      });

      if (_isInsideFaculty()) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_facultyCenter, 17),
        );
      }

      await _fetchRoute();
    }
  }

  // Check if inside faculty
  bool _isInsideFaculty() {
    if (_currentLocation == null) return false;
    double distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      _facultyCenter.latitude,
      _facultyCenter.longitude,
    );
    return distance <= _facultyRadius;
  }

  // Fetch route using Google Directions API
  Future<void> _fetchRoute() async {
    if (_currentLocation == null || _destination == null) return;

    final url =
        "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=${_currentLocation!.latitude},${_currentLocation!.longitude}"
        "&destination=${_destination.latitude},${_destination.longitude}"
        "&mode=walking"
        "&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['routes'].isNotEmpty) {
      final points = data['routes'][0]['overview_polyline']['points'];
      final decodedPoints = _decodePolyline(points);

      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue.shade400,
            width: 6,
            points: decodedPoints,
          ),
        );
      });
    }
  }

  // Decode polyline
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  void _centerToDestination() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_destination, 17),
    );
  }

  void _centerToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 17),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),

                // Back button
                Positioned(
                  top: 45,
                  left: 16,
                  child: FloatingActionButton(
                    heroTag: "back",
                    mini: true,
                    backgroundColor: const Color(0xFF1A2D33),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),

                // Search bar
                Positioned(
                  top: 45,
                  left: 60,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: GooglePlaceAutoCompleteTextField(
                      textEditingController: _searchController,
                      googleAPIKey: googleApiKey,
                      inputDecoration: const InputDecoration(
                        hintText: "Where are you going?",
                        border: InputBorder.none,
                      ),
                      debounceTime: 800,
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (prediction) {
                        double lat = double.parse(prediction.lat!);
                        double lng = double.parse(prediction.lng!);
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17),
                        );
                      },
                    ),
                  ),
                ),

                // Inside/Outside message
                Positioned(
                  top: 110,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isInsideFaculty() ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _isInsideFaculty()
                          ? "You are inside the Faculty"
                          : "You are outside of the Faculty",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // All campus place cards
                Positioned(
                  bottom: 30,
                  left: 16,
                  right: 16,
                  child: SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: campusPlaces.map((p) {
                        double distance = 0;
                        if (_currentLocation != null) {
                          distance = Geolocator.distanceBetween(
                            _currentLocation!.latitude,
                            _currentLocation!.longitude,
                            p['lat'] ?? 0.0,
                            p['lng'] ?? 0.0,
                          );
                        }

                        return _placeCard(
                          p['name'] ?? 'Unknown',
                          "${distance.toStringAsFixed(0)} m",
                          p['lat'] ?? 0.0,
                          p['lng'] ?? 0.0,
                          p['type'] ?? 'building',
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Navigation buttons
                Positioned(
                  bottom: 30,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "dest",
                        backgroundColor: const Color(0xFF1A2D33),
                        onPressed: _centerToDestination,
                        child: const Icon(Icons.navigation, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: "curr",
                        backgroundColor: const Color(0xFF1A2D33),
                        onPressed: _centerToCurrentLocation,
                        child: const Icon(Icons.my_location, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Place card with icon
  Widget _placeCard(
      String name, String distance, double lat, double lng, String type) {
    IconData icon;
    switch (type) {
      case 'library':
        icon = Icons.menu_book;
        break;
      case 'cafeteria':
        icon = Icons.restaurant;
        break;
      case 'hostel':
        icon = Icons.home;
        break;
      case 'gym':
        icon = Icons.fitness_center;
        break;
      case 'auditorium':
        icon = Icons.theater_comedy;
        break;
      case 'playground':
        icon = Icons.sports_soccer;
        break;
      default:
        icon = Icons.location_on;
    }

    return GestureDetector(
      onTap: () async {
        _destination = LatLng(lat, lng);

        _markers.removeWhere((m) => m.markerId.value == "destination");
        _markers.add(
          Marker(
            markerId: const MarkerId("destination"),
            position: _destination,
          ),
        );

        _polylines.clear();
        await _fetchRoute();

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_destination, 18),
        );

        setState(() {});
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 6, 50, 117), Color.fromARGB(255, 86, 128, 192)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 17, 13, 146).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              distance,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}