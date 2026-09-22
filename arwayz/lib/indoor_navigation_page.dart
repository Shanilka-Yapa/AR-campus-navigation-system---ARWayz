import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'qr_payload.dart';
import 'qr_scanner_page.dart';

class IndoorCheckpoint {
  final String id;
  final String name;
  final String instruction;
  final IconData icon;

  const IndoorCheckpoint({
    required this.id,
    required this.name,
    required this.instruction,
    required this.icon,
  });
}

/// QR-assisted indoor route for the IS Department building prototype.
///
/// Replace these four checkpoint labels with the real locations after doing
/// a walkthrough of the building. The QR payloads are documented in
/// INDOOR_QR_SETUP.md.
class IndoorNavigationPage extends StatefulWidget {
  static const buildingId = 'IS_BUILDING';
  static const floor = 0;

  final QrPayload startPoint;

  const IndoorNavigationPage({super.key, required this.startPoint});

  @override
  State<IndoorNavigationPage> createState() => _IndoorNavigationPageState();
}

class _IndoorNavigationPageState extends State<IndoorNavigationPage> {
  static const checkpoints = <IndoorCheckpoint>[
    IndoorCheckpoint(
      id: 'ground_entrance',
      name: 'Ground-floor entrance',
      instruction: 'Walk from the entrance to the lobby checkpoint.',
      icon: Icons.login,
    ),
    IndoorCheckpoint(
      id: 'ground_lobby',
      name: 'Ground-floor lobby',
      instruction: 'Continue straight to the corridor junction.',
      icon: Icons.meeting_room,
    ),
    IndoorCheckpoint(
      id: 'ground_corridor',
      name: 'Ground-floor corridor junction',
      instruction: 'Turn toward the IS laboratory corridor.',
      icon: Icons.turn_right,
    ),
    IndoorCheckpoint(
      id: 'new_computer_center',
      name: 'New Computer Center',
      instruction: 'You have reached the New Computer Center.',
      icon: Icons.computer,
    ),
  ];

  CameraController? _cameraController;
  int _currentIndex = 0;
  String? _message;
  bool _isScanning = false;

  IndoorCheckpoint get _current => checkpoints[_currentIndex];
  bool get _arrived => _currentIndex == checkpoints.length - 1;
  IndoorCheckpoint? get _next =>
      _arrived ? null : checkpoints[_currentIndex + 1];

  @override
  void initState() {
    super.initState();
    final startIndex = checkpoints.indexWhere(
      (checkpoint) => checkpoint.id == widget.startPoint.pointId,
    );
    if (startIndex >= 0) {
      _currentIndex = startIndex;
    }
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _cameraController = controller);
    } catch (_) {
      // Indoor navigation remains usable as a checkpoint list if the camera
      // is unavailable or permission is denied.
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _scanNextCheckpoint() async {
    if (_arrived || _isScanning) return;
    setState(() {
      _isScanning = true;
      _message = null;
    });

    final result = await Navigator.push<QrPayload>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerPage()),
    );

    if (!mounted) return;
    setState(() => _isScanning = false);
    if (result == null) return;

    final expected = _next!;
    if (result.buildingId != IndoorNavigationPage.buildingId ||
        result.floor != IndoorNavigationPage.floor) {
      setState(() => _message = 'Wrong building or floor QR code.');
      return;
    }
    if (result.pointId != expected.id) {
      setState(() => _message = 'Scan the next checkpoint: ${expected.name}.');
      return;
    }

    setState(() {
      _currentIndex++;
      _message = _arrived
          ? 'Arrival confirmed at New Computer Center.'
          : 'Checkpoint confirmed: ${expected.name}.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final next = _next;
    return Scaffold(
      backgroundColor: const Color(0xFF111A1D),
      appBar: AppBar(
        title: const Text('Indoor Navigation'),
        backgroundColor: const Color(0xFF1A2D33),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_cameraController?.value.isInitialized == true)
            CameraPreview(_cameraController!)
          else
            const ColoredBox(color: Color(0xFF243438)),
          ColoredBox(color: Colors.black26),
          SafeArea(
            child: Column(
              children: [
                _statusCard(),
                const Spacer(),
                if (!_arrived) _directionOverlay(next!),
                const Spacer(),
                _bottomPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.78),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.business, color: Color(0xFF63D6A0)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'IS Department Building\nGround Floor',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
          Text(
            '${_currentIndex + 1}/${checkpoints.length}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _directionOverlay(IndoorCheckpoint next) {
    return Column(
      children: [
        const Icon(Icons.navigation, color: Color(0xFF63D6A0), size: 92),
        const SizedBox(height: 8),
        Text(
          'NEXT: ${next.name}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _current.instruction,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ],
    );
  }

  Widget _bottomPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xF2111A1D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _arrived
                ? 'You have arrived'
                : 'Current checkpoint: ${_current.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(
              _message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    _message!.startsWith('Wrong') ||
                        _message!.startsWith('Scan')
                    ? Colors.orangeAccent
                    : const Color(0xFF63D6A0),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _arrived || _isScanning ? null : _scanNextCheckpoint,
              icon: Icon(_arrived ? Icons.check : Icons.qr_code_scanner),
              label: Text(
                _arrived
                    ? 'ARRIVAL CONFIRMED'
                    : _isScanning
                    ? 'SCANNING...'
                    : 'SCAN NEXT CHECKPOINT',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF63D6A0),
                foregroundColor: const Color(0xFF111A1D),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
