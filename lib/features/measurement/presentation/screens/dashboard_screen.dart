import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/ble_constants.dart';
import '../../../../core/utils/speed_formatter.dart';
import '../../../ble/presentation/controllers/ble_controller.dart';
import '../../presentation/controllers/measurement_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../widgets/bottom_wave_widget.dart';
import '../widgets/modern_header_widget.dart';
import '../widgets/modern_speedometer_card.dart';
import '../widgets/modern_status_pill.dart';

/// Modern Clean Dashboard screen adhering to the Design 1 visual identity.
/// Provides real-time radial gauge visualization, BLE status pill,
/// secondary metric cards, and one-touch actions.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveState = ref.watch(measurementControllerProvider);
    final bleState = ref.watch(bleControllerProvider);
    final settings = ref.watch(settingsControllerProvider);

    final isConnected = liveState.isHardwareConnected;
    final deviceName = isConnected
        ? (bleState.connectedDeviceName ?? BleConstants.deviceName)
        : BleConstants.deviceName;

    final convertedCurrentSpeed = SpeedFormatter.convertSpeed(
      liveState.currentSpeedKmph,
      settings.speedUnit,
    );
    final convertedPrevSpeed = SpeedFormatter.convertSpeed(
      liveState.previousSpeedKmph,
      settings.speedUnit,
    );
    final formattedPrevSpeed = SpeedFormatter.formatSpeed5Decimals(
      convertedPrevSpeed,
    );

    return Scaffold(
      backgroundColor: AppColors.modernBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Curved Deep Navy Header
            const ModernHeaderWidget(),

            // 2. Main Dashboard Content Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 5),

                  // BLE Connection Status Floating Pill
                  ModernStatusPill(
                    isConnected: isConnected,
                    deviceName: deviceName,
                  ),

                  const SizedBox(height: 5),

                  // Hero Speedometer Radial Gauge Card
                  ModernSpeedometerCard(
                    currentSpeed: convertedCurrentSpeed,
                    speedUnit: settings.speedUnit,
                  ),

                  const SizedBox(height: 5),

                  // Metrics Row: Previous Speed & Test Distance
                  Row(
                    children: [
                      // Previous Speed Card
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.history_rounded,
                          label: 'Previous Speed',
                          value: formattedPrevSpeed,
                          unit: settings.speedUnit,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Test Distance Card
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.straighten_rounded,
                          label: 'Test Distance',
                          value: liveState.distanceMm.toStringAsFixed(1),
                          unit: 'mm',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Measurement Time Card (Full Width)
                  _buildTimeCard(elapsedTimeUs: liveState.elapsedTimeUs),

                  const SizedBox(height: 5),

                  // Primary Action Buttons Row (Live Testing & Analytics)
                  Row(
                    children: [
                      // Live Testing Button (Vibrant Blue Pill)
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.go('/live'),
                            borderRadius: BorderRadius.circular(24),
                            child: Ink(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.modernBlueDark,
                                    AppColors.modernBlue,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.modernBlue.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Live Testing',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Analytics Button (Clean White Pill)
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.go('/history'),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFD0E2F5),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0A2E50,
                                    ).withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bar_chart_rounded,
                                    color: AppColors.modernBlue,
                                    size: 22,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Analytics',
                                    style: TextStyle(
                                      color: AppColors.modernTextDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Flowing Aesthetic Bottom Wave
            const BottomWaveWidget(height: 65),
          ],
        ),
      ),
    );
  }

  /// Metric Card for Previous Speed and Test Distance
  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.modernCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernCardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2E50).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          // Circular Icon Badge
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.modernIconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.modernBlue, size: 20),
          ),
          const SizedBox(width: 10),

          // Label, Value & Unit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.modernTextGrey,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: AppColors.modernTextDark,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Text(
                  unit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.modernTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Full Width Measurement Time Card
  Widget _buildTimeCard({required int elapsedTimeUs}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.modernCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernCardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2E50).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.modernIconBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: AppColors.modernBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Measurement Time',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.modernTextGrey,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$elapsedTimeUs µs',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.modernTextDark,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
