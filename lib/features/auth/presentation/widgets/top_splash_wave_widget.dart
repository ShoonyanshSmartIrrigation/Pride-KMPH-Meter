import 'package:flutter/material.dart';

/// Top multi-layer flowing organic wave for the Splash Screen
/// matching the fancy reference design with rich gradients,
/// silky S-curves, and a glowing specular crest.
class TopSplashWaveWidget extends StatelessWidget {
  final double height;

  const TopSplashWaveWidget({
    super.key,
    this.height = 145,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _TopWavePainter(),
      ),
    );
  }
}

class _TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Layer 1: Ambient Luminous Cyan Accent Wave (Back Layer)
    final backWavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x450052D4),
          Color(0x600072FF),
          Color(0x8000C6FF),
          Color(0x6560EFFF),
        ],
        stops: [0.0, 0.35, 0.75, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final backPath = Path();
    backPath.moveTo(0, 0);
    backPath.lineTo(size.width, 0);
    backPath.lineTo(size.width, size.height * 0.55);
    backPath.cubicTo(
      size.width * 0.72,
      size.height * 0.98,
      size.width * 0.36,
      size.height * 0.50,
      0,
      size.height * 0.82,
    );
    backPath.close();
    canvas.drawPath(backPath, backWavePaint);

    // Layer 2: Intermediate Azure Glow Ribbon
    final midWavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x55003DA5),
          Color(0x750066FF),
          Color(0x9000C6FF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final midPath = Path();
    midPath.moveTo(0, 0);
    midPath.lineTo(size.width, 0);
    midPath.lineTo(size.width, size.height * 0.42);
    midPath.cubicTo(
      size.width * 0.68,
      size.height * 0.85,
      size.width * 0.32,
      size.height * 0.38,
      0,
      size.height * 0.70,
    );
    midPath.close();
    canvas.drawPath(midPath, midWavePaint);

    // Layer 3: Solid Rich Sapphire-to-Cyan Foreground Wave
    final frontWavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF021B48),
          Color(0xFF003FAD),
          Color(0xFF0066FF),
          Color(0xFF0099FF),
          Color(0xFF00C6FF),
        ],
        stops: [0.0, 0.24, 0.54, 0.82, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final frontPath = Path();
    frontPath.moveTo(0, 0);
    frontPath.lineTo(size.width, 0);
    frontPath.lineTo(size.width, size.height * 0.35);
    frontPath.cubicTo(
      size.width * 0.65,
      size.height * 0.72,
      size.width * 0.28,
      size.height * 0.28,
      0,
      size.height * 0.58,
    );
    frontPath.close();
    canvas.drawPath(frontPath, frontWavePaint);

    // Layer 4: Specular Crest Glow Along Foreground Edge
    final crestGlowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          Color(0xC0FFFFFF),
          Color(0xFF60EFFF),
          Color(0x9000C6FF),
          Colors.transparent,
        ],
        stops: [0.0, 0.25, 0.55, 0.85, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final crestPath = Path();
    crestPath.moveTo(0, size.height * 0.58);
    crestPath.cubicTo(
      size.width * 0.28,
      size.height * 0.28,
      size.width * 0.65,
      size.height * 0.72,
      size.width,
      size.height * 0.35,
    );
    canvas.drawPath(crestPath, crestGlowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
