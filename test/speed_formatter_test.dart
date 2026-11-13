import 'package:flutter_test/flutter_test.dart';
import 'package:pride_kmph_meter/core/utils/speed_formatter.dart';

void main() {
  group('SpeedFormatter & ESP32 Physics Calculation Tests', () {
    test('formatSpeed5Decimals with leading zero below 10 km/h', () {
      expect(SpeedFormatter.formatSpeed5Decimals(1.34473), equals('01.34473'));
      expect(SpeedFormatter.formatSpeed5Decimals(2.215), equals('02.21500'));
      expect(SpeedFormatter.formatSpeed5Decimals(0.0), equals('00.00000'));
      expect(SpeedFormatter.formatSpeed5Decimals(9.99999), equals('09.99999'));
    });

    test('formatSpeed5Decimals for values >= 10 km/h', () {
      expect(SpeedFormatter.formatSpeed5Decimals(12.34567), equals('12.34567'));
      expect(SpeedFormatter.formatSpeed5Decimals(120.5), equals('120.50000'));
    });

    test('formatDistanceMm and formatTimeUs', () {
      expect(SpeedFormatter.formatDistanceMm(50.0), equals('50.0mm'));
      expect(SpeedFormatter.formatTimeUs(133856), equals('133856us'));
    });

    test('Speed calculation matches ESP32 formula: (D_mm * 3600) / T_us', () {
      const distanceMm = 50.0;
      const timeUs = 133856;

      // Firmware formula: (DISTANCE_MM * 3600.0) / measuredTimeUs
      final calculatedSpeed = (distanceMm * 3600.0) / timeUs;

      // 180000 / 133856 = 1.34472866... -> rounds to 1.34473
      expect(
          SpeedFormatter.formatSpeed5Decimals(calculatedSpeed), equals('01.34473'));
    });

    test('Unit conversions (KM/H, m/s, MPH)', () {
      const kmph = 36.0;
      expect(SpeedFormatter.kmphToMps(kmph), closeTo(10.0, 0.001));
      expect(SpeedFormatter.kmphToMph(kmph), closeTo(22.369, 0.01));
    });
  });
}
