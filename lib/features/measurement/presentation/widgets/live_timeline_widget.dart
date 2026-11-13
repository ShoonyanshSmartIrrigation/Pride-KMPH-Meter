import 'package:flutter/material.dart';
import 'package:pride_kmph_meter/core/constants/app_colors.dart';
import 'package:pride_kmph_meter/features/measurement/domain/measurement_status.dart';

class LiveTimelineWidget extends StatelessWidget {
  final HardwareMeasurementStatus status;

  const LiveTimelineWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Determine progress index:
    // 0 = Ready (waiting for START)
    // 1 = START Tripped / Measuring
    // 2 = STOP Tripped / Completed
    int activeStep = 0;
    if (status == HardwareMeasurementStatus.measuring) {
      activeStep = 1;
    } else if (status == HardwareMeasurementStatus.completed) {
      activeStep = 2;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'PHYSICAL MEASUREMENT TIMELINE',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.deepNavy.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Horizontal Pipeline
          Row(
            children: [
              // Step 1: START Sensor (GPIO 27)
              _buildStepNode(
                stepIndex: 0,
                activeStep: activeStep,
                label: 'START SENSOR',
                sublabel: 'GPIO 27',
                icon: Icons.sensors,
              ),

              // Connector 1
              _buildConnector(activeStep >= 1),

              // Step 2: Measuring ΔT
              _buildStepNode(
                stepIndex: 1,
                activeStep: activeStep,
                label: 'MEASURING ΔT',
                sublabel: 'micros()',
                icon: Icons.speed,
                isMeasuring: status == HardwareMeasurementStatus.measuring,
              ),

              // Connector 2
              _buildConnector(activeStep >= 2),

              // Step 3: STOP Sensor (GPIO 33) & Completed
              _buildStepNode(
                stepIndex: 2,
                activeStep: activeStep,
                label: 'STOP SENSOR',
                sublabel: 'GPIO 33',
                icon: Icons.check_circle,
              ),
            ],
          ),

          const SizedBox(height: 14),
          // State description banner
          Text(
            status.description,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(HardwareMeasurementStatus status) {
    switch (status) {
      case HardwareMeasurementStatus.ready:
        return AppColors.primary;
      case HardwareMeasurementStatus.measuring:
        return AppColors.measuring;
      case HardwareMeasurementStatus.completed:
        return AppColors.connected;
      case HardwareMeasurementStatus.resetting:
        return Colors.orange;
      case HardwareMeasurementStatus.connected:
        return AppColors.connected;
      case HardwareMeasurementStatus.disconnected:
        return AppColors.disconnected;
    }
  }

  Widget _buildStepNode({
    required int stepIndex,
    required int activeStep,
    required String label,
    required String sublabel,
    required IconData icon,
    bool isMeasuring = false,
  }) {
    final isDone = activeStep > stepIndex;
    final isCurrent = activeStep == stepIndex;

    Color nodeColor = Colors.grey.shade300;
    Color iconColor = Colors.grey.shade600;

    if (isDone) {
      nodeColor = AppColors.connected;
      iconColor = Colors.white;
    } else if (isCurrent) {
      nodeColor = isMeasuring ? AppColors.measuring : AppColors.primary;
      iconColor = Colors.white;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: nodeColor,
              shape: BoxShape.circle,
              boxShadow: [
                if (isMeasuring || isCurrent)
                  BoxShadow(
                    color: nodeColor.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
              color: isCurrent ? AppColors.deepNavy : Colors.grey.shade600,
            ),
          ),
          Text(
            sublabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      width: 24,
      height: 3,
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: isActive ? AppColors.connected : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
