import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pride_kmph_meter/features/measurement/domain/measurement_model.dart';
import 'package:pride_kmph_meter/core/utils/date_formatter.dart';

class CsvExporter {
  CsvExporter._();

  /// Converts a list of measurements into standard CSV format
  static String generateCsvString(List<MeasurementModel> measurements) {
    final List<List<dynamic>> rows = [
      [
        'Test Number',
        'Current Speed (km/h)',
        'Previous Speed (km/h)',
        'Distance (mm)',
        'Elapsed Time (us)',
        'Device Name',
        'Status',
        'Timestamp',
        'Measurement ID',
      ],
    ];

    for (final m in measurements) {
      rows.add([
        m.testNumber,
        m.currentSpeedKmph.toStringAsFixed(5),
        m.previousSpeedKmph.toStringAsFixed(5),
        m.distanceMm.toStringAsFixed(2),
        m.elapsedTimeUs,
        m.deviceName,
        m.status,
        DateFormatter.formatDateTime(m.measuredAt),
        m.id,
      ]);
    }

    return csv.encode(rows);
  }

  /// Exports measurements to a local CSV file and triggers the system share sheet
  static Future<String> exportAndShare(
      List<MeasurementModel> measurements) async {
    final csvContent = generateCsvString(measurements);
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/Pride_KMPH_Measurements_$timestamp.csv';

    final file = File(filePath);
    await file.writeAsString(csvContent);

    // Share using system share dialog
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        subject: 'Pride KMPH Meter Measurements Export',
        text:
            'Pride KMPH Meter export with ${measurements.length} recorded tests.',
      ),
    );

    return filePath;
  }
}
