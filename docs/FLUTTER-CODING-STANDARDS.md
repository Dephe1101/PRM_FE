# 📜 FLUTTER CODING STANDARDS & BEST PRACTICES

## 🎯 Mục đích (Context for AI & Team)
Tài liệu này định nghĩa các quy tắc bắt buộc (Mandatory Rules) khi viết code cho dự án Japanese EdTech Flutter. 
**Yêu cầu AI (Gemini):** Bắt buộc đọc kỹ và áp dụng 100% các quy tắc này vào mọi file code được generate. KHÔNG CÓ NGOẠI LỆ.

---

## 1. Kiến trúc & Phân lớp (Clean Architecture)

### 🔴 KHÔNG ĐƯỢC (DON'T):
- Không viết logic gọi API (`Dio`) trực tiếp bên trong UI (Widget).
- Không để Controller (Riverpod) import trực tiếp thư viện `dio`.
- Không gọi code chéo giữa các Features. (VD: Màn hình của `flashcard` không được gọi trực tiếp Repository của `auth`).

### 🟢 BẮT BUỘC (DO):
- Tuân thủ luồng dữ liệu 1 chiều: `UI -> Provider/Controller -> Repository -> Datasource`.
- Nếu Feature A cần dữ liệu của Feature B, hãy giao tiếp thông qua State (Riverpod) hoặc truyền tham số qua Router, không gọi Repository chéo.

---

## 2. Quản lý State (Riverpod)

### 🔴 KHÔNG ĐƯỢC (DON'T):
- Không sửa đổi trực tiếp (mutate) state. VD: `state.add(newItem)` là cấm kỵ.
- Không lạm dụng `StatefulWidget` để lưu trữ dữ liệu nghiệp vụ (chỉ dùng cho Animation hoặc logic UI thuần túy).

### 🟢 BẮT BUỘC (DO):
- Luôn sử dụng **Immutable State**. Khi cập nhật state, phải dùng hàm `copyWith()` do Freezed tự sinh: `state = state.copyWith(data: newData);`
- Kế thừa `ConsumerWidget` hoặc `ConsumerStatefulWidget` thay vì `StatelessWidget`.
- Đặt tên Provider có hậu tố rõ ràng: `authControllerProvider`, `topicListProvider`.

---

## 3. Data Models (Freezed)

### 🔴 KHÔNG ĐƯỢC (DON'T):
- Tuyệt đối KHÔNG viết tay các hàm `fromJson`, `toJson`, `copyWith`, `==`, `hashCode`.
- Không dùng kiểu dữ liệu `dynamic` khi parse JSON. Mọi trường phải được định nghĩa kiểu rõ ràng.

### 🟢 BẮT BUỘC (DO):
- 100% Data Model giao tiếp với Backend phải dùng `@freezed` và `@JsonSerializable()`.
- Chạy lệnh `flutter pub run build_runner build -d` để sinh code.
- Xử lý Null-safety nghiêm ngặt: Nếu BE có thể trả về null, biến đó bắt buộc phải có dấu `?` (VD: `String? avatarUrl`).

---

## 4. UI & Design System (Zero Hardcode)

### 🔴 KHÔNG ĐƯỢC (DON'T):
- CẤM dùng mã màu trực tiếp: `color: Colors.red`, `color: Color(0xFF123456)`.
- CẤM dùng style chữ trực tiếp: `style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)`.
- CẤM dùng string thô để hiển thị lỗi Backend: `Text(error.toString())`.

### 🟢 BẮT BUỘC (DO):
- Lấy màu từ Design System: `AppColors.primary` hoặc `Theme.of(context).colorScheme.primary`.
- Lấy text style từ hệ thống: `AppTextStyles.heading1`, `AppTextStyles.bodyText`.
- Đặt tiền tố `const` trước TẤT CẢ các Widget không thay đổi để tối ưu RAM và 60FPS.
- Thay vì dùng `Padding` bọc mọi thứ, hãy ưu tiên dùng `SizedBox(height: 16)` để tạo khoảng cách.

---

## 5. Xử lý Lỗi (Error Handling)

### 🔴 KHÔNG ĐƯỢC (DON'T):
- Không được ném thẳng `DioException` ra giao diện (UI).
- Không dùng các câu báo lỗi kỹ thuật hiển thị cho User (VD: "Cannot read properties of undefined").

### 🟢 BẮT BUỘC (DO):
- Mọi lỗi từ Datasource phải được bắt lại (`try-catch`) ở Repository và chuyển đổi thành một class `Failure` hoặc `AppException` (chứa message tiếng Việt).
- Ánh xạ chính xác các mã lỗi (VD: `TOKEN_EXPIRED`, `USER_NOT_FOUND`) khớp 100% với file `errorCode.ts` của Backend.
- Controller đọc lỗi và báo ra màn hình thông qua `CustomSnackbar`.

---

## 6. Đặt tên (Naming Conventions)

- **Tên File/Thư mục:** Bắt buộc dùng `snake_case` (VD: `home_screen.dart`, `auth_controller.dart`).
- **Tên Class:** Bắt buộc dùng `PascalCase` (VD: `HomeScreen`, `AuthController`).
- **Tên Biến/Hàm:** Bắt buộc dùng `camelCase` (VD: `fetchTopicList()`, `isLoading`).
- **Tên Constants:** Sử dụng `camelCase` cho hằng số class (VD: `AppColors.primary`) hoặc `UPPER_SNAKE_CASE` cho hằng số toàn cục.