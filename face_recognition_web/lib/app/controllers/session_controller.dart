// 📁 lib/app/controllers/session_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SessionController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var sessions = <Map<String, dynamic>>[].obs;

  final subjectController = TextEditingController();
  final instructorController = TextEditingController();
  final startTime = Rxn<DateTime>();
  final endTime = Rxn<DateTime>();

  // These IDs should be passed when needed (e.g., from dropdowns or session creation form)
  late String facultyId;
  late String departmentId;
  late String classId;
  late String courseId;

  // Set parent path
  void setPath({
    required String faculty,
    required String department,
    required String class_,
    required String course,
  }) {
    facultyId = faculty;
    departmentId = department;
    classId = class_;
    courseId = course;
  }

  Future<void> createSession() async {
    if (subjectController.text.isEmpty ||
        instructorController.text.isEmpty ||
        startTime.value == null ||
        endTime.value == null) {
      Get.snackbar("Validation Error", "All fields are required");
      return;
    }

    final data = {
      "subject": subjectController.text.trim(),
      "instructor": instructorController.text.trim(),
      "start_time": startTime.value!.toIso8601String(),
      "end_time": endTime.value!.toIso8601String(),
      "created_at": FieldValue.serverTimestamp(),
      "students": [],
    };

    try {
      await _db
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('classes')
          .doc(classId)
          .collection('courses')
          .doc(courseId)
          .collection('sessions')
          .add(data);

      Get.snackbar("Success", "Session created successfully");
      clearForm();
      await loadSessions(); // optional
    } catch (e) {
      Get.snackbar("Error", "Failed to create session");
    }
  }

  Future<void> loadSessions() async {
    isLoading.value = true;
    try {
      final query = await _db
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('classes')
          .doc(classId)
          .collection('courses')
          .doc(courseId)
          .collection('sessions')
          .orderBy('start_time', descending: true)
          .get();

      sessions.value =
          query.docs.map((doc) => {...doc.data(), "id": doc.id}).toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to load sessions");
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    subjectController.clear();
    instructorController.clear();
    startTime.value = null;
    endTime.value = null;
  }
}
