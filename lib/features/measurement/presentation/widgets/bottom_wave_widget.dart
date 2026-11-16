import 'package:flutter/material.dart';

/// Decorative flowing multi-layer wave graphic matching the fancy reference design,
/// featuring rich sapphire-to-cyan gradients, smooth dual-crest S-curves,
/// and luminous specular crest highlights.
class BottomWaveWidget extends StatelessWidget {
  final double height;

  const BottomWaveWidget({
    super.key,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _BottomWavePainter(),
      ),
    );
  }
}

class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Layer 1: Ambient Luminous Cyan Accent Wave (Back Layer peaking at right)
    final backWavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x350052D4),
          Color(0x600072FF),
          Color(0x8000C6FF),
          Color(0x5560EFFF),
        ],
        stops: [0.0, 0.35, 0.70, 1.0],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final backPath = Path();
    backPath.moveTo(0, size.height * 0.75);
    backPath.cubicTo(
      size.width * 0.35,
      size.height * 0.50,
      size.width * 0.65,
      size.height * 0.08,
      size.width,
      size.height * 0.38,
    );
    backPath.lineTo(size.width, size.height);
    backPath.lineTo(0, size.height);
    backPath.close();
    canvas.drawPath(backPath, backWavePaint);

    // Layer 2: Intermediate Radiant Sky Ribbon
    final midWavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x55003DA5),
          Color(0x800066FF),
          Color(0x9500C6FF),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final midPath = Path();
    midPath.moveTo(0, size.height * 0.58);
    midPath.cubicTo(
      size.width * 0.30,
      size.height * 0.15,
      size.width * 0.62,
      size.height * 0.75,
      size.width,
      size.height * 0.45,
    );
    midPath.lineTo(size.width, size.height);
    midPath.lineTo(0, size.height);
    midPath.close();
    canvas.drawPath(midPath, midWavePaint);

    // Layer 3: Solid Rich Sapphire-to-Cyan Foreground Wave (Primary)
    final frontWavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF003899),
          Color(0xFF0058DD),
          Color(0xFF0078FF),
          Color(0xFF00A6FF),
          Color(0xFF00C6FF),
        ],
        stops: [0.0, 0.25, 0.55, 0.80, 1.0],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final frontPath = Path();
    frontPath.moveTo(0, size.height * 0.42);
    frontPath.cubicTo(
      size.width * 0.28,
      size.height * 0.06,
      size.width * 0.60,
      size.height * 0.65,
      size.width,
      size.height * 0.35,
    );
    frontPath.lineTo(size.width, size.height);
    frontPath.lineTo(0, size.height);
    frontPath.close();
    canvas.drawPath(frontPath, frontWavePaint);

    // Layer 4: Specular Crest Highlight Line
    final crestHighlightPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          Color(0xB0FFFFFF),
          Color(0xFF60EFFF),
          Color(0x9000C6FF),
          Colors.transparent,
        ],
        stops: [0.0, 0.25, 0.55, 0.80, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final crestPath = Path();
    crestPath.moveTo(0, size.height * 0.42);
    crestPath.cubicTo(
      size.width * 0.28,
      size.height * 0.06,
      size.width * 0.60,
      size.height * 0.65,
      size.width,
      size.height * 0.35,
    );
    canvas.drawPath(crestPath, crestHighlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
