import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/device_settings_service.dart';
import '../../data/ble_service.dart';
import '../../domain/ble_device_state.dart';
import '../../../measurement/presentation/controllers/measurement_controller.dart';

class BleUiState {
  final BleConnectionStatus status;
  final List<DiscoveredDevice> discoveredDevices;
  final String statusMessage;
  final String? errorMessage;
  final String? connectedDeviceId;
  final String? connectedDeviceName;
  final bool isLocationServicesRequired;

  const BleUiState({
    required this.status,
    required this.discoveredDevices,
    required this.statusMessage,
    this.errorMessage,
    this.connectedDeviceId,
    this.connectedDeviceName,
    this.isLocationServicesRequired = false,
  });

  factory BleUiState.initial() {
    return const BleUiState(
      status: BleConnectionStatus.disconnected,
      discoveredDevices: [],
      statusMessage: 'Ready to scan for Pride KMPH Meter',
      isLocationServicesRequired: false,
    );
  }

  BleUiState copyWith({
    BleConnectionStatus? status,
    List<DiscoveredDevice>? discoveredDevices,
    String? statusMessage,
    String? errorMessage,
    String? connectedDeviceId,
    String? connectedDeviceName,
    bool? isLocationServicesRequired,
  }) {
    return BleUiState(
      status: status ?? this.status,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage,
      connectedDeviceId: connectedDeviceId ?? this.connectedDeviceId,
      connectedDeviceName: connectedDeviceName ?? this.connectedDeviceName,
      isLocationServicesRequired:
          isLocationServicesRequired ?? this.isLocationServicesRequired,
    );
  }
}

class BleController extends StateNotifier<BleUiState> {
  final BleService _bleService;
  StreamSubscription? _statusSub;
  StreamSubscription? _deviceListSub;
  StreamSubscription? _messageSub;
  StreamSubscription? _locationReqSub;

  BleController(this._bleService) : super(BleUiState.initial()) {
    _statusSub = _bleService.connectionStateStream.listen((status) {
      state = state.copyWith(
        status: status,
        connectedDeviceId: _bleService.connectedDeviceId,
        connectedDeviceName: _bleService.connectedDeviceName,
      );
    });

    _deviceListSub = _bleService.discoveredDevicesStream.listen((devices) {
      state = state.copyWith(discoveredDevices: devices);
    });

    _messageSub = _bleService.statusMessageStream.listen((message) {
      state = state.copyWith(statusMessage: message);
    });

    _locationReqSub =
        _bleService.isLocationRequiredStream.listen((isRequired) {
      state = state.copyWith(isLocationServicesRequired: isRequired);
    });
  }

  Future<void> startScan() async {
    state = state.copyWith(
      status: BleConnectionStatus.scanning,
      errorMessage: null,
      isLocationServicesRequired: false,
      statusMessage: 'Scanning for Pride KMPH Meter...',
    );
    await _bleService.startScan();
  }

  Future<void> stopScan() async {
    await _bleService.stopScan();
  }

  Future<void> openLocationSettings() async {
    await DeviceSettingsService.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await DeviceSettingsService.openAppSettings();
  }

  Future<bool> connect(String deviceId) async {
    state = state.copyWith(
      status: BleConnectionStatus.connecting,
      errorMessage: null,
      statusMessage: 'Connecting to $deviceId...',
    );
    final success = await _bleService.connectToDevice(deviceId);
    if (!success) {
      state = state.copyWith(
        errorMessage: 'Failed to connect. Ensure meter is powered and in range.',
      );
    }
    return success;
  }

  Future<void> disconnect() async {
    await _bleService.disconnect();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _deviceListSub?.cancel();
    _messageSub?.cancel();
    _locationReqSub?.cancel();
    super.dispose();
  }
}

final bleControllerProvider =
    StateNotifierProvider<BleController, BleUiState>((ref) {
  return BleController(ref.watch(bleServiceProvider));
});
