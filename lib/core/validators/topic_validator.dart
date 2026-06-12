class TopicValidator {
  static String? validateLevel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng chọn cấp độ (Level)';
    }
    return null;
  }

  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tên chủ đề không được để trống';
    }
    if (value.trim().length < 2) {
      return 'Tên chủ đề phải có ít nhất 2 ký tự';
    }
    return null;
  }

  static String? validateOrderIndex(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final number = int.tryParse(value.trim());
      if (number == null || number < 0) {
        return 'Thứ tự hiển thị phải là số nguyên >= 0';
      }
    }
    return null;
  }
}
