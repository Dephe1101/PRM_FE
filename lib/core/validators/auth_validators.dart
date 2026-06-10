class AuthValidators {
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'Tên người dùng không được để trống';
    if (value.length < 3) return 'Tên người dùng phải có ít nhất 3 ký tự';
    if (value.length > 50) return 'Tên người dùng không được vượt quá 50 ký tự';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email không được để trống';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mật khẩu không được để trống';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    if (value.length > 128) return 'Mật khẩu không được vượt quá 128 ký tự';
    return null;
  }
}

