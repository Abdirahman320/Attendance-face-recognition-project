// 📄 lib/app/data/attendance_model.dart

class AttendanceModel {
  final String studentId;
  final String name;
  final String status;
  final String? entryTime;
  final String? exitTime;
  final double? duration;

  AttendanceModel({
    required this.studentId,
    required this.name,
    required this.status,
    this.entryTime,
    this.exitTime,
    this.duration,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      studentId: map['student_id'] ?? '-',
      name: map['name'] ?? '-',
      status: map['status'] ?? '',
      entryTime: map['entry_time'],
      exitTime: map['exit_time'],
      duration:
          map['duration'] != null ? (map['duration'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'name': name,
      'status': status,
      'entry_time': entryTime,
      'exit_time': exitTime,
      'duration': duration,
    };
  }
}
