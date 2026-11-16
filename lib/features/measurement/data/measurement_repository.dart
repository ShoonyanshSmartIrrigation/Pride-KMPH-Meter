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

  /// Records a completed measurement locally first, then asynchronously syncs to Firestore under the user
  Future<bool> recordMeasurement(MeasurementModel measurement) async {
    // 1. Save to local storage first (reliable offline operation)
    final savedLocally = await _localStorage.saveMeasurement(measurement);
    if (!savedLocally) {
      debugPrint('[MeasurementRepo] Skipped duplicate or failed local save');
      return false;
    }

    // 2. Asynchronously sync to Cloud Firestore without blocking BLE execution
    if (_firestoreService.isAvailable) {
      _syncToFirestoreAsync(measurement);
    }

    return true;
  }

  void _syncToFirestoreAsync(MeasurementModel measurement) {
    final userId = _authService.currentUserId;
    final userEmail = _authService.currentUser?.email;

    _firestoreService
        .saveMeasurement(
          userId: userId,
          measurement: measurement,
          userEmail: userEmail,
        )
        .then((success) {
          if (success) {
            _localStorage.markAsSynced(measurement.id);
            debugPrint('[MeasurementRepo] Successfully synced test #${measurement.testNumber} to Firestore under user $userId');
          }
        })
        .catchError((e) {
          debugPrint('[MeasurementRepo] Background sync failure: $e');
        });
  }

  /// Syncs all currently unsynced local records to Firestore under the current user
  Future<int> syncAllPending() async {
    if (!_firestoreService.isAvailable) return 0;

    final userId = _authService.currentUserId;
    final userEmail = _authService.currentUser?.email;
    final list = _localStorage.getMeasurements();
    final pending = list.where((m) => !m.syncedToFirestore).toList();
    int count = 0;

    for (final m in pending) {
      final success = await _firestoreService.saveMeasurement(
        userId: userId,
        measurement: m,
        userEmail: userEmail,
      );
      if (success) {
        await _localStorage.markAsSynced(m.id);
        count++;
      }
    }
    return count;
  }

  /// Fetches history from Cloud Firestore under current user and merges into local cache
  Future<List<MeasurementModel>> fetchAndMergeRemoteHistory() async {
    final userId = _authService.currentUserId;
    if (!_firestoreService.isAvailable || userId == 'local_device_user') {
      return _localStorage.getMeasurements();
    }

    try {
      // 1. Sync pending local items first
      await syncAllPending();

      // 2. Pull remote history stored under users/{userId}/history
      final remoteList = await _firestoreService.fetchUserHistory(userId: userId);

      // 3. Cache any remote measurements locally
      for (final m in remoteList) {
        await _localStorage.saveMeasurement(m);
      }

      // 4. Return merged, sorted history
      return _localStorage.getMeasurements();
    } catch (e) {
      debugPrint('[MeasurementRepo] fetchAndMergeRemoteHistory error: $e');
      return _localStorage.getMeasurements();
    }
  }

  /// Clears local measurements and user history in Firestore
  Future<bool> clearHistory() async {
    final userId = _authService.currentUserId;
    if (_firestoreService.isAvailable && userId != 'local_device_user') {
      try {
        await _firestoreService.clearUserHistory(userId: userId);
      } catch (e) {
        debugPrint('[MeasurementRepo] Clear remote history error: $e');
      }
    }
    return await _localStorage.clearAll();
  }
}
