class QrPayload {
  final String buildingId;
  final int floor;
  final String pointId;

  const QrPayload({
    required this.buildingId,
    required this.floor,
    required this.pointId,
  });

  static QrPayload? parse(String value) {
    final parts = value.split('|');

    if (parts.length < 4 || parts[0] != 'ARWAYZ') {
      return null;
    }

    final data = <String, String>{};

    for (final part in parts.skip(1)) {
      final separator = part.indexOf('=');
      if (separator <= 0) continue;

      final key = part.substring(0, separator);
      final itemValue = part.substring(separator + 1);
      data[key] = itemValue;
    }

    final floor = int.tryParse(data['floor'] ?? '');

    if (data['building'] == null || data['point'] == null || floor == null) {
      return null;
    }

    return QrPayload(
      buildingId: data['building']!,
      floor: floor,
      pointId: data['point']!,
    );
  }
}
