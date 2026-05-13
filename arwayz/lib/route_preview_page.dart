import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'ar_compass_navigation_page.dart';

class RoutePreviewPage extends StatefulWidget {
  final double destLat;
  final double destLng;
  final String placeName;

  const RoutePreviewPage({
    super.key,
    required this.destLat,
    required this.destLng,
    required this.placeName,
  });

  @override
  State<RoutePreviewPage> createState() => _RoutePreviewPageState();
}

class _RoutePreviewPageState extends State<RoutePreviewPage> {
  // --- OUR COLOR PALETTE ---
  static const Color primaryDark = Color(0xFF1A2D33);
  static const Color deepTeal = Color(0xFF235559);
  static const Color mutedTeal = Color(0xFF3F727A);
  static const Color steelBlue = Color(0xFF7B929C);
  static const Color lightGray = Color(0xFFBEC4C4);

  LatLng? currentLocation;
  List<LatLng> polylineCoordinates = [];
  String distance = "";
  String duration = "";
  GoogleMapController? mapController;
  StreamSubscription<Position>? _positionStream;

  // Custom Map Style tuned to the Palette
  final String _customMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#f1f3f4"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#7b929c"}]},
  {"featureType": "poi", "elementType": "geometry", "stylers": [{"color": "#bec4c4"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#ffffff"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#bec4c4"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#3f727a"}]}
]
''';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    await getCurrentLocation();
    await getRoute();
    _startLiveTracking();
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _startLiveTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, 
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
        });
        getRoute(); 
      }
    });
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<void> getRoute() async {
    if (currentLocation == null) return;
    const String googleApiKey = "YOUR_GOOGLE_MAPS_API_KEY"; // Ensure this is valid

    final url = "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${currentLocation!.latitude},${currentLocation!.longitude}"
        "&destination=${widget.destLat},${widget.destLng}"
        "&mode=walking"
        "&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data["status"] == "OK") {
        final route = data["routes"][0];
        final leg = route["legs"][0];

        setState(() {
          distance = leg["distance"]["text"];
          duration = leg["duration"]["text"];
          String encodedPoints = route["overview_polyline"]["points"];
          polylineCoordinates = _decodePolyline(encodedPoints);
        });
        _fitMap();
      }
    } catch (e) {
      debugPrint("NETWORK ERROR: $e");
    }
  }

  void _fitMap() {
    if (mapController == null || (polylineCoordinates.isEmpty && currentLocation == null)) return;
    
    // Calculate bounds based on current route or the two points
    List<LatLng> pointsToFit = polylineCoordinates.isNotEmpty 
        ? polylineCoordinates 
        : [currentLocation!, LatLng(widget.destLat, widget.destLng)];

    double minLat = pointsToFit.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = pointsToFit.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = pointsToFit.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = pointsToFit.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)),
        100, 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.placeName, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: primaryDark.withOpacity(0.9),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
        centerTitle: true,
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator(color: deepTeal))
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                    mapController!.setMapStyle(_customMapStyle);
                    _fitMap();
                  },
                  initialCameraPosition: CameraPosition(target: currentLocation!, zoom: 15),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: {
                    Marker(
                      markerId: const MarkerId("destination"),
                      position: LatLng(widget.destLat, widget.destLng),
                      icon: BitmapDescriptor.defaultMarkerWithHue(195), // Tealish hue for marker
                      infoWindow: InfoWindow(title: widget.placeName),
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("route_line"),
                      // Use API points if available, otherwise draw straight line (like your image)
                      points: polylineCoordinates.isNotEmpty 
                          ? polylineCoordinates 
                          : [currentLocation!, LatLng(widget.destLat, widget.destLng)],
                      color: deepTeal, // Deep Teal from palette
                      width: 6,
                      jointType: JointType.round,
                      startCap: Cap.roundCap,
                      endCap: Cap.roundCap,
                    ),
                  },
                ),

                Positioned(
                  bottom: 30,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: primaryDark.withOpacity(0.15), 
                          blurRadius: 30, 
                          offset: const Offset(0, 10)
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfo("DISTANCE", distance, Icons.directions_walk),
                            Container(width: 1, height: 40, color: lightGray),
                            _buildInfo("TIME", duration, Icons.access_time_filled),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (_) => ARCompassNavigationPage(
                                    destLat: widget.destLat, 
                                    destLon: widget.destLng, 
                                    destName: widget.placeName, 
                                    locationType: "default"
                                  )
                                )
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: deepTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.view_in_ar, size: 20),
                                SizedBox(width: 12),
                                Text(
                                  "START AR NAVIGATION", 
                                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: mutedTeal, size: 24),
        const SizedBox(height: 8),
        Text(
          label, 
          style: const TextStyle(fontSize: 10, color: steelBlue, fontWeight: FontWeight.w800, letterSpacing: 0.5)
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? "Calculating..." : value, 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDark)
        ),
      ],
    );
  }
}