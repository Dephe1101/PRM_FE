class DateTimeUtils {
  /// Chuyển đổi DateTime (thường là UTC từ DB) sang giờ chuẩn Việt Nam (UTC+7)
  /// Giúp hiển thị giờ chính xác bất kể timezone của thiết bị người dùng.
  static DateTime toVietnamTime(DateTime time) {
    final utcTime = time.isUtc ? time : time.toUtc();
    return utcTime.add(const Duration(hours: 7));
  }

  /// Lấy thời gian hiện tại theo chuẩn giờ Việt Nam (UTC+7)
  static DateTime nowVietnamTime() {
    return toVietnamTime(DateTime.now().toUtc());
  }

  /// Parse chuỗi ISO8601 từ Database (VD: "2023-10-15T08:30:00Z") thành giờ Việt Nam
  static DateTime? parseToVietnamTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      final parsedTime = DateTime.parse(isoString);
      return toVietnamTime(parsedTime);
    } catch (e) {
      return null;
    }
  }

  /// Trả về chuỗi format dễ đọc: HH:mm dd/MM/yyyy (VD: 14:30 15/10/2023)
  static String formatVietnamTime(DateTime vnTime) {
    final day = vnTime.day.toString().padLeft(2, '0');
    final month = vnTime.month.toString().padLeft(2, '0');
    final year = vnTime.year;
    
    final hour = vnTime.hour.toString().padLeft(2, '0');
    final minute = vnTime.minute.toString().padLeft(2, '0');
    
    return '$hour:$minute $day/$month/$year';
  }
}
