import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pride_kmph_meter/core/constants/app_colors.dart';
import 'package:pride_kmph_meter/core/theme/app_theme.dart';
import 'package:pride_kmph_meter/core/utils/speed_formatter.dart';
import 'package:pride_kmph_meter/features/measurement/domain/measurement_status.dart';
import 'package:pride_kmph_meter/features/measurement/presentation/controllers/measurement_controller.dart';
import 'package:pride_kmph_meter/features/measurement/presentation/widgets/live_timeline_widget.dart';
import 'package:pride_kmph_meter/features/settings/presentation/controllers/settings_controller.dart';

class LiveMeasurementScreen extends ConsumerWidget {
  const LiveMeasurementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveState = ref.watch(measurementControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final isConnected = liveState.isHardwareConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Speed Measurement',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isConnected
                  ? AppColors.connected.withValues(alpha: 0.12)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  size: 16,
                  color: isConnected ? AppColors.connected : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  isConnected ? 'LIVE TELEMETRY' : 'OFFLINE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isConnected ? AppColors.connected : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. HUGE DIGITAL SPEED READOUT HERO CARD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: liveState.justCompleted
                      ? AppColors.currentSpeed
                      : AppColors.cardBorder,
                  width: liveState.justCompleted ? 2.5 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  if (liveState.justCompleted)
                    BoxShadow(
                      color: AppColors.currentSpeed.withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TEST #${liveState.testNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          settings.speedUnit,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Large Formatted Speed Value
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      SpeedFormatter.formatSpeed5Decimals(
                        SpeedFormatter.convertSpeed(
                          liveState.currentSpeedKmph,
                          settings.speedUnit,
                        ),
                      ),
                      style: AppTheme.digitalStyle(
                        fontSize: 64,
                        color: AppColors.currentSpeed,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    'INSTANTANEOUS SPEED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const Divider(height: 32),

                  // Metrics Row: Previous Speed, Distance, Elapsed Time
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricColumn(
                          label: 'PREV SPEED',
                          value: SpeedFormatter.formatSpeed5Decimals(
                            SpeedFormatter.convertSpeed(
                              liveState.previousSpeedKmph,
                              settings.speedUnit,
                            ),
                          ),
                          color: AppColors.previousSpeed,
                        ),
                      ),
                      Container(
                          width: 1, height: 40, color: Colors.grey.shade200),
                      Expanded(
                        child: _buildMetricColumn(
                          label: 'DISTANCE',
                          value: SpeedFormatter.formatDistanceMm(
                              liveState.distanceMm),
                          color: AppColors.deepNavy,
                        ),
                      ),
                      Container(
                          width: 1, height: 40, color: Colors.grey.shade200),
                      Expanded(
                        child: _buildMetricColumn(
                          label: 'TIME (ΔT)',
                          value:
                              SpeedFormatter.formatTimeUs(liveState.elapsedTimeUs),
                          color: AppColors.timerText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. INTERACTIVE PHYSICAL MEASUREMENT TIMELINE
            LiveTimelineWidget(status: liveState.status),

            const SizedBox(height: 16),

            // 3. SENSOR GPIO STATUS CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REAL-TIME HARDWARE SENSOR PINS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPinStatus(
                      title: 'START Optical Gate',
                      gpio: 'GPIO 27',
                      mode: 'INPUT_PULLUP (Falling Edge Interrupt)',
                      isActive:
                          liveState.status == HardwareMeasurementStatus.measuring,
                    ),
                    const Divider(height: 20),
                    _buildPinStatus(
                      title: 'STOP Optical Gate',
                      gpio: 'GPIO 33',
                      mode: 'INPUT_PULLUP (Falling Edge Interrupt)',
                      isActive:
                          liveState.status == HardwareMeasurementStatus.completed,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTheme.digitalStyle(
              fontSize: 15,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinStatus({
    required String title,
    required String gpio,
    required String mode,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? AppColors.connected : Colors.grey.shade400,
            shape: BoxShape.circle,
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: AppColors.connected.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      gpio,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                mode,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
