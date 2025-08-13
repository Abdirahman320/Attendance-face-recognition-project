// 📄 lib/app/controllers/student_controller.dart

import 'package:face_recognition_web/app/data/student_model.dart';
import 'package:get/get.dart';

import '../services/api_service.dart';

class StudentController extends GetxController {
  var allStudents = <StudentModel>[].obs;
  var filteredStudents = <StudentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }

  var isLoading = false.obs;

  Future<void> loadStudents() async {
    try {
      isLoading.value = true;

      final students = await ApiService.getStudents();
      final parsed =
          students
              .map((s) => StudentModel.fromJson(s as Map<String, dynamic>))
              .toList();
      allStudents.assignAll(parsed);
      filteredStudents.assignAll(parsed);
    } catch (e) {
      print("Error loading students: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterStudents(String query) {
    print("🔍 Searching for: $query"); // Debug log

    if (query.isEmpty) {
      filteredStudents.assignAll(allStudents);
      return;
    }

    final lower = query.toLowerCase();

    final filtered =
        allStudents.where((student) {
          print(
            "➡️ Checking: ${student.name} / ${student.studentId}",
          ); // See values
          return student.name.toLowerCase().contains(lower) ||
              student.studentId.toLowerCase().contains(lower);
        }).toList();

    print("✅ Matches: ${filtered.length}");

    filteredStudents.assignAll(filtered);
  }
}
