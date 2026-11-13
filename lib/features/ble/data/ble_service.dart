import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pride_kmph_meter/core/constants/ble_constants.dart';
import 'package:pride_kmph_meter/core/services/device_settings_service.dart';
import 'package:pride_kmph_meter/features/ble/domain/ble_device_state.dart';

class BleService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _measurementCharacteristic;
  BluetoothCharacteristic? _configCharacteristic;

  StreamSubscription? _scanSub;
  StreamSubscription? _connectionSub;
  StreamSubscription? _notifySub;
  StreamSubscription? _scanningStateSub;

  final _connectionStateController =
      StreamController<BleConnectionStatus>.broadcast();
  final _discoveredDevicesController =
      StreamController<List<DiscoveredDevice>>.broadcast();
  final _rawDataController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusMessageController = StreamController<String>.broadcast();
  final _isLocationRequiredController = StreamController<bool>.broadcast();

  Stream<BleConnectionStatus> get connectionStateStream =>
      _connectionStateController.stream;
  Stream<List<DiscoveredDevice>> get discoveredDevicesStream =>
      _discoveredDevicesController.stream;
  Stream<Map<String, dynamic>> get rawDataStream => _rawDataController.stream;
  Stream<String> get statusMessageStream => _statusMessageController.stream;
  Stream<bool> get isLocationRequiredStream =>
      _isLocationRequiredController.stream;

  BleConnectionStatus _currentStatus = BleConnectionStatus.disconnected;
  BleConnectionStatus get currentStatus => _currentStatus;
  String? get connectedDeviceName => _connectedDevice?.platformName;
  String? get connectedDeviceId => _connectedDevice?.remoteId.str;

  // StringBuffer for assembling fragmented BLE packets
  final StringBuffer _packetBuffer = StringBuffer();

  // Automatic Reconnection Management
  bool _isManualDisconnect = false;
  String? _lastConnectedDeviceId;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  BleService() {
    _connectionStateController.add(BleConnectionStatus.disconnected);
    _scanningStateSub = FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning && _currentStatus == BleConnectionStatus.scanning) {
        _setStatus(BleConnectionStatus.disconnected, 'Scan finished');
      }
    });
  }

  void _setStatus(BleConnectionStatus status, [String? message]) {
    _currentStatus = status;
    _connectionStateController.add(status);
    if (message != null) {
      _statusMessageController.add(message);
    }
  }

  /// Request runtime Bluetooth and Location permissions for Android & iOS
  Future<bool> checkAndRequestPermissions() async {
    try {
      // Check adapter state & permissions through FlutterBluePlus
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState == BluetoothAdapterState.unauthorized) {
        _statusMessageController.add(
          'Bluetooth permissions denied. Please grant Bluetooth permissions in phone settings.',
        );
        return false;
      }
      if (adapterState != BluetoothAdapterState.on) {
        if (!kIsWeb && Platform.isAndroid) {
          try {
            await FlutterBluePlus.turnOn();
          } catch (e) {
            debugPrint('[BleService] FlutterBluePlus.turnOn error: $e');
          }
        }
        final recheck = await FlutterBluePlus.adapterState.first;
        if (recheck != BluetoothAdapterState.on) {
          _statusMessageController.add(
            'Bluetooth adapter is turned OFF. Please enable Bluetooth on your phone.',
          );
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('[BleService] Adapter check error: $e');
      return true; // continue gracefully
    }
  }

  /// Scan for nearby BLE devices
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    final hasPerms = await checkAndRequestPermissions();
    if (!hasPerms) {
      _setStatus(BleConnectionStatus.error, 'Permission or Bluetooth error');
      return;
    }

    // Android 11 and lower strictly requires device Location Services (GPS) to be ON for BLE scans
    if (!kIsWeb && Platform.isAndroid) {
      final isLocationOn = await DeviceSettingsService.isLocationEnabled();
      if (!isLocationOn) {
        _isLocationRequiredController.add(true);
        _setStatus(
          BleConnectionStatus.error,
          'Location Services (GPS) are required on Android for Bluetooth discovery. Please turn ON Location.',
        );
        return;
      }
    }

    _isLocationRequiredController.add(false);
    _setStatus(
      BleConnectionStatus.scanning,
      'Scanning for Pride KMPH Meter...',
    );

    try {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }

      await _scanSub?.cancel();
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        final devices = results.map((r) {
          final name = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : (r.advertisementData.advName.isNotEmpty
                    ? r.advertisementData.advName
                    : 'Unknown Device');
          final isPride =
              name == BleConstants.deviceName ||
              r.advertisementData.serviceUuids.any(
                (u) =>
                    u.str128.toLowerCase() ==
                    BleConstants.serviceUuid.toLowerCase(),
              );

          return DiscoveredDevice(
            id: r.device.remoteId.str,
            name: name,
            rssi: r.rssi,
            isPrideMeter: isPride,
          );
        }).toList();

        // Sort so Pride KMPH Meter appears at the top
        devices.sort((a, b) {
          if (a.isPrideMeter && !b.isPrideMeter) return -1;
          if (!a.isPrideMeter && b.isPrideMeter) return 1;
          return b.rssi.compareTo(a.rssi);
        });

        _discoveredDevicesController.add(devices);
      });

      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: false,
      );
    } catch (e) {
      debugPrint('[BleService] Scan error: $e');
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('location')) {
        _isLocationRequiredController.add(true);
        _setStatus(
          BleConnectionStatus.error,
          'Location Services (GPS) are required on Android for Bluetooth discovery. Please turn ON Location.',
        );
      } else {
        _setStatus(BleConnectionStatus.error, 'Scan failed: $e');
      }
    }
  }

  Future<void> stopScan() async {
    try {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
      if (_currentStatus == BleConnectionStatus.scanning) {
        _setStatus(BleConnectionStatus.disconnected, 'Scan stopped');
      }
    } catch (_) {}
  }

  /// Connect to a specific BLE device by remoteId
  Future<bool> connectToDevice(String deviceId) async {
    try {
      await stopScan();
      _isManualDisconnect = false;
      _lastConnectedDeviceId = deviceId;
      _reconnectTimer?.cancel();

      _setStatus(BleConnectionStatus.connecting, 'Connecting to $deviceId...');

      final device = BluetoothDevice.fromId(deviceId);
      _connectedDevice = device;

      // Connect with timeout and negotiate MTU in a single coordinated operation
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
        mtu: Platform.isAndroid ? BleConstants.requestedMtu : null,
      );

      // Brief delay to allow Android GATT stack and bonding handshake to stabilize
      await Future.delayed(const Duration(milliseconds: 250));

      // Monitor connection state after connection is established
      await _connectionSub?.cancel();
      _connectionSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          debugPrint('[BleService] Device disconnected.');
          if (!_isManualDisconnect && _lastConnectedDeviceId != null) {
            _scheduleReconnect();
          } else {
            _cleanUpConnection();
            _setStatus(BleConnectionStatus.disconnected, 'Device disconnected');
          }
        }
      });

      // Discover Services
      _setStatus(
        BleConnectionStatus.discoveringServices,
        'Discovering services...',
      );
      final services = await device.discoverServices();

      BluetoothService? meterService;
      final targetServiceUuid = BleConstants.serviceUuid
          .replaceAll('-', '')
          .toLowerCase();
      for (final s in services) {
        final sUuid = s.uuid.toString().replaceAll('-', '').toLowerCase();
        if (sUuid == targetServiceUuid ||
            s.uuid == Guid(BleConstants.serviceUuid)) {
          meterService = s;
          break;
        }
      }

      if (meterService == null) {
        _setStatus(
          BleConnectionStatus.error,
          'Pride KMPH Meter primary service not found on device.',
        );
        await disconnect();
        return false;
      }

      // Find characteristics
      final targetTelemetryUuid = BleConstants.measurementCharacteristicUuid
          .replaceAll('-', '')
          .toLowerCase();
      final targetConfigUuid = BleConstants.configCharacteristicUuid
          .replaceAll('-', '')
          .toLowerCase();

      for (final c in meterService.characteristics) {
        final cUuid = c.uuid.toString().replaceAll('-', '').toLowerCase();
        if (cUuid == targetTelemetryUuid ||
            c.uuid == Guid(BleConstants.measurementCharacteristicUuid)) {
          _measurementCharacteristic = c;
        } else if (cUuid == targetConfigUuid ||
            c.uuid == Guid(BleConstants.configCharacteristicUuid)) {
          _configCharacteristic = c;
        }
      }

      if (_measurementCharacteristic == null) {
        _setStatus(
          BleConnectionStatus.error,
          'Telemetry characteristic not found on device.',
        );
        await disconnect();
        return false;
      }

      // Prepare packet buffer and attach notification listener BEFORE enabling notifications
      _packetBuffer.clear();
      await _notifySub?.cancel();
      _notifySub = _measurementCharacteristic!.onValueReceived.listen((data) {
        _handleIncomingBytes(data);
      });

      // Subscribe to Notifications
      _statusMessageController.add('Subscribing to telemetry notifications...');
      await _measurementCharacteristic!.setNotifyValue(true);

      // Immediately read current telemetry value stored on ESP32 characteristic
      try {
        _statusMessageController.add(
          'Reading current telemetry from device...',
        );
        final initialBytes = await _measurementCharacteristic!.read();
        if (initialBytes.isNotEmpty) {
          _handleIncomingBytes(initialBytes);
        }
      } catch (readErr) {
        debugPrint('[BleService] Initial telemetry read non-fatal: $readErr');
      }

      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;

      _setStatus(
        BleConnectionStatus.connected,
        'Connected to Pride KMPH Meter',
      );
      return true;
    } catch (e) {
      debugPrint('[BleService] Connection error: $e');
      _setStatus(BleConnectionStatus.error, 'Connection failed: $e');
      await disconnect();
      return false;
    }
  }

  /// Processes incoming byte chunks and parses JSON payloads.
  /// Robust against fragmented packets as well as multiple packets delivered together
  /// in the same BLE notification burst.
  void _handleIncomingBytes(List<int> bytes) {
    if (bytes.isEmpty) return;

    try {
      final chunk = utf8.decode(bytes, allowMalformed: true);
      _packetBuffer.write(chunk);

      String bufferContent = _packetBuffer.toString();

      // Repeatedly extract every complete JSON object {...} in the buffer
      while (true) {
        final startIndex = bufferContent.indexOf('{');
        if (startIndex == -1) {
          // No opening brace found. Prevent unbounded growth if junk text was received.
          if (bufferContent.length > 80) {
            bufferContent = '';
          }
          break;
        }

        // Discard any non-JSON prefix before the first '{'
        if (startIndex > 0) {
          bufferContent = bufferContent.substring(startIndex);
        }

        // Find the matching closing '}' for this opening '{'
        int braceDepth = 0;
        int matchingEndIndex = -1;
        bool inString = false;
        bool isEscaped = false;

        for (int i = 0; i < bufferContent.length; i++) {
          final char = bufferContent[i];

          if (isEscaped) {
            isEscaped = false;
            continue;
          }

          if (char == '\\') {
            isEscaped = true;
            continue;
          }

          if (char == '"') {
            inString = !inString;
            continue;
          }

          if (!inString) {
            if (char == '{') {
              braceDepth++;
            } else if (char == '}') {
              braceDepth--;
              if (braceDepth == 0) {
                matchingEndIndex = i;
                break;
              }
            }
          }
        }

        // If closing brace is not found yet, wait for subsequent chunks
        if (matchingEndIndex == -1) {
          break;
        }

        // Extract this single complete JSON candidate
        final jsonCandidate = bufferContent.substring(0, matchingEndIndex + 1);
        bufferContent = bufferContent.substring(matchingEndIndex + 1);

        try {
          final dynamic decoded = jsonDecode(jsonCandidate);
          if (decoded is Map<String, dynamic>) {
            _rawDataController.add(decoded);
          }
        } catch (jsonErr) {
          debugPrint(
            '[BleService] JSON decode error: $jsonErr in "$jsonCandidate"',
          );
        }
      }

      // Restore any remaining incomplete trailing bytes into the buffer
      _packetBuffer.clear();
      if (bufferContent.isNotEmpty) {
        _packetBuffer.write(bufferContent);
      }
    } catch (e) {
      debugPrint('[BleService] Incoming bytes error: $e');
    }
  }

  /// Disconnect current device manually
  Future<void> disconnect() async {
    _isManualDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _lastConnectedDeviceId = null;
    _reconnectAttempts = 0;

    try {
      _setStatus(BleConnectionStatus.disconnecting, 'Disconnecting...');
      await _connectedDevice?.disconnect();
    } catch (_) {
    } finally {
      _cleanUpConnection();
      _setStatus(BleConnectionStatus.disconnected, 'Disconnected');
    }
  }

  /// Automatically attempts reconnection with backoff when an unexpected drop occurs
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_isManualDisconnect || _lastConnectedDeviceId == null) return;

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[BleService] Max reconnect attempts reached.');
      _cleanUpConnection();
      _setStatus(
        BleConnectionStatus.disconnected,
        'Connection lost. Please tap Connect to reconnect.',
      );
      return;
    }

    _reconnectAttempts++;
    final delaySeconds = _reconnectAttempts == 1 ? 1 : (_reconnectAttempts * 2);
    _setStatus(
      BleConnectionStatus.connecting,
      'Connection lost. Auto-reconnecting in ${delaySeconds}s (attempt $_reconnectAttempts/$_maxReconnectAttempts)...',
    );

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      if (_isManualDisconnect || _lastConnectedDeviceId == null) return;
      debugPrint(
        '[BleService] Auto-reconnecting to $_lastConnectedDeviceId (attempt $_reconnectAttempts)...',
      );
      final success = await connectToDevice(_lastConnectedDeviceId!);
      if (!success && !_isManualDisconnect && _lastConnectedDeviceId != null) {
        _scheduleReconnect();
      }
    });
  }

  void _cleanUpConnection() {
    _notifySub?.cancel();
    _notifySub = null;
    _connectionSub?.cancel();
    _connectionSub = null;
    _measurementCharacteristic = null;
    _configCharacteristic = null;
    _connectedDevice = null;
    _packetBuffer.clear();
  }

  /// Update sensor distance remotely on ESP32 firmware
  Future<bool> setRemoteDistance(double distanceMm) async {
    if (_configCharacteristic == null) return false;
    try {
      final valueStr = distanceMm.toStringAsFixed(2);
      await _configCharacteristic!.write(utf8.encode(valueStr));
      return true;
    } catch (e) {
      debugPrint('[BleService] Set distance error: $e');
      return false;
    }
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _scanSub?.cancel();
    _scanningStateSub?.cancel();
    _connectionSub?.cancel();
    _notifySub?.cancel();
    _connectionStateController.close();
    _discoveredDevicesController.close();
    _rawDataController.close();
    _statusMessageController.close();
    _isLocationRequiredController.close();
  }
}
