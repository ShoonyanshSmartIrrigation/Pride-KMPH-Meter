import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

/// Modern floating status pill matching the Design 1 reference.
/// Displays live BLE connectivity status with green/grey indicator
/// and connected device name. Tappable to navigate to BLE management.
class ModernStatusPill extends StatelessWidget {
  final bool isConnected;
  final String deviceName;

  const ModernStatusPill({
    super.key,
    required this.isConnected,
    required this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/bluetooth'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.modernCardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.modernCardBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A2E50).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Bluetooth status icon badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isConnected ? AppColors.modernGreen : Colors.grey.shade400,
                  shape: BoxShape.circle,
                  boxShadow: isConnected
                      ? [
                          BoxShadow(
                            color: AppColors.modernGreen.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: const Icon(
                  Icons.bluetooth_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),

              // Status text
              Flexible(
                child: Text(
                  isConnected ? 'BLE Connected' : 'BLE Disconnected',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isConnected ? AppColors.modernGreen : AppColors.modernTextGrey,
                  ),
                ),
              ),

              // Vertical subtle divider
              Container(
                width: 1.2,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: const Color(0xFFD6E2EE),
              ),

              // Target Device Name
              Flexible(
                child: Text(
                  deviceName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.modernTextDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

