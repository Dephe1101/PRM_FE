import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/error/error_codes.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final Dio refreshDio;
  final SharedPreferences prefs;
  bool _isRefreshing = false;

  AuthInterceptor({
    required this.dio,
    required this.refreshDio,
    required this.prefs,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Không đính kèm token vào các API đăng nhập/đăng ký
    if (options.path == ApiConstants.login ||
        options.path == ApiConstants.register) {
      return handler.next(options);
    }

    try {
      final accessToken = prefs.getString('accessToken');
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    } catch (e) {
      debugPrint('Lỗi khi đọc token từ prefs: $e');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Bỏ qua việc check refresh token nếu đây là API login/register
    if (err.requestOptions.path == ApiConstants.login ||
        err.requestOptions.path == ApiConstants.register) {
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      final data = err.response?.data;
      if (data is Map && data['code'] == ErrorCodes.tokenExpired) {
        // Lấy token hiện tại trong header của request bị lỗi
        final requestToken = err.requestOptions.headers['Authorization']?.toString().replaceFirst('Bearer ', '');
        final currentToken = prefs.getString('accessToken');

        // Nếu token trong storage đã khác với token của request lỗi,
        // nghĩa là một request khác đã refresh token thành công. 
        // Chỉ cần lấy token mới và retry.
        if (currentToken != null && requestToken != currentToken) {
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $currentToken';
          final retryResponse = await dio.fetch(options);
          return handler.resolve(retryResponse);
        }

        // Chống race condition: Nếu đang có request khác gọi refresh, ta đợi nó
        if (_isRefreshing) {
          // Thử lại sau một khoảng thời gian ngắn (có thể cấu hình retry phức tạp hơn)
          await Future.delayed(const Duration(milliseconds: 500));
          final newToken = prefs.getString('accessToken');
          if (newToken != null && newToken != requestToken) {
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await dio.fetch(options);
            return handler.resolve(retryResponse);
          }
          return handler.next(err);
        }

        _isRefreshing = true;
        try {
          // Gọi API refresh token
          // Chú ý: refreshDio phải được cấu hình dùng chung CookieManager với dio chính
          // để cookie httpOnly (chứa refresh token) được tự động đính kèm.
          final response = await refreshDio.post(ApiConstants.refresh);

          if (response.statusCode == 200) {
            final newAccessToken = response.data['data']['accessToken'];
            await prefs.setString('accessToken', newAccessToken);

            // Cập nhật token mới và retry request bị lỗi
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // Nếu refresh lỗi (refresh token cũng hết hạn hoặc lỗi mạng),
          // đẩy lỗi đi tiếp, bên ngoài sẽ bắt và có thể dispatch event Logout
          return handler.next(err);
        } finally {
          _isRefreshing = false;
        }
      }
    }
    return handler.next(err);
  }
}
