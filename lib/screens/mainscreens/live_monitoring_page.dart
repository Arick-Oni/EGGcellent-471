import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poultry_app/screens/mainscreens/manual_controls_page.dart';
import 'package:poultry_app/widgets/navigation.dart';

class LiveMonitoringPage extends StatefulWidget {
  const LiveMonitoringPage({Key? key}) : super(key: key);

  @override
  _LiveMonitoringPageState createState() => _LiveMonitoringPageState();
}

class _LiveMonitoringPageState extends State<LiveMonitoringPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Coop selection
  String selectedCoop = 'coop1'; // Default coop
  List<String> availableCoops = ['coop1', 'coop2', 'coop3']; // Example coops

  // Realtime data
  Map<String, dynamic> environmentData = {
    'temperature': 0.0,
    'humidity': 0.0,
    'light': 0,
    'gas': 0,
    'ammonia': 0.0,
  };

  Map<String, bool> actuatorsData = {
    'fan': false,
    'light': false,
    'feeder': false,
  };

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _loadEnvironmentData();
    _loadActuatorsData();
  }

  void _loadEnvironmentData() {
    // Load environment data from Firestore for selected coop
    _firestore
        .collection('coops')
        .doc(selectedCoop)
        .collection('environment')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        setState(() {
          environmentData = doc.data();
        });
      }
    });
  }

  void _loadActuatorsData() {
    // Load actuator states from Firestore for selected coop
    _firestore
        .collection('coops')
        .doc(selectedCoop)
        .collection('environment')
        .where(FieldPath.documentId, isEqualTo: 'actuators')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        setState(() {
          actuatorsData = {
            'fan': doc['fan'] ?? false,
            'light': doc['light'] ?? false,
            'feeder': doc['feeder'] ?? false,
          };
        });
      }
    });
  }

  void _onCoopChanged(String? newValue) {
    if (newValue != null && newValue != selectedCoop) {
      setState(() {
        selectedCoop = newValue;
      });
      _loadInitialData(); // Reload data for the new coop
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Monitoring Dashboard'),
        backgroundColor: Colors.teal,
        centerTitle: true,
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
                // Modern Coop Selection Card
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
                            Icons.home_work,
                            color: Colors.teal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Select Coop:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.teal.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCoop,
                                onChanged: _onCoopChanged,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.teal,
                                ),
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                items: availableCoops
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.teal,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          value.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Realtime Environment Status',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),

                // Environment Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildEnvironmentCard(
                      title: 'Temperature',
                      value:
                          '${environmentData['temperature']?.toStringAsFixed(1) ?? 'N/A'}°C',
                      icon: Icons.thermostat,
                      color: Colors.red,
                      status: _getTemperatureStatus(
                        environmentData['temperature'] ?? 0,
                      ),
                    ),
                    _buildEnvironmentCard(
                      title: 'Humidity',
                      value:
                          '${environmentData['humidity']?.toStringAsFixed(1) ?? 'N/A'}%',
                      icon: Icons.water_drop,
                      color: Colors.blue,
                      status: _getHumidityStatus(
                        environmentData['humidity'] ?? 0,
                      ),
                    ),
                    _buildEnvironmentCard(
                      title: 'Light',
                      value:
                          '${environmentData['light']?.toString() ?? 'N/A'} lux',
                      icon: Icons.wb_sunny,
                      color: Colors.amber,
                      status: _getLightStatus(environmentData['light'] ?? 0),
                    ),
                    _buildEnvironmentCard(
                      title: 'Gas Level',
                      value:
                          '${environmentData['gas']?.toString() ?? 'N/A'} ppm',
                      icon: Icons.warning,
                      color: Colors.orange,
                      status: _getGasStatus(environmentData['gas'] ?? 0),
                    ),
                    _buildEnvironmentCard(
                      title: 'Ammonia',
                      value:
                          '${environmentData['ammonia']?.toStringAsFixed(1) ?? 'N/A'} ppm',
                      icon: Icons.air,
                      color: Colors.purple,
                      status: _getAmmoniaStatus(
                        environmentData['ammonia'] ?? 0,
                      ),
                    ),
                    _buildSystemStatusCard(),
                  ],
                ),

                const SizedBox(height: 30),

                // System Overview Section
                const Text(
                  'System Overview',
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
                        const Text(
                          'Actuator Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActuatorStatusRow(
                          'Fan',
                          actuatorsData['fan'] ?? false,
                          Icons.wind_power,
                          Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        _buildActuatorStatusRow(
                          'Light',
                          actuatorsData['light'] ?? false,
                          Icons.lightbulb,
                          Colors.yellow,
                        ),
                        const SizedBox(height: 8),
                        _buildActuatorStatusRow(
                          'Feeder',
                          actuatorsData['feeder'] ?? false,
                          Icons.restaurant,
                          Colors.green,
                        ),
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
                                NextScreen(
                                    context,
                                    ManualControlsPage(
                                        selectedCoop: selectedCoop));
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
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 10,
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

  Widget _buildSystemStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.green.withOpacity(0.1),
              Colors.green.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 32, color: Colors.green),
            const SizedBox(height: 8),
            const Text(
              'System',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Online',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Healthy',
                style: TextStyle(
                  fontSize: 10,
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
        Icon(icon, color: isActive ? color : Colors.grey),
        const SizedBox(width: 8),
        Text(name, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? color : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isActive ? 'ON' : 'OFF',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
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
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTemperatureStatus(double temp) {
    if (temp < 18) return 'Cold';
    if (temp > 30) return 'Hot';
    return 'Optimal';
  }

  String _getHumidityStatus(double humidity) {
    if (humidity < 30) return 'Low';
    if (humidity > 70) return 'High';
    return 'Good';
  }

  String _getLightStatus(int light) {
    if (light < 100) return 'Dark';
    if (light > 1000) return 'Bright';
    return 'Good';
  }

  String _getGasStatus(int gas) {
    if (gas > 1000) return 'Critical';
    if (gas > 500) return 'Warning';
    return 'Good';
  }

  String _getAmmoniaStatus(double ammonia) {
    if (ammonia > 20) return 'Critical';
    if (ammonia > 10) return 'Warning';
    return 'Good';
  }
}
