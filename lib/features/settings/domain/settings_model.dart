class AppSettings {
  final String speedUnit; // 'KM/H', 'm/s', 'MPH'
  final String instrumentTheme; // 'TFT_LIGHT', 'OLED_DARK'
  final double sensorDistanceMm;
  final bool enableHaptics;
  final bool enableSound;
  final bool autoReconnect;

  const AppSettings({
    this.speedUnit = 'KM/H',
    this.instrumentTheme = 'TFT_LIGHT',
    this.sensorDistanceMm = 50.0,
    this.enableHaptics = true,
    this.enableSound = true,
    this.autoReconnect = true,
  });

  AppSettings copyWith({
    String? speedUnit,
    String? instrumentTheme,
    double? sensorDistanceMm,
    bool? enableHaptics,
    bool? enableSound,
    bool? autoReconnect,
  }) {
    return AppSettings(
      speedUnit: speedUnit ?? this.speedUnit,
      instrumentTheme: instrumentTheme ?? this.instrumentTheme,
      sensorDistanceMm: sensorDistanceMm ?? this.sensorDistanceMm,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableSound: enableSound ?? this.enableSound,
      autoReconnect: autoReconnect ?? this.autoReconnect,
    );
  }
}
