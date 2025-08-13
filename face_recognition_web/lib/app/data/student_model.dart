// 📄 lib/app/data/student_model.dart

class StudentModel {
  final String studentId;
  final String name;
  final String faculty;
  final String department;
  final String status;
  final String studentClass;

  StudentModel({
    required this.studentId,
    required this.name,
    required this.faculty,
    required this.department,
    required this.status,
    required this.studentClass,
  });

  // 🔄 From JSON (from Flask API)
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentId: json['student_id'] ?? '',
      name: json['name'] ?? '',
      faculty: json['faculty'] ?? '',
      department: json['department'] ?? '',
      status: json['status'] ?? '',
      studentClass: json['class'] ?? '',
    );
  }

  // 🔁 To JSON (for saving, if needed)
  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
      'faculty': faculty,
      'department': department,
      'status': status,
      'class': studentClass,
    };
  }
}
