import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Speedometer gauge icon matching the reference splash screen graphic.
class SplashSpeedometerIcon extends StatelessWidget {
  final double size;

  const SplashSpeedometerIcon({
    super.key,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.88,
      child: CustomPaint(
        painter: _SpeedometerGaugePainter(),
      ),
    );
  }
}

class _SpeedometerGaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.62);
    final radius = size.width * 0.44;

    const startAngle = 135 * (math.pi / 180);
    const sweepAngle = 270 * (math.pi / 180);

    // 1. Gauge Arc Track (Vibrant cyan-blue gradient)
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0052D4), Color(0xFF0066FF), Color(0xFF00C6FF)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, trackPaint);

    // 2. Radial Tick Marks
    final tickPaint = Paint()
      ..color = const Color(0xFF0066FF).withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const totalTicks = 11;
    for (int i = 0; i < totalTicks; i++) {
      final angle = startAngle + (sweepAngle * (i / (totalTicks - 1)));
      final innerR = radius - 15;
      final outerR = radius - 7;

      final p1 = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );

      canvas.drawLine(p1, p2, tickPaint);
    }

    // 3. Speedometer Needle (pointing ~50° to the upper right)
    const needleAngle = 300 * (math.pi / 180); // upper right
    final needleLength = radius * 0.78;
    final needleTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0052D4), Color(0xFF00C6FF)],
      ).createShader(Rect.fromPoints(center, needleTip))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleTip, needlePaint);

    // 4. Center Needle Hub
    final hubShadowPaint = Paint()
      ..color = const Color(0xFF0052D4).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, 9, hubShadowPaint);

    final hubPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF0066FF), Color(0xFF003B99)],
      ).createShader(Rect.fromCircle(center: center, radius: 7))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 7, hubPaint);

    final hubInner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.8, hubInner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
