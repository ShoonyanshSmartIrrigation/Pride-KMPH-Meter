package com.example.pride_kmph_meter

import android.content.Context
import android.content.Intent
import android.location.LocationManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.shoonyansh.pride_kmph_meter/device_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isLocationEnabled" -> {
                    try {
                        val lm = getSystemService(Context.LOCATION_SERVICE) as? LocationManager
                        val isEnabled = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                            lm?.isLocationEnabled == true
                        } else {
                            @Suppress("DEPRECATION")
                            val mode = Settings.Secure.getInt(
                                contentResolver,
                                Settings.Secure.LOCATION_MODE,
                                Settings.Secure.LOCATION_MODE_OFF
                            )
                            @Suppress("DEPRECATION")
                            mode != Settings.Secure.LOCATION_MODE_OFF
                        }
                        result.success(isEnabled)
                    } catch (e: Exception) {
                        result.success(true)
                    }
                }
                "openLocationSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "openAppSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = android.net.Uri.fromParts("package", packageName, null)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
