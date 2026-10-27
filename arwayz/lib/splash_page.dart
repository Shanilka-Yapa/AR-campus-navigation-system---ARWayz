import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _fadeSubtitleAnimation;

  // Project Color Palette
  static const Color primaryDark = Color(0xFF1A2D33);
  static const Color goldAccent = Color(0xFFB7791F);
  static const Color steelBlue = Color(0xFF7B929C);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // 0.0 to 0.5: Draw building/campus logo stroke
    _logoAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    );

    // 0.4 to 0.85: Draw "ARWayz" title letters stroke by stroke
    _textAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.85, curve: Curves.easeInOut),
    );

    // 0.75 to 1.0: Fade in subtitle & progress indicator
    _fadeSubtitleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          context.go('/welcome');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Ambient Glowing Background Circles
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: goldAccent.withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: -120,
                left: -80,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: steelBlue.withOpacity(0.15),
                  ),
                ),
              ),

              // Main Animated Canvas Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Path Drawing Logo
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CustomPaint(
                        painter: _LogoPathPainter(
                          progress: _logoAnimation.value,
                          color: Colors.white,
                          accentColor: goldAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Letter by Letter Path Drawing Text "ARWayz"
                    SizedBox(
                      width: 260,
                      height: 50,
                      child: CustomPaint(
                        painter: _TextStrokePainter(
                          progress: _textAnimation.value,
                          text: 'ARWayz',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle Fade-in
                    Opacity(
                      opacity: _fadeSubtitleAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - _fadeSubtitleAnimation.value)),
                        child: const Text(
                          'Your Smart Campus Guide',
                          style: TextStyle(
                            color: steelBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Loading Progress Line
              Positioned(
                bottom: 60,
                left: 60,
                right: 60,
                child: Opacity(
                  opacity: _fadeSubtitleAnimation.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _controller.value,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      color: goldAccent,
                      minHeight: 3,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// CustomPainter that draws the campus building/compass logo stroke paths
class _LogoPathPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color accentColor;

  _LogoPathPainter({
    required this.progress,
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Building Roof Path
    final roofPath = Path();
    roofPath.moveTo(w * 0.1, h * 0.5);
    roofPath.lineTo(w * 0.5, h * 0.15);
    roofPath.lineTo(w * 0.9, h * 0.5);

    // Building Pillars Path
    roofPath.moveTo(w * 0.2, h * 0.5);
    roofPath.lineTo(w * 0.2, h * 0.85);
    roofPath.lineTo(w * 0.8, h * 0.85);
    roofPath.lineTo(w * 0.8, h * 0.5);

    // Dome / Tower Flag Path
    roofPath.moveTo(w * 0.5, h * 0.15);
    roofPath.lineTo(w * 0.5, h * 0.04);
    roofPath.lineTo(w * 0.65, h * 0.08);
    roofPath.lineTo(w * 0.5, h * 0.12);

    // Entrance Arch Path
    roofPath.moveTo(w * 0.4, h * 0.85);
    roofPath.arcToPoint(
      Offset(w * 0.6, h * 0.85),
      radius: Radius.circular(w * 0.1),
      clockwise: true,
    );

    // Animate Path Stroke Length based on progress
    final pathMetrics = roofPath.computeMetrics();
    for (final metric in pathMetrics) {
      final extractLength = metric.length * progress;
      final extractPath = metric.extractPath(0, extractLength);

      strokePaint.color = color;
      canvas.drawPath(extractPath, strokePaint);
    }

    // AR Needle Accent Dot
    if (progress > 0.6) {
      final dotPaint = Paint()
        ..color = accentColor.withOpacity(((progress - 0.6) / 0.4).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w * 0.5, h * 0.55), 6 * progress, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LogoPathPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// CustomPainter that draws the text "ARWayz" stroke paths letter by letter
class _TextStrokePainter extends CustomPainter {
  final double progress;
  final String text;

  _TextStrokePainter({
    required this.progress,
    required this.text,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      fontSize: 42,
      fontWeight: FontWeight.bold,
      letterSpacing: 2.0,
      color: Colors.white,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Calculate total character count to reveal letter by letter
    final int visibleChars = (text.length * progress).ceil().clamp(0, text.length);
    final String currentText = text.substring(0, visibleChars);

    final currentSpan = TextSpan(
      text: currentText,
      style: textStyle.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white.withOpacity(progress.clamp(0.2, 1.0)),
      ),
    );

    final currentPainter = TextPainter(
      text: currentSpan,
      textDirection: TextDirection.ltr,
    );
    currentPainter.layout();

    // Center the text
    final offset = Offset(
      (size.width - currentPainter.width) / 2,
      (size.height - currentPainter.height) / 2,
    );

    currentPainter.paint(canvas, offset);

    // Draw stroke glow effect under the text
    if (progress > 0.1) {
      final strokeSpan = TextSpan(
        text: currentText,
        style: textStyle.copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = const Color(0xFFB7791F).withOpacity((progress * 0.8).clamp(0.0, 0.8)),
        ),
      );

      final strokePainter = TextPainter(
        text: strokeSpan,
        textDirection: TextDirection.ltr,
      );
      strokePainter.layout();
      strokePainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _TextStrokePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
