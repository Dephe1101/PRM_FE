class WordValidator {
  static String? validateTopic(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng chọn Topic';
    }
    return null;
  }

  static String? validateHiragana(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hiragana không được để trống';
    }
    return null;
  }

  static String? validateMeaning(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nghĩa của từ không được để trống';
    }
    return null;
  }

  static String? validateAudioUrl(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final uri = Uri.tryParse(value.trim());
      if (uri == null || !uri.hasAbsolutePath) {
        return 'Audio URL không hợp lệ (phải là một đường dẫn hợp lệ)';
      }
    }
    return null;
  }
}
