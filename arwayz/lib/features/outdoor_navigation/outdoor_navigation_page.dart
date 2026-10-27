import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class OutdoorNavigationPage extends StatefulWidget {
  final double destLat;
  final double destLon;
  final String destinationName;

  const OutdoorNavigationPage({
    super.key,
    this.destLat = 6.0793684,
    this.destLon = 80.1919646,
    this.destinationName = 'Faculty of Engineering',
  });

  @override
  State<OutdoorNavigationPage> createState() => _OutdoorNavigationPageState();
}

class _OutdoorNavigationPageState extends State<OutdoorNavigationPage> {
  GoogleMapController? mapController;

  LatLng? _currentLocation;
  bool _isLocating = true;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  LatLng get _destination => LatLng(widget.destLat, widget.destLon);

  static const String _customMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#e7eeee"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#235559"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#e7eeee"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#c7d7d6"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#c3d8ce"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#b9ccce"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#3f727a"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#8fb9bb"}]}
]
''';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    _addMarkers();
    if (mounted) setState(() => _isLocating = false);
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (mounted) setState(() => _isLocating = true);
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => _isLocating = false);
        _addMarkers();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
          ),
        );
        if (!mounted) return;
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLocating = false;
        });
        _addMarkers();
      } else {
        if (mounted) {
          setState(() => _isLocating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _addMarkers() {
    Set<Marker> newMarkers = {
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
      Marker(
        markerId: const MarkerId('destination'),
        position: _destination,
        infoWindow: const InfoWindow(
          title: 'University of Ruhuna',
          snippet: 'Selected department',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
    final routePoints = _currentLocation == null
        ? <LatLng>[]
        : <LatLng>[_currentLocation!, _destination];
    if (mounted) {
      setState(() {
        markers = newMarkers;
        polylines = routePoints.length < 2
            ? {}
            : {
                Polyline(
                  polylineId: const PolylineId('destination_route'),
                  points: routePoints,
                  color: const Color(0xFF235559),
                  width: 7,
                  jointType: JointType.round,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                ),
              };
      });
    }
  }

  void _animateToDestination() {
    final controller = mapController;
    if (!mounted || controller == null) return;
    if (_currentLocation == null ||
        ((_currentLocation!.latitude - _destination.latitude).abs() < 0.00001 &&
            (_currentLocation!.longitude - _destination.longitude).abs() <
                0.00001)) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(_destination, 17));
      return;
    }
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(_calculateBounds(), 100),
    );
  }

  LatLngBounds _calculateBounds() {
    final origin = _currentLocation ?? _destination;
    final minLat = origin.latitude < _destination.latitude
        ? origin.latitude
        : _destination.latitude;
    final maxLat = origin.latitude > _destination.latitude
        ? origin.latitude
        : _destination.latitude;
    final minLng = origin.longitude < _destination.longitude
        ? origin.longitude
        : _destination.longitude;
    final maxLng = origin.longitude > _destination.longitude
        ? origin.longitude
        : _destination.longitude;

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  IconData get _departmentIcon {
    final name = widget.destinationName.toLowerCase();
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

  Widget _buildLocationBanner() {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xE61A2D33),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF8FD0C9),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Finding your live location...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGoogleMapsNavigation() async {
    final origin = _currentLocation ?? _destination;
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}&destination=${_destination.latitude},${_destination.longitude}&travelmode=walking';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_departmentIcon, color: const Color(0xFF8FD0C9), size: 25),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.destinationName,
                maxLines: 2,
                softWrap: true,
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
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
            gradient: LinearGradient(
              colors: [Color(0xFF1A2D33), Color(0xFF235559)],
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        centerTitle: true,
        elevation: 4,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
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
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              controller.setMapStyle(_customMapStyle);
              _animateToDestination();
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? _destination,
              zoom: 14.0,
            ),
            style: _customMapStyle,
            markers: markers,
            polylines: polylines,
            myLocationEnabled: _currentLocation != null,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          if (_isLocating)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildLocationBanner(),
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
                  child: const Icon(Icons.center_focus_strong_rounded),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _getCurrentLocation,
                  backgroundColor: const Color(0xFF1A2D33),
                  child: const Icon(Icons.location_searching_rounded),
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.destinationName}\nUniversity of Ruhuna',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2D33),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _openGoogleMapsNavigation,
                    icon: const Icon(Icons.directions_rounded),
                    label: const Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A2D33),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
    mapController?.dispose();
    super.dispose();
  }
}
