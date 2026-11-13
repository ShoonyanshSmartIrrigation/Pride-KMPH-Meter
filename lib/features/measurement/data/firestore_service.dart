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

  /// Saves a single measurement record under users/{userId}/devices/{deviceId}/measurements/{measurementId}
  Future<bool> saveMeasurement({
    required String userId,
    required MeasurementModel measurement,
  }) async {
    if (!isAvailable) return false;

    try {
      final safeDeviceId =
          measurement.deviceName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(safeDeviceId)
          .collection('measurements')
          .doc(measurement.id);

      await docRef.set(measurement.toFirestoreMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('[FirestoreService] Save error: $e');
      return false;
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
}
