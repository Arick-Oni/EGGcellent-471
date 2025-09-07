import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poultry_app/screens/mainscreens/manual_controls_page.dart';
import 'package:poultry_app/Responsive_helper.dart';

class LiveMonitoringPage extends StatefulWidget {
  const LiveMonitoringPage({Key? key}) : super(key: key);

  @override
  _LiveMonitoringPageState createState() => _LiveMonitoringPageState();
}

class _LiveMonitoringPageState extends State<LiveMonitoringPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Realtime data from ESP8266
  Map<String, dynamic> currentSensors = {
    'temperature': 0.0,
    'humidity': 0.0,
    'gas_level': 0,
    'light_level': 0,
    'food_level': 0,
    'last_update': 0,
    'data_valid': false,
    'arduino_data_valid': false,
  };

  Map<String, dynamic> actuatorsData = {
    'fan1': false,
    'fan2': false,
    'exhaust_fan': false,
    'lights': false,
    'water_pump': false,
    'feeder': false,
    'watering_active': false,
    'auto_mode': true,
  };

  Map<String, dynamic> systemStatus = {
    'status': 'offline',
    'uptime': 0,
    'free_heap': 0,
    'wifi_rssi': 0,
    'arduino_connection': false,
    'last_update': 0,
  };

  Map<String, dynamic> thresholds = {
    'temperature': 32.0,
    'humidity_max': 60.0,
    'humidity_min': 50.0,
    'gas_level': 400,
    'light_level': 300,
    'food_low': 200,
    'food_high': 800,
  };

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _loadCurrentSensors();
    _loadActuatorsData();
    _loadSystemStatus();
    _loadThresholds();
  }

  void _loadCurrentSensors() {
    // Load current sensor data from Firestore - using new simple structure
    _firestore.doc('eggcellent360/current_sensors').snapshots().listen(
        (snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          currentSensors = {
            'temperature': data['temperature'] ?? 0.0,
            'humidity': data['humidity'] ?? 0.0,
            'gas_level': data['gas_level'] ?? 0,
            'light_level': data['light_level'] ?? 0,
            'food_level': data['food_level'] ?? 0,
            'last_update': data['last_update'] ?? 0,
            'data_valid': data['data_valid'] ?? false,
            'arduino_data_valid': data['arduino_data_valid'] ?? false,
          };
        });
      }
    }, onError: (error) {
      print('Error loading current sensors: $error');
    });
  }

  void _loadActuatorsData() {
    // Load actuator states from Firestore - using new simple structure
    _firestore.doc('actuators/latest').snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          // Simple direct field reading matching manual controls structure
          actuatorsData = {
            'fan1': data['fan1'] ?? false,
            'fan2': data['fan2'] ?? false,
            'exhaust_fan': data['exhaust_fan'] ?? false,
            'lights': data['lights'] ?? false,
            'water_pump': data['water_pump'] ?? false,
            'feeder': data['feeder'] ?? false,
            'watering_active': data['watering_active'] ?? false,
            'auto_mode': data['auto_mode'] ?? true,
          };
        });
      }
    }, onError: (error) {
      print('Error loading actuator states: $error');
    });
  }

  void _loadSystemStatus() {
    // Load system status from Firestore - using new simple structure
    _firestore.doc('eggcellent360/system_status').snapshots().listen(
        (snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          systemStatus = {
            'status': data['status'] ?? 'offline',
            'uptime': data['uptime'] ?? 0,
            'free_heap': data['free_heap'] ?? 0,
            'wifi_rssi': data['wifi_rssi'] ?? 0,
            'arduino_connection': data['arduino_connection'] ?? false,
            'last_update': data['last_update'] ?? 0,
          };
        });
      }
    }, onError: (error) {
      print('Error loading system status: $error');
    });
  }

  void _loadThresholds() {
    // Load thresholds from Firestore - using new simple structure
    _firestore.doc('eggcellent360/thresholds').snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          thresholds = {
            'temperature': data['temperature'] ?? 32.0,
            'humidity_max': data['humidity_max'] ?? 60.0,
            'humidity_min': data['humidity_min'] ?? 50.0,
            'gas_level': data['gas_level'] ?? 400,
            'light_level': data['light_level'] ?? 300,
            'food_low': data['food_low'] ?? 200,
            'food_high': data['food_high'] ?? 800,
          };
        });
      }
    }, onError: (error) {
      print('Error loading thresholds: $error');
    });
  }

  String _formatLastUpdate(int timestamp) {
    if (timestamp == 0) return 'Never';

    final lastUpdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eggcellent 360 - Live Monitoring'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device Selection Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.withOpacity(0.1),
                          Colors.teal.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.developer_board,
                            color: Colors.teal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Device: ESP8266',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            Text(
                              'Status: ${systemStatus['status']?.toString().toUpperCase() ?? 'UNKNOWN'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: systemStatus['status'] == 'online'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Last Update:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _formatLastUpdate(
                                  currentSensors['last_update'] ?? 0),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Realtime Sensor Data',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),

                // Environment Cards Grid
                GridView.count(
                  crossAxisCount: ResponsiveHelper.isMobile(context)
                      ? 2
                      : ResponsiveHelper.isTablet(context)
                          ? 3
                          : 6,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildEnvironmentCard(
                      title: 'Temperature',
                      value:
                          '${(currentSensors['temperature'] ?? 0.0).toStringAsFixed(1)}°C',
                      icon: Icons.thermostat,
                      color: Colors.red,
                      status: _getTemperatureStatus(
                        currentSensors['temperature'] ?? 0.0,
                      ),
                      threshold:
                          'Max: ${thresholds['temperature']?.toStringAsFixed(1) ?? 'N/A'}°C',
                    ),
                    _buildEnvironmentCard(
                      title: 'Humidity',
                      value:
                          '${(currentSensors['humidity'] ?? 0.0).toStringAsFixed(1)}%',
                      icon: Icons.water_drop,
                      color: Colors.blue,
                      status: _getHumidityStatus(
                        currentSensors['humidity'] ?? 0.0,
                      ),
                      threshold:
                          '${thresholds['humidity_min']?.toStringAsFixed(0) ?? 'N/A'}-${thresholds['humidity_max']?.toStringAsFixed(0) ?? 'N/A'}%',
                    ),
                    _buildEnvironmentCard(
                      title: 'Gas Level',
                      value:
                          '${currentSensors['gas_level']?.toString() ?? 'N/A'}',
                      icon: Icons.warning,
                      color: Colors.orange,
                      status: _getGasStatus(currentSensors['gas_level'] ?? 0),
                      threshold:
                          'Max: ${thresholds['gas_level']?.toString() ?? 'N/A'}',
                    ),
                    _buildEnvironmentCard(
                      title: 'Light Level',
                      value:
                          '${currentSensors['light_level']?.toString() ?? 'N/A'}',
                      icon: Icons.wb_sunny,
                      color: Colors.amber,
                      status:
                          _getLightStatus(currentSensors['light_level'] ?? 0),
                      threshold:
                          'Min: ${thresholds['light_level']?.toString() ?? 'N/A'}',
                    ),
                    _buildEnvironmentCard(
                      title: 'Food Level',
                      value:
                          '${currentSensors['food_level']?.toString() ?? 'N/A'}',
                      icon: Icons.restaurant,
                      color: Colors.green,
                      status: _getFoodStatus(currentSensors['food_level'] ?? 0),
                      threshold:
                          '${thresholds['food_low']?.toString() ?? 'N/A'}-${thresholds['food_high']?.toString() ?? 'N/A'}',
                    ),
                    _buildSystemStatusCard(),
                  ],
                ),

                const SizedBox(height: 30),

                // Data Validity Indicators
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data Sources Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDataSourceRow(
                          'ESP8266 Sensors',
                          currentSensors['data_valid'] ?? false,
                          'Temperature, Humidity, Gas',
                        ),
                        const SizedBox(height: 8),
                        _buildDataSourceRow(
                          'Arduino Sensors',
                          currentSensors['arduino_data_valid'] ?? false,
                          'Light Level, Food Level',
                        ),
                        const SizedBox(height: 8),
                        _buildDataSourceRow(
                          'Arduino Connection',
                          systemStatus['arduino_connection'] ?? false,
                          'Serial Communication',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // System Overview Section
                const Text(
                  'Actuator Control Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),

                // Actuator Status
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Actuator Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: actuatorsData['auto_mode'] == true
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                actuatorsData['auto_mode'] == true
                                    ? 'AUTO MODE'
                                    : 'MANUAL MODE',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildActuatorStatusRow(
                          'Fan 1 (Humidity)',
                          actuatorsData['fan1'] ?? false,
                          Icons.wind_power,
                          Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        _buildActuatorStatusRow(
                          'Fan 2 (Temperature)',
                          actuatorsData['fan2'] ?? false,
                          Icons.air,
                          Colors.cyan,
                        ),
                        const SizedBox(height: 8),
                        _buildActuatorStatusRow(
                          'Exhaust Fan',
                          actuatorsData['exhaust_fan'] ?? false,
                          Icons.tornado,
                          Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        _buildActuatorStatusRow(
                          'LED Lights (ESP8266)',
                          actuatorsData['lights'] ?? false,
                          Icons.lightbulb,
                          Colors.yellow,
                        ),
                        const SizedBox(height: 8),
                        _buildActuatorStatusRow(
                          'Water Pump',
                          actuatorsData['water_pump'] ?? false,
                          Icons.water,
                          Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        _buildActuatorStatusRow(
                          'Feeder',
                          actuatorsData['feeder'] ?? false,
                          Icons.restaurant,
                          Colors.green,
                        ),
                        const SizedBox(height: 8),
                        _buildActuatorStatusRow(
                          'Watering System',
                          actuatorsData['watering_active'] ?? false,
                          Icons.water_drop,
                          Colors.lightBlue,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // System Info Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSystemInfoRow('Uptime',
                            '${(systemStatus['uptime'] ?? 0) / 1000 / 60}min'),
                        _buildSystemInfoRow('Free Memory',
                            '${systemStatus['free_heap'] ?? 0} bytes'),
                        _buildSystemInfoRow('WiFi Signal',
                            '${systemStatus['wifi_rssi'] ?? 0} dBm'),
                        _buildSystemInfoRow(
                            'Last Update',
                            _formatLastUpdate(
                                systemStatus['last_update'] ?? 0)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Actions
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ManualControlsPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.settings),
                              label: const Text('Manual Controls'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Refresh data
                                setState(() {});
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String status,
    required String threshold,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              threshold,
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusCard() {
    bool isOnline = systemStatus['status'] == 'online';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isOnline
                ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.2)]
                : [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOnline ? Icons.check_circle : Icons.error,
              size: 28,
              color: isOnline ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 8),
            const Text(
              'System',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isOnline ? 'Healthy' : 'Offline',
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActuatorStatusRow(
    String name,
    bool isActive,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: isActive ? color : Colors.grey, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? color : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isActive ? 'ON' : 'OFF',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataSourceRow(String name, bool isActive, String description) {
    return Row(
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.error,
          color: isActive ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isActive ? 'ACTIVE' : 'INACTIVE',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'optimal':
      case 'good':
      case 'healthy':
        return Colors.green;
      case 'warning':
      case 'moderate':
        return Colors.orange;
      case 'critical':
      case 'poor':
      case 'low':
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTemperatureStatus(double temp) {
    double threshold = thresholds['temperature'] ?? 32.0;
    if (temp < threshold - 5) return 'Low';
    if (temp > threshold + 3) return 'Critical';
    if (temp > threshold) return 'High';
    return 'Optimal';
  }

  String _getHumidityStatus(double humidity) {
    double minThreshold = thresholds['humidity_min'] ?? 50.0;
    double maxThreshold = thresholds['humidity_max'] ?? 60.0;

    if (humidity < minThreshold - 10) return 'Critical';
    if (humidity < minThreshold) return 'Low';
    if (humidity > maxThreshold + 10) return 'Critical';
    if (humidity > maxThreshold) return 'High';
    return 'Optimal';
  }

  String _getLightStatus(int light) {
    int threshold = thresholds['light_level'] ?? 300;
    if (light < threshold - 100) return 'Poor';
    if (light < threshold) return 'Low';
    if (light > threshold + 500) return 'High';
    return 'Good';
  }

  String _getGasStatus(int gas) {
    int threshold = thresholds['gas_level'] ?? 400;
    if (gas > threshold + 200) return 'Critical';
    if (gas > threshold) return 'High';
    if (gas > threshold - 100) return 'Warning';
    return 'Good';
  }

  String _getFoodStatus(int food) {
    int lowThreshold = thresholds['food_low'] ?? 200;
    int highThreshold = thresholds['food_high'] ?? 800;

    if (food < lowThreshold - 50) return 'Critical';
    if (food < lowThreshold) return 'Low';
    if (food > highThreshold) return 'High';
    return 'Good';
  }
}
