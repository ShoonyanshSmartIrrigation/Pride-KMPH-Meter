import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pride_kmph_meter/core/constants/ble_constants.dart';
import 'package:pride_kmph_meter/features/auth/data/auth_service.dart';
import 'package:pride_kmph_meter/features/ble/data/ble_service.dart';
import 'package:pride_kmph_meter/features/ble/data/hardware_simulator.dart';
import 'package:pride_kmph_meter/features/ble/domain/ble_device_state.dart';
import 'package:pride_kmph_meter/features/measurement/domain/measurement_model.dart';
import 'package:pride_kmph_meter/features/measurement/domain/measurement_status.dart';
import 'package:pride_kmph_meter/features/measurement/data/firestore_service.dart';
import 'package:pride_kmph_meter/features/measurement/data/measurement_local_storage.dart';
import 'package:pride_kmph_meter/features/measurement/data/measurement_repository.dart';

// Dependency injection providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main()');
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final measurementLocalStorageProvider =
    Provider<MeasurementLocalStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MeasurementLocalStorage(prefs);
});

final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  return MeasurementRepository(
    localStorage: ref.watch(measurementLocalStorageProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
    authService: ref.watch(authServiceProvider),
  );
});

final bleServiceProvider = Provider<BleService>((ref) {
  final service = BleService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Holds the live display and telemetry state
class LiveMeasurementState {
  final double currentSpeedKmph;
  final double previousSpeedKmph;
  final double distanceMm;
  final int elapsedTimeUs;
  final int testNumber;
  final HardwareMeasurementStatus status;
  final bool isHardwareConnected;
  final bool isSimulationMode;
  final bool isPreviewData; // true if showing the initial baseline preview data
  final bool justCompleted; // trigger for UI flash highlight
  final List<MeasurementModel> history;

  const LiveMeasurementState({
    required this.currentSpeedKmph,
    required this.previousSpeedKmph,
    required this.distanceMm,
    required this.elapsedTimeUs,
    required this.testNumber,
    required this.status,
    required this.isHardwareConnected,
    required this.isSimulationMode,
    required this.isPreviewData,
    required this.justCompleted,
    required this.history,
  });

  // Reference initial preview state matching the TFT photograph
  factory LiveMeasurementState.initial() {
    return const LiveMeasurementState(
      currentSpeedKmph: 1.34473,
      previousSpeedKmph: 2.21500,
      distanceMm: 50.0,
      elapsedTimeUs: 133856,
      testNumber: 1,
      status: HardwareMeasurementStatus.disconnected,
      isHardwareConnected: false,
      isSimulationMode: false,
      isPreviewData: true,
      justCompleted: false,
      history: [],
    );
  }

  LiveMeasurementState copyWith({
    double? currentSpeedKmph,
    double? previousSpeedKmph,
    double? distanceMm,
    int? elapsedTimeUs,
    int? testNumber,
    HardwareMeasurementStatus? status,
    bool? isHardwareConnected,
    bool? isSimulationMode,
    bool? isPreviewData,
    bool? justCompleted,
    List<MeasurementModel>? history,
  }) {
    return LiveMeasurementState(
      currentSpeedKmph: currentSpeedKmph ?? this.currentSpeedKmph,
      previousSpeedKmph: previousSpeedKmph ?? this.previousSpeedKmph,
      distanceMm: distanceMm ?? this.distanceMm,
      elapsedTimeUs: elapsedTimeUs ?? this.elapsedTimeUs,
      testNumber: testNumber ?? this.testNumber,
      status: status ?? this.status,
      isHardwareConnected: isHardwareConnected ?? this.isHardwareConnected,
      isSimulationMode: isSimulationMode ?? this.isSimulationMode,
      isPreviewData: isPreviewData ?? this.isPreviewData,
      justCompleted: justCompleted ?? this.justCompleted,
      history: history ?? this.history,
    );
  }
}

class MeasurementController extends StateNotifier<LiveMeasurementState> {
  final BleService _bleService;
  final MeasurementRepository _repository;
  HardwareSimulator? _simulator;

  StreamSubscription? _bleDataSub;
  StreamSubscription? _bleConnectionSub;
  Timer? _flashResetTimer;

  MeasurementController({
    required BleService bleService,
    required MeasurementRepository repository,
  })  : _bleService = bleService,
        _repository = repository,
        super(LiveMeasurementState.initial()) {
    _init();
  }

  void _init() {
    // 1. Load persisted history
    final cachedHistory = _repository.getLocalMeasurements();
    state = state.copyWith(history: cachedHistory);

    // 2. Listen to BLE connection state changes
    _bleConnectionSub = _bleService.connectionStateStream.listen((connState) {
      final isConn = connState == BleConnectionStatus.connected;
      state = state.copyWith(
        isHardwareConnected: isConn,
        status: isConn
            ? HardwareMeasurementStatus.connected
            : HardwareMeasurementStatus.disconnected,
      );
    });

    // 3. Listen to BLE incoming telemetry
    _bleDataSub = _bleService.rawDataStream.listen((data) {
      processIncomingJson(data, isSimulated: false);
    });
  }

  /// Toggles hardware simulation mode for offline UI testing and verification
  void toggleSimulationMode(bool enabled) {
    if (enabled == state.isSimulationMode) return;

    if (enabled) {
      _simulator = HardwareSimulator(
        onSimulatedData: (data) => processIncomingJson(data, isSimulated: true),
        initialTestNumber: state.testNumber,
        initialCurrentSpeed:
            state.currentSpeedKmph > 0 ? state.currentSpeedKmph : 1.34473,
        initialPreviousSpeed: state.previousSpeedKmph,
        distanceMm: state.distanceMm,
      );
      _simulator!.start();
      state = state.copyWith(
        isSimulationMode: true,
        isHardwareConnected: true,
        status: HardwareMeasurementStatus.ready,
      );
    } else {
      _simulator?.stop();
      _simulator = null;
      state = state.copyWith(
        isSimulationMode: false,
        isHardwareConnected:
            _bleService.currentStatus == BleConnectionStatus.connected,
        status: _bleService.currentStatus == BleConnectionStatus.connected
            ? HardwareMeasurementStatus.connected
            : HardwareMeasurementStatus.disconnected,
      );
    }
  }

  /// Triggers a test pass-through in simulation mode
  Future<void> triggerSimulationTest({double? speed}) async {
    if (_simulator != null) {
      await _simulator!.triggerSimulatedPassThrough(targetSpeedKmph: speed);
    }
  }

  /// Core JSON processing method handling ESP32 telemetry events
  void processIncomingJson(Map<String, dynamic> json,
      {required bool isSimulated}) {
    final statusStr = (json['status']?.toString() ?? '').toUpperCase();

    // 1. Connection Handshake or Telemetry Sync (CONNECTED or READY)
    if (statusStr == 'CONNECTED' || statusStr == 'READY') {
      final measurement = MeasurementModel.fromEsp32Json(
        json: json,
        deviceName: isSimulated
            ? 'Pride_KMPH_Simulator'
            : (_bleService.connectedDeviceName ?? BleConstants.deviceName),
      );

      // Check if ESP32 transmitted an active completed test from its memory
      final hasValidMeasurement = measurement.testNumber > 0 &&
          measurement.elapsedTimeUs > 0 &&
          !measurement.currentSpeedKmph.isNaN &&
          !measurement.currentSpeedKmph.isInfinite &&
          measurement.currentSpeedKmph > 0.0;

      List<MeasurementModel> newHistory = state.history;
      if (hasValidMeasurement &&
          !state.history.any((m) => m.testNumber == measurement.testNumber)) {
        _repository.recordMeasurement(measurement);
        newHistory = [measurement, ...state.history];
      }

      // Directly mirror the physical hardware display's live state
      state = state.copyWith(
        currentSpeedKmph: measurement.currentSpeedKmph,
        previousSpeedKmph: measurement.previousSpeedKmph,
        distanceMm: measurement.distanceMm,
        elapsedTimeUs: measurement.elapsedTimeUs,
        testNumber: measurement.testNumber,
        status: HardwareMeasurementStatus.ready,
        isHardwareConnected: true,
        isPreviewData: false,
        history: newHistory,
      );
      return;
    }

    // 2. START sensor activated
    if (statusStr == 'START') {
      state = state.copyWith(
        status: HardwareMeasurementStatus.measuring,
        isPreviewData: false,
      );
      return;
    }

    // 3. Completed speed measurement
    if (statusStr == 'COMPLETE') {
      final measurement = MeasurementModel.fromEsp32Json(
        json: json,
        deviceName: isSimulated
            ? 'Pride_KMPH_Simulator'
            : (_bleService.connectedDeviceName ?? BleConstants.deviceName),
      );

      // Validate measurement integrity
      if (measurement.elapsedTimeUs <= 0 ||
          measurement.currentSpeedKmph.isNaN ||
          measurement.currentSpeedKmph.isInfinite) {
        return;
      }

      // Record measurement locally and sync to Firebase
      _repository.recordMeasurement(measurement);

      // Trigger flash animation
      _flashResetTimer?.cancel();
      _flashResetTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted) {
          state = state.copyWith(justCompleted: false);
        }
      });

      // Update history without duplicates
      List<MeasurementModel> updatedHistory = state.history;
      if (!state.history.any((m) =>
          m.id == measurement.id ||
          (m.testNumber == measurement.testNumber &&
              m.deviceName == measurement.deviceName))) {
        updatedHistory = [measurement, ...state.history];
      }

      // Direct 1:1 mirror of the hardware ST7789 TFT display
      state = state.copyWith(
        currentSpeedKmph: measurement.currentSpeedKmph,
        previousSpeedKmph: measurement.previousSpeedKmph,
        distanceMm: measurement.distanceMm,
        elapsedTimeUs: measurement.elapsedTimeUs,
        testNumber: measurement.testNumber,
        status: HardwareMeasurementStatus.completed,
        isPreviewData: false,
        justCompleted: true,
        history: updatedHistory,
      );
    }
  }

  /// Clear all stored history
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    state = state.copyWith(history: []);
  }

  /// Manual trigger for sync
  Future<int> syncPendingMeasurements() async {
    final count = await _repository.syncAllPending();
    final updated = _repository.getLocalMeasurements();
    state = state.copyWith(history: updated);
    return count;
  }

  @override
  void dispose() {
    _bleDataSub?.cancel();
    _bleConnectionSub?.cancel();
    _flashResetTimer?.cancel();
    _simulator?.stop();
    super.dispose();
  }
}

final measurementControllerProvider =
    StateNotifierProvider<MeasurementController, LiveMeasurementState>((ref) {
  return MeasurementController(
    bleService: ref.watch(bleServiceProvider),
    repository: ref.watch(measurementRepositoryProvider),
  );
});
