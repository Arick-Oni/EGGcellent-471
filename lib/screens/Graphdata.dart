import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'data_seeder_page.dart';

class GraphData extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const GraphData({super.key, this.onBackToHome});

  @override
  _GraphDataState createState() => _GraphDataState();
}

class _GraphDataState extends State<GraphData> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Firebase instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time data lists
  List<SensorReading> sensorReadings = [];
  Map<String, dynamic> currentReadings = {};
  bool isLoading = true;
  String connectionStatus = 'Connecting...';

  // Timer for periodic updates
  Timer? _dataTimer;
  StreamSubscription<QuerySnapshot>? _sensorStream;
  StreamSubscription<DocumentSnapshot>? _currentSensorStream;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _initializeFirebaseStreams();
    _animationController.forward();
  }

  void _initializeFirebaseStreams() {
    // Stream for current sensor values
    _currentSensorStream = _firestore
        .collection('eggcellent360')
        .doc('current_sensors')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          currentReadings = snapshot.data() ?? {};
          connectionStatus = currentReadings['data_valid'] == true
              ? 'Connected'
              : 'Sensor Issues';
        });
      }
    }, onError: (error) {
      setState(() {
        connectionStatus = 'Connection Error';
      });
      print('Current sensors stream error: $error');
    });

    // Stream for historical data from new structure
    _loadSensorHistory();
  }

  void _loadSensorHistory() {
    print('Loading sensor history from new structure...');

    // Stream for sensor history from the new top-level sensor_history collection
    _sensorStream = _firestore
        .collection('sensor_history')
        .orderBy('timestamp', descending: false)
        .limit(100) // Limit to last 100 readings for performance
        .snapshots()
        .listen((snapshot) {
      List<SensorReading> readings = [];

      print('Found ${snapshot.docs.length} sensor history documents');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final docId = doc.id;

        print('Processing sensor document: $docId');
        print('Document fields: ${data.keys.toList()}');

        // Validate that this document has the expected sensor data fields
        if (data.containsKey('timestamp') &&
            data.containsKey('temperature') &&
            data.containsKey('device_id')) {
          final timestamp = (data['timestamp'] as num?)?.toInt();

          if (timestamp != null) {
            final dataDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final now = DateTime.now();
            final daysDiff = now.difference(dataDate).inDays;

            print('Sensor data from $daysDiff days ago ($dataDate)');

            readings.add(SensorReading(
              timestamp: timestamp,
              temperature: (data['temperature'] as num?)?.toDouble() ?? 0.0,
              humidity: (data['humidity'] as num?)?.toDouble() ?? 0.0,
              gasLevel: (data['gas_level'] as num?)?.toDouble() ?? 0.0,
              lightLevel: (data['light_level'] as num?)?.toDouble() ?? 0.0,
              foodLevel: (data['food_level'] as num?)?.toDouble() ?? 0.0,
              arduinoDataValid: data['arduino_data_valid'] as bool? ?? false,
            ));
          }
        } else {
          print('Document $docId missing required fields');
        }
      }

      print('Successfully processed ${readings.length} sensor readings');

      setState(() {
        // Sort by timestamp (oldest first)
        readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        sensorReadings = readings;
        isLoading = false;

        if (readings.isNotEmpty) {
          final newestData =
              DateTime.fromMillisecondsSinceEpoch(readings.last.timestamp);
          final oldestData =
              DateTime.fromMillisecondsSinceEpoch(readings.first.timestamp);
          final daysDiff = DateTime.now().difference(newestData).inDays;
          final dataSpan = newestData.difference(oldestData).inDays;

          connectionStatus =
              'Loaded ${readings.length} records (newest: ${daysDiff}d ago, span: ${dataSpan}d)';
        } else {
          connectionStatus = 'No Historical Data Found';
          // Generate sample data for testing if no real data is available
          _generateSampleDataForTesting();
        }
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
        connectionStatus = 'Data Load Error: $error';
      });
      print('Sensor history stream error: $error');

      // Generate sample data as fallback
      _generateSampleDataForTesting();
    });
  }

  void _generateSampleDataForTesting() {
    print('Generating sample sensor data for testing the charts...');

    final now = DateTime.now().millisecondsSinceEpoch;
    List<SensorReading> sampleData = [];

    // Generate sample data for the last 24 hours
    for (int i = 0; i < 24; i++) {
      final timestamp = now - (i * 60 * 60 * 1000); // Go back i hours

      // Generate realistic sensor values with some variation
      final temp = 28.0 +
          (5.0 * (0.5 - (i % 12) / 24.0)) +
          (2.0 * (0.5 - (i % 3) / 6.0));
      final humidity = 55.0 + (10.0 * (0.5 - (i % 8) / 16.0));
      final gas = 300.0 + (100.0 * (0.5 - (i % 5) / 10.0));
      final light = 400.0 + (200.0 * (0.5 - (i % 6) / 12.0));
      final food = 500.0 + (200.0 * (0.5 - (i % 10) / 20.0));

      sampleData.add(SensorReading(
        timestamp: timestamp,
        temperature: temp,
        humidity: humidity,
        gasLevel: gas,
        lightLevel: light,
        foodLevel: food,
        arduinoDataValid: true,
      ));
    }

    // Sort by timestamp (oldest first)
    sampleData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    setState(() {
      sensorReadings = sampleData;
      connectionStatus = 'Sample Data (No Real Data Found)';
    });

    print(
        'Generated ${sampleData.length} sample sensor readings for chart display');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dataTimer?.cancel();
    _sensorStream?.cancel();
    _currentSensorStream?.cancel();
    super.dispose();
  }

  // Convert timestamp to hours for chart
  List<FlSpot> _getChartData(String dataType) {
    if (sensorReadings.isEmpty) return [];

    final now = DateTime.now().millisecondsSinceEpoch;
    const maxPoints = 50; // Limit points for performance

    // Take recent readings and sample them if too many
    List<SensorReading> dataToChart = sensorReadings;
    if (dataToChart.length > maxPoints) {
      final step = dataToChart.length ~/ maxPoints;
      dataToChart = dataToChart.where((reading) {
        final index = dataToChart.indexOf(reading);
        return index % step == 0;
      }).toList();
    }

    return dataToChart.map((reading) {
      final hoursAgo = (now - reading.timestamp) / (1000 * 60 * 60);
      final value = _getValueForDataType(reading, dataType);
      return FlSpot(24 - hoursAgo, value);
    }).toList();
  }

  double _getValueForDataType(SensorReading reading, String dataType) {
    switch (dataType) {
      case 'temperature':
        return reading.temperature;
      case 'humidity':
        return reading.humidity;
      case 'gas':
        return reading.gasLevel;
      case 'light':
        return reading.lightLevel;
      case 'food':
        return reading.foodLevel;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Eggcellent 360 Monitor',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              connectionStatus,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: connectionStatus == 'Connected'
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF161B22),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF58A6FF)),
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_chart, color: Color(0xFF58A6FF)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DataSeederPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isLoading ? Icons.hourglass_empty : Icons.refresh,
              color: Color(0xFF58A6FF),
            ),
            onPressed: isLoading
                ? null
                : () {
                    setState(() {
                      isLoading = true;
                    });
                    // Reinitialize streams to refresh data
                    _sensorStream?.cancel();
                    _currentSensorStream?.cancel();
                    _initializeFirebaseStreams();
                  },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF58A6FF)),
                    SizedBox(height: 16),
                    Text(
                      'Loading sensor data...',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    SizedBox(height: 24),
                    _buildChartsGrid(),
                    SizedBox(height: 20),
                    _buildActionButtons(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final temp = currentReadings['temperature']?.toDouble() ?? 0.0;
    final humidity = currentReadings['humidity']?.toDouble() ?? 0.0;
    final gas = currentReadings['gas_level']?.toDouble() ?? 0.0;
    final light = currentReadings['light_level']?.toDouble() ?? 0.0;
    final food = currentReadings['food_level']?.toDouble() ?? 0.0;
    final lastUpdate = currentReadings['last_update'];

    String timeAgo = 'Unknown';
    if (lastUpdate != null) {
      final diff = DateTime.now().millisecondsSinceEpoch - (lastUpdate as int);
      final minutes = diff ~/ (1000 * 60);
      timeAgo = minutes < 1 ? 'Just now' : '${minutes}m ago';
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: connectionStatus == 'Connected'
              ? [Color(0xFF238636), Color(0xFF196127)]
              : [Color(0xFFBD2C00), Color(0xFF8B2635)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (connectionStatus == 'Connected'
                    ? Color(0xFF238636)
                    : Color(0xFFBD2C00))
                .withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dashboard, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Live Readings',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                timeAgo,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCurrentReading(
                  '${temp.toStringAsFixed(1)}°C', 'Temp', Icons.thermostat),
              _buildCurrentReading('${humidity.toStringAsFixed(1)}%',
                  'Humidity', Icons.water_drop),
              _buildCurrentReading(
                  '${gas.toStringAsFixed(0)}', 'Gas', Icons.air),
              _buildCurrentReading(
                  '${light.toStringAsFixed(0)}', 'Light', Icons.wb_sunny),
              _buildCurrentReading(
                  '${food.toStringAsFixed(0)}', 'Food', Icons.dining),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentReading(String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildChartCard(
                'Temperature (°C)',
                'temperature',
                Color(0xFFFF7B72),
                Icons.thermostat,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildChartCard(
                'Humidity (%)',
                'humidity',
                Color(0xFF79C0FF),
                Icons.water_drop,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildChartCard(
                'Gas Level',
                'gas',
                Color(0xFFE3B341),
                Icons.air,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildChartCard(
                'Light Level',
                'light',
                Color(0xFFD2A8FF),
                Icons.wb_sunny,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildChartCard(
          'Food Level',
          'food',
          Color(0xFF56D364),
          Icons.dining,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildChartCard(
      String title, String dataType, Color color, IconData icon,
      {bool fullWidth = false}) {
    final chartData = _getChartData(dataType);
    final dataCount = sensorReadings.length;

    return Container(
      width: fullWidth ? double.infinity : null,
      height: 280,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF21262D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF30363D), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF0F6FC),
                      ),
                    ),
                    Text(
                      '$dataCount data points',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Color(0xFF8B949E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: chartData.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF8B949E),
                        fontSize: 12,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Color(0xFF30363D),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Color(0xFF8B949E),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 25,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}h',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  color: Color(0xFF8B949E),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData,
                          isCurved: true,
                          color: color,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: chartData.length < 20,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: color,
                                strokeWidth: 2,
                                strokeColor: Color(0xFF21262D),
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withOpacity(0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _animationController.reset();
                  _animationController.forward();
                  setState(() {
                    isLoading = true;
                  });
                  _sensorStream?.cancel();
                  _currentSensorStream?.cancel();
                  _initializeFirebaseStreams();
                },
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Refresh Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF238636),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: Color(0xFF238636).withOpacity(0.3),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (widget.onBackToHome != null) {
                    widget.onBackToHome!();
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(Icons.home, size: 18),
                label: Text('Back to Home'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xFF58A6FF),
                  side: BorderSide(color: Color(0xFF58A6FF)),
                  backgroundColor: Color(0xFF58A6FF).withOpacity(0.1),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        // Add Data Seeder Button
        Container(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DataSeederPage()),
              );
            },
            icon: Icon(Icons.add_chart, size: 18),
            label: Text('Add Sample Data'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFFE3B341),
              side: BorderSide(color: Color(0xFFE3B341)),
              backgroundColor: Color(0xFFE3B341).withOpacity(0.1),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SensorReading {
  final int timestamp;
  final double temperature;
  final double humidity;
  final double gasLevel;
  final double lightLevel;
  final double foodLevel;
  final bool arduinoDataValid;

  SensorReading({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.gasLevel,
    required this.lightLevel,
    required this.foodLevel,
    required this.arduinoDataValid,
  });
}
