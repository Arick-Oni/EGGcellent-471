import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManualControlsPage extends StatefulWidget {
  const ManualControlsPage({Key? key}) : super(key: key);

  @override
  _ManualControlsPageState createState() => _ManualControlsPageState();
}

class _ManualControlsPageState extends State<ManualControlsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fixed device ID matching ESP8266 code
  static const String deviceId = 'eggcellent360';

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
    // Load actuator states from Firestore (matching ESP8266 structure)
    _firestore.doc('$deviceId/actuators').snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          // Extract boolean values from Firestore fields structure
          actuatorStates = {
            'fan1': _extractBoolValue(data, 'fan1'),
            'fan2': _extractBoolValue(data, 'fan2'),
            'exhaust_fan': _extractBoolValue(data, 'exhaust_fan'),
            'lights': _extractBoolValue(data, 'lights'),
            'water_pump': _extractBoolValue(data, 'water_pump'),
            'feeder': _extractBoolValue(data, 'feeder'),
            'watering_active': _extractBoolValue(data, 'watering_active'),
            'auto_mode':
                _extractBoolValue(data, 'auto_mode', defaultValue: true),
          };
        });
        print('Actuator states loaded: $actuatorStates');
      }
    }, onError: (error) {
      print('Error loading actuator states: $error');
    });

    // Load system status
    _firestore.doc('$deviceId/system_status').snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          systemStatus = {
            'status':
                _extractStringValue(data, 'status', defaultValue: 'offline'),
            'arduino_connection': _extractBoolValue(data, 'arduino_connection'),
            'device_id': _extractStringValue(data, 'device_id'),
            'uptime': _extractIntValue(data, 'uptime'),
            'free_heap': _extractIntValue(data, 'free_heap'),
            'wifi_rssi': _extractIntValue(data, 'wifi_rssi'),
          };
        });
        print('System status loaded: $systemStatus');
      }
    }, onError: (error) {
      print('Error loading system status: $error');
    });
  }

  // Helper methods to extract values from Firestore fields structure
  bool _extractBoolValue(Map<String, dynamic> data, String field,
      {bool defaultValue = false}) {
    if (data.containsKey('fields') && data['fields'][field] != null) {
      return data['fields'][field]['booleanValue'] ?? defaultValue;
    }
    return data[field] ?? defaultValue;
  }

  String _extractStringValue(Map<String, dynamic> data, String field,
      {String defaultValue = ''}) {
    if (data.containsKey('fields') && data['fields'][field] != null) {
      return data['fields'][field]['stringValue'] ?? defaultValue;
    }
    return data[field] ?? defaultValue;
  }

  int _extractIntValue(Map<String, dynamic> data, String field,
      {int defaultValue = 0}) {
    if (data.containsKey('fields') && data['fields'][field] != null) {
      final value = data['fields'][field]['integerValue'];
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return value ?? defaultValue;
    }
    return data[field] ?? defaultValue;
  }

  Future<void> _toggleActuator(String actuator, bool currentState) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create Firestore document format matching ESP8266 expectations
      final updateData = {
        'fields': {
          actuator: {'booleanValue': !currentState},
          'last_update': {
            'integerValue': DateTime.now().millisecondsSinceEpoch.toString()
          },
        }
      };

      await _firestore
          .doc('$deviceId/actuators')
          .set(updateData, SetOptions(merge: true));

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
      // Create Firestore document format matching ESP8266 expectations
      final updateData = {
        'fields': {
          'fan1': {'booleanValue': state},
          'fan2': {'booleanValue': state},
          'exhaust_fan': {'booleanValue': state},
          'lights': {'booleanValue': state},
          'water_pump': {'booleanValue': state},
          'feeder': {'booleanValue': state},
          'watering_active': {'booleanValue': state},
          'auto_mode': {
            'booleanValue': false
          }, // Disable auto mode when using manual override
          'last_update': {
            'integerValue': DateTime.now().millisecondsSinceEpoch.toString()
          },
        }
      };

      await _firestore
          .doc('$deviceId/actuators')
          .set(updateData, SetOptions(merge: true));

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

      // Create Firestore document format matching ESP8266 expectations
      final updateData = {
        'fields': {
          'auto_mode': {'booleanValue': newAutoModeState},
          'last_update': {
            'integerValue': DateTime.now().millisecondsSinceEpoch.toString()
          },
        }
      };

      await _firestore
          .doc('$deviceId/actuators')
          .set(updateData, SetOptions(merge: true));

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
        title: const Text('Manual Controls - EGGCELLENT360'),
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
                'ESP8266 Actuator Controls',
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
                      _buildInfoRow('Device ID', deviceId),
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
                        'All other actuators are controlled via serial commands to Arduino.',
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
