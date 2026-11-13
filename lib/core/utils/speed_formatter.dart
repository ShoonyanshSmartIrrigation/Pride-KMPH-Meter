/// High-precision numerical speed formatter adhering to ESP32 TFT firmware specs
class SpeedFormatter {
  SpeedFormatter._();

  /// Formats speed with exactly 5 decimal places and leading zero for positive values < 10.
  /// Example: 1.34473 -> "01.34473"
  /// Example: 12.50000 -> "12.50000"
  /// Example: 0.0 -> "00.00000"
  static String formatSpeed5Decimals(double speed) {
    if (speed.isNaN || speed.isInfinite) return '00.00000';
    final isNegative = speed < 0;
    final absSpeed = speed.abs();

    final parts = absSpeed.toStringAsFixed(5).split('.');
    final integerPart = parts[0].padLeft(2, '0');
    final decimalPart = parts.length > 1 ? parts[1] : '00000';

    return '${isNegative ? '-' : ''}$integerPart.$decimalPart';
  }

  /// Formats microsecond time with unit suffix
  /// Example: 133856 -> "133856us"
  static String formatTimeUs(int microseconds) {
    return '${microseconds}us';
  }

  /// Formats distance with one decimal place
  /// Example: 50.0 -> "50.0mm"
  static String formatDistanceMm(double distanceMm) {
    return '${distanceMm.toStringAsFixed(1)}mm';
  }

  /// Converts KM/H to m/s
  static double kmphToMps(double kmph) => kmph / 3.6;

  /// Converts KM/H to MPH
  static double kmphToMph(double kmph) => kmph * 0.621371;

  /// Converts from KM/H into the target display unit
  static double convertSpeed(double kmph, String unit) {
    switch (unit.toUpperCase()) {
      case 'M/S':
        return kmphToMps(kmph);
      case 'MPH':
        return kmphToMph(kmph);
      case 'KM/H':
      default:
        return kmph;
    }
  }
}
