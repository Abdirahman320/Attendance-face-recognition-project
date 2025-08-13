// 📄 lib/app/tables/student_table.dart

import 'package:face_recognition_web/app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:face_recognition_web/app/data/student_model.dart';
import 'package:face_recognition_web/app/widgets/paginated_table.dart';

class StudentTable extends StatelessWidget {
  final List<StudentModel> students;

  const StudentTable({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return const Center(child: Text("📭 No students available."));
    }

    return TPaginatedDataTable(
      columns: const [
        DataColumn(label: SelectableText("ID")),
        DataColumn(label: SelectableText("Name")),
        DataColumn(label: SelectableText("Faculty")),
        DataColumn(label: SelectableText("Department")),
        DataColumn(label: SelectableText("Class")),
        DataColumn(label: SelectableText("Status")),
      ],
      source: _StudentDataSource(students),
    );
  }
}

class _StudentDataSource extends DataTableSource {
  final List<StudentModel> students;

  _StudentDataSource(this.students);

  @override
  DataRow? getRow(int index) {
    if (index >= students.length) return null;
    final student = students[index];

    return DataRow(
      cells: [
        DataCell(SelectableText(student.studentId)),
        DataCell(SelectableText(student.name)),
        DataCell(SelectableText(student.faculty)),
        DataCell(SelectableText(student.department)),
        DataCell(SelectableText(student.studentClass)),

        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: getStatusColor(student.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              student.status,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => students.length;

  @override
  int get selectedRowCount => 0;
}
