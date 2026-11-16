import 'package:flutter/material.dart';

/// Decorative flowing multi-layer wave graphic with richer gradients,
/// organic cubic curves, and soft luminous crest highlights.
class BottomWaveWidget extends StatelessWidget {
  final double height;

  const BottomWaveWidget({
    super.key,
    this.height = 70,
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

    // Layer 1: Ambient Luminous Cyan Glow Wave (deepest layer)
    final wave1Paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x3500C6FF),
          Color(0x200052D4),
          Color(0x2860EFFF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.40);
    path1.cubicTo(
      size.width * 0.22,
      size.height * 0.05,
      size.width * 0.48,
      size.height * 0.46,
      size.width * 0.72,
      size.height * 0.22,
    );
    path1.quadraticBezierTo(
      size.width * 0.88,
      size.height * 0.08,
      size.width,
      size.height * 0.28,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, wave1Paint);

    // Layer 2: Radiant Sky/Cobalt Intermediate Wave
    final wave2Paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x550052D4),
          Color(0x450072FF),
          Color(0x4000C6FF),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.62);
    path2.cubicTo(
      size.width * 0.28,
      size.height * 0.18,
      size.width * 0.62,
      size.height * 0.68,
      size.width * 0.84,
      size.height * 0.42,
    );
    path2.quadraticBezierTo(
      size.width * 0.94,
      size.height * 0.32,
      size.width,
      size.height * 0.48,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, wave2Paint);

    // Layer 3: Vibrant Royal-to-Cyan Foreground Wave
    final wave3Paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x95082E6E),
          Color(0x850052D4),
          Color(0x750072FF),
          Color(0x6500C6FF),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path3 = Path();
    path3.moveTo(0, size.height * 0.72);
    path3.cubicTo(
      size.width * 0.30,
      size.height * 0.28,
      size.width * 0.66,
      size.height * 0.64,
      size.width * 0.88,
      size.height * 0.58,
    );
    path3.quadraticBezierTo(
      size.width * 0.95,
      size.height * 0.55,
      size.width,
      size.height * 0.60,
    );
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, wave3Paint);

    // Layer 4: Specular Crest Highlight Line
    final crestHighlightPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          Color(0x8060EFFF),
          Color(0xE0FFFFFF),
          Color(0x9000C6FF),
          Colors.transparent,
        ],
        stops: [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final crestPath = Path();
    crestPath.moveTo(0, size.height * 0.72);
    crestPath.cubicTo(
      size.width * 0.30,
      size.height * 0.28,
      size.width * 0.66,
      size.height * 0.64,
      size.width * 0.88,
      size.height * 0.58,
    );
    crestPath.quadraticBezierTo(
      size.width * 0.95,
      size.height * 0.55,
      size.width,
      size.height * 0.60,
    );
    canvas.drawPath(crestPath, crestHighlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
