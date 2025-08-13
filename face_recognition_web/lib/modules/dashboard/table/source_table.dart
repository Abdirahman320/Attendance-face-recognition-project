
import 'package:face_recognition_web/app/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionsDataSource extends DataTableSource {
  final List<Map<String, dynamic>> sessions;

  SessionsDataSource(this.sessions);

  @override
  DataRow? getRow(int index) {
    if (index >= sessions.length) return null;
    final session = sessions[index];
    final start = tryParseSessionDate(session['start_time']);
    final end = tryParseSessionDate(session['end_time']);

    return DataRow(
      cells: [
        DataCell(Text(session['subject'] ?? '')),
        DataCell(Text(session['instructor'] ?? '')),
        DataCell(
          Text(start != null ? DateFormat.yMd().add_jm().format(start) : ''),
        ),
        DataCell(Text(end != null ? DateFormat.jm().format(end) : '')),
        DataCell(Text("${session['students']?.length ?? 0}")),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => sessions.length;
  @override
  int get selectedRowCount => 0;
}
