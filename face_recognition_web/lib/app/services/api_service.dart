import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:5000/api";

  // static const String baseUrl = "http://192.168.1.5:5000/api";

  // Change for deployment

  // 🟢 Get all sessions with students
  static Future<List<dynamic>> getSessions() async {
    final response = await http.get(Uri.parse("$baseUrl/sessions"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load sessions: ${response.statusCode}");
    }
  }

  // 🔵 Future: Get all students
  static Future<List<dynamic>> getStudents() async {
    final response = await http.get(Uri.parse("$baseUrl/students"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load students");
    }
  }

  static Future<Map<String, dynamic>> getTodayAttendance() async {
    final response = await http.get(Uri.parse("$baseUrl/attendance/today"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch attendance counts");
    }
  }
}
