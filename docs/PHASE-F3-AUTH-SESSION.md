# 🔐 PHASE F-3: AUTHENTICATION & SESSION

## 1. Core Principles (Context for AI)
- **Nhiệm vụ:** Giao tiếp với BE Phase 3 (Đăng ký, Đăng nhập, Lấy thông tin User, Logout).
- **Tech Stack:** `Riverpod` (State), `Freezed` (Model).
- **Lưu ý:** Backend đã lo việc xoay vòng Refresh Token bằng Cookie. Mobile chỉ cần quản lý `accessToken` trong RAM và lưu vào `FlutterSecureStorage` để dùng khi khởi động lại app.

## 2. Data & Domain Layer
**Đường dẫn:** `lib/features/auth/`
- **Model (`user_model.dart`):** Dùng `@freezed`. Chứa `_id`, `username`, `email`, `role`, `level`, `xp`, `coins`. (Map đúng schema Mongoose BE).
- **Datasource (`auth_remote_datasource.dart`):** - Gọi POST `/auth/login`, POST `/auth/register`. 
  - Gọi GET `/auth/me`.
  - Gọi POST `/auth/logout` (xóa cookie trên BE) và `/auth/logout-all`.
- **Repository (`auth_repository_impl.dart`):** Xử lý Either<Failure, User>. Lưu `accessToken` xuống Secure Storage.

## 3. Presentation Layer
- **State (`auth_controller.dart`):** Dùng `AsyncNotifier<UserModel?>`. Xử lý các hàm `login`, `register`, `logout`.
- **UI (`login_screen.dart`, `register_screen.dart`):** - Form validation: Bắt buộc dùng text tiếng Việt giống hệt BE (VD: "Email không được để trống").
  - Hiển thị lỗi qua Custom Snackbar khi BE trả về `INVALID_CREDENTIALS` hoặc `EMAIL_EXISTS`.