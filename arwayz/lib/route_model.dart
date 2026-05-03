import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {
  final List<LatLng> points;
  final String destinationName;
  final double destLat;
  final double destLng;

  RouteModel({
    required this.points,
    required this.destinationName,
    required this.destLat,
    required this.destLng,
  });
}