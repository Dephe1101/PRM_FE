# 🗺️ FLUTTER ARCHITECTURE & TECH STACK MAPPING

## 1. Mục đích
Tài liệu này đóng vai trò là "Bản đồ tư duy" giúp các lập trình viên chuyển đổi mượt mà từ hệ sinh thái Web (React/Node.js) sang Mobile (Flutter). Nó định nghĩa các package tương đương, cách xử lý Form/Validation, kiến trúc phân lớp và cấu trúc thư mục chuẩn.

---

## 2. Tech Stack Mapping (React ➔ Flutter)

| Chức năng | Web / React Ecosystem | Mobile / Flutter Ecosystem | Ghi chú / Cách triển khai trong Flutter |
| :--- | :--- | :--- | :--- |
| **HTTP Client** | Axios | **Dio** | Có Interceptors để xử lý Refresh Token, gắn Header. |
| **Routing** | React Router | **GoRouter** | Hỗ trợ Deep link, Nested Route và Redirect Guard (bảo vệ route). |
| **Global State**| Zustand | **Riverpod** | Quản lý state gọn nhẹ, Dependency Injection an toàn (tránh lỗi runtime). |
| **Data Fetching**| React Query | **Riverpod** (`AsyncNotifier`)| Tự động cache data, quản lý trạng thái Loading/Error/Success. |
| **Styling** | TailwindCSS | **ThemeData + Core Widgets**| Không có CSS. Định nghĩa mã màu/font trong `ThemeData`, dùng `SizedBox` thay cho margin/padding. |
| **Safe Parsing**| Zod | **Freezed + JsonSerializable**| Sinh code tự động, parse JSON an toàn tuyệt đối, tránh lỗi Null-Pointer. |
| **Form Handler**| react-hook-form | **Flutter Form + Controller** | Dùng `GlobalKey<FormState>` và `TextEditingController` để quản lý form. |
| **Local Storage**| localStorage | **FlutterSecureStorage** | Lưu AccessToken/RefreshToken mã hóa an toàn ở cấp hệ điều hành. |

---

## 3. Chiến lược xử lý Form & Validation (Thay thế React-Hook-Form + Zod)

Trong React, bạn dùng `react-hook-form` để quản lý state của form (tránh re-render) và `zod` để validate (kiểu dữ liệu + rule). Trong Flutter, chúng ta kết hợp **Native Form** và **Lớp Validator Custom** theo mô hình sau:

### 3.1. Quản lý Form State (Thay cho `react-hook-form`)
Thay vì dùng thư viện bên ngoài, Flutter cung cấp sẵn Widget `Form` cực kỳ mạnh mẽ.
- Bọc toàn bộ ô nhập liệu bằng Widget `Form(key: formKey, ...)`.
- Sử dụng `TextFormField` thay cho `TextField`.
- Khi cần submit, gọi `formKey.currentState!.validate()` để kích hoạt chạy toàn bộ rule validation cùng lúc.

### 3.2. Validation Rules (Thay cho `Zod`)
Zod đảm nhiệm 2 việc: Safe Parse (ép kiểu) và Rules (độ dài, regex).
- **Safe Parse:** Đã được xử lý 100% bằng thư viện **Freezed**.
- **Rules:** Tạo một file `lib/core/utils/form_validators.dart` chứa các static functions để validate từng field (giống cách viết schema của Zod).

**Ví dụ lớp FormValidators chuẩn:**
```dart
class FormValidators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email không được để trống';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mật khẩu không được để trống';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }
}