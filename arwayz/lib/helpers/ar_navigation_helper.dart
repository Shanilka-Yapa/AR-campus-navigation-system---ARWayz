import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

import '../models/location_model.dart';

class ARNavigationHelper {
  // Calculate bearing between two points
  static double calculateBearing(LatLng from, LatLng to) {
    final dLng = to.longitude - from.longitude;
    final y =
        math.sin(dLng * math.pi / 180) * math.cos(to.latitude * math.pi / 180);
    final x =
        math.cos(from.latitude * math.pi / 180) *
            math.sin(to.latitude * math.pi / 180) -
        math.sin(from.latitude * math.pi / 180) *
            math.cos(to.latitude * math.pi / 180) *
            math.cos(dLng * math.pi / 180);
    return math.atan2(y, x) * 180 / math.pi;
  }

  // Normalize bearing to 0-360
  static double normalizeBearing(double bearing) {
    return (bearing + 360) % 360;
  }

  // Calculate distance in meters
  static double calculateDistance(LatLng from, LatLng to) {
    const double earthRadiusM = 6371000;
    final dLat = (to.latitude - from.latitude) * math.pi / 180;
    final dLng = (to.longitude - from.longitude) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(from.latitude * math.pi / 180) *
            math.cos(to.latitude * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusM * c;
  }

  // Get direction text from bearing
  static String getDirectionText(double bearing) {
    bearing = normalizeBearing(bearing);
    if (bearing < 22.5 || bearing >= 337.5) return 'North';
    if (bearing < 67.5) return 'Northeast';
    if (bearing < 112.5) return 'East';
    if (bearing < 157.5) return 'Southeast';
    if (bearing < 202.5) return 'South';
    if (bearing < 247.5) return 'Southwest';
    if (bearing < 292.5) return 'West';
    return 'Northwest';
  }

  // Get arrow icon based on bearing
  static IconData getArrowIcon(double bearing) {
    bearing = normalizeBearing(bearing);
    if (bearing < 45 || bearing >= 315) return Icons.arrow_upward;
    if (bearing < 135) return Icons.arrow_forward;
    if (bearing < 225) return Icons.arrow_downward;
    return Icons.arrow_back;
  }

  // Check if user is inside any location
  static LocationModel? getCurrentLocation(LatLng userLocation) {
    for (var location in campusLocations.values) {
      if (location.isWithinGeofence(userLocation)) {
        return location;
      }
    }
    return null;
  }

  // Get nearest location from user
  static LocationModel? getNearestLocation(LatLng userLocation) {
    LocationModel? nearest;
    double minDistance = double.infinity;

    for (var location in campusLocations.values) {
      final distance = location.distanceTo(userLocation);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = location;
      }
    }
    return nearest;
  }
}
