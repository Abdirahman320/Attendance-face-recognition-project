import 'package:intl/intl.dart';

enum SessionStatus { active, finished }

class SessionModel {
  final String id;
  final String subject;
  final DateTime? startTime;
  final DateTime? endTime;
  final SessionStatus? statusFromApi;

  SessionModel({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    this.statusFromApi,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val);
      } catch (e1) {
        try {
          return DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(val);
        } catch (e2) {
          try {
            return DateFormat("d MMMM yyyy 'at' HH:mm:ss 'UTC'Z").parseUtc(val);
          } catch (e3) {
            print("❌ Failed to parse datetime '$val'");
            return null;
          }
        }
      }
    }

    SessionStatus? apiStatus;
    final s = (json["status"] as String?)?.toLowerCase();
    if (s == "finished") apiStatus = SessionStatus.finished;
    if (s == "ongoing") apiStatus = SessionStatus.active;

    return SessionModel(
      id: json["id"] ?? "",
      subject: json["subject"] ?? "",
      startTime: parse(json["start_time"]?.toString()),
      endTime: parse(json["end_time"]?.toString()),
      statusFromApi: apiStatus,
    );
  }

  String get startTimeFormatted =>
      startTime != null ? _formatTime(startTime!.toLocal()) : "---";

  String get endTimeFormatted =>
      endTime != null ? _formatTime(endTime!.toLocal()) : "---";

  String get dateFormatted =>
      startTime != null ? _formatDate(startTime!.toLocal()) : "-";

  String _formatTime(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  String _formatDate(DateTime dt) =>
      "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

  /// Compute status if API didn’t send it
  SessionStatus get status {
    if (statusFromApi != null) return statusFromApi!;
    if (endTime != null && DateTime.now().isAfter(endTime!)) {
      return SessionStatus.finished;
    }
    return SessionStatus.active;
  }

  /// Label for UI
  String get statusLabel {
    switch (status) {
      case SessionStatus.finished:
        return "Finished";
      case SessionStatus.active:
        return "Continue";
    }
  }
}
