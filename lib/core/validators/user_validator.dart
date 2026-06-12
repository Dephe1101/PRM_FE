/// Validator cho các input liên quan đến User Management.
/// Các rule được đồng bộ với [userValidation.ts] trên Backend.
class UserValidator {
  // --- GET /users (query params) ---

  /// search: string, optional, allow empty.
  /// Backend không giới hạn độ dài nhưng UX nên yêu cầu ít nhất 2 ký tự
  /// để tránh query quá rộng.
  static String? validateSearch(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < 2) {
      return 'Từ khóa phải có ít nhất 2 ký tự';
    }
    return null;
  }

  // --- PATCH /users/:id/status (body: isActive) ---
  // isActive là boolean — không cần validate trên mobile vì
  // được gửi trực tiếp từ code (true/false), không phải từ TextField.
  // Hàm này giữ lại để dùng nếu sau này có form manual input.

  static String? validateIsActive(bool? value) {
    if (value == null) return 'Trường isActive là bắt buộc';
    return null;
  }
}
