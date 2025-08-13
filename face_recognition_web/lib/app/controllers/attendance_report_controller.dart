import 'dart:convert';
import 'package:face_recognition_web/app/data/attendance_model.dart';
import 'package:face_recognition_web/app/data/session_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AttendanceReportController extends GetxController {
  var isLoading = true.obs;
  var sessions = <SessionModel>[].obs;
  var selectedSession = Rxn<SessionModel>();

  //var attendanceList = [].obs; // each item will be a map
  var attendanceList = <AttendanceModel>[].obs;

  final String baseUrl = "http://127.0.0.1:5000/api";

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse("$baseUrl/sessions"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        sessions.value = List<SessionModel>.from(
          data.map((e) => SessionModel.fromJson(e)),
        );
      }
    } catch (e) {
      print("⚠️ Error loading sessions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAttendance(String sessionId) async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse("$baseUrl/attendance/session/$sessionId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        attendanceList.value = List<AttendanceModel>.from(
          data['students'].map((e) => AttendanceModel.fromMap(e)),
        );
        // ✅ FIXED
      } else {
        print("❌ Failed to load attendance");
        attendanceList.clear();
      }
    } catch (e) {
      print("⚠️ Error fetching attendance: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
