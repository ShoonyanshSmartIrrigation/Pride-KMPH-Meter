import 'package:uuid/uuid.dart';

/// Strongly-typed measurement model representing speed telemetry from ESP32
class MeasurementModel {
  final String id;
  final int testNumber;
  final double currentSpeedKmph;
  final double previousSpeedKmph;
  final double distanceMm;
  final int elapsedTimeUs;
  final String status;
  final String deviceName;
  final DateTime measuredAt;
  final bool syncedToFirestore;

  const MeasurementModel({
    required this.id,
    required this.testNumber,
    required this.currentSpeedKmph,
    required this.previousSpeedKmph,
    required this.distanceMm,
    required this.elapsedTimeUs,
    required this.status,
    required this.deviceName,
    required this.measuredAt,
    this.syncedToFirestore = false,
  });

  /// Factory creating a MeasurementModel from ESP32 JSON payload
  factory MeasurementModel.fromEsp32Json({
    required Map<String, dynamic> json,
    String? deviceName,
    String? customId,
    DateTime? timestamp,
  }) {
    // Parse test number safely
    final rawTestNo = json['test_no'] ?? json['testNumber'] ?? 0;
    final testNo = rawTestNo is num ? rawTestNo.toInt() : int.tryParse('$rawTestNo') ?? 0;

    // Parse speed values safely without precision loss
    final rawCurrent = json['current_speed_kmph'] ?? json['currentSpeedKmph'] ?? 0.0;
    final currentSpeed = rawCurrent is num ? rawCurrent.toDouble() : double.tryParse('$rawCurrent') ?? 0.0;

    final rawPrevious = json['previous_speed_kmph'] ?? json['previousSpeedKmph'] ?? 0.0;
    final previousSpeed = rawPrevious is num ? rawPrevious.toDouble() : double.tryParse('$rawPrevious') ?? 0.0;

    final rawDist = json['distance_mm'] ?? json['distanceMm'] ?? 50.0;
    final distance = rawDist is num ? rawDist.toDouble() : double.tryParse('$rawDist') ?? 50.0;

    final rawTime = json['time_us'] ?? json['elapsedTimeUs'] ?? 0;
    final timeUs = rawTime is num ? rawTime.toInt() : int.tryParse('$rawTime') ?? 0;

    final statusStr = json['status']?.toString() ?? 'COMPLETE';
    final now = timestamp ?? DateTime.now();
    final devName = deviceName ?? 'Pride_KMPH_Meter';

    // Stable idempotent ID: combine deviceName, timestamp, and test number or UUID
    final id = customId ??
        '${devName.replaceAll(' ', '_')}_t${testNo}_${now.millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 8)}';

    return MeasurementModel(
      id: id,
      testNumber: testNo,
      currentSpeedKmph: currentSpeed,
      previousSpeedKmph: previousSpeed,
      distanceMm: distance,
      elapsedTimeUs: timeUs,
      status: statusStr,
      deviceName: devName,
      measuredAt: now,
      syncedToFirestore: false,
    );
  }

  /// Serialization to Map for local storage (SharedPreferences / JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testNumber': testNumber,
      'currentSpeedKmph': currentSpeedKmph,
      'previousSpeedKmph': previousSpeedKmph,
      'distanceMm': distanceMm,
      'elapsedTimeUs': elapsedTimeUs,
      'status': status,
      'deviceName': deviceName,
      'measuredAt': measuredAt.toIso8601String(),
      'syncedToFirestore': syncedToFirestore,
    };
  }

  /// Deserialization from local storage Map
  factory MeasurementModel.fromMap(Map<String, dynamic> map) {
    return MeasurementModel(
      id: map['id']?.toString() ?? const Uuid().v4(),
      testNumber: (map['testNumber'] as num?)?.toInt() ?? 0,
      currentSpeedKmph: (map['currentSpeedKmph'] as num?)?.toDouble() ?? 0.0,
      previousSpeedKmph: (map['previousSpeedKmph'] as num?)?.toDouble() ?? 0.0,
      distanceMm: (map['distanceMm'] as num?)?.toDouble() ?? 50.0,
      elapsedTimeUs: (map['elapsedTimeUs'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? 'COMPLETE',
      deviceName: map['deviceName']?.toString() ?? 'Pride_KMPH_Meter',
      measuredAt: map['measuredAt'] != null
          ? DateTime.tryParse(map['measuredAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      syncedToFirestore: map['syncedToFirestore'] == true,
    );
  }

  /// Serialization for Cloud Firestore conforming to requested schema:
  /// {
  ///   "testNumber": 1,
  ///   "currentSpeedKmph": 1.34473,
  ///   "previousSpeedKmph": 2.215,
  ///   "distanceMm": 50.0,
  ///   "elapsedTimeUs": 133856,
  ///   "deviceName": "Pride_KMPH_Meter",
  ///   "status": "COMPLETE",
  ///   "measuredAt": "timestamp"
  /// }
  Map<String, dynamic> toFirestoreMap() {
    return {
      'testNumber': testNumber,
      'currentSpeedKmph': currentSpeedKmph,
      'previousSpeedKmph': previousSpeedKmph,
      'distanceMm': distanceMm,
      'elapsedTimeUs': elapsedTimeUs,
      'deviceName': deviceName,
      'status': status,
      'measuredAt': measuredAt.toIso8601String(),
    };
  }

  MeasurementModel copyWith({
    String? id,
    int? testNumber,
    double? currentSpeedKmph,
    double? previousSpeedKmph,
    double? distanceMm,
    int? elapsedTimeUs,
    String? status,
    String? deviceName,
    DateTime? measuredAt,
    bool? syncedToFirestore,
  }) {
    return MeasurementModel(
      id: id ?? this.id,
      testNumber: testNumber ?? this.testNumber,
      currentSpeedKmph: currentSpeedKmph ?? this.currentSpeedKmph,
      previousSpeedKmph: previousSpeedKmph ?? this.previousSpeedKmph,
      distanceMm: distanceMm ?? this.distanceMm,
      elapsedTimeUs: elapsedTimeUs ?? this.elapsedTimeUs,
      status: status ?? this.status,
      deviceName: deviceName ?? this.deviceName,
      measuredAt: measuredAt ?? this.measuredAt,
      syncedToFirestore: syncedToFirestore ?? this.syncedToFirestore,
    );
  }
}
