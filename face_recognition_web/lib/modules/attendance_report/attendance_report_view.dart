import 'package:face_recognition_web/app/utils/helpers/helper_functions.dart';
import 'package:face_recognition_web/app/widgets/paginated_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/attendance_report_controller.dart';
import '../../app/data/attendance_model.dart';
import '../../app/widgets/main_layout.dart'; // Import MainLayout

class AttendanceReportView extends StatelessWidget {
  final AttendanceReportController controller = Get.find();

  AttendanceReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Attendance Report", // Set the title dynamically
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Session Dropdown ===
              DropdownButton(
                hint: const Text("Select Session"),
                value: controller.selectedSession.value,
                items:
                    controller.sessions.map((session) {
                      return DropdownMenuItem(
                        value: session,
                        child: Text(
                          "${session.subject} (${session.startTimeFormatted}-${session.endTimeFormatted}) : ${session.dateFormatted}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  controller.selectedSession.value = value;
                  controller.fetchAttendance(value!.id);
                },
              ),

              const SizedBox(height: 20),

              // === Attendance Table ===
              Expanded(
                child:
                    controller.attendanceList.isEmpty
                        ? const Center(
                          child: Text("No attendance data available."),
                        )
                        : TPaginatedDataTable(
                          columns: const [
                            DataColumn(label: Text("Student ID")),
                            DataColumn(label: Text("Name")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Entry Time")),
                            DataColumn(label: Text("Exit Time")),
                            DataColumn(label: Text("Duration")),
                          ],
                          source: _AttendanceDataSource(
                            controller.attendanceList,
                          ),
                        ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _AttendanceDataSource extends DataTableSource {
  final List<AttendanceModel> records;

  _AttendanceDataSource(this.records);

  @override
  DataRow? getRow(int index) {
    if (index >= records.length) return null;
    final record = records[index];

    return DataRow(
      cells: [
        DataCell(Text(record.studentId)),
        DataCell(Text(record.name)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: record.status == "Present" ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              record.status,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        DataCell(
          Text(record.entryTime?.isNotEmpty == true ? record.entryTime! : "-"),
        ),
        DataCell(
          Text(record.exitTime?.isNotEmpty == true ? record.exitTime! : "-"),
        ),
        DataCell(
          Text(
            (record.duration != null && record.duration! > 0)
                ? formatDuration(record.duration!)
                : "-",
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => records.length;

  @override
  int get selectedRowCount => 0;
}
