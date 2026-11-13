/// Hardware and telemetry states for the Pride KMPH Meter
enum HardwareMeasurementStatus {
  ready,
  measuring,
  completed,
  resetting,
  connected,
  disconnected,
}

extension HardwareMeasurementStatusX on HardwareMeasurementStatus {
  String get label {
    switch (this) {
      case HardwareMeasurementStatus.ready:
        return 'READY';
      case HardwareMeasurementStatus.measuring:
        return 'MEASURING';
      case HardwareMeasurementStatus.completed:
        return 'COMPLETED';
      case HardwareMeasurementStatus.resetting:
        return 'RESETTING';
      case HardwareMeasurementStatus.connected:
        return 'CONNECTED';
      case HardwareMeasurementStatus.disconnected:
        return 'DISCONNECTED';
    }
  }

  String get description {
    switch (this) {
      case HardwareMeasurementStatus.ready:
        return 'Waiting for object to trip START sensor (GPIO 27)';
      case HardwareMeasurementStatus.measuring:
        return 'START tripped! Microsecond clock running -> Awaiting STOP (GPIO 33)';
      case HardwareMeasurementStatus.completed:
        return 'STOP sensor tripped! Speed calculation completed';
      case HardwareMeasurementStatus.resetting:
        return 'Waiting for both sensors to return HIGH before next test';
      case HardwareMeasurementStatus.connected:
        return 'ESP32 connected and telemetry stream active';
      case HardwareMeasurementStatus.disconnected:
        return 'Bluetooth disconnected. Hardware offline';
    }
  }
}
