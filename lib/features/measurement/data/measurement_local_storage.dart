import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/measurement_model.dart';

/// Local offline persistence for speed measurements using SharedPreferences
class MeasurementLocalStorage {
  static const String _storageKey = 'pride_kmph_measurements_v1';
  final SharedPreferences _prefs;

  MeasurementLocalStorage(this._prefs);

  /// Retrieves all locally saved measurements, sorted newest first
  List<MeasurementModel> getMeasurements() {
    try {
      final rawList = _prefs.getStringList(_storageKey);
      if (rawList == null || rawList.isEmpty) {
        return [];
      }

      final list = rawList
          .map((item) {
            try {
              final Map<String, dynamic> jsonMap = jsonDecode(item);
              return MeasurementModel.fromMap(jsonMap);
            } catch (_) {
              return null;
            }
          })
          .whereType<MeasurementModel>()
          .toList();

      // Sort newest first
      list.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Saves a new measurement with duplicate prevention (idempotent)
  Future<bool> saveMeasurement(MeasurementModel measurement) async {
    try {
      final existing = getMeasurements();

      // Idempotency check: don't save duplicates
      final isDuplicate = existing.any((m) =>
          m.id == measurement.id ||
          (m.testNumber == measurement.testNumber &&
              m.deviceName == measurement.deviceName &&
              (m.measuredAt.difference(measurement.measuredAt).inSeconds.abs() < 2)));

      if (isDuplicate) {
        return false;
      }

      existing.insert(0, measurement);

      final encoded = existing.map((m) => jsonEncode(m.toMap())).toList();
      return await _prefs.setStringList(_storageKey, encoded);
    } catch (_) {
      return false;
    }
  }

  /// Updates sync status for an existing measurement
  Future<void> markAsSynced(String measurementId) async {
    try {
      final existing = getMeasurements();
      final index = existing.indexWhere((m) => m.id == measurementId);
      if (index != -1) {
        existing[index] = existing[index].copyWith(syncedToFirestore: true);
        final encoded = existing.map((m) => jsonEncode(m.toMap())).toList();
        await _prefs.setStringList(_storageKey, encoded);
      }
    } catch (_) {}
  }

  /// Clears all local records
  Future<bool> clearAll() async {
    return await _prefs.remove(_storageKey);
  }
}
