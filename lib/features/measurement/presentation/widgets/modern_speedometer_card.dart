import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/speed_formatter.dart';

/// Modern clean hero speedometer card matching the Design 1 reference specification.
/// Features a semi-circular gradient gauge, radial tick marks, digital numerals,
/// and responsive dynamic scale.
class ModernSpeedometerCard extends StatelessWidget {
  final double currentSpeed;
  final String speedUnit;
  final VoidCallback? onTap;

  const ModernSpeedometerCard({
    super.key,
    required this.currentSpeed,
    this.speedUnit = 'km/h',
    this.onTap,
  });

  /// Dynamically computes an appropriate upper scale bound (e.g. 1.00, 5.00, 10.00, 50.00)
  double get _maxScale {
    if (currentSpeed <= 1.0) return 1.00;
    if (currentSpeed <= 5.0) return 5.00;
    if (currentSpeed <= 10.0) return 10.00;
    if (currentSpeed <= 25.0) return 25.00;
    if (currentSpeed <= 50.0) return 50.00;
    if (currentSpeed <= 100.0) return 100.00;
    return (currentSpeed * 1.25).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final maxScale = _maxScale;
    final scaleString = maxScale == 1.0 ? '1.00' : maxScale.toStringAsFixed(1);
    final formattedSpeed = SpeedFormatter.formatSpeed5Decimals(currentSpeed);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.modernCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.modernCardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2E50).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Semi-circular gauge with centered digital readouts
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: currentSpeed),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, animatedSpeed, child) {
              final progress = (animatedSpeed / maxScale).clamp(0.0, 1.0);

              return SizedBox(
                width: double.infinity,
                height: 220,
                child: CustomPaint(
                  painter: _SpeedometerPainter(
                    progress: progress,
                    scaleMin: '0',
                    scaleMax: scaleString,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Small circular gauge icon badge
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.modernIconBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.modernBlue.withValues(alpha: 0.15),
                                width: 1.2,
                              ),
                            ),
                            child: const Icon(
                              Icons.speed_rounded,
                              color: AppColors.modernBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // CURRENT SPEED Label
                          const Text(
                            'CURRENT SPEED',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: AppColors.modernTextDark,
                            ),
                          ),
                          const SizedBox(height: 2),

                          // 5-decimal Large Speed Numeral
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formattedSpeed,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: AppColors.modernTextDark,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Unit Capsule Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.modernPillBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              speedUnit,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.modernBlueDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Custom painter for semi-circular arc, radial tick marks, and range scale labels.
class _SpeedometerPainter extends CustomPainter {
  final double progress;
  final String scaleMin;
  final String scaleMax;

  _SpeedometerPainter({
    required this.progress,
    required this.scaleMin,
    required this.scaleMax,
  });

  // Gauge angles (approx 234 degrees sweep, starting at ~153 deg, ending at ~27 deg)
  static const double _startAngle = math.pi * 0.82; // ~147.6 degrees
  static const double _sweepAngle = math.pi * 1.36; // ~244.8 degrees

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.58);
    final radius = math.min(size.width * 0.44, size.height * 0.72);

    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // 1. Inactive background track
    final bgPaint = Paint()
      ..color = const Color(0xFFE5EDF6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect,
      _startAngle,
      _sweepAngle,
      false,
      bgPaint,
    );

    // 2. Radial tick marks along the arc
    const int totalTicks = 32;
    for (int i = 0; i <= totalTicks; i++) {
      final tickFraction = i / totalTicks;
      final tickAngle = _startAngle + (_sweepAngle * tickFraction);

      final isMajor = i % 4 == 0;
      final tickLength = isMajor ? 8.0 : 4.5;
      final tickWidth = isMajor ? 1.8 : 1.2;

      final isTickActive = tickFraction <= progress && progress > 0.005;

      final tickPaint = Paint()
        ..color = isTickActive
            ? AppColors.modernBlue.withValues(alpha: 0.9)
            : const Color(0xFFBDD2E8)
        ..strokeWidth = tickWidth
        ..strokeCap = StrokeCap.round;

      final innerRadius = radius - 16.0;
      final outerRadius = innerRadius - tickLength;

      final p1 = Offset(
        center.dx + innerRadius * math.cos(tickAngle),
        center.dy + innerRadius * math.sin(tickAngle),
      );
      final p2 = Offset(
        center.dx + outerRadius * math.cos(tickAngle),
        center.dy + outerRadius * math.sin(tickAngle),
      );

      canvas.drawLine(p1, p2, tickPaint);
    }

    // 3. Active gradient progress arc
    if (progress > 0.001) {
      final activeSweep = (_sweepAngle * progress).clamp(0.01, _sweepAngle);

      final activeGradient = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + _sweepAngle,
        colors: const [
          AppColors.modernBlueDark,
          AppColors.modernBlue,
          AppColors.modernCyan,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(0),
      );

      final activePaint = Paint()
        ..shader = activeGradient.createShader(arcRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        arcRect,
        _startAngle,
        activeSweep,
        false,
        activePaint,
      );
    }

    // 4. Scale numerals at arc extremities ("0" on left, "1.00" on right)
    const textStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: AppColors.modernTextDark,
    );

    // Left "0" position
    final leftAngle = _startAngle + 0.08;
    final leftOffset = Offset(
      center.dx + (radius + 2) * math.cos(leftAngle) - 10,
      center.dy + (radius + 2) * math.sin(leftAngle) + 10,
    );
    _drawText(canvas, scaleMin, leftOffset, textStyle, TextAlign.center);

    // Right "1.00" position
    final rightAngle = _startAngle + _sweepAngle - 0.08;
    final rightOffset = Offset(
      center.dx + (radius + 2) * math.cos(rightAngle) - 6,
      center.dy + (radius + 2) * math.sin(rightAngle) + 10,
    );
    _drawText(canvas, scaleMax, rightOffset, textStyle, TextAlign.center);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
    TextAlign align,
  ) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.scaleMax != scaleMax ||
        oldDelegate.scaleMin != scaleMin;
  }
}
