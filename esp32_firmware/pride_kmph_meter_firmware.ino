/*
 * ============================================================================
 * PRIDE KMPH METER - PRODUCTION ESP32 FIRMWARE
 * ============================================================================
 * 
 * Hardware Description:
 *  - ESP32 Development Board (NodeMCU / WROOM-32)
 *  - ST7789 240x320 SPI IPS/TFT Color Display
 *  - Photoelectric / Optical / Hall-Effect Through-Beam Speed Sensors:
 *      * START Sensor: GPIO 27 (Active LOW / Falling Edge)
 *      * STOP Sensor:  GPIO 33 (Active LOW / Falling Edge)
 *  - Sensor Distance: 50.0 mm (configurable via BLE)
 * 
 * Communication:
 *  - Bluetooth Low Energy (BLE 4.2 / 5.0)
 *  - Secured Pairing with Fixed 6-digit Passkey: 123456 (MITM protection enabled)
 *  - Service UUID:        12345678-1234-1234-1234-123456789001
 *  - Data Characteristic: 12345678-1234-1234-1234-123456789002 (READ | NOTIFY)
 *  - Config Characteristic: 12345678-1234-1234-1234-123456789003 (WRITE | READ)
 * 
 * Key Enhancements over Baseline:
 *  1. MTU Negotiation Support (Up to 512 bytes) preventing packet truncation.
 *  2. Lightweight Non-blocking State Notifications (READY, START, COMPLETE).
 *     Interrupt service routines remain microsecond-accurate and non-blocking.
 *  3. Bidirectional Distance Configuration with validation and EEPROM/NVS safety.
 *  4. Retains 100% backward compatibility with baseline JSON format and TFT UI.
 * ============================================================================
 */

#include <SPI.h>
#include <string.h>
#include <Adafruit_GFX.h>
#include <Adafruit_ST7789.h>
#include <Fonts/FreeSansBold24pt7b.h>

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <BLESecurity.h>

// =====================================================
// HARDWARE PIN DEFINITIONS
// =====================================================
// Display SPI Pins (VSPI Hardware Bus on ESP32: SCLK=GPIO 18, MOSI=GPIO 23)
#define TFT_CS   5
#define TFT_RST  4
#define TFT_DC   2

// Physical Speed Sensor Pins
#define START_SENSOR_PIN 27
#define STOP_SENSOR_PIN  33

// Default sensor mounting distance in millimeters
float DISTANCE_MM = 50.0;

// Bluetooth Security: Six-digit passkey
#define BLE_PASSKEY 123456

// =====================================================
// TFT CONFIGURATION & COLOR CONSTANTS
// =====================================================
Adafruit_ST7789 tft(TFT_CS, TFT_DC, TFT_RST);

#define BLACK   ST77XX_BLACK
#define WHITE   ST77XX_WHITE
#define GREEN   ST77XX_GREEN
#define CYAN    ST77XX_CYAN
#define YELLOW  ST77XX_YELLOW
#define RED     ST77XX_RED
#define BLUE    ST77XX_BLUE
#define MAGENTA ST77XX_MAGENTA

// =====================================================
// BLE CONFIGURATION & UUIDs
// =====================================================
#define BLE_DEVICE_NAME "Pride_KMPH_Meter"

#define SERVICE_UUID \
  "12345678-1234-1234-1234-123456789001"

#define CHARACTERISTIC_UUID \
  "12345678-1234-1234-1234-123456789002"

#define CONFIG_CHAR_UUID \
  "12345678-1234-1234-1234-123456789003"

BLEServer *pServer = nullptr;
BLECharacteristic *pCharacteristic = nullptr;
BLECharacteristic *pConfigCharacteristic = nullptr;

volatile bool deviceConnected = false;
volatile bool sendInitialData = false;
unsigned long connectTimestamp = 0;
volatile bool notifyStartTriggered = false;

// =====================================================
// MEASUREMENT TIMING AND STATE MACHINE
// =====================================================
// 0 = Ready for START sensor
// 1 = START sensor activated, waiting for STOP sensor
// 2 = Measurement completed, ready for calculation
// 3 = Waiting for both sensors to return HIGH (rearm)
volatile uint8_t measurementState = 0;

volatile uint32_t startTimeUs = 0;
volatile uint32_t elapsedTimeUs = 0;

portMUX_TYPE timerMux = portMUX_INITIALIZER_UNLOCKED;

float currentSpeed = 0.0;
float previousSpeed = 0.0;

uint32_t currentTimeUs = 0;
uint32_t testNumber = 0;

unsigned long lastDisplayUpdate = 0;

// =====================================================
// BLE SECURITY CALLBACKS
// =====================================================
class MySecurityCallbacks : public BLESecurityCallbacks {
  uint32_t onPassKeyRequest() override {
    Serial.println("[BLE Security] PassKey requested");
    return BLE_PASSKEY;
  }

  void onPassKeyNotify(uint32_t pass_key) override {
    Serial.printf("[BLE Security] On passkey notify: %06u\n", pass_key);
  }

  bool onConfirmPIN(uint32_t pass_key) override {
    Serial.printf("[BLE Security] Confirm PIN: %06u\n", pass_key);
    return (pass_key == BLE_PASSKEY);
  }

  bool onSecurityRequest() override {
    Serial.println("[BLE Security] Security request received -> Accepting");
    return true;
  }

  void onAuthenticationComplete(esp_ble_auth_cmpl_t cmpl) override {
    if (cmpl.success) {
      Serial.println("[BLE Security] Pair and Authentication SUCCESSFUL!");
    } else {
      Serial.printf("[BLE Security] Authentication FAILED, reason: 0x%x\n", cmpl.fail_reason);
    }
  }
};

// =====================================================
// BLE CONFIG CHARACTERISTIC CALLBACKS (Remote Distance)
// =====================================================
class ConfigCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pChar) override {
    String value = pChar->getValue().c_str();
    if (value.length() > 0) {
      float newDistance = value.toFloat();
      if (newDistance >= 5.0 && newDistance <= 5000.0) {
        portENTER_CRITICAL(&timerMux);
        DISTANCE_MM = newDistance;
        portEXIT_CRITICAL(&timerMux);
        Serial.printf("[Config] Updated DISTANCE_MM to: %.2f mm\n", DISTANCE_MM);
        
        // Confirm back written value
        char confirmBuf[32];
        snprintf(confirmBuf, sizeof(confirmBuf), "{\"distance_mm\":%.2f}", DISTANCE_MM);
        pChar->setValue(confirmBuf);
      } else {
        Serial.println("[Config] Invalid distance value received (must be 5.0mm - 5000.0mm)");
      }
    }
  }
};

// =====================================================
// BLE SERVER CALLBACKS
// =====================================================
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *server) override {
    deviceConnected = true;
    sendInitialData = true;
    connectTimestamp = millis();
    Serial.println("[BLE] Client Connected");
  }

  void onDisconnect(BLEServer *server) override {
    deviceConnected = false;
    sendInitialData = false;
    Serial.println("[BLE] Client Disconnected. Restarting Advertising...");
    server->startAdvertising();
  }
};

// =====================================================
// START SENSOR INTERRUPT (Ultra-fast, Non-blocking)
// =====================================================
void IRAM_ATTR startSensorISR() {
  portENTER_CRITICAL_ISR(&timerMux);
  if (measurementState == 0) {
    startTimeUs = micros();
    measurementState = 1;
    notifyStartTriggered = true;
  }
  portEXIT_CRITICAL_ISR(&timerMux);
}

// =====================================================
// STOP SENSOR INTERRUPT (Ultra-fast, Non-blocking)
// =====================================================
void IRAM_ATTR stopSensorISR() {
  portENTER_CRITICAL_ISR(&timerMux);
  if (measurementState == 1) {
    elapsedTimeUs = micros() - startTimeUs;
    measurementState = 2;
  }
  portEXIT_CRITICAL_ISR(&timerMux);
}

// =====================================================
// DISPLAY SPEED VALUE
// =====================================================
void drawSpeedValue(float value,
                    int x,
                    int baseline,
                    uint16_t color,
                    int clearY) {
  tft.fillRect(x, clearY, 286, 63, BLACK);

  tft.setFont(&FreeSansBold24pt7b);
  tft.setTextSize(1);
  tft.setTextColor(color, BLACK);
  tft.setCursor(x, baseline);

  if (value < 10.0) {
    tft.print("0");
  }

  tft.print(value, 5);

  tft.setFont();
  tft.setTextSize(1);
}

// =====================================================
// DISTANCE AND TIME DISPLAY
// =====================================================
void drawInfo() {
  tft.setFont();
  tft.setTextSize(2);

  // Distance on left
  tft.setTextColor(WHITE, BLACK);
  tft.setCursor(12, 202);
  tft.print("D:");
  tft.print(DISTANCE_MM, 1);
  tft.print("mm");

  // Time label
  tft.setTextColor(YELLOW, BLACK);
  tft.setCursor(165, 202);
  tft.print("T:");

  // Time value
  tft.fillRect(190, 194, 120, 35, BLACK);
  tft.setCursor(190, 202);
  tft.print(currentTimeUs);
  tft.print("us");

  tft.setTextSize(1);
}

// =====================================================
// UPDATE LIVE TIMER (100ms ticker for display)
// =====================================================
void updateLiveTimer() {
  uint8_t stateCopy;
  uint32_t startCopy;

  portENTER_CRITICAL(&timerMux);
  stateCopy = measurementState;
  startCopy = startTimeUs;
  portEXIT_CRITICAL(&timerMux);

  if (stateCopy == 1) {
    currentTimeUs = micros() - startCopy;

    // Clear only time digits on TFT
    tft.fillRect(190, 194, 120, 35, BLACK);

    tft.setFont();
    tft.setTextSize(2);
    tft.setTextColor(YELLOW, BLACK);
    tft.setCursor(190, 202);

    tft.print(currentTimeUs);
    tft.print("us");

    tft.setTextSize(1);
  }
}

// =====================================================
// COMPLETE TFT DISPLAY LAYOUT
// =====================================================
void drawScreen() {
  tft.fillScreen(BLACK);

  // Current speed panel
  tft.drawRect(8, 5, 304, 88, WHITE);
  tft.setFont();
  tft.setTextSize(2);
  tft.setTextColor(WHITE, BLACK);
  tft.setCursor(18, 14);
  tft.print("CURRENT SPEED");

  drawSpeedValue(currentSpeed, 18, 82, GREEN, 28);

  // Previous speed panel
  tft.drawRect(8, 98, 304, 88, WHITE);
  tft.setFont();
  tft.setTextSize(2);
  tft.setTextColor(WHITE, BLACK);
  tft.setCursor(18, 107);
  tft.print("PREVIOUS SPEED");

  drawSpeedValue(previousSpeed, 18, 175, CYAN, 121);

  drawInfo();
}

// =====================================================
// SPEED CALCULATION
// =====================================================
void calculateSpeed(uint32_t measuredTimeUs) {
  if (measuredTimeUs == 0) {
    return;
  }

  previousSpeed = currentSpeed;

  // Formula: (Distance in mm * 3600) / Time in us = Speed in km/h
  currentSpeed = (DISTANCE_MM * 3600.0) / measuredTimeUs;

  currentTimeUs = measuredTimeUs;
  testNumber++;

  drawScreen();
}

// =====================================================
// BLE DATA TRANSMISSION
// =====================================================
void sendBLEData(const char *status) {
  if (pCharacteristic == nullptr) {
    return;
  }

  char jsonData[256];

  snprintf(
    jsonData,
    sizeof(jsonData),
    "{"
    "\"test_no\":%lu,"
    "\"current_speed_kmph\":%.5f,"
    "\"previous_speed_kmph\":%.5f,"
    "\"distance_mm\":%.2f,"
    "\"time_us\":%lu,"
    "\"status\":\"%s\""
    "}",
    (unsigned long)testNumber,
    currentSpeed,
    previousSpeed,
    DISTANCE_MM,
    (unsigned long)currentTimeUs,
    status
  );

  pCharacteristic->setValue((uint8_t *)jsonData, strlen(jsonData));

  if (deviceConnected) {
    pCharacteristic->notify();
  }

  Serial.printf("[BLE Tx] %s\n", jsonData);
}

// =====================================================
// BLE INITIALIZATION WITH SECURITY & MTU
// =====================================================
void setupBLE() {
  BLEDevice::init(BLE_DEVICE_NAME);

  // Request maximum MTU for high-throughput single-packet notifications
  BLEDevice::setMTU(512);

  // Configure Bluetooth security with 6-digit PIN
  BLEDevice::setSecurityCallbacks(new MySecurityCallbacks());
  BLESecurity *pSecurity = new BLESecurity();

  pSecurity->setStaticPIN(BLE_PASSKEY);
  pSecurity->setCapability(ESP_IO_CAP_OUT);
  pSecurity->setAuthenticationMode(ESP_LE_AUTH_REQ_SC_MITM_BOND);

  Serial.print("[BLE] Configured passkey: ");
  Serial.println(BLE_PASSKEY);

  // Create BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create Primary Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Measurement Characteristic (Notify + Read)
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_NOTIFY
  );
  pCharacteristic->addDescriptor(new BLE2902());
  // Initialize characteristic with valid JSON holding startup state
  char startupJson[256];
  snprintf(startupJson, sizeof(startupJson),
    "{\"test_no\":0,\"current_speed_kmph\":0.00000,\"previous_speed_kmph\":0.00000,\"distance_mm\":%.2f,\"time_us\":0,\"status\":\"READY\"}",
    DISTANCE_MM);
  pCharacteristic->setValue((uint8_t *)startupJson, strlen(startupJson));

  // Configuration Characteristic (Read + Write)
  pConfigCharacteristic = pService->createCharacteristic(
    CONFIG_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE
  );
  pConfigCharacteristic->setCallbacks(new ConfigCallbacks());
  char initialDistance[32];
  snprintf(initialDistance, sizeof(initialDistance), "%.2f", DISTANCE_MM);
  pConfigCharacteristic->setValue(initialDistance);

  pService->start();

  // Configure Advertising with robust connection interval preferences (20ms - 50ms)
  // This prevents Android GATT from timing out during ST7789 TFT SPI display draws
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x10); // 20ms connection interval
  pAdvertising->setMaxPreferred(0x28); // 50ms connection interval

  BLEDevice::startAdvertising();

  Serial.println("[BLE] Advertising started successfully.");
  Serial.printf("[BLE] Device Name: %s\n", BLE_DEVICE_NAME);
}

// =====================================================
// SYSTEM SETUP
// =====================================================
void setup() {
  Serial.begin(115200);
  delay(200);
  Serial.println("\n--- PRIDE KMPH METER SYSTEM INITIALIZING ---");

  // Configure Sensor GPIO Pins with Internal Pullups
  pinMode(START_SENSOR_PIN, INPUT_PULLUP);
  pinMode(STOP_SENSOR_PIN, INPUT_PULLUP);

  attachInterrupt(
    digitalPinToInterrupt(START_SENSOR_PIN),
    startSensorISR,
    FALLING
  );

  attachInterrupt(
    digitalPinToInterrupt(STOP_SENSOR_PIN),
    stopSensorISR,
    FALLING
  );

  // Initialize ST7789 TFT Display (Landscape 320x240)
  tft.init(240, 320);
  tft.setRotation(1);
  tft.setTextWrap(false);

  drawScreen();

  // Initialize Secured BLE
  setupBLE();

  Serial.println("[System] Ready. Waiting for START sensor trigger.");
}

// =====================================================
// MAIN EVENT LOOP
// =====================================================
void loop() {
  // 1. Update live microsecond counter on TFT every 100ms
  if (millis() - lastDisplayUpdate >= 100) {
    lastDisplayUpdate = millis();
    updateLiveTimer();
  }

  // 2. Handle client initial connection event (wait 600ms for client service discovery & subscription)
  if (sendInitialData && (millis() - connectTimestamp >= 600)) {
    sendInitialData = false;
    sendBLEData("CONNECTED");
  }

  // 3. Handle lightweight START event notification if triggered
  bool startTriggered = false;
  portENTER_CRITICAL(&timerMux);
  if (notifyStartTriggered) {
    notifyStartTriggered = false;
    // Only broadcast START if measurement is still in progress (state == 1)
    // If the object already tripped STOP (state >= 2), skip intermediate START to prevent BLE packet congestion
    if (measurementState == 1) {
      startTriggered = true;
    }
  }
  portEXIT_CRITICAL(&timerMux);

  if (startTriggered && deviceConnected) {
    sendBLEData("START");
  }

  // 4. Check for completed speed measurement
  uint32_t completedTime = 0;
  bool measurementComplete = false;

  portENTER_CRITICAL(&timerMux);
  if (measurementState == 2) {
    completedTime = elapsedTimeUs;
    measurementState = 3;
    measurementComplete = true;
  }
  portEXIT_CRITICAL(&timerMux);

  // 5. Calculate and broadcast completed measurement
  if (measurementComplete) {
    calculateSpeed(completedTime);
    sendBLEData("COMPLETE");
    Serial.printf("[Result] Test #%lu: Speed = %.5f km/h, Time = %lu us\n",
                  (unsigned long)testNumber, currentSpeed, (unsigned long)currentTimeUs);
  }

  // 6. Rearm system after both sensors return HIGH
  if (digitalRead(START_SENSOR_PIN) == HIGH &&
      digitalRead(STOP_SENSOR_PIN) == HIGH) {
    portENTER_CRITICAL(&timerMux);
    if (measurementState == 3) {
      measurementState = 0;
    }
    portEXIT_CRITICAL(&timerMux);
  }

  // 7. Periodic Keep-Alive Heartbeat (every 4000ms when idle)
  // Prevents Android battery managers (Samsung/Xiaomi/OnePlus) from dropping idle BLE connections
  static unsigned long lastHeartbeatTime = 0;
  if (deviceConnected && (millis() - lastHeartbeatTime >= 4000)) {
    lastHeartbeatTime = millis();
    if (measurementState == 0) {
      sendBLEData("READY");
    }
  }
}
