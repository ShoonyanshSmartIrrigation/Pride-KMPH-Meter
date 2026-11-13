import 'package:flutter/foundation.dart';
import 'package:pride_kmph_meter/features/auth/data/auth_service.dart';
import 'package:pride_kmph_meter/features/measurement/domain/measurement_model.dart';
import 'package:pride_kmph_meter/features/measurement/data/firestore_service.dart';
import 'package:pride_kmph_meter/features/measurement/data/measurement_local_storage.dart';

class MeasurementRepository {
  final MeasurementLocalStorage _localStorage;
  final FirestoreService _firestoreService;
  final AuthService _authService;

  MeasurementRepository({
    required MeasurementLocalStorage localStorage,
    required FirestoreService firestoreService,
    required AuthService authService,
  })  : _localStorage = localStorage,
        _firestoreService = firestoreService,
        _authService = authService;

  /// Retrieves cached measurements from offline local storage
  List<MeasurementModel> getLocalMeasurements() {
    return _localStorage.getMeasurements();
  }

  /// Records a completed measurement locally first, then asynchronously syncs to Firestore
  Future<bool> recordMeasurement(MeasurementModel measurement) async {
    // 1. Save to local storage first (reliable offline operation)
    final savedLocally = await _localStorage.saveMeasurement(measurement);
    if (!savedLocally) {
      debugPrint('[MeasurementRepo] Skipped duplicate or failed local save');
      return false;
    }

    // 2. Asynchronously sync to Cloud Firestore without blocking BLE execution
    if (_firestoreService.isAvailable) {
      _authService.ensureSignedIn().then((_) {
        _syncToFirestoreAsync(measurement);
      }).catchError((e) {
        debugPrint('[MeasurementRepo] Auth ensure failed: $e');
      });
    }

    return true;
  }

  void _syncToFirestoreAsync(MeasurementModel measurement) {
    _firestoreService
        .saveMeasurement(
          userId: _authService.currentUserId,
          measurement: measurement,
        )
        .then((success) {
          if (success) {
            _localStorage.markAsSynced(measurement.id);
            debugPrint('[MeasurementRepo] Successfully synced test #${measurement.testNumber} to Firestore');
          }
        })
        .catchError((e) {
          debugPrint('[MeasurementRepo] Background sync failure: $e');
        });
  }

  /// Syncs all currently unsynced local records to Firestore
  Future<int> syncAllPending() async {
    if (!_firestoreService.isAvailable) return 0;
    await _authService.ensureSignedIn();

    final list = _localStorage.getMeasurements();
    final pending = list.where((m) => !m.syncedToFirestore).toList();
    int count = 0;

    for (final m in pending) {
      final success = await _firestoreService.saveMeasurement(
        userId: _authService.currentUserId,
        measurement: m,
      );
      if (success) {
        await _localStorage.markAsSynced(m.id);
        count++;
      }
    }
    return count;
  }

  /// Clears local measurements
  Future<bool> clearHistory() async {
    return await _localStorage.clearAll();
  }
}
