import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../domain/measurement_model.dart';

class FirestoreService {
  bool get isAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Saves a single measurement record under users/{userId}/history/{measurementId}
  /// and updates the user summary stats in Firestore.
  Future<bool> saveMeasurement({
    required String userId,
    required MeasurementModel measurement,
    String? userEmail,
  }) async {
    if (!isAvailable) return false;

    try {
      final safeDeviceId =
          measurement.deviceName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      final data = measurement.toFirestoreMap();
      data['id'] = measurement.id;
      data['userId'] = userId;
      if (userEmail != null && userEmail.isNotEmpty) {
        data['userEmail'] = userEmail;
      }
      data['timestamp'] = FieldValue.serverTimestamp();

      final firestore = FirebaseFirestore.instance;

      // 1. Primary History path: users/{userId}/history/{measurementId}
      final historyRef = firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc(measurement.id);

      await historyRef.set(data, SetOptions(merge: true));

      // 2. Measurements path: users/{userId}/measurements/{measurementId}
      final measurementsRef = firestore
          .collection('users')
          .doc(userId)
          .collection('measurements')
          .doc(measurement.id);

      await measurementsRef.set(data, SetOptions(merge: true));

      // 3. Per-device subcollection for hardware traceability
      if (safeDeviceId.isNotEmpty) {
        final deviceRef = firestore
            .collection('users')
            .doc(userId)
            .collection('devices')
            .doc(safeDeviceId)
            .collection('measurements')
            .doc(measurement.id);
        await deviceRef.set(data, SetOptions(merge: true));
      }

      // 4. Update user profile telemetry summary
      try {
        await firestore.collection('users').doc(userId).set({
          'lastMeasurementAt': FieldValue.serverTimestamp(),
          'lastSpeedKmph': measurement.currentSpeedKmph,
          'totalMeasurements': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[FirestoreService] Summary update warning: $e');
      }

      return true;
    } catch (e) {
      debugPrint('[FirestoreService] Save error: $e');
      return false;
    }
  }

  /// Fetches all measurements for a given user from users/{userId}/history
  Future<List<MeasurementModel>> fetchUserHistory({
    required String userId,
    int limit = 100,
  }) async {
    if (!isAvailable) return [];

    try {
      final firestore = FirebaseFirestore.instance;

      // Query primary history collection: users/{userId}/history
      var querySnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .orderBy('measuredAt', descending: true)
          .limit(limit)
          .get();

      // Fallback to measurements collection if history subcollection is empty
      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('measurements')
            .orderBy('measuredAt', descending: true)
            .limit(limit)
            .get();
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['syncedToFirestore'] = true;
        return MeasurementModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('[FirestoreService] Fetch user history error: $e');
      return [];
    }
  }

  /// Fetches recent measurements from Cloud Firestore for a given user & device
  Future<List<MeasurementModel>> fetchRemoteMeasurements({
    required String userId,
    required String deviceName,
    int limit = 50,
  }) async {
    if (!isAvailable) return [];

    try {
      final safeDeviceId =
          deviceName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(safeDeviceId)
          .collection('measurements')
          .orderBy('measuredAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['syncedToFirestore'] = true;
        return MeasurementModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('[FirestoreService] Fetch error: $e');
      return [];
    }
  }

  /// Deletes all history records for a given user from Firestore
  Future<bool> clearUserHistory({required String userId}) async {
    if (!isAvailable) return false;

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      final historyDocs = await firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .limit(500)
          .get();

      for (final doc in historyDocs.docs) {
        batch.delete(doc.reference);
      }

      final measurementDocs = await firestore
          .collection('users')
          .doc(userId)
          .collection('measurements')
          .limit(500)
          .get();

      for (final doc in measurementDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('[FirestoreService] Clear user history error: $e');
      return false;
    }
  }
}
