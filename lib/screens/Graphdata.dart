import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/screens/mainscreens/homepage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class GraphData extends StatefulWidget {
  const GraphData({super.key});

  @override
  _GraphDataState createState() => _GraphDataState();
}

class _GraphDataState extends State<GraphData> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Sample data - replace with your actual poultry sensor data
  final List<SensorData> temperatureData = [
    SensorData(1, 22.5),
    SensorData(2, 24.0),
    SensorData(3, 23.8),
    SensorData(4, 25.2),
    SensorData(5, 26.1),
    SensorData(6, 24.7),
    SensorData(7, 23.9),
  ];

  final List<SensorData> humidityData = [
    SensorData(1, 65.0),
    SensorData(2, 68.5),
    SensorData(3, 72.0),
    SensorData(4, 70.3),
    SensorData(5, 69.8),
    SensorData(6, 71.2),
    SensorData(7, 73.5),
  ];

  final List<SensorData> gasData = [
    SensorData(1, 120.0),
    SensorData(2, 135.0),
    SensorData(3, 128.0),
    SensorData(4, 142.0),
    SensorData(5, 138.0),
    SensorData(6, 145.0),
    SensorData(7, 132.0),
  ];

  final List<SensorData> ammoniaData = [
    SensorData(1, 15.2),
    SensorData(2, 18.7),
    SensorData(3, 16.9),
    SensorData(4, 20.1),
    SensorData(5, 19.3),
    SensorData(6, 17.8),
    SensorData(7, 21.4),
  ];

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
      backgroundColor: Color(0xFF0D1117), // Dark GitHub-like background
      appBar: AppBar(
        title: Text(
          'Poultry Environment Monitor',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF161B22), // Dark AppBar
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF58A6FF)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with current readings
              _buildHeaderSection(),
              SizedBox(height: 24),

              // Charts Grid
              _buildChartsGrid(),

              // Bottom navigation or action buttons
              SizedBox(height: 20),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF238636), Color(0xFF196127)], // Dark green gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF238636).withOpacity(0.3),
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
              Text(
                'Current Readings',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCurrentReading('${temperatureData.last.value.toStringAsFixed(1)}°C', 'Temp', Icons.thermostat),
              _buildCurrentReading('${humidityData.last.value.toStringAsFixed(1)}%', 'Humidity', Icons.water_drop),
              _buildCurrentReading('${gasData.last.value.toStringAsFixed(0)} ppm', 'Gas', Icons.air),
              _buildCurrentReading('${ammoniaData.last.value.toStringAsFixed(1)} ppm', 'NH₃', Icons.science),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentReading(String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
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
                temperatureData,
                Color(0xFFFF7B72), // Bright red for dark theme
                Icons.thermostat,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildChartCard(
                'Humidity (%)',
                humidityData,
                Color(0xFF79C0FF), // Bright blue for dark theme
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
                'Gas Level (ppm)',
                gasData,
                Color(0xFFE3B341), // Golden yellow for dark theme
                Icons.air,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildChartCard(
                'Ammonia (ppm)',
                ammoniaData,
                Color(0xFFD2A8FF), // Purple for dark theme
                Icons.science,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, List<SensorData> data,
      Color color, IconData icon) {
    return Container(
      height: 280,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF21262D), // Dark card background
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
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF0F6FC), // Light text for dark theme
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Color(0xFF30363D), // Dark grid lines
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
                            color: Color(0xFF8B949E), // Muted text
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
                          'D${value.toInt()}',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Color(0xFF8B949E), // Muted text
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
                    spots: data
                        .map((point) => FlSpot(point.day.toDouble(), point.value))
                        .toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeWidth: 2,
                          strokeColor: Color(0xFF21262D), // Dark stroke
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
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Add refresh functionality
              _animationController.reset();
              _animationController.forward();
            },
            icon: Icon(Icons.refresh, size: 18),
            label: Text('Refresh Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF238636), // Dark green
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
              Navigator.pop(context);
            },
            icon: Icon(Icons.home, size: 18),
            label: Text('Back to Home'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFF58A6FF), // Blue accent
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
    );
  }
}

class SensorData {
  final int day;
  final double value;

  SensorData(this.day, this.value);
}
