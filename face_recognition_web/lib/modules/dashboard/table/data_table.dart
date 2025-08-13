import 'package:face_recognition_web/app/widgets/paginated_table.dart';
import 'package:face_recognition_web/modules/dashboard/table/source_table.dart';
import 'package:flutter/material.dart';

class RecentSessionsTable extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;

  const RecentSessionsTable({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return TPaginatedDataTable(
      columns: const [
        DataColumn(label: Text("Subject")),
        DataColumn(label: Text("Instructor")),
        DataColumn(label: Text("Start Time")),
        DataColumn(label: Text("End Time")),
      ],
      source: SessionsDataSource(sessions),
    );
  }
}
