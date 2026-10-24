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
}
