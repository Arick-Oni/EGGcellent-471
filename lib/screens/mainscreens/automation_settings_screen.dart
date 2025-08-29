import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/schedule.dart';
import '../widgets/schedule_card.dart';

class AutomationSettings extends StatefulWidget {
  const AutomationSettings({super.key});

  @override
  State createState() => _AutomationSettingsState();
}

class _AutomationSettingsState extends State<AutomationSettings> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Schedule> feedingSchedules = [];
  List<Schedule> lightSchedules = [];
  List<Schedule> fanSchedules = [];

  bool isLoading = true;
  String errorMessage = '';

  final List<Map<String, String>> _weekDays = const [
    {'label': 'Monday', 'short': 'mon'},
    {'label': 'Tuesday', 'short': 'tue'},
    {'label': 'Wednesday', 'short': 'wed'},
    {'label': 'Thursday', 'short': 'thu'},
    {'label': 'Friday', 'short': 'fri'},
    {'label': 'Saturday', 'short': 'sat'},
    {'label': 'Sunday', 'short': 'sun'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllSchedules();
  }

  Future<void> _loadAllSchedules() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      feedingSchedules = await _fetchSchedules('feeding');
      lightSchedules = await _fetchSchedules('light');
      fanSchedules = await _fetchSchedules('fan');
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<List<Schedule>> _fetchSchedules(String type) async {
    final List<Schedule> out = [];
    final days = _weekDays.map((d) => d['short']!).toList();

    for (final day in days) {
      final col = _firestore
          .collection('sensors')
          .doc('schedule_and_threshold')
          .collection('${type}_schedule')
          .doc(day)
          .collection(day);

      final snapshot = await col.get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        out.add(Schedule(
          id: doc.id,
          days: [day],
          enabled: !(data['auto'] ?? false),
          details: {
            'startTime': data['start'],
            'endTime': data['end'],
            'auto': data['auto'] ?? false,
          },
        ));
      }
    }
    return out;
  }

  Future<void> _addEditSchedule(String type, {Schedule? existing}) async {
    String selectedDay = existing?.days.first ?? _weekDays.first['short']!;
    TimeOfDay? selectedStart;
    TimeOfDay? selectedEnd;

    if (existing != null && existing.details.isNotEmpty) {
      if (existing.details['startTime'] != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(
            existing.details['startTime'] * 1000);
        selectedStart = TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
      if (existing.details['endTime'] != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(
            existing.details['endTime'] * 1000);
        selectedEnd = TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
    }

    bool enabled = existing?.enabled ?? true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: Colors.grey[900],
            title: Text(
                '${existing == null ? "Add" : "Edit"} '
                '${type == "fan" ? "Fan" : '${type[0].toUpperCase()}${type.substring(1)}'} Schedule',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.grey[900],
                    decoration: const InputDecoration(
                      labelText: "Day of the week",
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    initialValue: selectedDay,
                    items: _weekDays
                        .map((e) => DropdownMenuItem(
                              value: e['short'],
                              child: Text(e['label']!,
                                  style: const TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedDay = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Start:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedStart ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => selectedStart = picked);
                          }
                        },
                        child: Text(
                            selectedStart != null
                                ? "${selectedStart!.hour.toString().padLeft(2, '0')}:${selectedStart!.minute.toString().padLeft(2, '0')}"
                                : "--:--",
                            style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 14),
                      const Text('End:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(width: 10),
                      TextButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedEnd ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() => selectedEnd = picked);
                            }
                          },
                          child: Text(
                              selectedEnd != null
                                  ? "${selectedEnd!.hour.toString().padLeft(2, '0')}:${selectedEnd!.minute.toString().padLeft(2, '0')}"
                                  : "--:--",
                              style: const TextStyle(color: Colors.white))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enabled',
                        style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Enable or disable this schedule',
                        style: TextStyle(color: Colors.white70)),
                    value: enabled,
                    onChanged: (val) => setState(() => enabled = val),
                    activeThumbColor: Colors.green,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  final now = DateTime.now();
                  int? startUnix;
                  int? endUnix;
                  bool auto = false;

                  if (selectedStart != null && selectedEnd != null) {
                    final startDt = DateTime(now.year, now.month, now.day,
                        selectedStart!.hour, selectedStart!.minute);
                    final endDt = DateTime(now.year, now.month, now.day,
                        selectedEnd!.hour, selectedEnd!.minute);

                    startUnix = startDt.millisecondsSinceEpoch ~/ 1000;
                    endUnix = endDt.millisecondsSinceEpoch ~/ 1000;
                    auto = false;
                  } else {
                    startUnix = null;
                    endUnix = null;
                    auto = true;
                  }

                  final scheduleId = existing?.id ?? const Uuid().v4();

                  final scheduleData = {
                    'start': startUnix,
                    'end': endUnix,
                    'auto': auto,
                  };

                  final col = _firestore
                      .collection('sensors')
                      .doc('schedule_and_threshold')
                      .collection('${type}_schedule')
                      .doc(selectedDay)
                      .collection(selectedDay);

                  await col.doc(scheduleId).set(scheduleData);

                  await _loadAllSchedules();

                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              )
            ],
          );
        });
      },
    );
  }

  String? formattedTime(int? unixTimestamp) {
    if (unixTimestamp == null) return null;
    final dt = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF181824),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Automation Settings',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(errorMessage,
                        style: const TextStyle(color: Colors.red)))
                : ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      _buildSection('Feeding Schedule', feedingSchedules,
                          'feeding', Colors.grey[900]!),
                      _buildSection('Light Schedule', lightSchedules, 'light',
                          Colors.grey[850]!),
                      _buildSection('Fan Schedule', fanSchedules, 'fan',
                          Colors.grey[900]!),
                    ],
                  ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'mainButton',
          backgroundColor: Colors.green.shade700,
          icon: const Icon(Icons.home, color: Colors.white),
          label: const Text('Main Menu', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false);
          },
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, List<Schedule> schedules, String type, Color color) {
    Widget sectionIcon;
    if (type == 'feeding') {
      sectionIcon = const Icon(Icons.restaurant, color: Colors.white);
    } else if (type == 'light') {
      sectionIcon = const Icon(Icons.lightbulb, color: Colors.white);
    } else if (type == 'fan') {
      sectionIcon =
          const Text('💨', style: TextStyle(fontSize: 22, color: Colors.white));
    } else {
      sectionIcon = const Icon(Icons.calendar_today, color: Colors.white);
    }

    return Card(
      elevation: 4,
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                sectionIcon,
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
                  tooltip: "Add $title",
                  onPressed: () => _addEditSchedule(type),
                ),
              ],
            ),
            schedules.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 10, top: 4),
                    child: Text(
                      'No schedules. Click "+" to add one.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : Column(
                    children: schedules
                        .map(
                          (schedule) => ScheduleCard(
                            schedule: schedule,
                            type: type,
                            onEdit: () =>
                                _addEditSchedule(type, existing: schedule),
                            onDelete: () async {
                              if (schedule.days.isNotEmpty) {
                                final col = _firestore
                                    .collection('sensors')
                                    .doc('schedule_and_threshold')
                                    .collection('${type}_schedule')
                                    .doc(schedule.days.first)
                                    .collection(schedule.days.first);
                                await col.doc(schedule.id).delete();
                                await _loadAllSchedules();
                              }
                            },
                            timeFormatter: formattedTime,
                          ),
                        )
                        .toList(),
                  )
          ],
        ),
      ),
    );
  }
}
