import 'package:flutter_test/flutter_test.dart';
import 'package:pride_kmph_meter/features/measurement/domain/measurement_model.dart';

void main() {
  group('MeasurementModel Parsing and Idempotency Tests', () {
    test('Parses ESP32 JSON payload correctly without precision loss', () {
      final json = {
        'test_no': 1,
        'current_speed_kmph': 1.34473,
        'previous_speed_kmph': 2.21500,
        'distance_mm': 50.00,
        'time_us': 133856,
        'status': 'COMPLETE',
      };

      final model = MeasurementModel.fromEsp32Json(
        json: json,
        deviceName: 'Pride_KMPH_Meter',
      );

      expect(model.testNumber, equals(1));
      expect(model.currentSpeedKmph, equals(1.34473));
      expect(model.previousSpeedKmph, equals(2.21500));
      expect(model.distanceMm, equals(50.00));
      expect(model.elapsedTimeUs, equals(133856));
      expect(model.status, equals('COMPLETE'));
      expect(model.deviceName, equals('Pride_KMPH_Meter'));
      expect(model.id, isNotEmpty);
    });

    test('Serializes to Cloud Firestore schema accurately', () {
      final model = MeasurementModel(
        id: 'test_id_123',
        testNumber: 5,
        currentSpeedKmph: 4.56789,
        previousSpeedKmph: 3.12345,
        distanceMm: 50.0,
        elapsedTimeUs: 39405,
        status: 'COMPLETE',
        deviceName: 'Pride_KMPH_Meter',
        measuredAt: DateTime.parse('2026-11-02T12:00:00Z'),
      );

      final firestoreMap = model.toFirestoreMap();

      expect(firestoreMap['testNumber'], equals(5));
      expect(firestoreMap['currentSpeedKmph'], equals(4.56789));
      expect(firestoreMap['previousSpeedKmph'], equals(3.12345));
      expect(firestoreMap['distanceMm'], equals(50.0));
      expect(firestoreMap['elapsedTimeUs'], equals(39405));
      expect(firestoreMap['deviceName'], equals('Pride_KMPH_Meter'));
      expect(firestoreMap['status'], equals('COMPLETE'));
      expect(firestoreMap['measuredAt'], isNotNull);
    });

    test('Local storage Map serialization roundtrip', () {
      final original = MeasurementModel(
        id: 'roundtrip_id_456',
        testNumber: 9,
        currentSpeedKmph: 2.34567,
        previousSpeedKmph: 1.23456,
        distanceMm: 50.0,
        elapsedTimeUs: 76736,
        status: 'COMPLETE',
        deviceName: 'Pride_KMPH_Meter',
        measuredAt: DateTime.now(),
        syncedToFirestore: true,
      );

      final map = original.toMap();
      final reconstructed = MeasurementModel.fromMap(map);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.testNumber, equals(original.testNumber));
      expect(reconstructed.currentSpeedKmph, equals(original.currentSpeedKmph));
      expect(reconstructed.previousSpeedKmph, equals(original.previousSpeedKmph));
      expect(reconstructed.distanceMm, equals(original.distanceMm));
      expect(reconstructed.elapsedTimeUs, equals(original.elapsedTimeUs));
      expect(reconstructed.syncedToFirestore, isTrue);
    });
  });
}
