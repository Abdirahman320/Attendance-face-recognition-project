// 📄 lib/app/utils/date_utils.dart

import 'package:intl/intl.dart';

DateTime? tryParseSessionDate(String? value) {
  if (value == null) return null;

  try {
    // Try ISO or standard format first
    return DateTime.tryParse(value) ??
        DateFormat(
          "dd MMMM yyyy 'at' HH:mm:ss 'UTC+3'",
        ).parse(value, true).toLocal();
  } catch (e) {
    print("❌ Failed to parse date: $value");
    return null;
  }
}
