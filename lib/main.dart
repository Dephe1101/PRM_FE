import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/network/cookie_manager_setup.dart'; // Thêm import

void main() async {
  // Bắt buộc gọi dòng này nếu có khởi tạo các module Native trước khi chạy app (vd: dotenv, Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // Load file môi trường (Phase 2 sẽ dùng tới)
  await dotenv.load(fileName: ".env");

  // Khởi tạo CookieManager cho Dio
  await CookieManagerSetup.init();

  // Bọc toàn bộ app bằng ProviderScope để Riverpod có thể hoạt động
  runApp(const ProviderScope(child: MyApp()));
}
