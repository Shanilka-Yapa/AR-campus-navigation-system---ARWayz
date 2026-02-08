import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import 'models/location_model.dart';
import 'helpers/ar_navigation_helper.dart';
import 'pages/ar_camera_navigation_page.dart';
import 'pages/test_ar_page.dart';
import 'widgets/faculty_location_card.dart';

class OutdoorNavigationPage extends StatefulWidget {
  const OutdoorNavigationPage({super.key});

  @override
  State<OutdoorNavigationPage> createState() => _OutdoorNavigationPageState();
}

class _OutdoorNavigationPageState extends State<OutdoorNavigationPage> {
  GoogleMapController? mapController;

  // University of Ruhuna, Faculty of Engineering coordinates
  static const LatLng DESTINATION = LatLng(
    6.0793684,
    80.1919646,
  ); // Faculty of Engineering, Galle
  LatLng? _currentLocation;
  LocationModel? _currentFaculty;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  StreamSubscription<Position>? _positionStreamSubscription;
  bool _showFacultyCard = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await _getCurrentLocation();
      _addMarkers();
      _startLocationTracking();
    } catch (e) {
      debugPrint('Error initializing map: $e');
    }
  }

  void _startLocationTracking() {
    try {
      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 10, // Update every 10 meters
            ),
          ).listen(
            (Position position) {
              if (!mounted) return;
              try {
                setState(() {
                  _currentLocation = LatLng(
                    position.latitude,
                    position.longitude,
                  );

                  // Check if user is inside any faculty
                  final currentLocation = ARNavigationHelper.getCurrentLocation(
                    _currentLocation!,
                  );
                  if (currentLocation != null &&
                      currentLocation.id != _currentFaculty?.id) {
                    _currentFaculty = currentLocation;
                    _showFacultyCard = true;
                    _addMarkers();
                  } else if (currentLocation == null) {
                    _currentFaculty = null;
                    _showFacultyCard = false;
                  }
                });
              } catch (e) {
                debugPrint('Error updating location: $e');
              }
            },
            onError: (error) {
              debugPrint('Location stream error: $error');
            },
            cancelOnError: false,
          );
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
    }
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
    try {
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
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
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
        // Library marker (if inside faculty)
        if (_currentFaculty != null && campusLocations['library'] != null)
          Marker(
            markerId: const MarkerId('library'),
            position: campusLocations['library']!.coordinates,
            infoWindow: const InfoWindow(
              title: 'University Library',
              snippet: 'Navigate here for AR guidance',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow,
            ),
          ),
        // Other campus locations when inside faculty
        if (_currentFaculty != null &&
            campusLocations['student_center'] != null)
          Marker(
            markerId: const MarkerId('student_center'),
            position: campusLocations['student_center']!.coordinates,
            infoWindow: const InfoWindow(
              title: 'Student Center',
              snippet: 'Tap for directions',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
      };
      if (mounted) {
        setState(() {
          markers = newMarkers;
        });
      }
    } catch (e) {
      debugPrint('Error adding markers: $e');
    }
  }

  void _animateToDestination() {
    try {
      if (mapController != null && mounted) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(_calculateBounds(), 100),
        );
      }
    } catch (e) {
      debugPrint('Error animating camera: $e');
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

  void _openARNavigation(LocationModel targetLocation) {
    try {
      debugPrint('Opening AR Navigation...');
      debugPrint('Current location: $_currentLocation');
      debugPrint('Target location: ${targetLocation.name}');

      if (_currentLocation == null) {
        debugPrint('Current location is null!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please get your location first (click location button)',
            ),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      debugPrint('Pushing AR Navigation Page...');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ARCameraNavigationPage(
            currentLocation: _currentLocation!,
            targetLocation: targetLocation,
          ),
        ),
      ).catchError((error) {
        debugPrint('Navigation error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    } catch (e) {
      debugPrint('Exception in _openARNavigation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _openTestAR() {
    // Test location - use current location or default to faculty location
    final testLocation = _currentLocation ?? DESTINATION;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestARPage(currentLocation: testLocation),
      ),
    );
  }

  void _navigateToLocation(LocationModel location) {
    _openGoogleMapsNavigation();
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
                    if (mounted) {
                      mapController = controller;
                      _animateToDestination();
                    } else {
                      controller.dispose();
                    }
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
                  bottom: 200,
                  right: 20,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'fab_center',
                        onPressed: _animateToDestination,
                        backgroundColor: const Color(0xFF1A2D33),
                        child: const Icon(Icons.center_focus_strong),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'fab_location',
                        onPressed: _getCurrentLocation,
                        backgroundColor: const Color(0xFF1A2D33),
                        child: const Icon(Icons.location_searching),
                      ),
                      const SizedBox(height: 10),
                      // Test AR button
                      FloatingActionButton(
                        heroTag: 'fab_test_ar',
                        onPressed: _openTestAR,
                        backgroundColor: Colors.purple,
                        child: const Icon(Icons.psychology_alt),
                        tooltip: 'Test AR (No location needed)',
                      ),
                      const SizedBox(height: 10),
                      // AR Camera button
                      if (_currentLocation != null)
                        FloatingActionButton(
                          heroTag: 'fab_ar_camera',
                          onPressed: () => _openARNavigation(
                            campusLocations['faculty_engineering']!,
                          ),
                          backgroundColor: Colors.orange,
                          child: const Icon(Icons.camera_alt),
                          tooltip: 'AR Navigation',
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
                        // Show faculty card if inside faculty premises
                        if (_showFacultyCard && _currentFaculty != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: FacultyLocationCard(
                              location: _currentFaculty!,
                              onNavigatePressed: () =>
                                  _navigateToLocation(_currentFaculty!),
                              onARNavigatePressed: () {
                                // Navigate to library from faculty
                                _openARNavigation(campusLocations['library']!);
                              },
                            ),
                          ),
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
    try {
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
    } catch (e) {
      debugPrint('Error cancelling location subscription: $e');
    }
    try {
      mapController?.dispose();
      mapController = null;
    } catch (e) {
      debugPrint('Error disposing map controller: $e');
    }
    super.dispose();
  }
}
