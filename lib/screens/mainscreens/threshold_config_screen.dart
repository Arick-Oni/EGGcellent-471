import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThresholdConfigScreen extends StatefulWidget {
  const ThresholdConfigScreen({Key? key}) : super(key: key);

  @override
  State<ThresholdConfigScreen> createState() => _ThresholdConfigScreenState();
}

class _ThresholdConfigScreenState extends State<ThresholdConfigScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _tempThreshold = 30;
  double _ldrThreshold = 1000;
  int _gasThreshold = 50;
  bool _loading = false;

  Future<void> _loadThresholds() async {
    setState(() => _loading = true);
    try {
      final tempDoc = await _firestore
          .collection('sensors')
          .doc('schedule_and_threshold')
          .collection('temp_threshold')
          .doc('temp')
          .get();
      final lightDoc = await _firestore
          .collection('sensors')
          .doc('schedule_and_threshold')
          .collection('light_threshold')
          .doc('light')
          .get();
      final gasDoc = await _firestore
          .collection('sensors')
          .doc('schedule_and_threshold')
          .collection('gas_threshold')
          .doc('gas')
          .get();

      setState(() {
        _tempThreshold = (tempDoc['temp'] ?? 30).toDouble();
        _ldrThreshold = (lightDoc['ldr'] ?? 1000).toDouble();
        _gasThreshold = (gasDoc['gas'] ?? 50).toInt();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveThresholds() async {
    setState(() => _loading = true);
    await _firestore
        .collection('sensors')
        .doc('schedule_and_threshold')
        .collection('temp_threshold')
        .doc('temp')
        .set({'temp': _tempThreshold});
    await _firestore
        .collection('sensors')
        .doc('schedule_and_threshold')
        .collection('light_threshold')
        .doc('light')
        .set({'ldr': _ldrThreshold});
    await _firestore
        .collection('sensors')
        .doc('schedule_and_threshold')
        .collection('gas_threshold')
        .doc('gas')
        .set({'gas': _gasThreshold});
    setState(() => _loading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Thresholds saved!')));
  }

  @override
  void initState() {
    super.initState();
    _loadThresholds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Threshold Configuration',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF342056),
                Color(0xFF5757CC),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFF15121E),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure values below. These will be used to control automations when no schedule is active.',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 24),
                  ThresholdCard(
                    title: 'Temperature threshold (°C):',
                    tooltip: 'Set the automation trigger for temperature.',
                    valueText: _tempThreshold.toStringAsFixed(1),
                    slider: _buildSlider(
                      value: _tempThreshold,
                      label: _tempThreshold.toString(),
                      min: 10,
                      max: 45,
                      divisions: 35,
                      onChanged: (v) => setState(() => _tempThreshold = v),
                    ),
                  ),
                  Divider(color: Colors.white12, height: 32),
                  ThresholdCard(
                    title: 'Light threshold (LDR):',
                    tooltip: 'Set the level for light sensor automation.',
                    valueText: _ldrThreshold.toInt().toString(),
                    slider: _buildSlider(
                      value: _ldrThreshold,
                      label: _ldrThreshold.toString(),
                      min: 0,
                      max: 5000,
                      divisions: 50,
                      onChanged: (v) => setState(() => _ldrThreshold = v),
                    ),
                  ),
                  Divider(color: Colors.white12, height: 32),
                  ThresholdCard(
                    title: 'Gas threshold (unit):',
                    tooltip: 'Set the automation trigger for gas sensor.',
                    valueText: _gasThreshold.toString(),
                    slider: _buildSlider(
                      value: _gasThreshold.toDouble(),
                      label: _gasThreshold.toString(),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (v) =>
                          setState(() => _gasThreshold = v.toInt()),
                    ),
                  ),
                  SizedBox(height: 38),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Cancel',
                            style: TextStyle(color: Colors.white70)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                        icon: Icon(Icons.save, size: 20),
                        label: Text('Save Thresholds',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: _saveThresholds,
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildSlider({
    required double value,
    required String label,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbColor: Colors.deepPurpleAccent,
        trackHeight: 4,
        overlayColor: Colors.deepPurple.withOpacity(0.18),
        activeTrackColor: Colors.purpleAccent,
        inactiveTrackColor: Colors.white12,
        valueIndicatorColor: Colors.deepPurpleAccent,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
      ),
    );
  }
}

class ThresholdCard extends StatelessWidget {
  final String title;
  final String tooltip;
  final String valueText;
  final Widget slider;
  const ThresholdCard({
    Key? key,
    required this.title,
    required this.tooltip,
    required this.valueText,
    required this.slider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              SizedBox(width: 5),
              Tooltip(
                message: tooltip,
                child: Icon(Icons.info_outline,
                    color: Colors.purpleAccent, size: 15),
              ),
              Spacer(),
              Text(valueText,
                  style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 15))
            ],
          ),
          slider,
        ],
      ),
    );
  }
}
