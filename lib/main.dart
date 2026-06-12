import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/network/cookie_manager_setup.dart';
import 'core/network/dio_client.dart';

void main() async {
  // Bắt buộc gọi dòng này nếu có khởi tạo các module Native trước khi chạy app (vd: dotenv, Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // Load file môi trường
  await dotenv.load(fileName: ".env");

  // Khởi tạo CookieManager cho Dio
  await CookieManagerSetup.init();

  // Khởi tạo SharedPreferences đồng bộ để app dùng tức thời không bị block UI
  final sharedPreferences = await SharedPreferences.getInstance();

  // Bọc toàn bộ app bằng ProviderScope để Riverpod có thể hoạt động, inject sharedPreferences
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}
