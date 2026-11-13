import 'package:flutter/material.dart';

/// Decorative flowing multi-layer wave graphic at the base of the dashboard,
/// faithfully matching the bottom curve aesthetics of the reference UI design.
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
    // Layer 1: Soft Cyan/Blue background wave
    final wave1Paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x304FACFE),
          Color(0x2500C6FF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.45);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.08,
      size.width * 0.52,
      size.height * 0.42,
    );
    path1.quadraticBezierTo(
      size.width * 0.80,
      size.height * 0.80,
      size.width,
      size.height * 0.32,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, wave1Paint);

    // Layer 2: Vibrant Deep Sky Blue foreground wave
    final wave2Paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x600052D4),
          Color(0x550066FF),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.68);
    path2.quadraticBezierTo(
      size.width * 0.32,
      size.height * 0.22,
      size.width * 0.68,
      size.height * 0.60,
    );
    path2.quadraticBezierTo(
      size.width * 0.88,
      size.height * 0.78,
      size.width,
      size.height * 0.55,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, wave2Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

