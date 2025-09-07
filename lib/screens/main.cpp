  /**
   * Eggcellent 360 - ESP8266 Firebase Handler
   * FIXED VERSION - Optimized sensor distribution
   * ESP8266 handles: DHT11, MQ2, LED lights, WiFi/Firebase
   */


  #include <ESP8266WiFi.h>
  #include <Firebase_ESP_Client.h>
  #include <ArduinoJson.h>
  #include <DHT.h>
  #include "time.h"
  #include <addons/TokenHelper.h>
  #include <vector>


  /************** USER CONFIG **************/
  #define WIFI_SSID "Tarun1"
  #define WIFI_PASSWORD "motafish"
  #define API_KEY "AIzaSyAclkKEMjBb2dQLYpg4OtYyM1a18OGUqUY"
  #define FIREBASE_PROJECT_ID "esp32-e0a40"
  #define USER_EMAIL "incredibleboy71@gmail.com"
  #define USER_PASSWORD "102030"
  /*************** END USER CONFIG ***************/


  // Device ID for this ESP8266
  static const char* DEVICE_ID = "eggcellent360-esp8266";


  // Pin Definitions for ESP8266
  #define DHT_PIN D1
  #define DHT_TYPE DHT11
  #define MQ2_PIN A0       // Only analog sensor on ESP8266


  // LED light pins (moved from Arduino to ESP8266)
  #define LED1_PIN D5
  #define LED2_PIN D6
  #define LED3_PIN D7


  // NTP settings
  const char* NTP_SERVER = "pool.ntp.org";
  const long GMT_OFFSET_SEC = 6 * 3600; // Bangladesh GMT+6
  const int DST_OFFSET_SEC = 0;


  // Timing intervals
  #define SENSOR_READ_INTERVAL 5000     // 5 seconds - slower to reduce conflicts
  #define ACTUATOR_CHECK_INTERVAL 8000   // 8 seconds - read actuator states from Firestore
  #define THRESHOLD_CHECK_INTERVAL 60000 // 60 seconds
  #define ARDUINO_REQUEST_INTERVAL 4000   // 4 seconds - request Arduino sensor data


  unsigned long lastSensorRead = 0;
  unsigned long lastActuatorCheck = 0;
  unsigned long lastThresholdCheck = 0;
  unsigned long lastArduinoRequest = 0;


  /*****************************************/


  // Firebase globals
  FirebaseData fbdo;
  FirebaseAuth auth;
  FirebaseConfig config;


  // DHT sensor
  DHT dht(DHT_PIN, DHT_TYPE);


  // JSON buffer for parsing data
  StaticJsonDocument<512> jsonDoc;


  // Current thresholds (cached from Firestore)
  struct Thresholds {
    float temperature = 32.0;
    float humidityMax = 60.0;
    float humidityMin = 50.0;
    int gasLevel = 400;
    int lightLevel = 300;
    int foodLow = 200;
    int foodHigh = 800;
  };


  Thresholds currentThresholds;


  // Current actuator states
  bool currentFan1State = false;
  bool currentFan2State = false;
  bool currentExhaustState = false;
  bool currentLightState = false;
  bool currentPumpState = false;
  bool currentFeederState = false;
  bool currentWateringState = false;
  bool currentAutoMode = true; // Cache auto mode state


  // Combined sensor data structure (ESP8266 + Arduino sensors)
  struct SensorData {
    // ESP8266 sensors
    float temperature;
    float humidity;
    int gasLevel;
   
    // Arduino sensors (received via serial)
    int lightLevel;
    int foodLevel;
   
    int64_t timestamp;
    bool dataValid;
    bool arduinoDataValid;
  };


  // Arduino sensor data
  struct ArduinoSensorData {
    int lightLevel = 0;
    int foodLevel = 0;
    bool valid = false;
    unsigned long lastUpdate = 0;
  };


  ArduinoSensorData arduinoSensors;


  /* ---------- Forward Declarations ---------- */
  void connectWiFi();
  bool syncTimeNTP(uint8_t maxAttempts = 5);
  void setupFirebase();
  void setupPins();
  int64_t epochMillisNow();
  SensorData readCombinedSensors();
  void requestArduinoSensorData();
  bool uploadSensorDataToFirestore(SensorData data);
  bool updateLatestSensorValues(SensorData data);
  void processAutomaticControls(SensorData data);
  void checkAndUpdateActuators();
  bool readActuatorStatesFromFirestore();
  void sendCommandsToArduino();
  void loadThresholdsFromFirestore();
  void createAlert(String alertType, String message);
  void updateSystemStatus(String status);
  void handleArduinoResponse();
  void createAlertsIfNeeded(SensorData data);
  void initializeFirestoreCollections();
  void updateLEDState(bool state);
  void sendThresholdsToArduino();
  void updateFirebaseThresholds(String thresholdData);
  /* ----------------------------------------- */


  void setup() {
    Serial.begin(115200); // Match Arduino baud rate
    delay(1000);


    Serial.println("Eggcellent 360 ESP8266 Starting...");


    setupPins();
    connectWiFi();
   
    if (!syncTimeNTP()) {
      Serial.println("Time sync failed; proceeding anyway.");
    }
   
    setupFirebase();
   
    // Initialize DHT sensor
    dht.begin();
   
    // Initialize Firestore collections
    initializeFirestoreCollections();
   
    // Load initial thresholds
    loadThresholdsFromFirestore();


    Serial.println("ESP8266 Ready - Monitoring sensors and actuators...");
  }


  void loop() {
    // Handle Arduino responses
    handleArduinoResponse();
   
    // Request sensor data from Arduino
    if (millis() - lastArduinoRequest >= ARDUINO_REQUEST_INTERVAL) {
      requestArduinoSensorData();
      lastArduinoRequest = millis();
    }
   
    // Check actuator commands from Firestore FIRST (before automatic control decisions)
    if (millis() - lastActuatorCheck >= ACTUATOR_CHECK_INTERVAL) {
      checkAndUpdateActuators();
      lastActuatorCheck = millis();
    }
   
    // Read and upload sensor data + run automatic controls (only if in auto mode)
    if (millis() - lastSensorRead >= SENSOR_READ_INTERVAL) {
      SensorData data = readCombinedSensors();
      if (data.dataValid) {
        if (uploadSensorDataToFirestore(data)) {
          updateLatestSensorValues(data);
          // Only run automatic controls if we're not in the middle of an actuator update
          if (millis() - lastActuatorCheck > 2000) { // 2 second buffer
            processAutomaticControls(data);
          }
          Serial.println("Sensor data uploaded and processed");
        }
      }
      lastSensorRead = millis();
    }
   
    // Update thresholds from Firestore
    if (millis() - lastThresholdCheck >= THRESHOLD_CHECK_INTERVAL) {
      loadThresholdsFromFirestore();
      lastThresholdCheck = millis();
    }
   
    // Update system status
    updateSystemStatus("online");
   
    // Keep Firebase connection alive
    if (Firebase.ready()) {
      // Firebase is ready for operations
    }


    delay(100);
  }


  /* ================= Helper Implementations ================= */


  void setupPins() {
    // Setup LED pins (now controlled by ESP8266)
    pinMode(LED1_PIN, OUTPUT);
    pinMode(LED2_PIN, OUTPUT);
    pinMode(LED3_PIN, OUTPUT);
   
    // Initialize all LEDs to OFF
    digitalWrite(LED1_PIN, LOW);
    digitalWrite(LED2_PIN, LOW);
    digitalWrite(LED3_PIN, LOW);
   
    Serial.println("ESP8266 GPIO pins initialized");
  }


  void connectWiFi() {
    Serial.print("Connecting to Wi-Fi");
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);


    unsigned long start = millis();
    while (WiFi.status() != WL_CONNECTED) {
      Serial.print(".");
      delay(500);
      if (millis() - start > 30000) {
        Serial.println("\nWiFi timeout, restarting...");
        ESP.restart();
      }
    }


    Serial.println();
    Serial.print("Connected with IP: ");
    Serial.println(WiFi.localIP());
  }


  bool syncTimeNTP(uint8_t maxAttempts) {
    configTime(GMT_OFFSET_SEC, DST_OFFSET_SEC, NTP_SERVER);
    Serial.print("Syncing time");


    time_t now = time(nullptr);
    uint8_t attempts = 0;


    while (now < 8 * 3600 * 2 && attempts < maxAttempts) {
      delay(1000);
      Serial.print(".");
      now = time(nullptr);
      attempts++;
    }


    if (now > 8 * 3600 * 2) {
      Serial.println("\nTime synced successfully");
      return true;
    } else {
      Serial.println("\nTime sync failed");
      return false;
    }
  }


  void setupFirebase() {
    config.api_key = API_KEY;
    auth.user.email = USER_EMAIL;
    auth.user.password = USER_PASSWORD;
    config.token_status_callback = tokenStatusCallback;


    Firebase.reconnectNetwork(true);


    // Configure buffer sizes for ESP8266
    fbdo.setBSSLBufferSize(2048, 512);
    fbdo.setResponseSize(2048);


    Firebase.begin(&config, &auth);
    Serial.println("Firebase initialized");
  }


  void initializeFirestoreCollections() {
    if (!Firebase.ready()) {
      Serial.println("Firebase not ready for initialization");
      return;
    }


    Serial.println("Initializing Firestore collections...");


    // Initialize thresholds document with proper Firestore format
    FirebaseJson thresholdsContent;
    thresholdsContent.set("fields/temperature/doubleValue", currentThresholds.temperature);
    thresholdsContent.set("fields/humidity_max/doubleValue", currentThresholds.humidityMax);
    thresholdsContent.set("fields/humidity_min/doubleValue", currentThresholds.humidityMin);
    thresholdsContent.set("fields/gas_level/integerValue", String(currentThresholds.gasLevel));
    thresholdsContent.set("fields/light_level/integerValue", String(currentThresholds.lightLevel));
    thresholdsContent.set("fields/food_low/integerValue", String(currentThresholds.foodLow));
    thresholdsContent.set("fields/food_high/integerValue", String(currentThresholds.foodHigh));
   
    if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", "eggcellent360/thresholds", thresholdsContent.raw(), "")) {
      Serial.println("Thresholds document initialized");
    } else {
      Serial.print("Thresholds init failed: ");
      Serial.println(fbdo.errorReason());
    }
   
    // Initialize actuator states document with proper Firestore format
    FirebaseJson actuatorsContent;
    actuatorsContent.set("fields/fan1/booleanValue", false);
    actuatorsContent.set("fields/fan2/booleanValue", false);
    actuatorsContent.set("fields/exhaust_fan/booleanValue", false);
    actuatorsContent.set("fields/lights/booleanValue", false);
    actuatorsContent.set("fields/water_pump/booleanValue", false);
    actuatorsContent.set("fields/feeder/booleanValue", false);
    actuatorsContent.set("fields/watering_active/booleanValue", false);
    actuatorsContent.set("fields/auto_mode/booleanValue", true);
   
    if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", "eggcellent360/actuators", actuatorsContent.raw(), "")) {
      Serial.println("Actuators document initialized");
    } else {
      Serial.print("Actuators init failed: ");
      Serial.println(fbdo.errorReason());
    }
  }


  int64_t epochMillisNow() {
    time_t nowSec = time(nullptr);
    return (int64_t)nowSec * 1000LL + (int64_t)(millis() % 1000);
  }


  void requestArduinoSensorData() {
    // Send request to Arduino for sensor data
    Serial.println("REQ:SENSORS");
  }


  SensorData readCombinedSensors() {
    SensorData data;
   
    // Read ESP8266 sensors
    data.humidity = dht.readHumidity();
    data.temperature = dht.readTemperature();
    data.gasLevel = analogRead(MQ2_PIN);
   
    // Get Arduino sensor data
    data.lightLevel = arduinoSensors.lightLevel;
    data.foodLevel = arduinoSensors.foodLevel;
   
    data.timestamp = epochMillisNow();
    data.dataValid = !isnan(data.humidity) && !isnan(data.temperature);
    data.arduinoDataValid = arduinoSensors.valid && (millis() - arduinoSensors.lastUpdate < 10000);
   
    if (data.dataValid) {
      Serial.println("=== Combined Sensor Readings ===");
      Serial.println("ESP8266 - Temperature: " + String(data.temperature) + "°C");
      Serial.println("ESP8266 - Humidity: " + String(data.humidity) + "%");
      Serial.println("ESP8266 - Gas Level: " + String(data.gasLevel));
      Serial.println("Arduino - Light Level: " + String(data.lightLevel));
      Serial.println("Arduino - Food Level: " + String(data.foodLevel));
      Serial.println("Arduino Data Valid: " + String(data.arduinoDataValid ? "Yes" : "No"));
    } else {
      Serial.println("Invalid ESP8266 sensor data detected!");
    }
   
    return data;
  }


  void handleArduinoResponse() {
    if (Serial.available()) {
      String response = Serial.readStringUntil('\n');
      response.trim();
     
      if (response.startsWith("SENSORS:")) {
        // Parse Arduino sensor data
        // Format: SENSORS:LIGHT:500,FOOD:300
        String sensorData = response.substring(8);
       
        int lightPos = sensorData.indexOf("LIGHT:");
        int foodPos = sensorData.indexOf("FOOD:");
       
        if (lightPos >= 0 && foodPos >= 0) {
          // Extract light level
          int lightEnd = sensorData.indexOf(",", lightPos);
          if (lightEnd > lightPos) {
            String lightStr = sensorData.substring(lightPos + 6, lightEnd);
            arduinoSensors.lightLevel = lightStr.toInt();
          }
         
          // Extract food level
          String foodStr = sensorData.substring(foodPos + 5);
          int foodEnd = foodStr.indexOf(",");
          if (foodEnd > 0) {
            foodStr = foodStr.substring(0, foodEnd);
          }
          arduinoSensors.foodLevel = foodStr.toInt();
         
          arduinoSensors.valid = true;
          arduinoSensors.lastUpdate = millis();
         
          Serial.println("Arduino sensors updated: Light=" + String(arduinoSensors.lightLevel) +
                        ", Food=" + String(arduinoSensors.foodLevel));
        }
      }
      else if (response.startsWith("THRESHOLDS:")) {
        // Arduino is sending updated thresholds - update Firebase
        String thresholdData = response.substring(11);
        updateFirebaseThresholds(thresholdData);
      }
      else if (response.startsWith("STATUS:")) {
        // Handle Arduino status (water levels, actuator states, etc.)
        String statusData = response.substring(7);
       
        // Create proper Firestore document format for Arduino status
        FirebaseJson content;
        content.set("fields/raw_status/stringValue", statusData);
        content.set("fields/timestamp/integerValue", String(epochMillisNow()));
        content.set("fields/connection/stringValue", "active");
       
        // Parse individual actuator states for better monitoring
        if (statusData.indexOf("F1:1") >= 0) content.set("fields/fan1_active/booleanValue", true);
        else if (statusData.indexOf("F1:0") >= 0) content.set("fields/fan1_active/booleanValue", false);
       
        if (statusData.indexOf("F2:1") >= 0) content.set("fields/fan2_active/booleanValue", true);
        else if (statusData.indexOf("F2:0") >= 0) content.set("fields/fan2_active/booleanValue", false);
       
        if (statusData.indexOf("EX:1") >= 0) content.set("fields/exhaust_active/booleanValue", true);
        else if (statusData.indexOf("EX:0") >= 0) content.set("fields/exhaust_active/booleanValue", false);
       
        if (statusData.indexOf("PUMP:1") >= 0) content.set("fields/pump_active/booleanValue", true);
        else if (statusData.indexOf("PUMP:0") >= 0) content.set("fields/pump_active/booleanValue", false);
       
        if (statusData.indexOf("WATER:1") >= 0) content.set("fields/watering_active/booleanValue", true);
        else if (statusData.indexOf("WATER:0") >= 0) content.set("fields/watering_active/booleanValue", false);
       
        // Extract water tank level (0=EMPTY, 1=MEDIUM, 2=FULL)
        int tankPos = statusData.indexOf("TANK:");
        if (tankPos >= 0) {
          String tankLevel = statusData.substring(tankPos + 5, tankPos + 6);
          content.set("fields/water_tank_level/integerValue", tankLevel);
        }
       
        if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", "eggcellent360/arduino_status", content.raw(), "")) {
          Serial.println("Arduino status processed: " + statusData);
        } else {
          Serial.print("Arduino status update failed: ");
          Serial.println(fbdo.errorReason());
        }
      }
    }
  }


  void updateFirebaseThresholds(String thresholdData) {
    if (!Firebase.ready()) {
      Serial.println("Firebase not ready for threshold update");
      return;
    }
   
    // Parse threshold data from Arduino
    // Expected format: "TEMP:32.5,HUM_MAX:60.0,HUM_MIN:50.0,GAS:400,LIGHT:300,FOOD_LOW:200,FOOD_HIGH:800"
    FirebaseJson content;
   
    // Parse each threshold value
    if (thresholdData.indexOf("TEMP:") >= 0) {
      int start = thresholdData.indexOf("TEMP:") + 5;
      int end = thresholdData.indexOf(",", start);
      if (end < 0) end = thresholdData.length();
      String tempStr = thresholdData.substring(start, end);
      content.set("fields/temperature/doubleValue", tempStr.toFloat());
    }
   
    if (thresholdData.indexOf("HUM_MAX:") >= 0) {
      int start = thresholdData.indexOf("HUM_MAX:") + 8;
      int end = thresholdData.indexOf(",", start);
      if (end < 0) end = thresholdData.length();
      String humMaxStr = thresholdData.substring(start, end);
      content.set("fields/humidity_max/doubleValue", humMaxStr.toFloat());
    }
   
    if (thresholdData.indexOf("HUM_MIN:") >= 0) {
      int start = thresholdData.indexOf("HUM_MIN:") + 8;
      int end = thresholdData.indexOf(",", start);
      if (end < 0) end = thresholdData.length();
      String humMinStr = thresholdData.substring(start, end);
      content.set("fields/humidity_min/doubleValue", humMinStr.toFloat());
    }
   
    if (thresholdData.indexOf("GAS:") >= 0) {
      int start = thresholdData.indexOf("GAS:") + 4;
      int end = thresholdData.indexOf(",", start);
      if (end < 0) end = thresholdData.length();
      String gasStr = thresholdData.substring(start, end);
      content.set("fields/gas_level/integerValue", gasStr);
    }
   
    if (thresholdData.indexOf("LIGHT:") >= 0) {
      int start = thresholdData.indexOf("LIGHT:") + 6;
      int end = thresholdData.indexOf(",", start);
      if (end < 0) end = thresholdData.length();
      String lightStr = thresholdData.substring(start, end);
      content.set("fields/light_level/integerValue", lightStr);
    }
   
    if (thresholdData.indexOf("FOOD_LOW:") >= 0) {
      int start = thresholdData.indexOf("FOOD_LOW:") + 9;
      int end = thresholdData.indexOf(",", start);
      if (end < 0) end = thresholdData.length();
      String foodLowStr = thresholdData.substring(start, end);
      content.set("fields/food_low/integerValue", foodLowStr);
    }
   
    if (thresholdData.indexOf("FOOD_HIGH:") >= 0) {
      int start = thresholdData.indexOf("FOOD_HIGH:") + 10;
      int end = thresholdData.indexOf(",", start);
      if (end < 0) end = thresholdData.length();
      String foodHighStr = thresholdData.substring(start, end);
      content.set("fields/food_high/integerValue", foodHighStr);
    }
   
    content.set("fields/last_update/integerValue", String(epochMillisNow()));
    content.set("fields/updated_by/stringValue", "arduino_menu");
   
    if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", "eggcellent360/thresholds", content.raw(), "")) {
      Serial.println("Thresholds updated from Arduino: " + thresholdData);
     
      // Reload local thresholds to sync with updated values
      loadThresholdsFromFirestore();
    } else {
      Serial.print("Failed to update thresholds from Arduino: ");
      Serial.println(fbdo.errorReason());
    }
  }


  void sendCommandsToArduino() {
    // Build command string for Arduino (exclude lights - now handled by ESP8266)
    String commands = "";
    commands += "FAN1:" + String(currentFan1State ? "1" : "0") + ",";
    commands += "FAN2:" + String(currentFan2State ? "1" : "0") + ",";
    commands += "EXHAUST:" + String(currentExhaustState ? "1" : "0") + ",";
    commands += "PUMP:" + String(currentPumpState ? "1" : "0") + ",";
    commands += "FEEDER:" + String(currentFeederState ? "1" : "0") + ",";
    commands += "WATERING:" + String(currentWateringState ? "1" : "0");
   
    // Send to Arduino
    Serial.println("CMD:" + commands);
  }


  void updateLEDState(bool state) {
    // Control LEDs directly from ESP8266
    digitalWrite(LED1_PIN, state ? HIGH : LOW);
    digitalWrite(LED2_PIN, state ? HIGH : LOW);
    digitalWrite(LED3_PIN, state ? HIGH : LOW);
   
    if (state) {
      Serial.println("ESP8266: LEDs turned ON");
    } else {
      Serial.println("ESP8266: LEDs turned OFF");
    }
  }


  void loadThresholdsFromFirestore() {
    if (!Firebase.ready()) return;
   
    String documentPath = "eggcellent360/thresholds";
   
    if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str())) {
      FirebaseJson json;
      json.setJsonData(fbdo.payload());
     
      FirebaseJsonData jsonData;
     
      if (json.get(jsonData, "fields/temperature/doubleValue")) {
        currentThresholds.temperature = jsonData.doubleValue;
      }
      if (json.get(jsonData, "fields/humidity_max/doubleValue")) {
        currentThresholds.humidityMax = jsonData.doubleValue;
      }
      if (json.get(jsonData, "fields/humidity_min/doubleValue")) {
        currentThresholds.humidityMin = jsonData.doubleValue;
      }
      if (json.get(jsonData, "fields/gas_level/integerValue")) {
        currentThresholds.gasLevel = jsonData.intValue;
      }
      if (json.get(jsonData, "fields/light_level/integerValue")) {
        currentThresholds.lightLevel = jsonData.intValue;
      }
      if (json.get(jsonData, "fields/food_low/integerValue")) {
        currentThresholds.foodLow = jsonData.intValue;
      }
      if (json.get(jsonData, "fields/food_high/integerValue")) {
        currentThresholds.foodHigh = jsonData.intValue;
      }
     
      Serial.println("Thresholds updated from Firestore");
     
      // Send updated thresholds to Arduino for local display
      sendThresholdsToArduino();
    } else {
      Serial.print("Failed to load thresholds: ");
      Serial.println(fbdo.errorReason());
    }
  }


  void sendThresholdsToArduino() {
    // Send current thresholds to Arduino for local menu display
    String thresholdCmd = "THRESHOLDS_UPDATE:";
    thresholdCmd += "TEMP:" + String(currentThresholds.temperature, 1) + ",";
    thresholdCmd += "HUM_MAX:" + String(currentThresholds.humidityMax, 1) + ",";
    thresholdCmd += "HUM_MIN:" + String(currentThresholds.humidityMin, 1) + ",";
    thresholdCmd += "GAS:" + String(currentThresholds.gasLevel) + ",";
    thresholdCmd += "LIGHT:" + String(currentThresholds.lightLevel) + ",";
    thresholdCmd += "FOOD_LOW:" + String(currentThresholds.foodLow) + ",";
    thresholdCmd += "FOOD_HIGH:" + String(currentThresholds.foodHigh);
   
    Serial.println(thresholdCmd);
  }


  void updateSystemStatus(String status) {
    static unsigned long lastStatusUpdate = 0;
   
    // Only update every 30 seconds to avoid too many writes
    if (millis() - lastStatusUpdate < 30000) return;
   
    if (!Firebase.ready()) return;
   
    // Create proper Firestore document format
    FirebaseJson content;
    content.set("fields/status/stringValue", status);
    content.set("fields/last_update/integerValue", String(epochMillisNow()));
    content.set("fields/uptime/integerValue", String(millis()));
    content.set("fields/free_heap/integerValue", String(ESP.getFreeHeap()));
    content.set("fields/wifi_rssi/integerValue", String(WiFi.RSSI()));
    content.set("fields/device_id/stringValue", DEVICE_ID);
    content.set("fields/arduino_connection/booleanValue", arduinoSensors.valid && (millis() - arduinoSensors.lastUpdate < 15000));
   
    if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", "eggcellent360/system_status", content.raw(), "")) {
      Serial.println("System status updated");
    } else {
      Serial.print("System status update failed: ");
      Serial.println(fbdo.errorReason());
    }
   
    lastStatusUpdate = millis();
  }


  bool uploadSensorDataToFirestore(SensorData data) {
    if (!Firebase.ready()) {
      Serial.println("Firebase not ready");
      return false;
    }


    // Create document with timestamp as ID in sensor_history collection
    String docId = String(data.timestamp);
    String documentPath = "sensor_history/" + docId;


    // Create proper Firestore document format
    FirebaseJson content;
    content.set("fields/device_id/stringValue", DEVICE_ID);
    content.set("fields/temperature/doubleValue", data.temperature);
    content.set("fields/humidity/doubleValue", data.humidity);
    content.set("fields/gas_level/integerValue", String(data.gasLevel));
    content.set("fields/light_level/integerValue", String(data.lightLevel));
    content.set("fields/food_level/integerValue", String(data.foodLevel));
    content.set("fields/timestamp/integerValue", String(data.timestamp));
    content.set("fields/arduino_data_valid/booleanValue", data.arduinoDataValid);


    Serial.print("Uploading combined sensor data to Firestore...");


    // Use the simpler 4-parameter version with full document path
    if (Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), content.raw())) {
      Serial.println(" Success!");
      return true;
    } else {
      Serial.print(" Failed: ");
      Serial.println(fbdo.errorReason());
      return false;
    }
  }


  bool updateLatestSensorValues(SensorData data) {
    if (!Firebase.ready()) {
      Serial.println("Firebase not ready for latest values update");
      return false;
    }


    Serial.print("Updating latest sensor values...");


    // Create proper Firestore document format
    FirebaseJson content;
    content.set("fields/temperature/doubleValue", data.temperature);
    content.set("fields/humidity/doubleValue", data.humidity);
    content.set("fields/gas_level/integerValue", String(data.gasLevel));
    content.set("fields/light_level/integerValue", String(data.lightLevel));
    content.set("fields/food_level/integerValue", String(data.foodLevel));
    content.set("fields/last_update/integerValue", String(data.timestamp));
    content.set("fields/data_valid/booleanValue", data.dataValid);
    content.set("fields/arduino_data_valid/booleanValue", data.arduinoDataValid);


    if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", "eggcellent360/current_sensors", content.raw(), "")) {
      Serial.println(" Success!");
      return true;
    } else {
      Serial.print(" Failed: ");
      Serial.println(fbdo.errorReason());
      return false;
    }
  }


  void processAutomaticControls(SensorData data) {
    // Only proceed with automatic controls if auto mode is enabled
    if (!currentAutoMode) {
      Serial.println("Auto mode disabled - skipping automatic controls");
      createAlertsIfNeeded(data); // Still create alerts even in manual mode
      return;
    }

    Serial.println("Auto mode enabled - processing automatic controls");
    
    // Get current actuator states from Firestore first to avoid conflicts
    if (!readActuatorStatesFromFirestore()) {
      Serial.println("Failed to read current actuator states for auto control");
      createAlertsIfNeeded(data);
      return;
    }
    
    // Re-check auto mode after reading from Firestore (might have changed)
    if (!currentAutoMode) {
      Serial.println("Auto mode was disabled during read - aborting auto controls");
      createAlertsIfNeeded(data);
      return;
    }
    
    FirebaseJson content;
    bool anyChange = false;

    // Temperature control - only change if threshold is exceeded
    if (data.temperature > currentThresholds.temperature && !currentFan2State) {
      content.set("fields/fan2/booleanValue", true);
      Serial.println("Auto: Fan2 ON - High temperature");
      anyChange = true;
    } else if (data.temperature <= currentThresholds.temperature - 1.0 && currentFan2State) {
      // Add hysteresis - turn off 1 degree below threshold
      content.set("fields/fan2/booleanValue", false);
      Serial.println("Auto: Fan2 OFF - Temperature normalized");
      anyChange = true;
    }

    // Gas control - only change if threshold is exceeded
    if (data.gasLevel > currentThresholds.gasLevel && !currentExhaustState) {
      content.set("fields/exhaust_fan/booleanValue", true);
      Serial.println("Auto: Exhaust fan ON - High gas level");
      anyChange = true;
    } else if (data.gasLevel <= currentThresholds.gasLevel - 50 && currentExhaustState) {
      // Add hysteresis - turn off 50 points below threshold
      content.set("fields/exhaust_fan/booleanValue", false);
      Serial.println("Auto: Exhaust fan OFF - Gas level normalized");
      anyChange = true;
    }

    // Light control (only if Arduino data is valid) - only change if threshold is not met
    if (data.arduinoDataValid) {
      if (data.lightLevel < currentThresholds.lightLevel && !currentLightState) {
        content.set("fields/lights/booleanValue", true);
        Serial.println("Auto: Lights ON - Low ambient light");
        anyChange = true;
      } else if (data.lightLevel >= currentThresholds.lightLevel + 50 && currentLightState) {
        // Add hysteresis - turn off 50 points above threshold
        content.set("fields/lights/booleanValue", false);
        Serial.println("Auto: Lights OFF - Ambient light sufficient");
        anyChange = true;
      }
    }

    // Food level control (only if Arduino data is valid)
    if (data.arduinoDataValid) {
      if (data.foodLevel < currentThresholds.foodLow && !currentFeederState) {
        content.set("fields/feeder/booleanValue", true);
        Serial.println("Auto: Feeder ON - Low food level");
        anyChange = true;
      } else if (data.foodLevel > currentThresholds.foodHigh && currentFeederState) {
        content.set("fields/feeder/booleanValue", false);
        Serial.println("Auto: Feeder OFF - Food level sufficient");
        anyChange = true;
      }
    }

    // Humidity control - only change if thresholds are exceeded
    if (data.humidity > currentThresholds.humidityMax && !currentFan1State) {
      content.set("fields/fan1/booleanValue", true);
      Serial.println("Auto: Fan1 ON - High humidity");
      anyChange = true;
    } else if (data.humidity < currentThresholds.humidityMin && currentFan1State) {
      content.set("fields/fan1/booleanValue", false);
      Serial.println("Auto: Fan1 OFF - Low humidity");
      anyChange = true;
    } else if (data.humidity <= currentThresholds.humidityMax - 5.0 && currentFan1State && data.humidity > currentThresholds.humidityMin) {
      // Add hysteresis for humidity - turn off 5% below max threshold
      content.set("fields/fan1/booleanValue", false);
      Serial.println("Auto: Fan1 OFF - Humidity normalized");
      anyChange = true;
    }

    if (anyChange) {
      // Get the complete current document to avoid overwriting other fields
      String documentPath = "eggcellent360/actuators";
      
      if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str())) {
        FirebaseJson currentDoc;
        currentDoc.setJsonData(fbdo.payload());
        
        FirebaseJsonData jsonData;
        FirebaseJson completeContent;
        
        // Copy all existing fields
        if (currentDoc.get(jsonData, "fields")) {
          completeContent.set("fields", jsonData.jsonObject);
        }
        
        // Update only the changed actuator fields
        FirebaseJsonData contentData;
        FirebaseJson *fieldsObj = completeContent.getJsonObjectPtr("fields");
        
        // Apply our changes to the complete document
        if (content.get(contentData, "fields/fan1/booleanValue")) {
          fieldsObj->set("fan1/booleanValue", contentData.boolValue);
        }
        if (content.get(contentData, "fields/fan2/booleanValue")) {
          fieldsObj->set("fan2/booleanValue", contentData.boolValue);
        }
        if (content.get(contentData, "fields/exhaust_fan/booleanValue")) {
          fieldsObj->set("exhaust_fan/booleanValue", contentData.boolValue);
        }
        if (content.get(contentData, "fields/lights/booleanValue")) {
          fieldsObj->set("lights/booleanValue", contentData.boolValue);
        }
        if (content.get(contentData, "fields/feeder/booleanValue")) {
          fieldsObj->set("feeder/booleanValue", contentData.boolValue);
        }
        
        // Update timestamp
        fieldsObj->set("last_update/integerValue", String(data.timestamp));
        fieldsObj->set("updated_by/stringValue", "auto_control");
        
        // Write the complete document back
        if (Firebase.Firestore.patchDocument(&fbdo, FIREBASE_PROJECT_ID, "", "eggcellent360/actuators", completeContent.raw(), "")) {
          Serial.println("Automatic controls updated successfully");
        } else {
          Serial.print("Auto control update failed: ");
          Serial.println(fbdo.errorReason());
        }
      } else {
        Serial.print("Failed to read current document for auto update: ");
        Serial.println(fbdo.errorReason());
      }
    }

    // Create alerts for critical conditions
    createAlertsIfNeeded(data);
  }


  void createAlertsIfNeeded(SensorData data) {
    if (data.temperature > currentThresholds.temperature + 3) {
      createAlert("high_temperature", "Temperature critically high: " + String(data.temperature) + "°C");
    }
   
    if (data.gasLevel > currentThresholds.gasLevel + 100) {
      createAlert("high_gas", "Gas level critically high: " + String(data.gasLevel));
    }
   
    if (data.arduinoDataValid && data.foodLevel < currentThresholds.foodLow - 50) {
      createAlert("very_low_food", "Food level critically low: " + String(data.foodLevel));
    }
   
    if (!data.arduinoDataValid) {
      createAlert("arduino_communication", "Arduino communication lost - sensor data unavailable");
    }
  }


  void createAlert(String alertType, String message) {
    if (!Firebase.ready()) return;
   
    String docPath = "alerts/" + alertType + "_" + String(millis());
   
    // Create proper Firestore document format
    FirebaseJson content;
    content.set("fields/type/stringValue", alertType);
    content.set("fields/message/stringValue", message);
    content.set("fields/timestamp/integerValue", String(epochMillisNow()));
    content.set("fields/resolved/booleanValue", false);
    content.set("fields/severity/stringValue", "high");
   
    if (Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "", docPath.c_str(), content.raw())) {
      Serial.println("Alert created: " + alertType);
    } else {
      Serial.print("Alert creation failed: ");
      Serial.println(fbdo.errorReason());
    }
  }


  void checkAndUpdateActuators() {
    if (readActuatorStatesFromFirestore()) {
      sendCommandsToArduino();
      updateLEDState(currentLightState); // Update ESP8266 LEDs
    }
  }


  bool readActuatorStatesFromFirestore() {
    if (!Firebase.ready()) {
      Serial.println("Firebase not ready for actuator read");
      return false;
    }


    String documentPath = "eggcellent360/actuators";
   
    if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str())) {
      FirebaseJson json;
      json.setJsonData(fbdo.payload());
     
      FirebaseJsonData jsonData;
     
      // Extract all actuator states
      bool fan1State = false, fan2State = false, exhaustState = false;
      bool lightState = false, pumpState = false, feederState = false, wateringState = false;
      bool autoMode = true; // default to true
     
      if (json.get(jsonData, "fields/fan1/booleanValue")) {
        fan1State = jsonData.boolValue;
      }
      if (json.get(jsonData, "fields/fan2/booleanValue")) {
        fan2State = jsonData.boolValue;
      }
      if (json.get(jsonData, "fields/exhaust_fan/booleanValue")) {
        exhaustState = jsonData.boolValue;
      }
      if (json.get(jsonData, "fields/lights/booleanValue")) {
        lightState = jsonData.boolValue;
      }
      if (json.get(jsonData, "fields/water_pump/booleanValue")) {
        pumpState = jsonData.boolValue;
      }
      if (json.get(jsonData, "fields/feeder/booleanValue")) {
        feederState = jsonData.boolValue;
      }
      if (json.get(jsonData, "fields/watering_active/booleanValue")) {
        wateringState = jsonData.boolValue;
      }
      if (json.get(jsonData, "fields/auto_mode/booleanValue")) {
        autoMode = jsonData.boolValue;
      }
     
      // Update current states only if they changed
      bool statesChanged = false;
     
      if (currentFan1State != fan1State) {
        currentFan1State = fan1State;
        statesChanged = true;
        Serial.println("Fan1 state changed: " + String(fan1State ? "ON" : "OFF"));
      }
     
      if (currentFan2State != fan2State) {
        currentFan2State = fan2State;
        statesChanged = true;
        Serial.println("Fan2 state changed: " + String(fan2State ? "ON" : "OFF"));
      }
     
      if (currentExhaustState != exhaustState) {
        currentExhaustState = exhaustState;
        statesChanged = true;
        Serial.println("Exhaust fan state changed: " + String(exhaustState ? "ON" : "OFF"));
      }
     
      if (currentLightState != lightState) {
        currentLightState = lightState;
        statesChanged = true;
        Serial.println("Light state changed: " + String(lightState ? "ON" : "OFF"));
      }
     
      if (currentPumpState != pumpState) {
        currentPumpState = pumpState;
        statesChanged = true;
        Serial.println("Pump state changed: " + String(pumpState ? "ON" : "OFF"));
      }
     
      if (currentFeederState != feederState) {
        currentFeederState = feederState;
        statesChanged = true;
        Serial.println("Feeder state changed: " + String(feederState ? "ON" : "OFF"));
      }
     
      if (currentWateringState != wateringState) {
        currentWateringState = wateringState;
        statesChanged = true;
        Serial.println("Watering state changed: " + String(wateringState ? "ON" : "OFF"));
      }

      if (currentAutoMode != autoMode) {
        currentAutoMode = autoMode;
        statesChanged = true;
        Serial.println("Auto mode changed: " + String(autoMode ? "ENABLED" : "DISABLED"));
      }
     
      if (statesChanged) {
        Serial.println("Actuator states updated from Firestore");
      }
     
      return true;
    } else {
      Serial.print("Failed to read actuators: ");
      Serial.println(fbdo.errorReason());
      return false;
    }
  }

