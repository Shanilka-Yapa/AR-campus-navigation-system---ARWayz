class Destination {
  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? buildingId;
  final int? floor;
  final String? indoorNodeId;

  const Destination({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.buildingId,
    this.floor,
    this.indoorNodeId,
  });

  factory Destination.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final latitude = data['latitude'];
    final longitude = data['longitude'];

    if (latitude is! num || longitude is! num) {
      throw FormatException('Invalid coordinates for destination $documentId');
    }

    return Destination(
      id: documentId,
      name: data['name'] as String? ?? 'Unknown Building',
      description: data['description'] as String?,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      buildingId: data['buildingId'] as String? ?? documentId,
      floor: (data['floor'] as num?)?.toInt(),
      indoorNodeId: data['indoorNodeId'] as String?,
    );
  }
}
