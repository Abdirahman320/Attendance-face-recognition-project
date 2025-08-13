import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return Colors.green;
    case 'inactive':
      return Colors.red;
    case 'suspended':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

Future<DateTime?> pickDateTime(BuildContext context) async {
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  );
  if (date == null) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  if (time == null) return null;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}



String formatDuration(double minutes) {
  final int totalMinutes = minutes.floor();
  final int hours = totalMinutes ~/ 60;
  final int mins = totalMinutes % 60;

  if (hours > 0) {
    return "${hours}h ${mins}min";
  } else {
    return "${mins} min";
  }
}

