import 'package:flutter/material.dart';

/// Top multi-layer flowing organic wave for the Splash Screen.
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
    // Layer 1: Soft Cyan/Blue background wave flowing down
    final wave1Paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x3500C6FF),
          Color(0x300052D4),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(size.width, 0);
    path1.lineTo(size.width, size.height * 0.55);
    path1.quadraticBezierTo(
      size.width * 0.72,
      size.height * 0.95,
      size.width * 0.42,
      size.height * 0.65,
    );
    path1.quadraticBezierTo(
      size.width * 0.18,
      size.height * 0.40,
      0,
      size.height * 0.78,
    );
    path1.close();
    canvas.drawPath(path1, wave1Paint);

    // Layer 2: Vibrant Deep Sky Blue foreground wave
    final wave2Paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x650052D4),
          Color(0x550066FF),
          Color(0x4000C6FF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, 0);
    path2.lineTo(size.width, 0);
    path2.lineTo(size.width, size.height * 0.42);
    path2.quadraticBezierTo(
      size.width * 0.68,
      size.height * 0.78,
      size.width * 0.35,
      size.height * 0.45,
    );
    path2.quadraticBezierTo(
      size.width * 0.12,
      size.height * 0.22,
      0,
      size.height * 0.58,
    );
    path2.close();
    canvas.drawPath(path2, wave2Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

