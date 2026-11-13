import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pride_kmph_meter/core/constants/app_colors.dart';
import 'package:pride_kmph_meter/core/constants/ble_constants.dart';
import 'package:pride_kmph_meter/features/ble/domain/ble_device_state.dart';
import 'package:pride_kmph_meter/features/ble/presentation/controllers/ble_controller.dart';
import 'package:pride_kmph_meter/features/measurement/presentation/controllers/measurement_controller.dart';

class BleConnectionScreen extends ConsumerStatefulWidget {
  const BleConnectionScreen({super.key});

  @override
  ConsumerState<BleConnectionScreen> createState() =>
      _BleConnectionScreenState();
}

class _BleConnectionScreenState extends ConsumerState<BleConnectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bleState = ref.watch(bleControllerProvider);
    final liveState = ref.watch(measurementControllerProvider);
    final isScanning = bleState.status == BleConnectionStatus.scanning;
    final isConnecting = bleState.status == BleConnectionStatus.connecting ||
        bleState.status == BleConnectionStatus.discoveringServices;
    final isConnected = bleState.status == BleConnectionStatus.connected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
        actions: [
          if (isScanning)
            IconButton(
              icon: const Icon(Icons.stop),
              tooltip: 'Stop Scanning',
              onPressed: () =>
                  ref.read(bleControllerProvider.notifier).stopScan(),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Scan for Devices',
              onPressed: () =>
                  ref.read(bleControllerProvider.notifier).startScan(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. ACTIVE CONNECTION STATUS CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'HARDWARE CONNECTION STATUS',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(bleState.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isConnected) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.connected.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bluetooth_connected,
                              color: AppColors.connected,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bleState.connectedDeviceName ??
                                      BleConstants.deviceName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.deepNavy,
                                  ),
                                ),
                                Text(
                                  bleState.connectedDeviceId ?? 'Unknown MAC',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(bleControllerProvider.notifier)
                                .disconnect(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                            ),
                            child: const Text('Disconnect'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.speed, size: 18),
                        label: const Text('Return to Dashboard'),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          if (isScanning)
                            AnimatedBuilder(
                              animation: _radarController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _radarController.value * 6.28,
                                  child: const Icon(
                                    Icons.radar,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                );
                              },
                            )
                          else
                            const Icon(
                              Icons.bluetooth_searching,
                              color: Colors.grey,
                              size: 28,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              bleState.statusMessage,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (bleState.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          bleState.errorMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: isScanning
                            ? () => ref
                                .read(bleControllerProvider.notifier)
                                .stopScan()
                            : () => ref
                                .read(bleControllerProvider.notifier)
                                .startScan(),
                        icon: Icon(
                            isScanning ? Icons.stop : Icons.bluetooth_searching),
                        label: Text(
                            isScanning ? 'Stop Scanning' : 'Scan for Meter'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (bleState.isLocationServicesRequired) ...[
              const SizedBox(height: 12),
              _buildLocationRequiredCard(context),
            ],

            const SizedBox(height: 16),

            // 3. PAIRING & SECURITY INSTRUCTION BANNER
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_outline,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Secure Bluetooth Passkey',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepNavy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'When your phone displays the OS Bluetooth pairing prompt, enter PIN: ${BleConstants.passKey}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. DISCOVERED DEVICES LIST
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'DISCOVERED DEVICES (${bleState.discoveredDevices.length})',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                if (isScanning) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            if (bleState.discoveredDevices.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.devices_other,
                        size: 44, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    Text(
                      isScanning
                          ? 'Searching for Pride_KMPH_Meter...'
                          : 'No devices found. Tap "Scan for Meter" above.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bleState.discoveredDevices.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final dev = bleState.discoveredDevices[index];
                  final isPride = dev.isPrideMeter;

                  return Card(
                    color: isPride ? const Color(0xFFF0F5FF) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isPride ? AppColors.primary : AppColors.cardBorder,
                        width: isPride ? 1.8 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isPride
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPride ? Icons.speed : Icons.bluetooth,
                          color: isPride
                              ? AppColors.primary
                              : Colors.grey.shade700,
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              dev.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: isPride
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                fontSize: 15,
                                color: isPride
                                    ? AppColors.primary
                                    : AppColors.deepNavy,
                              ),
                            ),
                          ),
                          if (isPride) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'METER',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        'ID: ${dev.id}   RSSI: ${dev.rssi} dBm',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: isConnecting
                            ? null
                            : () async {
                                final success = await ref
                                    .read(bleControllerProvider.notifier)
                                    .connect(dev.id);
                                if (success && context.mounted) {
                                  context.go('/');
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPride
                              ? AppColors.primary
                              : Colors.grey.shade800,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                        child: isConnecting &&
                                bleState.connectedDeviceId == dev.id
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Connect'),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRequiredCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_off,
                    color: Colors.amber.shade900, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Services (GPS) Required',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.amber.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Android OS requires Location enabled to discover BLE hardware',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'On your Android device, Bluetooth scanning requires device Location (GPS) to be turned ON in Quick Settings / System Settings. Please enable Location and tap Retry Scan.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () => ref
                      .read(bleControllerProvider.notifier)
                      .openLocationSettings(),
                  icon: const Icon(Icons.settings_outlined, size: 16),
                  label: const Text(
                    'Location Settings',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(bleControllerProvider.notifier).startScan(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text(
                    'Retry',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber.shade900,
                    side: BorderSide(color: Colors.amber.shade700),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BleConnectionStatus status) {
    Color color = Colors.grey;
    String label = 'DISCONNECTED';

    switch (status) {
      case BleConnectionStatus.connected:
        color = AppColors.connected;
        label = 'CONNECTED';
        break;
      case BleConnectionStatus.scanning:
        color = AppColors.primary;
        label = 'SCANNING';
        break;
      case BleConnectionStatus.connecting:
      case BleConnectionStatus.discoveringServices:
      case BleConnectionStatus.authenticating:
        color = Colors.orange;
        label = 'CONNECTING';
        break;
      case BleConnectionStatus.disconnecting:
        color = Colors.grey;
        label = 'DISCONNECTING';
        break;
      case BleConnectionStatus.error:
        color = AppColors.error;
        label = 'ERROR';
        break;
      case BleConnectionStatus.disconnected:
        color = AppColors.disconnected;
        label = 'DISCONNECTED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
