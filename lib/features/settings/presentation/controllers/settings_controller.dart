import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pride_kmph_meter/core/constants/ble_constants.dart';
import 'package:pride_kmph_meter/features/measurement/presentation/controllers/measurement_controller.dart';
import 'package:pride_kmph_meter/features/settings/domain/settings_model.dart';

class SettingsController extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsController(this._prefs) : super(const AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    final unit = _prefs.getString('pref_speed_unit') ?? 'KM/H';
    final theme = _prefs.getString('pref_instrument_theme') ?? 'TFT_LIGHT';
    final dist = _prefs.getDouble('pref_sensor_distance') ??
        BleConstants.defaultDistanceMm;
    final haptics = _prefs.getBool('pref_enable_haptics') ?? true;
    final sound = _prefs.getBool('pref_enable_sound') ?? true;

    state = AppSettings(
      speedUnit: unit,
      instrumentTheme: theme,
      sensorDistanceMm: dist,
      enableHaptics: haptics,
      enableSound: sound,
    );
  }

  Future<void> setSpeedUnit(String unit) async {
    await _prefs.setString('pref_speed_unit', unit);
    state = state.copyWith(speedUnit: unit);
  }

  Future<void> setInstrumentTheme(String theme) async {
    await _prefs.setString('pref_instrument_theme', theme);
    state = state.copyWith(instrumentTheme: theme);
  }

  Future<void> setDistance(double distanceMm) async {
    await _prefs.setDouble('pref_sensor_distance', distanceMm);
    state = state.copyWith(sensorDistanceMm: distanceMm);
  }

  Future<void> toggleHaptics(bool value) async {
    await _prefs.setBool('pref_enable_haptics', value);
    state = state.copyWith(enableHaptics: value);
  }

  Future<void> toggleSound(bool value) async {
    await _prefs.setBool('pref_enable_sound', value);
    state = state.copyWith(enableSound: value);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsController(prefs);
});
