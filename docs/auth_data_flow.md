# Luồng Tương Tác & Dữ Liệu (Data Flow) - Ghi Chú Theo File

Dưới đây là sơ đồ chi tiết giải phẫu luồng chạy của ứng dụng từ lúc người dùng thao tác trên màn hình cho đến khi API phản hồi, đính kèm chính xác **tên các file đảm nhận từng tác vụ**.

---

## Bước 1: Người dùng tương tác tại UI Screen
**📍 File:** `lib/features/auth/views/login_screen.dart`

Người dùng điền thông tin và bấm nút `PrimaryButton(text: 'Đăng nhập')`. Màn hình này sẽ kích hoạt hàm nội bộ `_onLogin()`. Ngay dòng đầu tiên của hàm, ứng dụng sẽ thực hiện gọi:
```dart
if (!_formKey.currentState!.validate()) return;
```

## Bước 2: Kiểm tra dữ liệu tại chỗ (Local Validation)
**📍 File:** `lib/core/validators/auth_validators.dart`

Hàm `validate()` ở trên tự động quét qua các `CustomTextField`. Nó tìm đến hàm tĩnh `AuthValidators.email` và `AuthValidators.password` được truyền vào trong TextField.
- Nếu email sai định dạng, `AuthValidators` lập tức trả về chuỗi `"Email không hợp lệ"`.
- Widget `CustomTextField` tự động hiện chữ màu đỏ. Quá trình dừng tại đây, **không có bất kỳ API nào được gọi**.
- Ngược lại, nếu dữ liệu đạt chuẩn, luồng code chạy tiếp xuống dưới.

## Bước 3: Đẩy xuống Tầng Trạng Thái (State Controller)
**📍 File:** `lib/features/auth/controllers/auth_controller.dart`

Từ UI, code tiếp tục chạy lệnh:
```dart
await ref.read(authControllerProvider.notifier).login(email, password);
```
Tại hàm `login()` của file `auth_controller.dart`:
1. `state = state.copyWith(isLoading: true, errorMessage: null)`: Cập nhật trạng thái loading. Giao diện (file `login_screen.dart`) lập tức vẽ lại (rebuild) nút Đăng nhập thành **Vòng tròn Loading xoay tròn**.
2. Nó gọi tiếp hàm `login` của tầng Repository bên dưới.

## Bước 4: Chuyển tiếp & Map Dữ Liệu (Repository Layer)
**📍 File:** `lib/features/auth/repositories/auth_repository.dart`

Repository đóng vai trò trung gian. Nó gọi hàm `login` từ `AuthRemoteDataSource`. Tùy thuộc vào kết quả trả về:
- Cố gắng parse JSON từ backend thành `UserModel`.
- Bọc vào `Right(UserModel)` (Nếu thành công) hoặc `Left(Failure)` (Nếu thất bại) bằng thư viện `fpdart`.

## Bước 5: Thực thi Gọi Mạng (Network Data Source)
**📍 File:** `lib/features/auth/data/auth_remote_data_source.dart`
**📍 File:** `lib/core/constants/api_constants.dart`

Bên trong `AuthRemoteDataSource`, ứng dụng dùng đối tượng `dio` để thực hiện cú request thực tế:
```dart
final response = await dio.post(
  ApiConstants.login, // Lấy đường dẫn API '/auth/login'
  data: {'email': email, 'password': password},
);
```
- Nếu backend NodeJS (`BE/src/routes/v1/authRoute.ts`) trả về HTTP `200 OK`, thư viện `dio_cookie_manager` (được cấu hình ở `lib/core/network/dio_client.dart`) sẽ tự động nhặt `refreshToken` lưu vào máy. Hàm trả về data thành công.

## Bước 6: Xử Lý Lỗi Tập Trung (Khi Backend từ chối)
**📍 File:** `lib/core/network/api_error_handler.dart`
**📍 File:** `lib/core/exceptions/app_exception.dart`

Nếu Backend trả về lỗi (Ví dụ: HTTP 400 Joi Validation hoặc HTTP 401 Sai mật khẩu), Dio sẽ văng `DioException`.
Khối `catch` ở Data Source bắt được, nó truyền lỗi này cho `ApiErrorHandler.handle(e)`.
- File `api_error_handler.dart` đọc JSON của Backend: Lấy ra chữ `"VALIDATION_ERROR"` và `message` ("Sai mật khẩu").
- Nó bọc lại thành class `AppException`. Repository tiếp nhận và bọc thành `Failure` đẩy lên lại cho Controller.

## Bước 7: Cập Nhật Trạng Thái Cho Màn Hình (Reactive)
**📍 File:** `lib/features/auth/controllers/auth_controller.dart`
**📍 File:** `lib/features/auth/views/login_screen.dart`
**📍 File:** `lib/routes/app_router.dart`

Dữ liệu đẩy về tới Controller, Controller chốt hạ State cuối cùng:

**Trường hợp Thất bại (Lỗi):**
- `auth_controller.dart`: Đặt `errorMessage = "Sai mật khẩu"`, `isLoading = false`.
- `login_screen.dart`: Hàm `ref.listen` đang chực chờ lập tức phát hiện `errorMessage` có thay đổi -> Lệnh `ScaffoldMessenger.of(context).showSnackBar` được gọi ra -> Màn hình hiện thông báo đỏ.

**Trường hợp Thành công:**
- `auth_controller.dart`: Đặt `isLoggedIn = true`, `isLoading = false`.
- Tự bản thân `app_router.dart` (đã được cấu hình lăng nghe Provider) thấy `isLoggedIn = true` -> Kích hoạt rule `redirect`, tự động điều hướng người dùng sang `GoRoute(path: '/home')`.
