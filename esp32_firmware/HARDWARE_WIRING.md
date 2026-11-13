# Hardware Wiring & Technical Reference

## 1. System Overview
The **Pride KMPH Meter** system calculates projectile or moving object velocity over a fixed reference distance ($D = 50.0\text{ mm}$ default) using microsecond hardware timer interrupts (`micros()`) on an ESP32 microcontroller, presenting readings simultaneously on a local ST7789 2.0" 240×320 IPS display and streaming real-time measurements over secured Bluetooth Low Energy (BLE) to this Flutter application.

---

## 2. ESP32 Pinout & Connection Map

### A. Sensors (Optical / IR Beam / Micro-switch)
Both sensors are configured with `INPUT_PULLUP` and trigger on `FALLING` edge when the beam is broken.

| Sensor Pin | ESP32 GPIO | Interrupt Mode | Logic Description |
| :--- | :--- | :--- | :--- |
| **START Sensor OUT** | **GPIO 27** | `FALLING` | Object crosses 1st gate -> captures $T_{\text{start}} = \mu s$ |
| **STOP Sensor OUT** | **GPIO 33** | `FALLING` | Object crosses 2nd gate -> captures $\Delta T = \mu s - T_{\text{start}}$ |
| **Sensor VCC** | **3.3V or 5V** | - | Power according to sensor specs |
| **Sensor GND** | **GND** | - | Common ground with ESP32 |

> **Wiring Note:** Ensure sensors share a common ground (GND) with the ESP32. If using 5V optical sensors (such as LM393 IR break-beam modules), verify their output logic level does not exceed 3.3V, or use a 1kΩ / 2kΩ resistive voltage divider on the output lines.

---

### B. ST7789 240×320 IPS Display (SPI Interface)
The firmware utilizes the hardware VSPI bus on the ESP32:

| ST7789 Pin Label | ESP32 GPIO Pin | Function |
| :--- | :--- | :--- |
| **GND** | **GND** | Power Ground |
| **VCC** | **3.3V** | Power Supply (+3.3V DC) |
| **SCL / SCK** | **GPIO 18** | VSPI Clock (SCK) |
| **SDA / MOSI** | **GPIO 23** | VSPI Data Out (MOSI) |
| **RES / RST** | **GPIO 4** | Hardware Display Reset (`TFT_RST`) |
| **DC / RS** | **GPIO 2** | Data / Command Select (`TFT_DC`) |
| **CS** | **GPIO 5** | Chip Select (`TFT_CS`) |
| **BLK / LED** | **3.3V** (or GPIO) | Backlight LED (+3.3V or 100Ω to 3.3V) |

---

## 3. Speed Calculation Physics

$$\text{Speed (km/h)} = \frac{\text{Distance (mm)} \times 3600}{\text{Elapsed Time } (\mu s)}$$

### Derivation:
- Distance in meters: $d = D_{\text{mm}} \times 10^{-3}\text{ m} = D_{\text{mm}} \times 10^{-6}\text{ km}$
- Time in hours: $t = T_{\mu s} \times 10^{-6}\text{ s} = \frac{T_{\mu s}}{3.6 \times 10^{9}}\text{ hr}$
- Speed:
$$v = \frac{d}{t} = \frac{D_{\text{mm}} \times 10^{-6}}{\frac{T_{\mu s}}{3.6 \times 10^{9}}} = \frac{D_{\text{mm}} \times 3600}{T_{\mu s}}\text{ km/h}$$

For $D = 50.0\text{ mm}$ and $\Delta T = 133856\ \mu s$:
$$v = \frac{50.0 \times 3600}{133856} = \frac{180000}{133856} \approx 1.34473\text{ km/h}$$

---

## 4. Bluetooth Low Energy (BLE) Specification

- **Advertised Device Name**: `Pride_KMPH_Meter`
- **Primary Service UUID**: `12345678-1234-1234-1234-123456789001`
- **Measurement Characteristic UUID**: `12345678-1234-1234-1234-123456789002` (Properties: `READ`, `NOTIFY`)
- **Remote Config Characteristic UUID**: `12345678-1234-1234-1234-123456789003` (Properties: `READ`, `WRITE`)
- **Passkey**: `123456` (6-digit numeric passkey)
- **Security Mode**: MITM Protection, Secure Connections, Display-Only Passkey

### JSON Notification Payloads:

1. **Connection Acknowledgement (`CONNECTED`)**:
```json
{
  "test_no": 0,
  "current_speed_kmph": 0.00000,
  "previous_speed_kmph": 0.00000,
  "distance_mm": 50.00,
  "time_us": 0,
  "status": "CONNECTED"
}
```

2. **Completed Test (`COMPLETE`)**:
```json
{
  "test_no": 1,
  "current_speed_kmph": 1.34473,
  "previous_speed_kmph": 2.21500,
  "distance_mm": 50.00,
  "time_us": 133856,
  "status": "COMPLETE"
}
```

3. **Sensor Start Triggered (`START`)**:
```json
{
  "test_no": 1,
  "current_speed_kmph": 0.00000,
  "previous_speed_kmph": 1.34473,
  "distance_mm": 50.00,
  "time_us": 0,
  "status": "START"
}
```
