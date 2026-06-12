class LevelValidator {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tên cấp độ không được để trống';
    }
    if (value.trim().length < 2) {
      return 'Tên cấp độ phải có ít nhất 2 ký tự';
    }
    return null;
  }

  static String? validateOrderIndex(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Thứ tự hiển thị không được để trống';
    }
    final number = int.tryParse(value.trim());
    if (number == null || number < 0) {
      return 'Thứ tự hiển thị phải là số nguyên >= 0';
    }
    return null;
  }
}
