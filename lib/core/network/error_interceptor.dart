import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/app.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Xử lý các lỗi liên quan đến mất kết nối mạng
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      
      // Hiển thị Global Snackbar báo mất mạng
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Không có kết nối mạng. Vui lòng kiểm tra lại đường truyền!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    // Tiếp tục chuyển lỗi xuống cho Repository xử lý (nếu Repo muốn làm thêm gì đó)
    super.onError(err, handler);
  }
}
