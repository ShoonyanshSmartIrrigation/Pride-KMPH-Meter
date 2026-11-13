import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform bridge for device settings (Location, Bluetooth, App Settings)
class DeviceSettingsService {
  DeviceSettingsService._();

  static const MethodChannel _channel =
      MethodChannel('com.shoonyansh.pride_kmph_meter/device_settings');

  /// Check if system Location Services (GPS) is currently enabled on Android
  static Future<bool> isLocationEnabled() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final bool? enabled =
            await _channel.invokeMethod<bool>('isLocationEnabled');
        return enabled ?? true;
      } catch (e) {
        debugPrint('[DeviceSettingsService] isLocationEnabled error: $e');
        return true;
      }
    }
    return true;
  }

  /// Open Android system Location Settings screen
  static Future<bool> openLocationSettings() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final bool? result =
            await _channel.invokeMethod<bool>('openLocationSettings');
        return result ?? false;
      } catch (e) {
        debugPrint('[DeviceSettingsService] openLocationSettings error: $e');
        return false;
      }
    }
    return false;
  }

  /// Open Android system Application Details Settings screen
  static Future<bool> openAppSettings() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final bool? result =
            await _channel.invokeMethod<bool>('openAppSettings');
        return result ?? false;
      } catch (e) {
        debugPrint('[DeviceSettingsService] openAppSettings error: $e');
        return false;
      }
    }
    return false;
  }
}
