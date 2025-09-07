import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/firestore_data_seeder.dart';

class DataSeederPage extends StatefulWidget {
  const DataSeederPage({super.key});

  @override
  _DataSeederPageState createState() => _DataSeederPageState();
}

class _DataSeederPageState extends State<DataSeederPage> {
  bool _isSeeding = false;
  String _status = 'Ready to seed data';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        title: Text(
          'Firestore Data Seeder',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF161B22),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF58A6FF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF21262D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF30363D), width: 1),
              ),
              child: Column(
                children: [
                  Icon(
                    _isSeeding ? Icons.hourglass_empty : Icons.storage,
                    color: _isSeeding ? Colors.orange : Color(0xFF58A6FF),
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Database Status',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Color(0xFF8B949E),
                    ),
                  ),
                  if (_isSeeding) ...[
                    SizedBox(height: 16),
                    LinearProgressIndicator(
                      backgroundColor: Color(0xFF30363D),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF58A6FF)),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 32),

            // Action Buttons
            Text(
              'Choose Data Type',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),

            // Demo Data Button
            _buildActionButton(
              title: 'Create Demo Data',
              subtitle: 'Perfect patterns for beautiful graphs (48 hours)',
              icon: Icons.auto_graph,
              color: Color(0xFF238636),
              onPressed: _isSeeding ? null : _seedDemoData,
            ),

            SizedBox(height: 16),

            // Realistic Data Button
            _buildActionButton(
              title: 'Create Realistic Data',
              subtitle: 'Natural variations and patterns (7 days)',
              icon: Icons.scatter_plot,
              color: Color(0xFF58A6FF),
              onPressed: _isSeeding ? null : _seedRealisticData,
            ),

            SizedBox(height: 24),

            Divider(color: Color(0xFF30363D)),

            SizedBox(height: 16),

            // Clear Data Button
            _buildActionButton(
              title: 'Clear All Data',
              subtitle: 'Remove all existing sensor data',
              icon: Icons.delete_forever,
              color: Color(0xFFBD2C00),
              onPressed: _isSeeding ? null : _clearData,
            ),

            Spacer(),

            // Info Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF0969DA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF0969DA).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF58A6FF), size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Current time: ${DateTime.now().toString().substring(0, 16)}\n'
                      'Data will be generated backwards from now.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Color(0xFF58A6FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? color : Color(0xFF30363D),
          foregroundColor: Colors.white,
          padding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seedDemoData() async {
    setState(() {
      _isSeeding = true;
      _status = 'Creating demo data with beautiful patterns...';
    });

    try {
      await FirestoreDataSeeder.seedDemoData();
      setState(() {
        _status = 'Demo data created successfully! 🎉';
      });
      _showSuccessDialog(
          'Demo Data Created',
          'Beautiful demo data has been added to your Firestore database. '
              'Check your graphs now to see the patterns!');
    } catch (e) {
      setState(() {
        _status = 'Error creating demo data: $e';
      });
      _showErrorDialog('Failed to create demo data: $e');
    } finally {
      setState(() {
        _isSeeding = false;
      });
    }
  }

  Future<void> _seedRealisticData() async {
    setState(() {
      _isSeeding = true;
      _status = 'Creating realistic sensor data for 7 days...';
    });

    try {
      await FirestoreDataSeeder.seedSensorData();
      setState(() {
        _status = 'Realistic data created successfully! 📊';
      });
      _showSuccessDialog(
          'Realistic Data Created',
          'A week of realistic sensor data has been added to your database. '
              'This includes natural daily patterns and variations.');
    } catch (e) {
      setState(() {
        _status = 'Error creating realistic data: $e';
      });
      _showErrorDialog('Failed to create realistic data: $e');
    } finally {
      setState(() {
        _isSeeding = false;
      });
    }
  }

  Future<void> _clearData() async {
    final confirmed = await _showConfirmDialog(
      'Clear All Data',
      'This will permanently delete all sensor data from your Firestore database. '
          'This action cannot be undone. Are you sure?',
    );

    if (!confirmed) return;

    setState(() {
      _isSeeding = true;
      _status = 'Clearing all sensor data...';
    });

    try {
      await FirestoreDataSeeder.clearSensorData();
      setState(() {
        _status = 'All data cleared successfully! 🧹';
      });
      _showSuccessDialog('Data Cleared',
          'All sensor data has been removed from your database.');
    } catch (e) {
      setState(() {
        _status = 'Error clearing data: $e';
      });
      _showErrorDialog('Failed to clear data: $e');
    } finally {
      setState(() {
        _isSeeding = false;
      });
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF21262D),
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
        content:
            Text(message, style: GoogleFonts.poppins(color: Color(0xFF8B949E))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFF58A6FF))),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF21262D),
        title: Text('Error', style: GoogleFonts.poppins(color: Colors.red)),
        content:
            Text(message, style: GoogleFonts.poppins(color: Color(0xFF8B949E))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFF58A6FF))),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color(0xFF21262D),
            title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
            content: Text(message,
                style: GoogleFonts.poppins(color: Color(0xFF8B949E))),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:
                    Text('Cancel', style: TextStyle(color: Color(0xFF8B949E))),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Confirm', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
