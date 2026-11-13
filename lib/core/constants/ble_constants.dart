/// Bluetooth Low Energy (BLE) hardware identifiers matching ESP32 firmware
class BleConstants {
  BleConstants._();

  /// Advertised local name of the ESP32 meter
  static const String deviceName = 'Pride_KMPH_Meter';

  /// Primary 128-bit Service UUID
  static const String serviceUuid = '12345678-1234-1234-1234-123456789001';

  /// Measurement Data Characteristic UUID (Properties: READ, NOTIFY)
  static const String measurementCharacteristicUuid =
      '12345678-1234-1234-1234-123456789002';

  /// Distance Configuration Characteristic UUID (Properties: READ, WRITE)
  static const String configCharacteristicUuid =
      '12345678-1234-1234-1234-123456789003';

  /// Fixed pairing passkey configured in ESP32 firmware
  static const int passKey = 123456;

  /// Default sensor distance in millimeters
  static const double defaultDistanceMm = 50.0;

  /// Target BLE MTU for single-packet reliable telemetry transmission
  static const int requestedMtu = 512;
}
