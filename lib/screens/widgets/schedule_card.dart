import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../../utils/constants.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final String type;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? Function(int?)? timeFormatter;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.type,
    required this.onEdit,
    required this.onDelete,
    this.timeFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final details = schedule.details;
    final showTimes =
        details.containsKey('startTime') && details.containsKey('endTime');
    String formattedTimes = '';
    if (showTimes && timeFormatter != null) {
      formattedTimes =
          '${timeFormatter!(details['startTime'])} - ${timeFormatter!(details['endTime'])}';
    }

    // Get appropriate icon and color based on schedule type
    IconData typeIcon;
    Color typeColor;
    switch (type) {
      case 'feeding':
        typeIcon = Icons.restaurant;
        typeColor = Colors.green;
        break;
      case 'light':
        typeIcon = Icons.lightbulb;
        typeColor = Colors.amber;
        break;
      case 'fan':
        typeIcon = Icons.air;
        typeColor = Colors.blue;
        break;
      default:
        typeIcon = Icons.schedule;
        typeColor = Colors.grey;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              typeColor.withOpacity(0.1),
              typeColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${type[0].toUpperCase()}${type.substring(1)} Schedule',
                          style: bodyText16w600(color: black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Days: ${schedule.days.join(", ")}',
                          style: bodyText14normal(color: darkGray),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: schedule.enabled
                              ? green.withOpacity(0.2)
                              : red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              schedule.enabled
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 14,
                              color: schedule.enabled ? green : red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              schedule.enabled ? 'Active' : 'Inactive',
                              style: bodyText12w600(
                                color: schedule.enabled ? green : red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (showTimes && formattedTimes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: darkGray),
                      const SizedBox(width: 8),
                      Text(
                        formattedTimes,
                        style: bodyText14w500(color: black),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: white,
                      foregroundColor: green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: green),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit, size: 16),
                        const SizedBox(width: 4),
                        Text('Edit', style: bodyText12w600(color: green)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: white,
                      foregroundColor: red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: red),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.delete, size: 16),
                        const SizedBox(width: 4),
                        Text('Delete', style: bodyText12w600(color: red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
