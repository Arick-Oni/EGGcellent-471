import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThresholdConfigDialog extends StatefulWidget {
  const ThresholdConfigDialog({Key? key}) : super(key: key);
  @override
  State<ThresholdConfigDialog> createState() => _ThresholdConfigDialogState();
}

class _ThresholdConfigDialogState extends State<ThresholdConfigDialog> {
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
      // Optionally handle error
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
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _loadThresholds();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Threshold Configuration'),
      content: _loading
          ? SizedBox(
              height: 100, child: Center(child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Temperature threshold (°C):')),
                    Text('${_tempThreshold.toStringAsFixed(1)}'),
                  ],
                ),
                Slider(
                  value: _tempThreshold,
                  min: 10,
                  max: 45,
                  divisions: 35,
                  label: _tempThreshold.toString(),
                  onChanged: (v) => setState(() => _tempThreshold = v),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Text('Light threshold (LDR):')),
                    Text('${_ldrThreshold.toInt()}'),
                  ],
                ),
                Slider(
                  value: _ldrThreshold,
                  min: 0,
                  max: 5000,
                  divisions: 50,
                  label: _ldrThreshold.toString(),
                  onChanged: (v) => setState(() => _ldrThreshold = v),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Text('Gas threshold (unit):')),
                    Text('${_gasThreshold}'),
                  ],
                ),
                Slider(
                  value: _gasThreshold.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: _gasThreshold.toString(),
                  onChanged: (v) => setState(() => _gasThreshold = v.toInt()),
                ),
              ],
            ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.save),
          label: Text('Save Thresholds'),
          onPressed: _saveThresholds,
        ),
      ],
    );
  }
}
