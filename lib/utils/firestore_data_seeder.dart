import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class FirestoreDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Random _random = Random();

  /// Seeds realistic sensor data for the past 7 days
  static Future<void> seedSensorData() async {
    print('🌱 Starting to seed sensor data...');

    final now = DateTime.now();
    final batch = _firestore.batch();

    // Generate data for the past 7 days with varying intervals
    for (int day = 0; day < 7; day++) {
      final dayStart = now.subtract(Duration(days: day));

      // Generate 24-48 readings per day (every 30-60 minutes)
      int readingsPerDay = 24 + _random.nextInt(24);

      for (int reading = 0; reading < readingsPerDay; reading++) {
        final timestamp = dayStart.subtract(Duration(
            minutes: reading * (1440 ~/ readingsPerDay) + _random.nextInt(30)));

        final sensorData = _generateRealisticSensorReading(timestamp, day);

        // Add to sensor_history collection
        final docRef = _firestore.collection('sensor_history').doc();
        batch.set(docRef, sensorData);
      }
    }

    // Commit the batch
    await batch.commit();
    print('✅ Successfully seeded ${7 * 30} sensor readings!');

    // Update current sensors with the latest reading
    await _updateCurrentSensors();
  }

  /// Generates realistic sensor data with daily and seasonal patterns
  static Map<String, dynamic> _generateRealisticSensorReading(
      DateTime timestamp, int daysAgo) {
    final hour = timestamp.hour;
    final dayOfWeek = timestamp.weekday;

    // Base values with realistic ranges for chicken coop environment
    double baseTemp = 28.0; // Ideal chicken coop temperature
    double baseHumidity = 60.0; // Good humidity for chickens
    double baseGas = 350.0; // Normal air quality
    double baseLight = 300.0; // Ambient light
    double baseFood = 400.0; // Food level

    // Daily temperature cycle (cooler at night, warmer during day)
    double tempVariation = 8.0 * sin((hour - 6) * pi / 12); // Peak at 2 PM
    double temperature = baseTemp + tempVariation + _randomVariation(2.0);

    // Humidity inversely related to temperature + weather patterns
    double humidityVariation = -4.0 * sin((hour - 6) * pi / 12);
    double humidity = baseHumidity + humidityVariation + _randomVariation(8.0);

    // Light levels (dark at night, bright during day)
    double lightLevel;
    if (hour >= 6 && hour <= 18) {
      // Daylight hours - varies with cloud cover
      lightLevel = baseLight +
          300.0 * sin((hour - 6) * pi / 12) +
          _randomVariation(100.0);
    } else {
      // Night time - minimal light
      lightLevel = 10.0 + _randomVariation(20.0);
    }

    // Gas levels (slightly higher during feeding times and night)
    double gasLevel = baseGas;
    if (hour == 7 || hour == 17) {
      // Feeding times
      gasLevel += 50.0 + _randomVariation(30.0);
    } else {
      gasLevel += _randomVariation(40.0);
    }

    // Food level decreases throughout the day, refilled at feeding times
    double foodLevel = baseFood;
    if (hour == 7 || hour == 17) {
      // Just after feeding
      foodLevel = 450.0 + _randomVariation(50.0);
    } else {
      // Gradual decrease based on time since last feeding
      double hoursSinceFeeding = hour < 7
          ? (hour + 24 - 17)
          : hour < 17
              ? (hour - 7)
              : (hour - 17);
      foodLevel = 450.0 - (hoursSinceFeeding * 15.0) + _randomVariation(30.0);
    }

    // Weekend variations (less activity)
    if (dayOfWeek == 6 || dayOfWeek == 7) {
      gasLevel -= 20.0;
      foodLevel += 20.0; // Less consumption on weekends
    }

    // Weather events (simulate occasional bad weather)
    if (_random.nextDouble() < 0.1) {
      // 10% chance of weather event
      humidity += 15.0 + _randomVariation(10.0);
      temperature -= 3.0 + _randomVariation(2.0);
      lightLevel *= 0.6; // Cloudy
    }

    // Ensure values stay within realistic bounds
    temperature = temperature.clamp(15.0, 45.0);
    humidity = humidity.clamp(30.0, 95.0);
    gasLevel = gasLevel.clamp(200.0, 800.0);
    lightLevel = lightLevel.clamp(0.0, 1000.0);
    foodLevel = foodLevel.clamp(0.0, 500.0);

    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'temperature': double.parse(temperature.toStringAsFixed(1)),
      'humidity': double.parse(humidity.toStringAsFixed(1)),
      'gas_level': double.parse(gasLevel.toStringAsFixed(0)),
      'light_level': double.parse(lightLevel.toStringAsFixed(0)),
      'food_level': double.parse(foodLevel.toStringAsFixed(0)),
      'arduino_data_valid': _random.nextDouble() > 0.05, // 95% valid data
      'device_id': 'ESP32_COOP_001',
      'location': 'Main Chicken Coop',
      'battery_level': 85 + _random.nextInt(15), // 85-100%
      'signal_strength': -40 + _random.nextInt(30), // -40 to -70 dBm
    };
  }

  /// Updates the current sensors document with the latest reading
  static Future<void> _updateCurrentSensors() async {
    final now = DateTime.now();
    final currentReading = _generateRealisticSensorReading(now, 0);

    // Add some current-specific fields
    currentReading['last_update'] = now.millisecondsSinceEpoch;
    currentReading['data_valid'] = true;
    currentReading['connection_status'] = 'Connected';
    currentReading['uptime_hours'] =
        24 + _random.nextInt(72); // 1-4 days uptime

    await _firestore
        .collection('eggcellent360')
        .doc('current_sensors')
        .set(currentReading);

    print('📊 Updated current sensor readings');
  }

  /// Helper to add random variation to sensor values
  static double _randomVariation(double maxVariation) {
    return ((_random.nextDouble() - 0.5) * 2) * maxVariation;
  }

  /// Seeds data with specific patterns for demonstration
  static Future<void> seedDemoData() async {
    print('🎭 Creating demo data with interesting patterns...');

    final now = DateTime.now();
    final batch = _firestore.batch();

    // Create data for the last 48 hours with clear patterns
    for (int hour = 0; hour < 48; hour++) {
      final timestamp = now.subtract(Duration(hours: hour));

      // Create interesting patterns for demo
      final hourOfDay = timestamp.hour;

      // Temperature: clear daily cycle
      double temp = 28.0 + 6.0 * sin((hourOfDay - 6) * pi / 12);

      // Humidity: inverse to temperature
      double humidity = 65.0 - 10.0 * sin((hourOfDay - 6) * pi / 12);

      // Light: sharp day/night cycle
      double light = hourOfDay >= 6 && hourOfDay <= 18
          ? 200.0 + 400.0 * sin((hourOfDay - 6) * pi / 12)
          : 5.0;

      // Gas: spikes at feeding times
      double gas = 300.0;
      if (hourOfDay == 7 || hourOfDay == 17) {
        gas += 150.0;
      }

      // Food: drops throughout day, refilled at feeding
      double food = 400.0;
      if (hourOfDay >= 7 && hourOfDay < 17) {
        food = 450.0 - ((hourOfDay - 7) * 20.0);
      } else if (hourOfDay >= 17) {
        food = 450.0 - ((hourOfDay - 17) * 15.0);
      }

      // Add some noise but keep patterns clear
      temp += _randomVariation(1.5);
      humidity += _randomVariation(3.0);
      gas += _randomVariation(25.0);
      light += _randomVariation(30.0);
      food += _randomVariation(20.0);

      final sensorData = {
        'timestamp': timestamp.millisecondsSinceEpoch,
        'temperature': double.parse(temp.clamp(20.0, 40.0).toStringAsFixed(1)),
        'humidity': double.parse(humidity.clamp(40.0, 80.0).toStringAsFixed(1)),
        'gas_level': double.parse(gas.clamp(250.0, 600.0).toStringAsFixed(0)),
        'light_level': double.parse(light.clamp(0.0, 800.0).toStringAsFixed(0)),
        'food_level': double.parse(food.clamp(50.0, 500.0).toStringAsFixed(0)),
        'arduino_data_valid': true,
        'device_id': 'ESP32_DEMO_001',
        'location': 'Demo Chicken Coop',
      };

      final docRef = _firestore.collection('sensor_history').doc();
      batch.set(docRef, sensorData);
    }

    await batch.commit();
    await _updateCurrentSensors();

    print('✨ Demo data created with beautiful patterns!');
  }

  /// Clear all existing sensor data (use with caution!)
  static Future<void> clearSensorData() async {
    print('🧹 Clearing existing sensor data...');

    // Clear sensor_history collection
    final historyQuery = await _firestore.collection('sensor_history').get();
    final batch = _firestore.batch();

    for (var doc in historyQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    print('🗑️ Cleared ${historyQuery.docs.length} historical records');
  }
}
