import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_interceptor.dart';
import 'cookie_manager_setup.dart';
import 'error_interceptor.dart';
import 'loading_interceptor.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

final dioProvider = Provider<Dio>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000/api/v1';

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: 15000),
      receiveTimeout: const Duration(milliseconds: 15000),
    ),
  );

  final refreshDio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: 15000),
      receiveTimeout: const Duration(milliseconds: 15000),
    ),
  );

  // Đính kèm Cookie Manager để xử lý httpOnly cookies (cho refresh token)
  dio.interceptors.add(CookieManagerSetup.cookieManager);
  refreshDio.interceptors.add(CookieManagerSetup.cookieManager);

  // Gắn Loading Interceptor vào dio chính (tự động bật vòng xoay khi gọi API)
  dio.interceptors.add(LoadingInterceptor(ref));

  // Gắn Error Interceptor để bắt lỗi mất mạng toàn cục (Global Snackbar)
  dio.interceptors.add(ErrorInterceptor());

  // Gắn AuthInterceptor vào dio chính
  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      refreshDio: refreshDio,
      prefs: prefs,
    ),
  );

  return dio;
});
