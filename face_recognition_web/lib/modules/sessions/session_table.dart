import 'package:flutter/material.dart';

class SessionTable extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;

  const SessionTable({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(child: Text("📭 No sessions available."));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Subject")),
          DataColumn(label: Text("Instructor")),
          DataColumn(label: Text("Start Time")),
          DataColumn(label: Text("End Time")),
          DataColumn(label: Text("Students")),
        ],
        rows: sessions.map((session) {
          return DataRow(cells: [
            DataCell(Text(session['subject'] ?? '')),
            DataCell(Text(session['instructor'] ?? '')),
            DataCell(Text(session['start_time'] ?? '')),
            DataCell(Text(session['end_time'] ?? '')),
            DataCell(Text("${session['students']?.length ?? 0}")),
          ]);
        }).toList(),
      ),
    );
  }
}