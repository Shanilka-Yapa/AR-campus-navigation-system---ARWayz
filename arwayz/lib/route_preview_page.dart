import 'dart:convert';
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
  LatLng? currentLocation;
  List<LatLng> polylineCoordinates = [];
  String distance = "";
  String duration = "";
  GoogleMapController? mapController;

  // --- PREMIUM SILVER MAP STYLE ---
  final String _customMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#f5f5f5"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#616161"}]},
  {"featureType": "poi", "elementType": "geometry", "stylers": [{"color": "#eeeeee"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#ffffff"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#dadada"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#c9c9c9"}]}
]
''';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await getCurrentLocation();
    await getRoute();
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  // --- MANUAL DECODER ---
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

    // IMPORTANT: Make sure this key is valid and Directions API is enabled in Google Cloud Console
    const String googleApiKey = "YOUR_GOOGLE_MAPS_API_KEY"; 

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
      } else {
        print("API Error: ${data["status"]} - ${data["error_message"]}");
      }
    } catch (e) {
      print("Network Error: $e");
    }
  }

  void _fitMap() {
    if (mapController == null || polylineCoordinates.isEmpty) return;
    
    double minLat = polylineCoordinates.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = polylineCoordinates.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = polylineCoordinates.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = polylineCoordinates.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)),
        80, // Padding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.placeName, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                    mapController!.setMapStyle(_customMapStyle); // This hides standard map clutter
                    _fitMap();
                  },
                  initialCameraPosition: CameraPosition(target: currentLocation!, zoom: 15),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: {
                    // Custom Marker for Destination
                    Marker(
                      markerId: const MarkerId("destination"),
                      position: LatLng(widget.destLat, widget.destLng),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      infoWindow: InfoWindow(title: widget.placeName),
                    ),
                  },
                  polylines: {
                    // 1. OUTER GLOW (Wide and transparent)
                    Polyline(
                      polylineId: const PolylineId("glow"),
                      points: polylineCoordinates,
                      color: Colors.blue.withOpacity(0.2),
                      width: 15,
                    ),
                    // 2. BORDER (Medium width)
                    Polyline(
                      polylineId: const PolylineId("border"),
                      points: polylineCoordinates,
                      color: Colors.blueAccent,
                      width: 8,
                    ),
                    // 3. CORE LINE (Thin white/light blue center for the "Modern Path" look)
                    Polyline(
                      polylineId: const PolylineId("core"),
                      points: polylineCoordinates,
                      color: Colors.white,
                      width: 3,
                    ),
                  },
                ),

                // Floating Information Card
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfo("DISTANCE", distance, Icons.directions_walk),
                            _buildInfo("TIME", duration, Icons.timer_outlined),
                          ],
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ARCompassNavigationPage(destLat: widget.destLat, destLon: widget.destLng, destName: widget.placeName, locationType: "default")));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 0,
                            ),
                            child: const Text("START AR NAVIGATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
        Icon(icon, color: Colors.blueAccent, size: 22),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(value.isEmpty ? "--" : value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}