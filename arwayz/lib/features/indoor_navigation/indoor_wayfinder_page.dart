import 'package:flutter/material.dart';

import '../../core/models/qr_payload.dart';
import '../qr_scanner/qr_scanner_page.dart';
import 'department_config.dart';

class _FloorLocation {
  final String id;
  final String name;
  final int floor;

  const _FloorLocation(this.id, this.name, this.floor);
}

class _BuildingDestination {
  final String name;
  final int floor;
  final String wing;

  const _BuildingDestination(this.name, this.floor, this.wing);
}

class IndoorWayfinderPage extends StatefulWidget {
  final DepartmentConfig? departmentConfig;

  const IndoorWayfinderPage({super.key, this.departmentConfig});

  @override
  State<IndoorWayfinderPage> createState() => _IndoorWayfinderPageState();
}

class _IndoorWayfinderPageState extends State<IndoorWayfinderPage> {
  late final DepartmentConfig _config;

  static const _isFloorLocations = <_FloorLocation>[
    _FloorLocation('floor_0', 'Ground-floor QR location', 0),
    _FloorLocation('floor_1', 'First-floor QR location', 1),
    _FloorLocation('floor_2', 'Second-floor QR location', 2),
    _FloorLocation('floor_3', 'Third-floor QR location', 3),
  ];

  static const _civilFloorLocations = <_FloorLocation>[
    _FloorLocation('floor_0', 'Ground-floor QR location', 0),
    _FloorLocation('floor_1', 'First-floor QR location', 1),
    _FloorLocation('floor_2', 'Second-floor QR location', 2),
  ];

  static const _isDestinations = <_BuildingDestination>[
    _BuildingDestination('Central Reception & Lobby', 0, 'Center'),
    _BuildingDestination('Meeting Room', 0, 'Left Wing'),
    _BuildingDestination('Board Room', 0, 'Right Wing'),
    _BuildingDestination("Dean's Office Suite", 1, 'Center'),
    _BuildingDestination('EEC (Engineering Education Center)', 1, 'Left Wing'),
    _BuildingDestination('Classroom A', 1, 'Left Wing'),
    _BuildingDestination('Finance Office', 1, 'Left Wing'),
    _BuildingDestination('Assistant Registrar Office', 1, 'Right Wing'),
    _BuildingDestination("Dean's Office", 1, 'Right Wing'),
    _BuildingDestination('Staff & Faculty Lounge', 1, 'Right Wing'),
    _BuildingDestination('IS Seminar Room', 2, 'Left Wing'),
    _BuildingDestination('Academic Wing & Faculty Suites', 2, 'Right & Center'),
    _BuildingDestination('Computer Center', 3, 'Left Wing'),
    _BuildingDestination('NCC (New Computer Center)', 3, 'Right Wing'),
  ];

  late final List<_FloorLocation> _floorLocations;
  late final List<_BuildingDestination> _destinations;

  _BuildingDestination? _destination;
  _FloorLocation? _currentLocation;
  String? _message;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _config = widget.departmentConfig ?? isDepartmentConfig;

    if (_config.id == 'CIVIL_BUILDING') {
      _floorLocations = _civilFloorLocations;
      _destinations = _config.divisions
          .map((div) => _BuildingDestination(div.title, div.floor, div.wing))
          .toList();
    } else {
      _floorLocations = _isFloorLocations;
      _destinations = _isDestinations;
    }
  }

  _FloorLocation? _findLocation(QrPayload payload) {
    for (final location in _floorLocations) {
      if (location.id == payload.pointId && location.floor == payload.floor) {
        return location;
      }
    }
    return null;
  }

  Future<void> _scanLocation() async {
    if (_destination == null || _isScanning) return;
    setState(() {
      _isScanning = true;
      _message = null;
    });

    final payload = await Navigator.push<QrPayload>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerPage()),
    );

    if (!mounted) return;
    setState(() => _isScanning = false);
    if (payload == null) return;

    if (payload.buildingId != _config.id) {
      setState(
        () => _message = 'This QR code is not for the ${_config.name}.',
      );
      return;
    }

    final location = _findLocation(payload);
    if (location == null) {
      setState(
        () => _message =
            'This is not one of the ${_config.name} floor QR codes.',
      );
      return;
    }

    setState(() {
      _currentLocation = location;
      _message = null;
    });
  }

  String _directionText() {
    final location = _currentLocation!;
    final destination = _destination!;

    if (location.floor == destination.floor) {
      return 'You are on the destination floor. Follow signs to the '
          '${destination.wing} to find ${destination.name}.';
    }
    final movement = location.floor < destination.floor ? 'up' : 'down';
    return 'Go $movement to floor ${destination.floor}, then follow signs '
        'to the ${destination.wing} to find ${destination.name}.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Dynamic title: e.g. "Civil Building QR Wayfinder" or "IS Building QR Wayfinder"
        title: Text('${_config.name} QR Wayfinder'),
        backgroundColor: _config.themeColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.25)),
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.location_searching_rounded, size: 56, color: _config.themeColor),
          const SizedBox(height: 12),
          Text(
            'Find your way inside ${_config.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your division or room destination, then scan the nearest wayfinder QR code.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13.5),
          ),
          const SizedBox(height: 24),

          // Dynamic Location Dropdown
          DropdownButtonFormField<_BuildingDestination>(
            initialValue: _destination,
            decoration: const InputDecoration(
              labelText: 'Where do you want to go?',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            isExpanded: true,
            items: _destinations
                .map((destination) => DropdownMenuItem<_BuildingDestination>(
                      value: destination,
                      child: Text(
                        destination.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _destination = value;
                _currentLocation = null;
                _message = null;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _destination == null || _isScanning
                  ? null
                  : _scanLocation,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: Text(_isScanning ? 'Opening scanner...' : 'Scan QR Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _config.themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            _MessageCard(message: _message!),
          ],
          if (_currentLocation != null) ...[
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFFEAF7F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT LOCATION',
                      style: TextStyle(
                        color: Color(0xFF247A50),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentLocation!.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_config.name} • ${_currentLocation!.floor == 0 ? 'Ground' : '${_currentLocation!.floor}'} floor',
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                    ),
                    const Divider(height: 24),
                    const Text(
                      'DIRECTION',
                      style: TextStyle(
                        color: Color(0xFF247A50),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _directionText(),
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;

  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(message, style: TextStyle(color: Colors.orange.shade900)),
      ),
    );
  }
}
