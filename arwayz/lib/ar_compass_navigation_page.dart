import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

/// AR Navigation — ground-path style.
///
/// Paints a perspective green path on the camera feed with animated
/// chevron arrows flowing toward the destination.
/// No floating centre icon. No compass widget.
class ARCompassNavigationPage extends StatefulWidget {
  final double destLat;
  final double destLon;
  final String destName;
  final String locationType;

  const ARCompassNavigationPage({
    required this.destLat,
    required this.destLon,
    required this.destName,
    required this.locationType,
    super.key,
  });

  @override
  State<ARCompassNavigationPage> createState() =>
      _ARCompassNavigationPageState();
}

class _ARCompassNavigationPageState extends State<ARCompassNavigationPage>
    with TickerProviderStateMixin {
  // ── camera ────────────────────────────────────────────────────
  CameraController? _cam;
  bool _camReady = false;

  // ── sensors ───────────────────────────────────────────────────
  double _heading = 0;
  double _bearing = 0;
  double _distance = 0;
  Position? _position;
  bool _locationReady = false;
  _GpsMode _gpsMode = _GpsMode.acquiring;
  bool _arrived = false;
  String? _error;

  // ── animations ────────────────────────────────────────────────
  late AnimationController _flowCtrl;
  late AnimationController _celebCtrl;
  late Animation<double> _celebScale;
  late Animation<double> _celebOpacity;

  // ── colours ───────────────────────────────────────────────────
  static const _green = Color(0xFF2ECC71);
  static const _darkCard = Color(0xF2111111);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _flowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _celebCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _celebScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _celebCtrl, curve: Curves.elasticOut),
    );
    _celebOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _celebCtrl, curve: Curves.easeIn),
    );

    _initCamera();
    _startHeading();
    _startLocation();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _cam?.dispose();
    _flowCtrl.dispose();
    _celebCtrl.dispose();
    super.dispose();
  }

  // ── Init ──────────────────────────────────────────────────────

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No camera');
        return;
      }
      final ctrl = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await ctrl.initialize();
      _cam = ctrl;
      if (mounted) setState(() => _camReady = true);
    } catch (e) {
      if (mounted) setState(() => _error = 'Camera error: $e');
    }
  }

  void _startHeading() {
    FlutterCompass.events?.listen((e) {
      if (mounted) setState(() => _heading = e.heading ?? 0);
    });
  }

  void _startLocation() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      if (mounted) setState(() => _error = 'Location permission denied');
      return;
    }

    _listenAt(LocationAccuracy.best);

    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted || _locationReady) return;
      setState(() => _gpsMode = _GpsMode.network);
      _listenAt(LocationAccuracy.medium);
    });

    Future.delayed(const Duration(seconds: 20), () {
      if (!mounted || _locationReady) return;
      setState(() => _gpsMode = _GpsMode.compassOnly);
    });
  }

  void _listenAt(LocationAccuracy accuracy) {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: accuracy, distanceFilter: 1),
    ).listen((pos) {
      if (!mounted) return;
      setState(() {
        _position = pos;
        _locationReady = true;
        _gpsMode = accuracy == LocationAccuracy.best
            ? _GpsMode.gps
            : _GpsMode.network;
        _recalculate();
      });
    });
  }

  // ── Maths ─────────────────────────────────────────────────────

  void _recalculate() {
    if (_position == null) return;
    final lat1 = _position!.latitude * math.pi / 180;
    final lon1 = _position!.longitude * math.pi / 180;
    final lat2 = widget.destLat * math.pi / 180;
    final lon2 = widget.destLon * math.pi / 180;

    final y = math.sin(lon2 - lon1) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(lon2 - lon1);
    _bearing = (math.atan2(y, x) * 180 / math.pi + 360) % 360;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    _distance = 6371000 * 2 * math.asin(math.sqrt(a));

    if (_distance < 15 && !_arrived) {
      _arrived = true;
      _celebCtrl.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) => _showArrival());
    }
  }

  double get _angleDiff {
    final a = (_bearing - _heading) % 360;
    return a > 180 ? a - 360 : a;
  }

  _Direction get _direction {
    final d = _angleDiff;
    if (d > -22 && d < 22) return _Direction.straight;
    return d >= 22 ? _Direction.right : _Direction.left;
  }

  // ── Helpers ───────────────────────────────────────────────────

  String _fmtDist(double m) => m < 1000
      ? '${m.toStringAsFixed(0)} m'
      : '${(m / 1000).toStringAsFixed(2)} km';

  String get _locationIcon => switch (widget.locationType) {
        'admin' => '🏛️',
        'cafeteria' => '🍽️',
        'library' => '📚',
        'auditorium' => '🎭',
        'gym' => '🏋️',
        'hostel' => '🏠',
        _ => '🏢',
      };

  Color get _locationColor => switch (widget.locationType) {
        'admin' => const Color(0xFFAB47BC),
        'cafeteria' => const Color(0xFFFF7043),
        'library' => const Color(0xFF5C6BC0),
        'auditorium' => const Color(0xFFEF5350),
        'gym' => const Color(0xFFEC407A),
        'hostel' => const Color(0xFFFFCA28),
        _ => const Color(0xFF29B6F6),
      };

  (String, IconData) get _directionInfo => switch (_direction) {
        _Direction.straight => ('Straight ahead', Icons.arrow_upward_rounded),
        _Direction.left => ('Turn left', Icons.turn_left_rounded),
        _Direction.right => ('Turn right', Icons.turn_right_rounded),
      };

  // ── Arrival dialog ────────────────────────────────────────────

  void _showArrival() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScaleTransition(
        scale: _celebScale,
        child: FadeTransition(
          opacity: _celebOpacity,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
              decoration: BoxDecoration(
                color: _darkCard,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _green, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: _green.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 4),
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(_locationIcon, style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 14),
                const Text(
                  'You Have Arrived',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.destName,
                  style: TextStyle(
                      color: _green,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Done',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _errorScreen();

    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        // 1 ── Camera feed
        _camReady && _cam != null
            ? CameraPreview(_cam!)
            : const ColoredBox(
                color: Colors.black,
                child: Center(
                    child: CircularProgressIndicator(color: _green))),

        // 2 ── AR ground-path overlay
        if (_camReady)
          AnimatedBuilder(
            animation: _flowCtrl,
            builder: (_, __) => CustomPaint(
              painter: _GroundPathPainter(
                angleDiff: _locationReady ? _angleDiff : 0,
                flowValue: _flowCtrl.value,
                pathColor: _green,
              ),
            ),
          ),

        // 3 ── Top bar
        _topBar(mq),

        // 4 ── Destination badge below top bar
        Positioned(
          top: mq.padding.top + 66,
          left: 0,
          right: 0,
          child: Center(child: _destBadge()),
        ),

        // 5 ── Bottom white card
        Positioned(
          left: 16,
          right: 16,
          bottom: mq.padding.bottom + 20,
          child: _bottomCard(),
        ),

        // 6 ── Arrived strip (only live after GPS fix)
        if (_locationReady && _distance < 15)
          Positioned(
            top: mq.padding.top + 120,
            left: 20,
            right: 20,
            child: _arrivalStrip(),
          ),
      ]),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────

  Widget _topBar(MediaQueryData mq) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 17),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(children: [
                  Text(_locationIcon,
                      style: const TextStyle(fontSize: 17)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.destName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(width: 10),
            _gpsChip(),
          ]),
        ),
      ),
    );
  }

  Widget _gpsChip() {
    final (color, icon, label) = switch (_gpsMode) {
      _GpsMode.gps => (Colors.greenAccent, Icons.gps_fixed, 'GPS'),
      _GpsMode.network => (Colors.orange, Icons.wifi, 'NET'),
      _GpsMode.compassOnly => (Colors.redAccent, Icons.signal_wifi_off, 'NO'),
      _GpsMode.acquiring => (Colors.white54, Icons.radar, '···'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  // ── Destination badge ─────────────────────────────────────────

  Widget _destBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white30, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 16, spreadRadius: 1),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(_locationIcon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          widget.destName,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2),
        ),
      ]),
    );
  }

  // ── Bottom card ───────────────────────────────────────────────

  Widget _bottomCard() {
    final (label, icon) = _directionInfo;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black38,
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: _locationReady
          ? Row(children: [
              // Direction icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: _green, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _fmtDist(_distance),
                      style: const TextStyle(
                          color: Colors.black45, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Location type pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _locationColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: _locationColor.withOpacity(0.3)),
                ),
                child: Text(_locationIcon,
                    style: const TextStyle(fontSize: 22)),
              ),
            ])
          : _gpsWaitRow(),
    );
  }

  Widget _gpsWaitRow() {
    final (msg, sub) = switch (_gpsMode) {
      _GpsMode.acquiring =>
        ('Acquiring GPS…', 'Searching for satellite signal'),
      _GpsMode.network =>
        ('Network location…', 'Using WiFi / cell towers'),
      _GpsMode.compassOnly =>
        ('No signal', 'Move near a window or go outdoors'),
      _GpsMode.gps => ('', ''),
    };
    return Row(children: [
      if (_gpsMode != _GpsMode.compassOnly)
        const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: _green))
      else
        const Icon(Icons.signal_wifi_off_rounded,
            color: Colors.orange, size: 20),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg,
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            Text(sub,
                style: const TextStyle(
                    color: Colors.black45, fontSize: 12)),
          ],
        ),
      ),
    ]);
  }

  Widget _arrivalStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade900.withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _green.withOpacity(0.5)),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle_rounded, color: _green, size: 22),
        const SizedBox(width: 10),
        const Text('You have arrived!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _errorScreen() => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline_rounded,
                  size: 52, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(_error ?? 'Unknown error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Go Back'),
              ),
            ]),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
//  Ground-path CustomPainter
//
//  Draws a perspective-correct green trapezoid on the bottom half
//  of the screen, with animated white chevron arrows flowing from
//  the bottom toward the vanishing point — just like the reference.
//
//  angleDiff < 0  → path curves left
//  angleDiff > 0  → path curves right
//  angleDiff ≈ 0  → path goes straight up
// ═══════════════════════════════════════════════════════════════
class _GroundPathPainter extends CustomPainter {
  final double angleDiff;
  final double flowValue; // 0→1 looping
  final Color pathColor;

  const _GroundPathPainter({
    required this.angleDiff,
    required this.flowValue,
    required this.pathColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vanishing point shifts left/right with direction
    final double vpX = size.width / 2 +
        (angleDiff.clamp(-90.0, 90.0) / 90.0) * size.width * 0.32;
    final double vpY = size.height * 0.40;
    final vp = Offset(vpX, vpY);

    const double halfBase = 115; // half-width at bottom of screen
    const double halfTop = 16;   // half-width at vanishing point

    final bl = Offset(size.width / 2 - halfBase, size.height);
    final br = Offset(size.width / 2 + halfBase, size.height);
    final vl = Offset(vpX - halfTop, vpY);
    final vr = Offset(vpX + halfTop, vpY);

    // ── 1. Filled gradient path ───────────────────────────────
    final pathShape = Path()
      ..moveTo(bl.dx, bl.dy)
      ..lineTo(vl.dx, vl.dy)
      ..lineTo(vr.dx, vr.dy)
      ..lineTo(br.dx, br.dy)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          pathColor.withOpacity(0.50),
          pathColor.withOpacity(0.22),
          pathColor.withOpacity(0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromPoints(Offset(vpX, size.height), vp));

    canvas.drawPath(pathShape, fillPaint);

    // ── 2. Edge lines ─────────────────────────────────────────
    final edgePaint = Paint()
      ..color = pathColor.withOpacity(0.45)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(bl, vl, edgePaint);
    canvas.drawLine(br, vr, edgePaint);

    // ── 3. Chevron arrows ─────────────────────────────────────
    // 5 chevrons animated from bottom toward vanishing point.
    // Each is a simple ">" / "V" shape (pointing upward = toward dest).
    const int chevronCount = 5;
    for (int i = 0; i < chevronCount; i++) {
      // Raw t: 0 = bottom, 1 = top; staggered by index + animation phase
      double t = ((i / chevronCount) + flowValue) % 1.0;

      // Quadratic ease: chevrons bunch near horizon (realistic perspective)
      final double tP = t * t;

      // Centre position interpolated between bottom-centre and vanishing pt
      final double cx =
          _lerp(size.width / 2, vpX, tP);
      final double cy = _lerp(size.height, vpY, tP);

      // Width and height shrink with perspective
      final double hw = _lerp(halfBase * 0.52, halfTop * 0.7, tP);
      final double ch = _lerp(30.0, 7.0, tP);

      // Fade near horizon and near base
      final double alpha = math.sin(t * math.pi).clamp(0.15, 1.0);

      final chevPaint = Paint()
        ..color = Colors.white.withOpacity(alpha * 0.92)
        ..strokeWidth = _lerp(3.2, 1.0, tP)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // V-shape pointing upward
      final chevPath = Path()
        ..moveTo(cx - hw, cy + ch / 2)
        ..lineTo(cx, cy - ch / 2)
        ..lineTo(cx + hw, cy + ch / 2);

      canvas.drawPath(chevPath, chevPaint);
    }
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(_GroundPathPainter old) =>
      old.flowValue != flowValue || old.angleDiff != angleDiff;
}

// ═══════════════════════════════════════════════════════════════
// Enums
// ═══════════════════════════════════════════════════════════════

enum _Direction { straight, left, right }

enum _GpsMode { acquiring, network, compassOnly, gps }