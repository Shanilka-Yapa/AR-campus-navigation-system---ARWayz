import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../ar_navigation/ar_compass_navigation_page.dart';

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
  static const Color primaryDark = Color(0xFF1A2D33);
  static const Color deepTeal = Color(0xFF235559);
  static const Color mutedTeal = Color(0xFF3F727A);
  static const Color steelBlue = Color(0xFF7B929C);
  static const Color lightGray = Color(0xFFBEC4C4);

  LatLng? currentLocation;
  List<LatLng> polylineCoordinates = [];
  String distance = "";
  String duration = "";
  bool _isLoadingRoute = true;
  String? _locationMessage;
  GoogleMapController? mapController;
  StreamSubscription<Position>? _positionStream;

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
    _setFallbackRouteMetrics();
    await getRoute();
    _startLiveTracking();
  }

  Future<void> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          setState(() => _locationMessage = 'Location services are off');
        }
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(
            () => _locationMessage = 'Enable location for live positioning',
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
          _locationMessage = null;
        });
        _setFallbackRouteMetrics();
      }
    } catch (error) {
      debugPrint('Location error: $error');
      if (mounted) {
        setState(() => _locationMessage = 'Using destination preview');
      }
    }
  }

  void _startLiveTracking() {
    _positionStream =
        Geolocator.getPositionStream(
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
    if (currentLocation == null) {
      if (mounted) setState(() => _isLoadingRoute = false);
      return;
    }
    const String googleApiKey = "YOUR_GOOGLE_MAPS_API_KEY";

    if (googleApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      if (mounted) setState(() => _isLoadingRoute = false);
      return;
    }

    final url =
        "https://maps.googleapis.com/maps/api/directions/json?"
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
          _isLoadingRoute = false;
        });
        _fitMap();
      } else if (mounted) {
        setState(() => _isLoadingRoute = false);
      }
    } catch (e) {
      debugPrint("NETWORK ERROR: $e");
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  void _setFallbackRouteMetrics() {
    final origin = currentLocation;
    if (origin == null) return;
    final meters = Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      widget.destLat,
      widget.destLng,
    );
    if (mounted) {
      setState(() {
        distance = meters < 1000
            ? '${meters.round()} m'
            : '${(meters / 1000).toStringAsFixed(1)} km';
        duration = '${(meters / 1.25 / 60).ceil()} min walk';
      });
    }
  }

  void _fitMap() {
    if (mapController == null) return;

    final pointsToFit = polylineCoordinates.isNotEmpty
        ? polylineCoordinates
        : [_mapTarget, LatLng(widget.destLat, widget.destLng)];

    double minLat = pointsToFit
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLat = pointsToFit
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    double minLng = pointsToFit
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLng = pointsToFit
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

    if ((maxLat - minLat).abs() < 0.00001 &&
        (maxLng - minLng).abs() < 0.00001) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 17),
      );
      return;
    }
    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100,
      ),
    );
  }

  LatLng get _mapTarget =>
      currentLocation ?? LatLng(widget.destLat, widget.destLng);

  IconData get _departmentIcon {
    final name = widget.placeName.toLowerCase();
    if (name.contains('computer') || name.contains('information')) {
      return Icons.computer_rounded;
    }
    if (name.contains('civil') || name.contains('environment')) {
      return Icons.foundation_rounded;
    }
    if (name.contains('mechanical') || name.contains('manufacturing')) {
      return Icons.precision_manufacturing_rounded;
    }
    if (name.contains('electrical') || name.contains('electronic')) {
      return Icons.electric_bolt_rounded;
    }
    return Icons.business_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 76,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_departmentIcon, color: const Color(0xFF8FD0C9), size: 25),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.placeName,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
        titleSpacing: 4,
        actions: const [SizedBox(width: 48)],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [primaryDark, deepTeal]),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        elevation: 6,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
              mapController!.setMapStyle(_customMapStyle);
              WidgetsBinding.instance.addPostFrameCallback((_) => _fitMap());
            },
            initialCameraPosition: CameraPosition(target: _mapTarget, zoom: 15),
            style: _customMapStyle,
            mapType: MapType.normal,
            myLocationEnabled: currentLocation != null,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId("destination"),
                position: LatLng(widget.destLat, widget.destLng),
                icon: BitmapDescriptor.defaultMarkerWithHue(195),
                infoWindow: InfoWindow(title: widget.placeName),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId("route_line"),
                points: polylineCoordinates.isNotEmpty
                    ? polylineCoordinates
                    : [_mapTarget, LatLng(widget.destLat, widget.destLng)],
                color: deepTeal,
                width: 6,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            },
          ),

          if (_locationMessage != null)
            Positioned(
              top: 88,
              left: 16,
              right: 16,
              child: _buildNotice(_locationMessage!),
            ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryDark.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfo(
                        "DISTANCE",
                        distance,
                        Icons.directions_walk_rounded,
                      ),
                      Container(width: 1, height: 40, color: lightGray),
                      _buildInfo(
                        "TIME",
                        duration,
                        Icons.access_time_filled_rounded,
                      ),
                    ],
                  ),
                  if (_isLoadingRoute) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(
                      minHeight: 3,
                      color: deepTeal,
                      backgroundColor: lightGray,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _fitMap,
                          icon: const Icon(Icons.my_location_rounded),
                          label: const Text('Recenter'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: deepTeal,
                            side: const BorderSide(color: deepTeal),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.view_in_ar_rounded),
                          label: const Text('3D / AR'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: mutedTeal,
                            side: const BorderSide(color: mutedTeal),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                              locationType: "default",
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deepTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.view_in_ar_rounded, size: 20),
                          SizedBox(width: 12),
                          Text(
                            "START AR NAVIGATION",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotice(String message) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: primaryDark.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
          style: const TextStyle(
            fontSize: 10,
            color: steelBlue,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? "Calculating..." : value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryDark,
          ),
        ),
      ],
    );
  }
}
