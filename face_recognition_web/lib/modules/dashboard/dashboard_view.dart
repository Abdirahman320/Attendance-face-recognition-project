// lib/modules/dashboard/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:face_recognition_web/app/widgets/main_layout.dart';
import 'package:face_recognition_web/app/widgets/stat_card.dart';
// Paginated table
import 'package:face_recognition_web/app/widgets/paginated_table.dart';
import '../../app/data/session_model.dart';
import '../../app/controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find();

    return MainLayout(
      title: 'Attendance Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Top stat cards ===
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  StatCard(
                    title: "Total Students",
                    count: controller.totalStudents.value.toString(),
                    icon: Icons.people,
                    color: Colors.blueAccent,
                  ),
                  StatCard(
                    title: "Active Sessions",
                    count: controller.activeSessions.value.toString(),
                    icon: Icons.schedule,
                    color: Colors.orangeAccent,
                  ),
                  StatCard(
                    title: "Sessions Today",
                    count: controller.sessionsToday.value.toString(),
                    icon: Icons.today,
                    color: Colors.green,
                  ),
                ],
              );
            }),
            const SizedBox(height: 32),

            // === Recent Sessions ===
            const Text(
              'Recent Sessions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Obx(() {
              if (controller.isSessionsLoading.value) {
                return const Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.sessionsError.isNotEmpty) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Error loading sessions:',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        controller.sessionsError.value,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: controller.loadRecentSessions,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text(
                          'Retry',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.recentSessions.isEmpty) {
                return const Center(
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 40),
                      SizedBox(height: 10),
                      Text(
                        'No recent sessions found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return SizedBox(
                height: 350,
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TPaginatedDataTable(
                      columns: const [
                        DataColumn(
                          label: SelectableText(
                            "Subject",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: SelectableText(
                            "Date",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: SelectableText(
                            "Start Time",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: SelectableText(
                            "End Time",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: SelectableText(
                            "Status",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ), // NEW
                      ],
                      source: _RecentSessionsDataSource(
                        controller.recentSessions,
                      ),
                      rowsPerPage: 5,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// === Data source ===
class _RecentSessionsDataSource extends DataTableSource {
  final List<SessionModel> _sessions;
  _RecentSessionsDataSource(this._sessions);

  @override
  DataRow? getRow(int index) {
    assert(index >= 0 && index < _sessions.length);
    final session = _sessions[index];

    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(SelectableText(session.subject)),
        DataCell(SelectableText(session.dateFormatted)),
        DataCell(SelectableText(session.startTimeFormatted)),
        DataCell(SelectableText(session.endTimeFormatted)),
        DataCell(_StatusChip(session)), // NEW
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _sessions.length;

  @override
  int get selectedRowCount => 0;
}

// === Small chip widget to show Finished / Continue ===
class _StatusChip extends StatelessWidget {
  final SessionModel s;
  const _StatusChip(this.s);

  @override
  Widget build(BuildContext context) {
    final isFinished = s.statusLabel == "Finished";

    final fg = isFinished ? Colors.green : Colors.orange; // Finished / Continue
    final bg = fg.withOpacity(.12);

    return Chip(
      label: Text(
        s.statusLabel, // "Finished" or "Continue"
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
      backgroundColor: bg,
      side: BorderSide(color: fg.withOpacity(.35)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
