import 'package:flutter/material.dart';

/// Perspective speed highway receding to the horizon, matching the futuristic
/// aesthetic of the reference splash screen.
class SpeedPerspectiveRoadWidget extends StatelessWidget {
  final double height;

  const SpeedPerspectiveRoadWidget({
    super.key,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _RoadPerspectivePainter(),
      ),
    );
  }
}

class _RoadPerspectivePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final vp = Offset(size.width / 2, size.height * 0.12); // Vanishing point

    // 1. Horizon Soft Mountain Silhouettes
    final mountainPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0072FF).withValues(alpha: 0.18),
          const Color(0xFF00C6FF).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, vp.dy + 15))
      ..style = PaintingStyle.fill;

    final mountainPath = Path();
    mountainPath.moveTo(0, vp.dy);
    mountainPath.lineTo(size.width * 0.15, vp.dy - 12);
    mountainPath.lineTo(size.width * 0.32, vp.dy - 6);
    mountainPath.lineTo(size.width * 0.44, vp.dy - 14);
    mountainPath.lineTo(vp.dx, vp.dy - 8);
    mountainPath.lineTo(size.width * 0.58, vp.dy - 15);
    mountainPath.lineTo(size.width * 0.72, vp.dy - 7);
    mountainPath.lineTo(size.width * 0.88, vp.dy - 13);
    mountainPath.lineTo(size.width, vp.dy);
    mountainPath.lineTo(size.width, vp.dy + 10);
    mountainPath.lineTo(0, vp.dy + 10);
    mountainPath.close();
    canvas.drawPath(mountainPath, mountainPaint);

    // 2. Horizon Glowing Cyan Aura
    final horizonGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF60EFFF).withValues(alpha: 0.65),
          const Color(0xFF00C6FF).withValues(alpha: 0.30),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: vp, radius: 55))
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: vp, width: size.width * 0.70, height: 28),
      horizonGlow,
    );

    // 3. Perspective Highway Surface (Trapezoid)
    final roadPath = Path();
    final roadTopHalfWidth = 12.0;
    final roadBottomHalfWidth = size.width * 0.44;

    roadPath.moveTo(vp.dx - roadTopHalfWidth, vp.dy);
    roadPath.lineTo(vp.dx + roadTopHalfWidth, vp.dy);
    roadPath.lineTo(vp.dx + roadBottomHalfWidth, size.height);
    roadPath.lineTo(vp.dx - roadBottomHalfWidth, size.height);
    roadPath.close();

    final roadSurfacePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0052D4).withValues(alpha: 0.18),
          const Color(0xFF00C6FF).withValues(alpha: 0.08),
          const Color(0xFFE8F3FF).withValues(alpha: 0.02),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, vp.dy, size.width, size.height - vp.dy))
      ..style = PaintingStyle.fill;
    canvas.drawPath(roadPath, roadSurfacePaint);

    // 4. Glowing Left & Right Highway Boundary Rails
    final leftRailPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0066FF).withValues(alpha: 0.8),
          const Color(0xFF00C6FF).withValues(alpha: 0.6),
          const Color(0xFF60EFFF).withValues(alpha: 0.15),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, vp.dy, size.width, size.height - vp.dy))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    canvas.drawLine(
      Offset(vp.dx - roadBottomHalfWidth, size.height),
      Offset(vp.dx - roadTopHalfWidth, vp.dy),
      leftRailPaint,
    );

    final rightRailPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0066FF).withValues(alpha: 0.8),
          const Color(0xFF00C6FF).withValues(alpha: 0.6),
          const Color(0xFF60EFFF).withValues(alpha: 0.15),
        ],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ).createShader(Rect.fromLTWH(0, vp.dy, size.width, size.height - vp.dy))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    canvas.drawLine(
      Offset(vp.dx + roadBottomHalfWidth, size.height),
      Offset(vp.dx + roadTopHalfWidth, vp.dy),
      rightRailPaint,
    );

    // 5. Outer Speed Light Streaks (Flanking Highway)
    final streakPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final streakOffsets = [-0.15, -0.07, 0.07, 0.15];
    for (final off in streakOffsets) {
      streakPaint.shader = LinearGradient(
        colors: [
          const Color(0xFF00C6FF).withValues(alpha: 0.35),
          Colors.transparent,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      final bottomX = vp.dx + (roadBottomHalfWidth * (1.0 + off));
      final topX = vp.dx + (roadTopHalfWidth * (1.0 + off * 0.4));
      canvas.drawLine(
        Offset(bottomX, size.height),
        Offset(topX, vp.dy + 8),
        streakPaint,
      );
    }

    // 6. Perspective Center White Dashed Lane Markers
    // Receding geometry: t from 0 (horizon) to 1 (foreground)
    const dashSteps = [
      {'t1': 0.10, 't2': 0.18},
      {'t1': 0.26, 't2': 0.38},
      {'t1': 0.48, 't2': 0.64},
      {'t1': 0.74, 't2': 0.96},
    ];

    for (final step in dashSteps) {
      final t1 = step['t1']!;
      final t2 = step['t2']!;

      final y1 = vp.dy + (size.height - vp.dy) * (t1 * t1); // quadratic perspective
      final y2 = vp.dy + (size.height - vp.dy) * (t2 * t2);

      final w1 = 1.2 + 4.5 * (t1 * t1);
      final w2 = 1.2 + 4.5 * (t2 * t2);

      final dashPath = Path();
      dashPath.moveTo(vp.dx - w1 / 2, y1);
      dashPath.lineTo(vp.dx + w1 / 2, y1);
      dashPath.lineTo(vp.dx + w2 / 2, y2);
      dashPath.lineTo(vp.dx - w2 / 2, y2);
      dashPath.close();

      final dashPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35 + 0.60 * t2)
        ..style = PaintingStyle.fill;

      canvas.drawPath(dashPath, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

