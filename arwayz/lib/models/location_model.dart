import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class LocationModel {
  final String id;
  final String name;
  final String description;
  final LatLng coordinates;
  final double radius; // in meters (geofence radius)
  final bool isIndoor;

  LocationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinates,
    required this.radius,
    required this.isIndoor,
  });

  // Calculate distance from another location
  double distanceTo(LatLng other) {
    const double earthRadiusM = 6371000; // Meters
    final dLat = _toRadians(other.latitude - coordinates.latitude);
    final dLng = _toRadians(other.longitude - coordinates.longitude);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(dLat / 2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadiusM * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  // Check if location is within this geofence
  bool isWithinGeofence(LatLng userLocation) {
    return distanceTo(userLocation) <= radius;
  }
}

// Predefined campus locations
final Map<String, LocationModel> campusLocations = {
  'faculty_engineering': LocationModel(
    id: 'faculty_engineering',
    name: 'Faculty of Engineering',
    description: 'University of Ruhuna, Faculty of Engineering',
    coordinates: const LatLng(6.0793684, 80.1919646),
    radius: 200, // 200 meters geofence
    isIndoor: true,
  ),
  'library': LocationModel(
    id: 'library',
    name: 'University Library',
    description: 'Main Library Building',
    coordinates: const LatLng(
      6.0785,
      80.1925,
    ), // Approximate location near faculty
    radius: 150,
    isIndoor: true,
  ),
  'student_center': LocationModel(
    id: 'student_center',
    name: 'Student Center',
    description: 'Student Activities Center',
    coordinates: const LatLng(6.0800, 80.1910),
    radius: 150,
    isIndoor: true,
  ),
  'cafeteria': LocationModel(
    id: 'cafeteria',
    name: 'Cafeteria',
    description: 'Main Cafeteria',
    coordinates: const LatLng(6.0775, 80.1930),
    radius: 100,
    isIndoor: false,
  ),
};
