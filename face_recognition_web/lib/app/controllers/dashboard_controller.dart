// lib/app/controllers/dashboard_controller.dart
import 'package:face_recognition_web/app/services/api_service.dart';
import 'package:face_recognition_web/app/data/session_model.dart'; // Import your SessionModel
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardController extends GetxController {
  // --- Existing reactive variables for stats ---
  var totalStudents = 0.obs;
  var activeSessions = 0.obs;
  var sessionsToday = 0.obs;
  var isLoading = true.obs; // For main stats loading
  // --- End existing variables ---

  // --- Reactive variables for recent sessions ---
  var recentSessions = <SessionModel>[].obs; // Use SessionModel list
  var isSessionsLoading = false.obs; // Separate loading state for sessions
  var sessionsError = ''.obs; // To hold any error messages for sessions
  // --- End new variables ---

  @override
  void onInit() {
    super.onInit();
    loadDashboardStats();
    // Load recent sessions after main stats are loaded
    // We can use ever() to react to isLoading becoming false
    ever(isLoading, (value) {
      if (value == false) {
        loadRecentSessions();
      }
    });
    // Or, call it directly here, assuming the API is ready
    // loadRecentSessions();
  }

  Future<void> loadDashboardStats() async {
    try {
      isLoading.value = true;

      // ✅ Total students (using your existing service)
      final students = await ApiService.getStudents();
      totalStudents.value = students.length;

      // ✅ Dashboard summary (active + today's session) from Flask
      final response = await http.get(
        Uri.parse("http://127.0.0.1:5000/api/dashboard"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          activeSessions.value = data['active_sessions'] ?? 0;
          sessionsToday.value = data['sessions_today'] ?? 0;
        } else {
          print("⚠️ Unexpected data format for dashboard summary.");
          activeSessions.value = 0;
          sessionsToday.value = 0;
        }
      } else {
        print(
          "⚠️ Failed to load dashboard summary, status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("⚠️ Error loading dashboard stats: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Method to load and process recent sessions ---
  Future<void> loadRecentSessions() async {
    if (isSessionsLoading.value) return; // Prevent concurrent calls
    try {
      isSessionsLoading.value = true;
      sessionsError.value = '';

      final response = await http.get(
        Uri.parse("http://127.0.0.1:5000/api/sessions"),
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        if (data is List) {
          // Convert the raw JSON map data into SessionModel objects
          List<SessionModel> allSessions =
              data
                  .map((item) {
                    if (item is Map<String, dynamic>) {
                      return SessionModel.fromJson(item);
                    } else {
                      print(
                        "Warning: Skipping invalid session item in response: $item",
                      );
                      return null;
                    }
                  })
                  .where((session) => session != null)
                  .cast<SessionModel>()
                  .toList();

          // Sort sessions by startTime descending (latest first)
          allSessions.sort((a, b) {
            if (a.startTime == null && b.startTime == null) return 0;
            if (a.startTime == null) return 1;
            if (b.startTime == null) return -1;
            return b.startTime!.compareTo(a.startTime!);
          });

          // Take the first N sessions as "recent" (e.g., last 5)
          // You can adjust the number '5' or implement full pagination later
          final recent = allSessions.toList();

          recentSessions.assignAll(recent);
          print("✅ Loaded ${recent.length} recent sessions.");
        } else {
          final errorMsg =
              data is Map<String, dynamic>
                  ? data['error']?.toString() ??
                      'Invalid session data format received.'
                  : 'Invalid session data format received.';
          sessionsError.value = errorMsg;
          recentSessions.clear();
          print("⚠️ Error loading recent sessions: $errorMsg");
        }
      } else {
        final errorMsg =
            'Failed to load sessions (Status: ${response.statusCode})';
        sessionsError.value = errorMsg;
        recentSessions.clear();
        print("⚠️ $errorMsg");
      }
    } catch (e, stackTrace) {
      final errorMsg = 'Error loading recent sessions: $e';
      sessionsError.value = errorMsg;
      recentSessions.clear();
      print("⚠️ $errorMsg\nStack trace: $stackTrace");
    } finally {
      isSessionsLoading.value = false;
    }
  }

  // --- End method ---
}
