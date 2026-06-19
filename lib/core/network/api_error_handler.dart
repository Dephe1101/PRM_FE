import 'package:dio/dio.dart';
import 'package:mobile/core/error/error_codes.dart';
import 'package:mobile/core/exceptions/app_exception.dart';

class ApiErrorHandler {
  static AppException handle(dynamic error) {
    print('ApiErrorHandler caught: $error');
    if (error is Error) {
      print('Stacktrace: ${error.stackTrace}');
    }
    if (error is DioException) {
      if (error.response != null && error.response?.data != null) {
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          final code = data['code'] as String? ?? ErrorCodes.internalError;
          final message = data['message'] as String? ?? 'Lỗi hệ thống không xác định';
          
          List<String>? errorsList;
          if (data['errors'] is List) {
            errorsList = (data['errors'] as List).map((e) => e.toString()).toList();
          }

          return AppException(code: code, message: message, errors: errorsList);
        }
      }
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const AppException(
            code: 'TIMEOUT',
            message: 'Kết nối mạng bị gián đoạn, vui lòng thử lại',
          );
        case DioExceptionType.connectionError:
          return const AppException(
            code: 'NETWORK_ERROR',
            message: 'Không có kết nối mạng',
          );
        case DioExceptionType.cancel:
          return const AppException(
            code: 'CANCELLED',
            message: 'Yêu cầu đã bị huỷ',
          );
        default:
          return const AppException(
            code: ErrorCodes.internalError,
            message: 'Đã xảy ra lỗi hệ thống, vui lòng thử lại sau',
          );
      }
    }
    
    return AppException(
      code: ErrorCodes.internalError,
      message: 'Lỗi không xác định: \${error.toString()}',
    );
  }
}
