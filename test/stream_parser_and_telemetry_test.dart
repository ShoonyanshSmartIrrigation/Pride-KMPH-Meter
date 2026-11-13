import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pride_kmph_meter/features/measurement/domain/measurement_model.dart';

void main() {
  group('BLE Stream Buffer & Multi-Packet Parser Logic Tests', () {
    List<Map<String, dynamic>> parsePackets(List<String> incomingChunks) {
      final buffer = StringBuffer();
      final results = <Map<String, dynamic>>[];

      for (final chunk in incomingChunks) {
        buffer.write(chunk);
        String bufferContent = buffer.toString();

        while (true) {
          final startIndex = bufferContent.indexOf('{');
          if (startIndex == -1) {
            if (bufferContent.length > 80) bufferContent = '';
            break;
          }

          if (startIndex > 0) {
            bufferContent = bufferContent.substring(startIndex);
          }

          int braceDepth = 0;
          int matchingEndIndex = -1;
          bool inString = false;
          bool isEscaped = false;

          for (int i = 0; i < bufferContent.length; i++) {
            final char = bufferContent[i];

            if (isEscaped) {
              isEscaped = false;
              continue;
            }
            if (char == '\\') {
              isEscaped = true;
              continue;
            }
            if (char == '"') {
              inString = !inString;
              continue;
            }
            if (!inString) {
              if (char == '{') {
                braceDepth++;
              } else if (char == '}') {
                braceDepth--;
                if (braceDepth == 0) {
                  matchingEndIndex = i;
                  break;
                }
              }
            }
          }

          if (matchingEndIndex == -1) break;

          final jsonCandidate = bufferContent.substring(0, matchingEndIndex + 1);
          bufferContent = bufferContent.substring(matchingEndIndex + 1);

          try {
            final dynamic decoded = jsonDecode(jsonCandidate);
            if (decoded is Map<String, dynamic>) {
              results.add(decoded);
            }
          } catch (_) {}
        }

        buffer.clear();
        if (bufferContent.isNotEmpty) {
          buffer.write(bufferContent);
        }
      }

      return results;
    }

    test('Parses multiple JSON packets delivered in a single BLE burst', () {
      const burst =
          '{"test_no":1,"status":"START"}{"test_no":1,"current_speed_kmph":18.54321,"previous_speed_kmph":12.30000,"distance_mm":50.0,"time_us":9707,"status":"COMPLETE"}';

      final parsed = parsePackets([burst]);
      expect(parsed.length, equals(2));
      expect(parsed[0]['status'], equals('START'));
      expect(parsed[1]['status'], equals('COMPLETE'));
      expect(parsed[1]['current_speed_kmph'], equals(18.54321));
      expect(parsed[1]['previous_speed_kmph'], equals(12.30000));
    });

    test('Reassembles fragmented packet chunks cleanly', () {
      final chunks = [
        '{"test_no":2,"current_spe',
        'ed_kmph":22.12345,"previous_spe',
        'ed_kmph":18.54321,"distance_mm":50.0,"time_us":8136,"status":"COMPLETE"}',
      ];

      final parsed = parsePackets(chunks);
      expect(parsed.length, equals(1));
      expect(parsed[0]['test_no'], equals(2));
      expect(parsed[0]['current_speed_kmph'], equals(22.12345));
      expect(parsed[0]['previous_speed_kmph'], equals(18.54321));
      expect(parsed[0]['status'], equals('COMPLETE'));
    });

    test('Ignores noisy prefix junk without corrupting payload', () {
      const noisyChunk =
          'random_noise_prefix{"test_no":3,"current_speed_kmph":15.00000,"status":"COMPLETE"}';

      final parsed = parsePackets([noisyChunk]);
      expect(parsed.length, equals(1));
      expect(parsed[0]['test_no'], equals(3));
      expect(parsed[0]['current_speed_kmph'], equals(15.00000));
    });

    test('Handles escaped quotes inside strings without tripping brace counter', () {
      const complexChunk =
          '{"test_no":4,"status":"COMPLETE","msg":"Gate \\"A\\" cleared"}';

      final parsed = parsePackets([complexChunk]);
      expect(parsed.length, equals(1));
      expect(parsed[0]['msg'], equals('Gate "A" cleared'));
    });
  });

  group('Hardware Display 1:1 Mirroring Tests', () {
    test('Exact 1:1 match of ESP32 current and previous speed payloads', () {
      final incomingEspJson = {
        'test_no': 1,
        'current_speed_kmph': 31.25000,
        'previous_speed_kmph': 0.00000,
        'distance_mm': 50.0,
        'time_us': 5760,
        'status': 'COMPLETE',
      };

      final measurement = MeasurementModel.fromEsp32Json(json: incomingEspJson);

      expect(measurement.currentSpeedKmph, equals(31.25000));
      expect(measurement.previousSpeedKmph, equals(0.00000));
      expect(measurement.elapsedTimeUs, equals(5760));
      expect(measurement.distanceMm, equals(50.0));
    });

    test('Uses ESP32 previous speed when ESP32 provides non-zero previous speed', () {
      final incomingEspJson = {
        'test_no': 2,
        'current_speed_kmph': 35.00000,
        'previous_speed_kmph': 31.25000,
        'distance_mm': 50.0,
        'time_us': 5142,
        'status': 'COMPLETE',
      };

      final measurement = MeasurementModel.fromEsp32Json(json: incomingEspJson);

      expect(measurement.previousSpeedKmph, equals(31.25000));
      expect(measurement.currentSpeedKmph, equals(35.00000));
    });
  });
}

