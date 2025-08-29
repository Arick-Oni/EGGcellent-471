import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManualControlsPage extends StatefulWidget {
  final String selectedCoop;

  const ManualControlsPage({Key? key, required this.selectedCoop})
      : super(key: key);

  @override
  _ManualControlsPageState createState() => _ManualControlsPageState();
}

class _ManualControlsPageState extends State<ManualControlsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Coop selection
  String selectedCoop = '';
  List<String> availableCoops = ['coop1', 'coop2', 'coop3']; // Example coops

  // Control states
  bool fanOn = false;
  bool lightOn = false;
  bool feederOn = false;

  @override
  void initState() {
    super.initState();
    selectedCoop = widget.selectedCoop; // Initialize with passed coop
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load initial actuator states from Firestore for selected coop
    _firestore
        .collection('coops')
        .doc(selectedCoop)
        .collection('environment')
        .where(FieldPath.documentId, isEqualTo: 'actuators')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        setState(() {
          fanOn = doc['fan'] ?? false;
          lightOn = doc['light'] ?? false;
          feederOn = doc['feeder'] ?? false;
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

  void _toggleActuator(String actuator, bool currentState) {
    _firestore
        .collection('coops')
        .doc(selectedCoop)
        .collection('environment')
        .doc('actuators')
        .update({actuator: !currentState});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual Override Controls - ${selectedCoop.toUpperCase()}'),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                        Colors.orange.withOpacity(0.1),
                        Colors.orange.withOpacity(0.2),
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
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.home_work,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Control Coop:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
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
                              color: Colors.orange.withOpacity(0.3),
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
                                color: Colors.orange,
                              ),
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              items: availableCoops
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius:
                                              BorderRadius.circular(4),
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

              Text(
                'Manual Control Panel - ${selectedCoop.toUpperCase()}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),

              // Fan Control Card
              _buildControlCard(
                icon: Icons.wind_power,
                title: 'Fan Control',
                subtitle: 'Emergency/Maintenance Fan',
                isOn: fanOn,
                onToggle: () => _toggleActuator('fan', fanOn),
                color: Colors.blue,
              ),

              const SizedBox(height: 16),

              // Light Control Card
              _buildControlCard(
                icon: Icons.lightbulb,
                title: 'Light Control',
                subtitle: 'Coop Lighting System',
                isOn: lightOn,
                onToggle: () => _toggleActuator('light', lightOn),
                color: Colors.yellow,
              ),

              const SizedBox(height: 16),

              // Feeder Control Card
              _buildControlCard(
                icon: Icons.restaurant,
                title: 'Feeder Control',
                subtitle: 'Automatic Feeder System',
                isOn: feederOn,
                onToggle: () => _toggleActuator('feeder', feederOn),
                color: Colors.green,
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
                    const Text(
                      'Emergency Controls',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Use these controls for maintenance or emergency situations. '
                      'All changes are immediately reflected in the system.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _firestore
                                .collection('coops')
                                .doc(widget.selectedCoop)
                                .collection('environment')
                                .doc('actuators')
                                .update({
                              'fan': true,
                              'light': true,
                              'feeder': true,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('All ON'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _firestore
                                .collection('coops')
                                .doc(widget.selectedCoop)
                                .collection('environment')
                                .doc('actuators')
                                .update({
                              'fan': false,
                              'light': false,
                              'feeder': false,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('All OFF'),
                        ),
                      ],
                    ),
                  ],
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
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Switch(
              value: isOn,
              onChanged: (value) => onToggle(),
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
}
