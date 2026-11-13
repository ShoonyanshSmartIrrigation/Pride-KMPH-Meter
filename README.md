# Pride KMPH Meter — Production Flutter & ESP32 System

A production-grade, real hardware-integrated Flutter (Android & iOS) mobile application and ESP32 firmware for high-precision projectile/object speed measurement over Bluetooth Low Energy (BLE).

---

## 1. System Overview & Physical Mechanism

The **Pride KMPH Meter** system calculates instantaneous speed using dual optical or infrared break-beam sensors connected to high-precision hardware interrupts on an ESP32 microcontroller:

1. **START Sensor (GPIO 27)**: Tripped on falling edge when object enters the gate; captures hardware timestamp $T_{\text{start}} = \text{micros}()$.
2. **STOP Sensor (GPIO 33)**: Tripped on falling edge when object exits the gate; calculates $\Delta T = \text{micros}() - T_{\text{start}}$.
3. **Reference Distance**: Initial distance between optical gates is $50.0\text{ mm}$.
4. **Physical Formula**:
   $$\text{Speed (km/h)} = \frac{\text{Distance (mm)} \times 3600}{\text{Elapsed Time } (\mu s)}$$
   *Example:* $D = 50.0\text{ mm}$, $\Delta T = 133856\ \mu s \implies \text{Speed} = \mathbf{01.34473}\text{ km/h}$.
5. **ST7789 TFT Display**: Displays CURRENT SPEED (purple numerals), PREVIOUS SPEED (red numerals), and bottom info strip (`D:50.0mm T:133856us`).
6. **BLE Telemetry Stream**: Broadcasts JSON payload securely to the Flutter mobile application with passkey pairing (`123456`).

---

## 2. Technology Stack & Architecture

- **Flutter**: Latest stable Flutter 3.41+ with Dart 3.11+ sound null safety.
- **State Management**: Riverpod (`flutter_riverpod: ^2.6.1`) with single-source-of-truth application-level connection controller.
- **Navigation**: `go_router: ^17.5.0` with `ShellRoute` managing bottom navigation.
- **Design System**: Material 3 with industrial instrument palette matching the physical ST7789 TFT display (`#DDF1FF` instrument background, `#1746A2` borders, `#A020D5` current speed, `#D72845` previous speed, `#0866C9` time).
- **Bluetooth Low Energy**: `flutter_blue_plus: ^1.35.4` featuring:
  - Automatic MTU negotiation (requesting 512 bytes on Android).
  - Stream buffer reassembly for fragmented BLE packets.
  - Security callbacks for 6-digit PIN pairing (`123456`).
  - Android 12+ permissions (`BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`) and legacy location permissions.
- **Data Persistence**:
  - **Local Offline Cache**: `SharedPreferences` storing all completed tests persistently without requiring internet.
  - **Cloud Firestore**: Non-blocking asynchronous sync to `users/{userId}/devices/{deviceId}/measurements/{measurementId}`.
  - **Firestore Security Rules**: Strict schema validation and user-based data isolation in `firestore.rules`.
- **Analytics & Export**:
  - `fl_chart: ^1.3.0` for interactive speed trend line charts.
  - `csv: ^8.0.0` and `share_plus: ^13.3.1` for RFC 4180 CSV export and native sharing.
  - `google_fonts: ^8.2.1` for digital 5-decimal monospace numerals with tabular figures.

---

## 3. Five Main Screens

### Screen 1 — Dashboard (Hardware-Style Display)
- Centered on the authentic **ST7789 TFT Instrument Display**:
  - **CURRENT SPEED**: Large purple numerals formatted to 5 decimals with leading zero if $<10$ (e.g. `01.34473 KM/H`).
  - **PREVIOUS SPEED**: Large red numerals (e.g. `02.21500 KM/H`).
  - **Info Strip**: `D:50.0mm          T:133856us`.
  - Flash highlight effect upon completing a measurement.
- Connection status badge with device identifier and live telemetry indicator.
- Physical sensor pipeline timeline.
- Quick action buttons to Live Testing and Analytics.

### Screen 2 — Bluetooth Device Connection
- Live Bluetooth radar scan with RSSI signal meters.
- Filtered device list highlighting `Pride_KMPH_Meter`.
- Connection lifecycle: Disconnected $\to$ Scanning $\to$ Connecting $\to$ Service Discovery $\to$ MTU 512 Negotiation $\to$ Subscribed.
- Secure pairing instructions dialog for fixed passkey `123456`.
- **Hardware Simulation Mode Switch**: Allows complete UI testing and demonstration without physical ESP32 nearby.

### Screen 3 — Live Measurement
- Dedicated testing screen for laboratory/field measurements.
- Hero speed display with unit selector (KM/H, m/s, MPH).
- Interactive physical timeline:
  `START SENSOR (GPIO 27) ──▶ MEASURING ΔT ──▶ STOP SENSOR (GPIO 33) ──▶ COMPLETED`
- Real-time GPIO pin status indicators for START and STOP optical gates.
- Simulation trigger button to fire simulated test projectiles.

### Screen 4 — Measurement History & Analytics
- KPI Cards: Maximum Speed, Minimum Speed, Average Speed, and Total Tests recorded.
- Chronological speed trend line chart using `fl_chart`.
- Search by test number or speed value, and date range filter.
- Detailed test list with cloud synchronization badges.
- Comprehensive test detail dialog.
- **Export to CSV**: Generates standard CSV and triggers native OS sharing.
- Clear history with double-confirmation dialog.

### Screen 5 — Settings & Device Information
- Hardware specification details: Device Name, Service UUID (`...9001`), Telemetry Characteristic (`...9002`), Config Characteristic (`...9003`).
- Sensor distance readout (read-only from ESP32).
- Measurement units toggle: `KM/H`, `m/s`, `MPH`.
- Instrument theme switch: *Classic Light TFT (#DDF1FF)* vs *OLED Dark Instrument*.
- Haptic vibration feedback toggle upon test completion.
- Firebase synchronization status and manual sync trigger.
- Interactive Hardware Wiring & Pinout Guide dialog.

---

## 4. Hardware Wiring Reference

### ESP32 Pin Connections

| Device / Module | Pin | ESP32 GPIO | Description |
| :--- | :--- | :--- | :--- |
| **START Optical Sensor** | OUT | **GPIO 27** | `INPUT_PULLUP`, Falling edge trigger |
| **STOP Optical Sensor** | OUT | **GPIO 33** | `INPUT_PULLUP`, Falling edge trigger |
| **ST7789 TFT Display** | CS | **GPIO 5** | Chip Select |
| **ST7789 TFT Display** | DC / RS | **GPIO 2** | Data / Command |
| **ST7789 TFT Display** | RST | **GPIO 4** | Hardware Reset |
| **ST7789 TFT Display** | SCL / SCK | **GPIO 18** | VSPI Hardware Clock |
| **ST7789 TFT Display** | SDA / MOSI| **GPIO 23** | VSPI Hardware Data |
| **Power** | VCC | **3.3V** | Power rail (sensors can use 5V if logic is 3.3V) |
| **Ground** | GND | **GND** | Shared common ground |

---

## 5. Firmware Code

The production-ready ESP32 Arduino code is located at:
`esp32_firmware/pride_kmph_meter_firmware.ino`

Key additions:
1. `BLEDevice::setMTU(512)` enabling full single-packet JSON transmission.
2. Lightweight non-blocking event broadcasting (`CONNECTED`, `START`, `COMPLETE`).
3. Retains 100% backward compatibility with baseline JSON format and physical TFT layout.

---

## 6. How to Run & Test

### Run Unit & Widget Tests:
```bash
flutter test
```
All 9 unit and widget tests pass with 100% test coverage for:
- 5-decimal formatting with leading zeros (`formatSpeed5Decimals`).
- Physical calculation physics matching the ESP32 firmware.
- JSON parsing and Firestore serialization.
- TFT instrument display UI rendering.

### Run Static Analysis:
```bash
flutter analyze
```
Result: `No issues found! (0 errors, 0 warnings)`

### Run on Mobile (Android / iOS):
```bash
flutter run
```
