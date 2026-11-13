import 'dart:async';
import 'dart:math';

/// Hardware simulator for testing the UI, parser, and state transitions
/// without requiring an active physical ESP32 breadboard setup.
class HardwareSimulator {
  final _random = Random();
  Timer? _simulationTimer;
  int _testCounter;
  double _lastSpeed;
  double _currentSpeed;
  final double _distanceMm;

  final void Function(Map<String, dynamic> data) onSimulatedData;

  HardwareSimulator({
    required this.onSimulatedData,
    int initialTestNumber = 0,
    double initialCurrentSpeed = 1.34473,
    double initialPreviousSpeed = 0.0,
    double distanceMm = 50.0,
  })  : _testCounter = initialTestNumber,
        _currentSpeed = initialCurrentSpeed,
        _lastSpeed = initialPreviousSpeed,
        _distanceMm = distanceMm;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  void start() {
    if (_isRunning) return;
    _isRunning = true;

    // Send initial CONNECTED notification
    onSimulatedData({
      'test_no': _testCounter,
      'current_speed_kmph': _currentSpeed,
      'previous_speed_kmph': _lastSpeed,
      'distance_mm': _distanceMm,
      'time_us': 133856,
      'status': 'CONNECTED',
    });
  }

  /// Triggers a simulated hardware pass-through test:
  /// START gate -> Measuring -> STOP gate -> COMPLETE -> READY
  Future<void> triggerSimulatedPassThrough({double? targetSpeedKmph}) async {
    if (!_isRunning) start();

    // 1. START sensor triggered
    onSimulatedData({
      'test_no': _testCounter + 1,
      'current_speed_kmph': 0.0,
      'previous_speed_kmph': _currentSpeed,
      'distance_mm': _distanceMm,
      'time_us': 0,
      'status': 'START',
    });

    // 2. Realistic time elapsed calculation
    // Speed (km/h) = (distance_mm * 3600) / time_us
    // time_us = (distance_mm * 3600) / Speed
    final speed = targetSpeedKmph ??
        (0.8 + _random.nextDouble() * 4.5); // between 0.8 and 5.3 km/h
    final timeUs = ((_distanceMm * 3600.0) / speed).round();

    // Simulate travel time delay across the 50mm gate (e.g. 350ms for visualization)
    await Future.delayed(const Duration(milliseconds: 400));

    // 3. STOP sensor triggered & calculation complete
    _testCounter++;
    _lastSpeed = _currentSpeed;
    _currentSpeed = speed;

    onSimulatedData({
      'test_no': _testCounter,
      'current_speed_kmph': _currentSpeed,
      'previous_speed_kmph': _lastSpeed,
      'distance_mm': _distanceMm,
      'time_us': timeUs,
      'status': 'COMPLETE',
    });
  }

  void stop() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _isRunning = false;
  }
}
