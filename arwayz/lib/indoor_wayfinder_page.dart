import 'package:flutter/material.dart';

import 'qr_payload.dart';
import 'qr_scanner_page.dart';

class _WayfinderPoint {
  final String id;
  final String name;
  final int floor;

  const _WayfinderPoint(this.id, this.name, this.floor);
}

class IndoorWayfinderPage extends StatefulWidget {
  const IndoorWayfinderPage({super.key});

  @override
  State<IndoorWayfinderPage> createState() => _IndoorWayfinderPageState();
}

class _IndoorWayfinderPageState extends State<IndoorWayfinderPage> {
  static const _buildingId = 'IS_BUILDING';

  static const _points = <_WayfinderPoint>[
    _WayfinderPoint('ground_entrance', 'Ground-floor entrance', 0),
    _WayfinderPoint('ground_lobby', 'Ground-floor lobby', 0),
    _WayfinderPoint('ground_corridor', 'Ground-floor corridor junction', 0),
    _WayfinderPoint('new_computer_center', 'New Computer Center', 0),
  ];

  static const _destinations = <String>[
    'New Computer Center',
    'IS Laboratory',
    'Reception and Lobby',
  ];

  String? _destination;
  _WayfinderPoint? _currentPoint;
  String? _message;
  bool _isScanning = false;

  _WayfinderPoint? _findPoint(QrPayload payload) {
    for (final point in _points) {
      if (point.id == payload.pointId && point.floor == payload.floor) {
        return point;
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

    if (payload.buildingId != _buildingId) {
      setState(() => _message = 'This QR code is not for the IS Building.');
      return;
    }

    final point = _findPoint(payload);
    if (point == null) {
      setState(
        () => _message =
            'This wayfinder point is not registered yet. Add it to the building QR setup.',
      );
      return;
    }

    setState(() {
      _currentPoint = point;
      _message = null;
    });
  }

  String _directionText() {
    final point = _currentPoint!;
    final destination = _destination!;

    if (point.name == destination) {
      return 'You have arrived at $destination.';
    }
    if (destination == 'New Computer Center') {
      return point.floor == 0
          ? 'Follow the corridor toward the New Computer Center.'
          : 'Go to the stairs and follow signs down to the ground floor.';
    }
    if (destination == 'Reception and Lobby') {
      return point.floor == 0
          ? 'Follow the entrance signs toward Reception and Lobby.'
          : 'Go to the stairs and continue down to the ground-floor lobby.';
    }
    if (destination == 'IS Laboratory') {
      return point.floor == 0
          ? 'Follow the laboratory corridor from this checkpoint.'
          : 'Go to the stairs and continue to the ground-floor laboratory.';
    }
    final targetFloor = destination.startsWith('First')
        ? 1
        : destination.startsWith('Second')
        ? 2
        : 3;
    if (point.floor == targetFloor) {
      return 'Follow the signs to the $destination.';
    }
    return point.floor < targetFloor
        ? 'Go to the stairs and move up to floor $targetFloor.'
        : 'Go to the stairs and move down to floor $targetFloor.';
  }

  @override
  Widget build(BuildContext context) {
    final point = _currentPoint;
    return Scaffold(
      appBar: AppBar(
        title: const Text('IS Building QR Wayfinder'),
        backgroundColor: const Color(0xFF1A2D33),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.location_searching, size: 56, color: Color(0xFFB7791F)),
          const SizedBox(height: 12),
          const Text(
            'Find your way inside the building',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your destination first, then scan the nearest wayfinder QR code.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _destination,
            decoration: const InputDecoration(
              labelText: 'Where do you want to go?',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: _destinations
                .map((destination) => DropdownMenuItem(
                      value: destination,
                      child: Text(destination),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _destination = value;
                _currentPoint = null;
                _message = null;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _destination == null || _isScanning
                  ? null
                  : _scanLocation,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(_isScanning ? 'Opening scanner...' : 'Scan QR Location'),
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            _MessageCard(message: _message!),
          ],
          if (point != null) ...[
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFFEAF7F0),
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
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      point.name,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('IS Building • ${point.floor == 0 ? 'Ground' : '${point.floor}'} floor'),
                    const Divider(height: 24),
                    const Text(
                      'DIRECTION',
                      style: TextStyle(
                        color: Color(0xFF247A50),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _directionText(),
                      style: const TextStyle(fontSize: 17, height: 1.4),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(message, style: TextStyle(color: Colors.orange.shade900)),
      ),
    );
  }
}