import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManualControlsPage extends StatefulWidget {
  const ManualControlsPage({Key? key}) : super(key: key);

  @override
  _ManualControlsPageState createState() => _ManualControlsPageState();
}

class _ManualControlsPageState extends State<ManualControlsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // All actuator control states from ESP8266
  Map<String, bool> actuatorStates = {
    'fan1': false, // Humidity control fan
    'fan2': false, // Temperature control fan
    'exhaust_fan': false, // Gas level exhaust fan
    'lights': false, // LED lights (ESP8266 controlled)
    'water_pump': false, // Water pump
    'feeder': false, // Feeder system
    'watering_active': false, // Watering system
    'auto_mode': true, // Auto/Manual mode toggle
  };

  // System status
  Map<String, dynamic> systemStatus = {
    'status': 'offline',
    'arduino_connection': false,
    'device_id': '',
    'uptime': 0,
    'free_heap': 0,
    'wifi_rssi': 0,
  };

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load actuator states from Firestore - simple key-value structure
    _firestore.doc('actuators/latest').snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        print('Raw Firestore actuator data: $data'); // Debug print

        setState(() {
          // Simple direct field reading
          actuatorStates = {
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
        print('Parsed actuator states: $actuatorStates'); // Debug print
      }
    }, onError: (error) {
      print('Error loading actuator states: $error');
    });

    // Load system status from simple path structure
    _firestore.doc('eggcellent360/system_status').snapshots().listen(
        (snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          // Simple direct field reading
          systemStatus = {
            'status': data['status'] ?? 'offline',
            'arduino_connection': data['arduino_connection'] ?? false,
            'device_id': data['device_id'] ?? '',
            'uptime': data['uptime'] ?? 0,
            'free_heap': data['free_heap'] ?? 0,
            'wifi_rssi': data['wifi_rssi'] ?? 0,
          };
        });
        print('System status loaded: $systemStatus');
      }
    }, onError: (error) {
      print('Error loading system status: $error');
    });
  }

  Future<void> _toggleActuator(String actuator, bool currentState) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simple direct field update
      Map<String, dynamic> updateData = {
        actuator: !currentState,
        'last_update': DateTime.now().millisecondsSinceEpoch,
        'updated_by': 'flutter_app'
      };

      print('Updating actuator $actuator to ${!currentState}'); // Debug print
      print('Update data structure: $updateData'); // Debug print

      // Use update() to only update specific fields
      await _firestore.doc('actuators/latest').update(updateData);

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${actuator.replaceAll('_', ' ').toUpperCase()} ${!currentState ? 'ON' : 'OFF'}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update $actuator: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print('Error updating actuator: $e'); // Debug print
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setAllActuators(bool state) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simple direct field updates
      final updateData = {
        'fan1': state,
        'fan2': state,
        'exhaust_fan': state,
        'lights': state,
        'water_pump': state,
        'feeder': state,
        'watering_active': state,
        'auto_mode': false, // Disable auto mode when using manual override
        'last_update': DateTime.now().millisecondsSinceEpoch,
        'updated_by': 'flutter_emergency_override',
      };

      await _firestore.doc('actuators/latest').update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All actuators turned ${state ? 'ON' : 'OFF'}'),
          backgroundColor: state ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update all actuators: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print('Error setting all actuators: $e'); // Debug print
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAutoMode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newAutoModeState = !actuatorStates['auto_mode']!;

      // Simple direct field update
      final updateData = {
        'auto_mode': newAutoModeState,
        'last_update': DateTime.now().millisecondsSinceEpoch,
        'updated_by': 'flutter_mode_toggle',
      };

      await _firestore.doc('actuators/latest').update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Auto mode ${newAutoModeState ? 'ENABLED' : 'DISABLED'}'),
          backgroundColor: newAutoModeState ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to toggle auto mode: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print('Error toggling auto mode: $e'); // Debug print
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSystemOnline = systemStatus['status'] == 'online';
    bool isArduinoConnected = systemStatus['arduino_connection'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Controls - ESP8266'),
        backgroundColor: Colors.orange,
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Status Card
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
                      colors: isSystemOnline
                          ? [
                              Colors.green.withOpacity(0.1),
                              Colors.green.withOpacity(0.2)
                            ]
                          : [
                              Colors.red.withOpacity(0.1),
                              Colors.red.withOpacity(0.2)
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            isSystemOnline ? Icons.check_circle : Icons.error,
                            color: isSystemOnline ? Colors.green : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ESP8266 Status: ${isSystemOnline ? 'ONLINE' : 'OFFLINE'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSystemOnline ? Colors.green : Colors.red,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: actuatorStates['auto_mode'] == true
                                  ? Colors.green
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              actuatorStates['auto_mode'] == true
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            isArduinoConnected ? Icons.link : Icons.link_off,
                            color:
                                isArduinoConnected ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Arduino Connection: ${isArduinoConnected ? 'ACTIVE' : 'DISCONNECTED'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isArduinoConnected
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (isSystemOnline) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Uptime: ${_formatUptime(systemStatus['uptime'])}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              'Free Heap: ${systemStatus['free_heap']} bytes',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'WiFi RSSI: ${systemStatus['wifi_rssi']} dBm',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Auto/Manual Mode Toggle
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: actuatorStates['auto_mode'] == true
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          actuatorStates['auto_mode'] == true
                              ? Icons.auto_mode
                              : Icons.fiber_manual_record,
                          size: 32,
                          color: actuatorStates['auto_mode'] == true
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'System Mode',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              actuatorStates['auto_mode'] == true
                                  ? 'Automatic threshold-based control'
                                  : 'Manual override mode',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: actuatorStates['auto_mode'] ?? true,
                        onChanged:
                            isSystemOnline ? (_) => _toggleAutoMode() : null,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Actuator Controls',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),

              // Automatic Mode Notice
              if (actuatorStates['auto_mode'] ?? true) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_mode, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AUTOMATIC MODE ACTIVE - Individual controls are disabled. '
                          'Switch to Manual Mode above to enable manual control.',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Fan 1 Control (Humidity)
              _buildControlCard(
                icon: Icons.wind_power,
                title: 'Fan 1 (Humidity Control)',
                subtitle: 'ESP8266 → Arduino relay control',
                isOn: actuatorStates['fan1'] ?? false,
                onToggle: () =>
                    _toggleActuator('fan1', actuatorStates['fan1'] ?? false),
                color: Colors.blue,
                enabled:
                    isSystemOnline && !(actuatorStates['auto_mode'] ?? true),
              ),
              const SizedBox(height: 16),

              // Fan 2 Control (Temperature)
              _buildControlCard(
                icon: Icons.air,
                title: 'Fan 2 (Temperature Control)',
                subtitle: 'ESP8266 → Arduino relay control',
                isOn: actuatorStates['fan2'] ?? false,
                onToggle: () =>
                    _toggleActuator('fan2', actuatorStates['fan2'] ?? false),
                color: Colors.cyan,
                enabled:
                    isSystemOnline && !(actuatorStates['auto_mode'] ?? true),
              ),
              const SizedBox(height: 16),

              // Exhaust Fan Control
              _buildControlCard(
                icon: Icons.tornado,
                title: 'Exhaust Fan (Gas Control)',
                subtitle: 'ESP8266 → Arduino relay control',
                isOn: actuatorStates['exhaust_fan'] ?? false,
                onToggle: () => _toggleActuator(
                    'exhaust_fan', actuatorStates['exhaust_fan'] ?? false),
                color: Colors.orange,
                enabled:
                    isSystemOnline && !(actuatorStates['auto_mode'] ?? true),
              ),
              const SizedBox(height: 16),

              // LED Lights Control (ESP8266 direct)
              _buildControlCard(
                icon: Icons.lightbulb,
                title: 'LED Lights',
                subtitle: 'ESP8266 direct GPIO control (D5, D6, D7)',
                isOn: actuatorStates['lights'] ?? false,
                onToggle: () => _toggleActuator(
                    'lights', actuatorStates['lights'] ?? false),
                color: Colors.yellow,
                enabled:
                    isSystemOnline && !(actuatorStates['auto_mode'] ?? true),
              ),
              const SizedBox(height: 16),

              // Water Pump Control
              _buildControlCard(
                icon: Icons.water,
                title: 'Water Pump',
                subtitle: 'ESP8266 → Arduino relay control',
                isOn: actuatorStates['water_pump'] ?? false,
                onToggle: () => _toggleActuator(
                    'water_pump', actuatorStates['water_pump'] ?? false),
                color: Colors.blue,
                enabled: isSystemOnline &&
                    isArduinoConnected &&
                    !(actuatorStates['auto_mode'] ?? true),
              ),
              const SizedBox(height: 16),

              // Feeder Control
              _buildControlCard(
                icon: Icons.restaurant,
                title: 'Automatic Feeder',
                subtitle: 'ESP8266 → Arduino servo/relay control',
                isOn: actuatorStates['feeder'] ?? false,
                onToggle: () => _toggleActuator(
                    'feeder', actuatorStates['feeder'] ?? false),
                color: Colors.green,
                enabled: isSystemOnline &&
                    isArduinoConnected &&
                    !(actuatorStates['auto_mode'] ?? true),
              ),
              const SizedBox(height: 16),

              // Watering System Control
              _buildControlCard(
                icon: Icons.water_drop,
                title: 'Watering System',
                subtitle: 'ESP8266 → Arduino relay control',
                isOn: actuatorStates['watering_active'] ?? false,
                onToggle: () => _toggleActuator('watering_active',
                    actuatorStates['watering_active'] ?? false),
                color: Colors.lightBlue,
                enabled: isSystemOnline &&
                    isArduinoConnected &&
                    !(actuatorStates['auto_mode'] ?? true),
              ),

              const SizedBox(height: 30),

              // Emergency Controls Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text(
                          'Emergency Override Controls',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'WARNING: These controls will override automatic mode and affect all actuators. '
                      'Use only during maintenance or emergency situations.',
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: isSystemOnline &&
                                  !(actuatorStates['auto_mode'] ?? true)
                              ? () => _setAllActuators(true)
                              : null,
                          icon: const Icon(Icons.power_settings_new),
                          label: const Text('ALL ON'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: isSystemOnline &&
                                  !(actuatorStates['auto_mode'] ?? true)
                              ? () => _setAllActuators(false)
                              : null,
                          icon: const Icon(Icons.power_off),
                          label: const Text('ALL OFF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    if (!isSystemOnline) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Emergency controls disabled: ESP8266 is offline',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else if (actuatorStates['auto_mode'] ?? true) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Emergency controls disabled: Switch to Manual Mode to enable',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // System Information
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                      _buildInfoRow('Actuator Collection', 'actuators/latest'),
                      _buildInfoRow('System Status Collection',
                          'eggcellent360/system_status'),
                      _buildInfoRow('Data Format', 'Nested Firestore fields'),
                      _buildInfoRow('ESP8266 Status',
                          isSystemOnline ? 'Online' : 'Offline'),
                      _buildInfoRow('Arduino Connection',
                          isArduinoConnected ? 'Active' : 'Disconnected'),
                      _buildInfoRow(
                          'Control Mode',
                          actuatorStates['auto_mode'] == true
                              ? 'Automatic'
                              : 'Manual'),
                      if (systemStatus['device_id'].toString().isNotEmpty)
                        _buildInfoRow(
                            'Reported Device ID', systemStatus['device_id']),
                      const SizedBox(height: 10),
                      Text(
                        'Note: LED lights are controlled directly by ESP8266 GPIO pins. '
                        'All other actuators are controlled via serial commands to Arduino. '
                        'Data is stored using nested Firestore field structure for compatibility with ESP8266.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isOn,
    required VoidCallback onToggle,
    required Color color,
    bool enabled = true,
  }) {
    // Check if disabled due to automatic mode
    bool isAutoMode = actuatorStates['auto_mode'] ?? true;
    bool isSystemOnline = systemStatus['status'] == 'online';
    bool isArduinoConnected = systemStatus['arduino_connection'] == true;

    String disabledReason = '';
    if (!enabled) {
      if (!isSystemOnline) {
        disabledReason = 'Requires system connection';
      } else if (isAutoMode) {
        disabledReason = 'Switch to Manual Mode to control';
      } else if (!isArduinoConnected) {
        disabledReason = 'Arduino connection required';
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: enabled
                      ? color.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(icon, size: 32, color: enabled ? color : Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: enabled ? null : Colors.grey,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: enabled ? Colors.grey : Colors.grey[400],
                      ),
                    ),
                    if (!enabled && disabledReason.isNotEmpty)
                      Text(
                        disabledReason,
                        style: TextStyle(
                          fontSize: 11,
                          color: isAutoMode ? Colors.orange : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Switch(
                value: isOn,
                onChanged: enabled ? (value) => onToggle() : null,
                activeColor: enabled ? color : Colors.grey,
                inactiveThumbColor: enabled ? null : Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  String _formatUptime(int milliseconds) {
    if (milliseconds == 0) return 'N/A';

    final seconds = milliseconds ~/ 1000;
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final days = hours ~/ 24;

    if (days > 0) {
      return '${days}d ${hours % 24}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes % 60}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds % 60}s';
    } else {
      return '${seconds}s';
    }
  }
}
