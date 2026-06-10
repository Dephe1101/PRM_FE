# 🌐 PHASE F-2: NETWORK (DIO) & ROUTING (GOROUTER)

## 1. Core Principles (Context for AI)
- **Nhiệm vụ:** Thiết lập lớp giao tiếp API và điều hướng màn hình.
- **Tech Stack:** `dio`, `dio_cookie_manager`, `cookie_jar` (BẮT BUỘC để xử lý httpOnly cookie từ BE), `go_router`, `flutter_dotenv`.
- **Zero Hardcode:** Base URL lấy từ `.env`. Các mã lỗi map 100% với `ERROR_CODES` của Backend Node.js.

## 2. Setup Network Layer (Data Layer)
**Đường dẫn:** `lib/core/network/`
1. **`cookie_manager_setup.dart`**: Khởi tạo `CookieJar` và `DioCookieManager`. Vì BE Node.js trả Refresh Token qua `set-cookie` (httpOnly), Dio BẮT BUỘC phải dùng CookieManager để tự động lưu và gửi lại cookie này trong API `/v1/auth/refresh`.
2. **`dio_client.dart`**:
   - Cấu hình base URL `/api/v1`, timeout 15s.
   - Thêm `DioCookieManager(cookieJar)`.
3. **`auth_interceptor.dart`**:
   - `onRequest`: Lấy `accessToken` từ bộ nhớ (Riverpod/SecureStorage) gắn vào Header `Authorization: Bearer <token>`.
   - `onError`: Nếu BE trả về HTTP 401 và mã `TOKEN_EXPIRED`, tự động khóa Dio (`dio.interceptors.requestLock`), gọi API `/v1/auth/refresh` (cookie tự động được gửi đi), lấy `accessToken` mới, mở khóa và retry request lỗi.
4. **`api_error_handler.dart`**: Map JSON error từ BE (`{ success: false, code: "...", message: "..." }`) thành `AppException`.

## 3. Setup Routing Layer
**Đường dẫn:** `lib/routes/app_router.dart`
- Dùng `GoRouter`.
- **Định nghĩa Routes:** `/login`, `/register`, `/home`, `/topics/:levelId`, `/flashcard/:topicId`, `/game`.
- **Guard (Bảo vệ Route):** Lắng nghe `authControllerProvider` (Riverpod). Nếu truy cập `/home` mà chưa có `accessToken`, redirect về `/login`.