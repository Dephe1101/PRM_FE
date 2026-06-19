import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'global_loading_provider.dart';

class LoadingInterceptor extends Interceptor {
  final Ref ref;

  LoadingInterceptor(this.ref);

  bool _shouldShowLoading(RequestOptions options) {
    // Cho phép truyền cờ 'showLoading': false trong options.extra để bỏ qua vòng quay
    return options.extra['showLoading'] ?? true;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_shouldShowLoading(options)) {
      Future.microtask(() => ref.read(globalLoadingProvider.notifier).show());
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_shouldShowLoading(response.requestOptions)) {
      Future.microtask(() => ref.read(globalLoadingProvider.notifier).hide());
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldShowLoading(err.requestOptions)) {
      Future.microtask(() => ref.read(globalLoadingProvider.notifier).hide());
    }
    super.onError(err, handler);
  }
}
