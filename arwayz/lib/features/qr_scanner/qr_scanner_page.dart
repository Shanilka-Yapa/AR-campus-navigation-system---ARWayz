import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/qr_payload.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with TickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  late final AnimationController _scanAnimationController;
  late final AnimationController _pulseAnimationController;
  String scannedCode = "";
  bool hasScanned = false;
  QrPayload? scannedPayload;
  bool _torchEnabled = false;

  static const _primaryDark = Color(0xFF1A2D33);
  static const _deepTeal = Color(0xFF235559);
  static const _accentTeal = Color(0xFF8FD0C9);

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _pulseAnimationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  String _prepareUrl(String code) {
    String urlString = code.trim().replaceAll('\n', '').replaceAll('\r', '');
    if (!urlString.startsWith(RegExp(r'https?://'))) {
      urlString = 'https://$urlString';
    }
    return urlString;
  }

  Future<void> _openUrl(String code) async {
    final urlString = _prepareUrl(code);

    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Cannot open link'),
            content: Text('Scanned QR code is not a valid URL:\n$urlString'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening link: $e')));
    }
  }

  void _useScannedPayload() {
    final payload = scannedPayload;
    if (payload == null) return;
    Navigator.pop(context, payload);
  }

  void _scanAgain() {
    setState(() {
      scannedCode = "";
      scannedPayload = null;
      hasScanned = false;
    });
    _scannerController.start();
  }

  Future<void> _toggleTorch() async {
    await _scannerController.toggleTorch();
    if (mounted) {
      setState(() => _torchEnabled = !_torchEnabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                if (capture.barcodes.isEmpty) return;
                final code = capture.barcodes.first.rawValue?.trim() ?? '';
                if (code.isEmpty || scannedCode == code) return;
                final payload = QrPayload.parse(code);
                if (payload != null) _scannerController.stop();
                setState(() {
                  scannedCode = code;
                  scannedPayload = payload;
                  hasScanned = true;
                });
              },
            ),
          ),
          if (!hasScanned)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ScannerMaskPainter(
                    color: Colors.black.withValues(alpha: 0.66),
                    targetSize: 260,
                    targetCenterFactor: 0.48,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 126,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(64, 14, 64, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _primaryDark,
                      Color(0xCC1A2D33),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Scan QR Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Find your next campus destination',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 10,
            left: 16,
            child: _headerButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          if (!hasScanned)
            Positioned.fill(
              top: 142,
              bottom: 24,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _scanAnimationController,
                  _pulseAnimationController,
                ]),
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: _readableText(
                          'Align the QR code inside the frame',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _ScanFrame(
                        color: _accentTeal,
                        laserProgress: _scanAnimationController.value,
                      ),
                      Column(
                        children: [
                          _buildQuickActions(),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Opacity(
                                opacity:
                                    0.55 +
                                    (_pulseAnimationController.value * 0.45),
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: _accentTeal,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _readableText(
                                'Scanning starts automatically',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          if (hasScanned)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildResultSheet(_deepTeal),
            ),
        ],
      ),
    );
  }

  Widget _readableText(
    String text, {
    required double fontSize,
    required FontWeight fontWeight,
    Color color = Colors.white,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            shadows: const [Shadow(color: Colors.black87, blurRadius: 5)],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _quickAction(
            icon: _torchEnabled
                ? Icons.flash_on_rounded
                : Icons.flash_off_rounded,
            label: 'Flash',
            active: _torchEnabled,
            onPressed: _toggleTorch,
          ),
          const SizedBox(width: 8),
          _quickAction(
            icon: Icons.flip_camera_android_rounded,
            label: 'Flip',
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool active = false,
  }) {
    return Material(
      color: active ? _accentTeal.withValues(alpha: 0.25) : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: active ? _accentTeal : Colors.white, size: 20),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: active ? _accentTeal : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 19),
        tooltip: 'Scanner control',
      ),
    );
  }

  Widget _buildResultSheet(Color accent) {
    final isPayload = scannedPayload != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFBEC4C4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: accent.withValues(alpha: 0.12),
                  child: Icon(
                    isPayload ? Icons.location_on_rounded : Icons.link_rounded,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPayload ? 'Campus QR detected' : 'QR code detected',
                        style: const TextStyle(
                          color: Color(0xFF1A2D33),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        scannedCode,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF7B929C),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isPayload)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _useScannedPayload,
                  icon: const Icon(Icons.navigation_rounded),
                  label: const Text('START INDOOR NAVIGATION'),
                  style: _primaryButtonStyle(accent),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _resultAction(
                      icon: Icons.open_in_browser_rounded,
                      label: 'Open',
                      onPressed: () => _openUrl(scannedCode),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _resultAction(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: scannedCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _resultAction(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      onPressed: () =>
                          Share.share(scannedCode, subject: 'QR Code Link'),
                    ),
                  ),
                ],
              ),
            ],
            TextButton.icon(
              onPressed: _scanAgain,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Scan another code'),
              style: TextButton.styleFrom(foregroundColor: accent),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle(Color accent) {
    return ElevatedButton.styleFrom(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  Widget _resultAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF235559),
        side: const BorderSide(color: Color(0xFFBEC4C4)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  final Color color;
  final double laserProgress;

  const _ScanFrame({required this.color, required this.laserProgress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: CustomPaint(
        painter: _ScanFramePainter(color: color, laserProgress: laserProgress),
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  final Color color;
  final double laserProgress;

  const _ScanFramePainter({required this.color, required this.laserProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const corner = 28.0;
    const length = 48.0;
    final path = Path()
      ..moveTo(0, length)
      ..lineTo(0, corner)
      ..quadraticBezierTo(0, 0, corner, 0)
      ..lineTo(length, 0)
      ..moveTo(size.width - length, 0)
      ..lineTo(size.width - corner, 0)
      ..quadraticBezierTo(size.width, 0, size.width, corner)
      ..lineTo(size.width, length)
      ..moveTo(0, size.height - length)
      ..lineTo(0, size.height - corner)
      ..quadraticBezierTo(0, size.height, corner, size.height)
      ..lineTo(length, size.height)
      ..moveTo(size.width - length, size.height)
      ..lineTo(size.width - corner, size.height)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width,
        size.height - corner,
      )
      ..lineTo(size.width, size.height - length);
    canvas.drawPath(path, paint);

    final laserY = 18 + ((size.height - 36) * laserProgress);
    final laserPaint = Paint()
      ..strokeWidth = 2.5
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0), color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, laserY, size.width, 1));
    canvas.drawLine(
      Offset(18, laserY),
      Offset(size.width - 18, laserY),
      laserPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.laserProgress != laserProgress;
  }
}

class _ScannerMaskPainter extends CustomPainter {
  final Color color;
  final double targetSize;
  final double targetCenterFactor;

  const _ScannerMaskPainter({
    required this.color,
    required this.targetSize,
    required this.targetCenterFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final targetLeft = (size.width - targetSize) / 2;
    final targetTop = (size.height * targetCenterFactor) - (targetSize / 2);
    final target = RRect.fromRectAndRadius(
      Rect.fromLTWH(targetLeft, targetTop, targetSize, targetSize),
      const Radius.circular(12),
    );

    canvas.saveLayer(Offset.zero & size, Paint());
    final mask = Paint()..color = color;
    canvas.drawRect(Offset.zero & size, mask);
    final clear = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(target, clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScannerMaskPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.targetSize != targetSize ||
        oldDelegate.targetCenterFactor != targetCenterFactor;
  }
}
