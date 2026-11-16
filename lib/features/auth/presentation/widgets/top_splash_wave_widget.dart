import 'package:flutter/material.dart';

/// Top multi-layer flowing organic wave for the Splash Screen
/// featuring rich gradient stops and a glowing specular edge.
class TopSplashWaveWidget extends StatelessWidget {
  final double height;

  const TopSplashWaveWidget({
    super.key,
    this.height = 140,
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

    // Layer 1: Ambient Cyan Aura (Top deepest wave)
    final wave1Paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x4000C6FF),
          Color(0x300052D4),
          Color(0x2560EFFF),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(size.width, 0);
    path1.lineTo(size.width, size.height * 0.60);
    path1.cubicTo(
      size.width * 0.76,
      size.height * 0.98,
      size.width * 0.45,
      size.height * 0.60,
      size.width * 0.20,
      size.height * 0.82,
    );
    path1.quadraticBezierTo(
      size.width * 0.08,
      size.height * 0.90,
      0,
      size.height * 0.74,
    );
    path1.close();
    canvas.drawPath(path1, wave1Paint);

    // Layer 2: Vibrant Cobalt-to-Electric Intermediate Wave
    final wave2Paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x750052D4),
          Color(0x600066FF),
          Color(0x4500C6FF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, 0);
    path2.lineTo(size.width, 0);
    path2.lineTo(size.width, size.height * 0.44);
    path2.cubicTo(
      size.width * 0.70,
      size.height * 0.82,
      size.width * 0.38,
      size.height * 0.42,
      size.width * 0.16,
      size.height * 0.65,
    );
    path2.quadraticBezierTo(
      size.width * 0.06,
      size.height * 0.72,
      0,
      size.height * 0.58,
    );
    path2.close();
    canvas.drawPath(path2, wave2Paint);

    // Layer 3: Specular Crest Glow Line
    final crestGlowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          Color(0x90FFFFFF),
          Color(0xC060EFFF),
          Color(0x8000C6FF),
          Colors.transparent,
        ],
        stops: [0.0, 0.3, 0.6, 0.85, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final crestPath = Path();
    crestPath.moveTo(0, size.height * 0.58);
    crestPath.quadraticBezierTo(
      size.width * 0.06,
      size.height * 0.72,
      size.width * 0.16,
      size.height * 0.65,
    );
    crestPath.cubicTo(
      size.width * 0.38,
      size.height * 0.42,
      size.width * 0.70,
      size.height * 0.82,
      size.width,
      size.height * 0.44,
    );
    canvas.drawPath(crestPath, crestGlowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
