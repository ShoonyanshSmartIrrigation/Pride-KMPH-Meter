/// State representing BLE device connection and discovery status
enum BleConnectionStatus {
  disconnected,
  scanning,
  connecting,
  discoveringServices,
  authenticating,
  connected,
  disconnecting,
  error,
}

class DiscoveredDevice {
  final String id;
  final String name;
  final int rssi;
  final bool isPrideMeter;

  const DiscoveredDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.isPrideMeter,
  });
}
