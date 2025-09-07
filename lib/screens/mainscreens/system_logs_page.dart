import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SystemLogsPage extends StatefulWidget {
  const SystemLogsPage({Key? key}) : super(key: key);

  @override
  _SystemLogsPageState createState() => _SystemLogsPageState();
}

class _SystemLogsPageState extends State<SystemLogsPage>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedFilter = 'all';
  bool _showResolvedOnly = false;

  final Map<String, IconData> _alertIcons = {
    'high_temperature': Icons.thermostat,
    'high_gas': Icons.warning,
    'very_low_food': Icons.restaurant,
    'arduino_communication': Icons.error_outline,
    'feeding': Icons.pets,
    'fan_activation': Icons.air,
    'manual_override': Icons.touch_app,
    'system_error': Icons.error,
    'water_pump': Icons.water_drop,
    'lights': Icons.lightbulb,
  };

  final Map<String, Color> _alertColors = {
    'high_temperature': Colors.red,
    'high_gas': Colors.orange,
    'very_low_food': Colors.yellow,
    'arduino_communication': Colors.purple,
    'feeding': Colors.green,
    'fan_activation': Colors.blue,
    'manual_override': Colors.indigo,
    'system_error': Colors.red,
    'water_pump': Colors.cyan,
    'lights': Colors.amber,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1508),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E2418),
        elevation: 0,
        title: const Text(
          'System Logs & Event Timeline',
          style: TextStyle(
            color: Color(0xFFFFC107),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFC107)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Color(0xFFFFC107)),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Events')),
              const PopupMenuItem(
                  value: 'high_temperature', child: Text('Temperature Alerts')),
              const PopupMenuItem(value: 'high_gas', child: Text('Gas Alerts')),
              const PopupMenuItem(
                  value: 'very_low_food', child: Text('Food Alerts')),
              const PopupMenuItem(
                  value: 'arduino_communication',
                  child: Text('Communication Issues')),
              const PopupMenuItem(
                  value: 'feeding', child: Text('Feeding Events')),
              const PopupMenuItem(
                  value: 'fan_activation', child: Text('Fan Activity')),
              const PopupMenuItem(
                  value: 'manual_override', child: Text('Manual Controls')),
            ],
          ),
          Switch(
            value: _showResolvedOnly,
            onChanged: (value) {
              setState(() {
                _showResolvedOnly = value;
              });
            },
            activeColor: const Color(0xFFFFC107),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFFFFC107)),
            onPressed: _addSampleData,
            tooltip: 'Add Sample Data',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Statistics Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E2418), Color(0xFF3E3425)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildStatisticsRow(),
            ),
            // Event Timeline
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2418).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildEventTimeline(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAllAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Color(0xFFFFC107));
        }

        if (!snapshot.hasData) {
          return const Text('Error loading statistics');
        }

        final alerts = snapshot.data!;
        final totalEvents = alerts.length;
        final todayEvents = alerts.where((alert) {
          final timestamp = _extractTimestamp(alert);
          if (timestamp == 0) return false;

          final eventDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final today = DateTime.now();
          return eventDate.year == today.year &&
              eventDate.month == today.month &&
              eventDate.day == today.day;
        }).length;

        final criticalEvents = alerts.where((alert) {
          final severity = _extractSeverity(alert);
          final resolved = _extractResolved(alert);
          return severity == 'high' && !resolved;
        }).length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard('Total Events', totalEvents.toString(), Icons.event,
                Colors.blue),
            _buildStatCard(
                'Today', todayEvents.toString(), Icons.today, Colors.green),
            _buildStatCard('Critical', criticalEvents.toString(), Icons.warning,
                Colors.red),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFC107),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEventTimeline() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAllAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No events found',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        var alerts = snapshot.data!;

        // Apply filters
        alerts = alerts.where((alert) {
          final type = _extractType(alert);
          final resolved = _extractResolved(alert);

          // Filter by type
          if (_selectedFilter != 'all' && type != _selectedFilter) {
            return false;
          }

          // Filter by resolved status
          if (_showResolvedOnly && !resolved) {
            return false;
          }

          return true;
        }).toList();

        // Sort by timestamp (descending order - newest first)
        alerts.sort((a, b) {
          final aTimestamp = _extractTimestamp(a);
          final bTimestamp = _extractTimestamp(b);
          return bTimestamp.compareTo(aTimestamp);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            return _buildEventCard(alerts[index], index == 0);
          },
        );
      },
    );
  }

  // Method to get all alerts from the new simplified structure
  Future<List<Map<String, dynamic>>> _getAllAlerts() async {
    List<Map<String, dynamic>> allAlerts = [];

    try {
      print('Fetching alerts from Firestore...');

      // Query the alerts collection directly
      final alertsCollection = await _firestore
          .collection('alerts')
          .orderBy('timestamp', descending: true)
          .limit(100) // Limit to recent 100 alerts
          .get();

      print('Found ${alertsCollection.docs.length} alert documents');

      for (final doc in alertsCollection.docs) {
        final data = doc.data();
        data['doc_id'] = doc.id;
        allAlerts.add(data);
      }

      print('Total alerts found: ${allAlerts.length}');
    } catch (e) {
      print('Error fetching alerts: $e');
    }

    return allAlerts;
  }

  // Method to get sensor history data
  Future<List<Map<String, dynamic>>> _getSensorHistory() async {
    List<Map<String, dynamic>> sensorData = [];

    try {
      print('Fetching sensor history from Firestore...');

      // Query the sensor_history collection directly
      final sensorCollection = await _firestore
          .collection('sensor_history')
          .orderBy('timestamp', descending: true)
          .limit(50) // Limit to recent 50 sensor readings
          .get();

      print('Found ${sensorCollection.docs.length} sensor history documents');

      for (final doc in sensorCollection.docs) {
        final data = doc.data();
        data['doc_id'] = doc.id;
        sensorData.add(data);
      }

      print('Total sensor readings found: ${sensorData.length}');
    } catch (e) {
      print('Error fetching sensor history: $e');
    }

    return sensorData;
  }

  // Helper methods to extract data from the simplified Firestore structure
  String _extractType(Map<String, dynamic>? data) {
    if (data == null) return 'unknown';

    // Direct field access for simplified structure
    if (data.containsKey('type')) {
      return data['type'] as String? ?? 'unknown';
    }

    return 'unknown';
  }

  String _extractMessage(Map<String, dynamic>? data) {
    if (data == null) return 'No message';

    // Direct field access for simplified structure
    if (data.containsKey('message')) {
      return data['message'] as String? ?? 'No message';
    }

    return 'No message';
  }

  int _extractTimestamp(Map<String, dynamic>? data) {
    if (data == null) return 0;

    // Direct field access for simplified structure
    if (data.containsKey('timestamp')) {
      final value = data['timestamp'];
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is Timestamp) return value.millisecondsSinceEpoch;
    }

    return DateTime.now().millisecondsSinceEpoch;
  }

  bool _extractResolved(Map<String, dynamic>? data) {
    if (data == null) return false;

    // Direct field access for simplified structure
    if (data.containsKey('resolved')) {
      return data['resolved'] as bool? ?? false;
    }

    return false;
  }

  String _extractSeverity(Map<String, dynamic>? data) {
    if (data == null) return 'medium';

    // Direct field access for simplified structure
    if (data.containsKey('severity')) {
      return data['severity'] as String? ?? 'medium';
    }

    return 'medium';
  }

  // Method to add sample data for testing (matching new Arduino structure)
  void _addSampleData() async {
    final samples = [
      {
        'type': 'high_temperature',
        'message': 'Temperature critically high: 35.5°C',
        'resolved': false,
        'severity': 'high',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'type': 'high_gas',
        'message': 'Gas level critically high: 450',
        'resolved': false,
        'severity': 'high',
        'timestamp':
            DateTime.now().millisecondsSinceEpoch - 300000, // 5 minutes ago
      },
      {
        'type': 'very_low_food',
        'message': 'Food level critically low: 15%',
        'resolved': true,
        'severity': 'medium',
        'timestamp':
            DateTime.now().millisecondsSinceEpoch - 600000, // 10 minutes ago
      },
    ];

    try {
      for (final sample in samples) {
        final alertType = sample['type'] as String;
        final timestamp = sample['timestamp'] as int;

        // Create document ID like ESP: {alert_type}_{timestamp}
        final docId = '${alertType}_$timestamp';

        // Save to: /alerts/{alert_type}_{timestamp}
        await _firestore.collection('alerts').doc(docId).set(sample);

        print('Created alert document: $docId');

        // Small delay to ensure different timestamps
        await Future.delayed(const Duration(milliseconds: 50));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample data added successfully!'),
          backgroundColor: Color(0xFFFFC107),
        ),
      );

      setState(() {});
    } catch (e) {
      print('Error adding sample data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding sample data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildEventCard(Map<String, dynamic> data, bool isLatest) {
    final timestamp = _extractTimestamp(data);
    final type = _extractType(data);
    final message = _extractMessage(data);
    final resolved = _extractResolved(data);
    final severity = _extractSeverity(data);

    final eventTime = timestamp > 0
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : DateTime.now();
    final timeAgo = _getTimeAgo(eventTime);

    final icon = _alertIcons[type] ?? Icons.info;
    final color = _alertColors[type] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLatest
              ? [const Color(0xFF3E3425), const Color(0xFF4E4335)]
              : [const Color(0xFF2E2418), const Color(0xFF3E3425)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: isLatest
            ? Border.all(color: const Color(0xFFFFC107), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          _getEventTitle(type),
          style: const TextStyle(
            color: Color(0xFFFFC107),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.white54),
                const SizedBox(width: 4),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(severity).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    severity.toUpperCase(),
                    style: TextStyle(
                      color: _getSeverityColor(severity),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (resolved) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'RESOLVED',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: isLatest
            ? const Icon(Icons.fiber_new, color: Color(0xFFFFC107))
            : null,
      ),
    );
  }

  String _getEventTitle(String type) {
    switch (type) {
      case 'high_temperature':
        return 'High Temperature Alert';
      case 'high_gas':
        return 'Gas Level Warning';
      case 'very_low_food':
        return 'Low Food Level';
      case 'arduino_communication':
        return 'Communication Error';
      case 'feeding':
        return 'Feeding Event';
      case 'fan_activation':
        return 'Fan Activated';
      case 'manual_override':
        return 'Manual Control';
      case 'system_error':
        return 'System Error';
      case 'water_pump':
        return 'Water Pump Activity';
      case 'lights':
        return 'Lighting Control';
      default:
        return 'System Event';
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime eventTime) {
    final now = DateTime.now();
    final difference = now.difference(eventTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(eventTime);
    }
  }
}
