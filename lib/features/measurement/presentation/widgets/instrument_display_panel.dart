import 'package:flutter/material.dart';
import 'package:pride_kmph_meter/core/constants/app_colors.dart';
import 'package:pride_kmph_meter/core/theme/app_theme.dart';
import 'package:pride_kmph_meter/core/utils/speed_formatter.dart';
import 'package:pride_kmph_meter/features/measurement/domain/measurement_status.dart';

/// Pixel-accurate digital recreation of the physical ST7789 TFT display
/// configured in the Pride KMPH Meter ESP32 firmware.
class InstrumentDisplayPanel extends StatelessWidget {
  final double currentSpeed;
  final double previousSpeed;
  final double distanceMm;
  final int elapsedTimeUs;
  final HardwareMeasurementStatus status;
  final bool isPreview;
  final bool justCompleted;
  final bool isDarkInstrument;
  final String speedUnit;

  const InstrumentDisplayPanel({
    super.key,
    required this.currentSpeed,
    required this.previousSpeed,
    required this.distanceMm,
    required this.elapsedTimeUs,
    required this.status,
    this.isPreview = false,
    this.justCompleted = false,
    this.isDarkInstrument = false,
    this.speedUnit = 'KM/H',
  });

  @override
  Widget build(BuildContext context) {
    // Visual theme colors
    final bgColor = isDarkInstrument
        ? AppColors.instrumentBgDark
        : AppColors.instrumentBgLight;
    final borderColor = isDarkInstrument
        ? AppColors.instrumentBorderDark
        : AppColors.instrumentBorder;
    final labelColor = isDarkInstrument
        ? AppColors.instrumentLabelLight
        : AppColors.instrumentLabelDark;
    final subInfoColor = isDarkInstrument
        ? Colors.white
        : AppColors.deepNavy;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          if (justCompleted)
            BoxShadow(
              color: AppColors.currentSpeed.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 2,
            ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // PREVIEW or STATUS WATERMARK if in preview or measuring
          if (isPreview || status == HardwareMeasurementStatus.measuring)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: status == HardwareMeasurementStatus.measuring
                    ? AppColors.measuring.withValues(alpha: 0.2)
                    : Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: status == HardwareMeasurementStatus.measuring
                      ? AppColors.measuring
                      : AppColors.primary,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    status == HardwareMeasurementStatus.measuring
                        ? Icons.timer
                        : Icons.info_outline,
                    size: 14,
                    color: status == HardwareMeasurementStatus.measuring
                        ? AppColors.measuring
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      status == HardwareMeasurementStatus.measuring
                          ? 'MEASUREMENT IN PROGRESS...'
                          : 'DESIGN PREVIEW DATA — AWAITING HARDWARE',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: status == HardwareMeasurementStatus.measuring
                            ? AppColors.measuring
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 1. CURRENT SPEED PANEL
          _buildSpeedBox(
            title: 'CURRENT SPEED',
            unit: speedUnit,
            speedValue: SpeedFormatter.convertSpeed(currentSpeed, speedUnit),
            nativeKmph: currentSpeed,
            valueColor: AppColors.currentSpeed,
            borderColor: justCompleted
                ? AppColors.currentSpeed
                : borderColor,
            labelColor: labelColor,
            isCurrent: true,
          ),

          const SizedBox(height: 10),

          // 2. PREVIOUS SPEED PANEL
          _buildSpeedBox(
            title: 'PREVIOUS SPEED',
            unit: speedUnit,
            speedValue: SpeedFormatter.convertSpeed(previousSpeed, speedUnit),
            nativeKmph: previousSpeed,
            valueColor: AppColors.previousSpeed,
            borderColor: borderColor,
            labelColor: labelColor,
            isCurrent: false,
          ),

          const SizedBox(height: 12),

          // 3. BOTTOM INFO STRIP: D:50.0mm          T:133856us
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkInstrument
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Distance readout
                Row(
                  children: [
                    Text(
                      'D:',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: subInfoColor,
                      ),
                    ),
                    Text(
                      SpeedFormatter.formatDistanceMm(distanceMm),
                      style: AppTheme.digitalStyle(
                        fontSize: 16,
                        color: subInfoColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                // Live microsecond time readout
                Row(
                  children: [
                    Text(
                      'T:',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.timerYellow,
                      ),
                    ),
                    Text(
                      SpeedFormatter.formatTimeUs(elapsedTimeUs),
                      style: AppTheme.digitalStyle(
                        fontSize: 16,
                        color: isDarkInstrument
                            ? AppColors.timerYellow
                            : AppColors.timerText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedBox({
    required String title,
    required String unit,
    required double speedValue,
    required double nativeKmph,
    required Color valueColor,
    required Color borderColor,
    required Color labelColor,
    required bool isCurrent,
  }) {
    final formattedSpeed = SpeedFormatter.formatSpeed5Decimals(speedValue);
    final isConverted = unit.toUpperCase() != 'KM/H';

    return Container(
      decoration: BoxDecoration(
        color: isDarkInstrument
            ? const Color(0xFF000000)
            : Colors.white.withValues(alpha: 0.85),
        border: Border.all(color: borderColor, width: 2.0),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Title and Unit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: labelColor,
                      ),
                    ),
                    if (isConverted) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '(TFT: ${SpeedFormatter.formatSpeed5Decimals(nativeKmph)} KM/H)',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: labelColor.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: labelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Large Digital Numerals
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formattedSpeed,
              style: AppTheme.digitalStyle(
                fontSize: 42,
                color: valueColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
