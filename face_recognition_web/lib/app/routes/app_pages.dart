import 'package:face_recognition_web/app/bindings/AttendanceReport_Binding.dart';

import 'package:face_recognition_web/app/bindings/student_binding.dart';

import 'package:face_recognition_web/modules/attendance_report/attendance_report_view.dart';
import 'package:face_recognition_web/modules/create%20Session/create_session.dart';

import 'package:face_recognition_web/modules/students/student_view.dart';
import 'package:get/get.dart';
import '../bindings/dashboard_binding.dart';
import '../../modules/dashboard/dashboard_view.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.Students,
      page: () => StudentView(),
      binding: StudentBinding(),
    ),

    GetPage(
      name: Routes.AttendanceReport,
      page: () => AttendanceReportView(),
      binding: AttendanceReportBinding(),
    ),
    GetPage(name: Routes.CreateSession, page: () => CreateSession()),
    // GetPage(name: Routes.Attendance, page: () => AttendanceView()),
  ];
}
