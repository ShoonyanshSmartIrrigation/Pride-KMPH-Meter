import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Precision high-end speedometer gauge with multi-stop glowing gradients,
/// concentric guide rings, precision ticks, and polished metallic center hub.
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
      height: size * 0.78,
      child: CustomPaint(
        painter: _SpeedometerGaugePainter(),
      ),
    );
  }
}

class _SpeedometerGaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.83);
    final radius = size.width * 0.42;

    const startAngle = 148 * (math.pi / 180);
    const sweepAngle = 244 * (math.pi / 180);

    // 0. Ambient Soft Glow Behind Gauge Arc
    final glowRect = Rect.fromCircle(center: center, radius: radius);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00C6FF).withValues(alpha: 0.22),
          const Color(0xFF0052D4).withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const [0.4, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 18))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 12, glowPaint);

    // 1. Concentric Hairline Outer Guide Arc
    final outerRingPaint = Paint()
      ..color = const Color(0xFF00C6FF).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 7),
      startAngle,
      sweepAngle,
      false,
      outerRingPaint,
    );

    // 2. Main Luminous Speedometer Arc Track (Rich 4-Stop Gradient)
    final trackPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0044B8),
          Color(0xFF0066FF),
          Color(0xFF00C6FF),
          Color(0xFF60EFFF),
        ],
        stops: [0.0, 0.35, 0.75, 1.0],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(glowRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(glowRect, startAngle, sweepAngle, false, trackPaint);

    // 3. Precision Radial Tick Marks (Alternating Major & Minor)
    const totalTicks = 11;
    for (int i = 0; i < totalTicks; i++) {
      final isMajor = i % 2 == 0;
      final angle = startAngle + (sweepAngle * (i / (totalTicks - 1)));
      final innerR = radius - (isMajor ? 15 : 11);
      final outerR = radius - 6;

      final tickPaint = Paint()
        ..color = isMajor
            ? const Color(0xFF0066FF).withValues(alpha: 0.85)
            : const Color(0xFF00C6FF).withValues(alpha: 0.50)
        ..strokeWidth = isMajor ? 2.2 : 1.4
        ..strokeCap = StrokeCap.round;

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

    // 4. Luminous Speedometer Needle
    const needleAngle = 308 * (math.pi / 180); // upper right (~52°)
    final needleLength = radius * 0.78;
    final needleTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    // Needle body gradient
    final needlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF004ECC), Color(0xFF0072FF), Color(0xFF00C6FF)],
      ).createShader(Rect.fromPoints(center, needleTip))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleTip, needlePaint);

    // Needle luminous tip dot
    final tipGlowPaint = Paint()
      ..color = const Color(0xFF60EFFF)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(needleTip, 2.5, tipGlowPaint);

    // 5. Polished Multi-Tiered Metallic Center Pivot Hub
    final hubShadowPaint = Paint()
      ..color = const Color(0xFF0044B8).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, 9, hubShadowPaint);

    final hubOuterPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF0072FF), Color(0xFF003899)],
      ).createShader(Rect.fromCircle(center: center, radius: 7))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 7, hubOuterPaint);

    // Specular silver reflection rim
    final hubRimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, 7, hubRimPaint);

    // Bright center core
    final hubInner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.5, hubInner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
