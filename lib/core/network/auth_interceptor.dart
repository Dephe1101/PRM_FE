import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/error/error_codes.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final Dio refreshDio;
  final FlutterSecureStorage secureStorage;

  AuthInterceptor({
    required this.dio,
    required this.refreshDio,
    required this.secureStorage,
  });

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Không đính kèm token vào các API đăng nhập/đăng ký
    if (options.path == ApiConstants.login || options.path == ApiConstants.register) {
      return handler.next(options);
    }

    final accessToken = await secureStorage.read(key: 'accessToken');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Bỏ qua việc check refresh token nếu đây là API login/register
    if (err.requestOptions.path == ApiConstants.login || err.requestOptions.path == ApiConstants.register) {
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      final data = err.response?.data;
      if (data is Map && data['code'] == ErrorCodes.tokenExpired) {
        try {
          // Gọi API refresh token
          // Chú ý: refreshDio phải được cấu hình dùng chung CookieManager với dio chính
          // để cookie httpOnly (chứa refresh token) được tự động đính kèm.
          final response = await refreshDio.post(ApiConstants.refresh);
          
          if (response.statusCode == 200) {
            final newAccessToken = response.data['data']['accessToken'];
            await secureStorage.write(key: 'accessToken', value: newAccessToken);
            
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
        }
      }
    }
    return handler.next(err);
  }
}
