import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class OutdoorNavigationPage extends StatefulWidget {
  const OutdoorNavigationPage({super.key});

  @override
  State<OutdoorNavigationPage> createState() => _OutdoorNavigationPageState();
}

class _OutdoorNavigationPageState extends State<OutdoorNavigationPage> {
  late GoogleMapController mapController;

  // University of Ruhuna, Faculty of Engineering coordinates
  static const LatLng DESTINATION = LatLng(
    6.0793684,
    80.1919646,
  ); // Faculty of Engineering, Galle
  LatLng? _currentLocation;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    _addMarkers();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _addMarkers() {
    Set<Marker> newMarkers = {
      // Current location marker
      if (_currentLocation != null)
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(
            title: 'Your Current Location',
            snippet: 'You are here',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      // Destination marker
      Marker(
        markerId: const MarkerId('destination'),
        position: DESTINATION,
        infoWindow: const InfoWindow(
          title: 'University of Ruhuna',
          snippet: 'Faculty of Engineering',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
    setState(() {
      markers = newMarkers;
    });
  }

  void _animateToDestination() {
    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(_calculateBounds(), 100),
      );
    }
  }

  LatLngBounds _calculateBounds() {
    double minLat = _currentLocation?.latitude ?? DESTINATION.latitude;
    double maxLat = DESTINATION.latitude;
    double minLng = _currentLocation?.longitude ?? DESTINATION.longitude;
    double maxLng = DESTINATION.longitude;

    if (_currentLocation != null) {
      minLat = minLat > maxLat ? maxLat : minLat;
      maxLat = maxLat < minLat ? minLat : maxLat;
      minLng = minLng > maxLng ? maxLng : minLng;
      maxLng = maxLng < minLng ? minLng : maxLng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _openGoogleMapsNavigation() async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=${_currentLocation?.latitude},${_currentLocation?.longitude}&destination=${DESTINATION.latitude},${DESTINATION.longitude}&travelmode=walking';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigate to University'),
        backgroundColor: const Color(0xFF1A2D33),
        elevation: 0,
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    _animateToDestination();
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? DESTINATION,
                    zoom: 14.0,
                  ),
                  markers: markers,
                  polylines: polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
                // Custom buttons
                Positioned(
                  bottom: 30,
                  right: 20,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: _animateToDestination,
                        backgroundColor: const Color(0xFF1A2D33),
                        child: const Icon(Icons.center_focus_strong),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: _getCurrentLocation,
                        backgroundColor: const Color(0xFF1A2D33),
                        child: const Icon(Icons.location_searching),
                      ),
                    ],
                  ),
                ),
                // Navigation button at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'University of Ruhuna\nFaculty of Engineering',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _openGoogleMapsNavigation,
                          icon: const Icon(Icons.directions),
                          label: const Text('Get Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A2D33),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
