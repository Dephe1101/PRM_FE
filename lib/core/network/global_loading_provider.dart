import 'package:flutter_riverpod/flutter_riverpod.dart';

final globalLoadingProvider = NotifierProvider<GlobalLoadingNotifier, bool>(() {
  return GlobalLoadingNotifier();
});

class GlobalLoadingNotifier extends Notifier<bool> {
  int _requestCount = 0;

  @override
  bool build() {
    return false;
  }

  void show() {
    // Dùng microtask để tránh lỗi "setState() or markNeedsBuild() called during build"
    Future.microtask(() {
      _requestCount++;
      if (_requestCount == 1) {
        state = true;
      }
    });
  }

  void hide() {
    Future.microtask(() {
      if (_requestCount > 0) {
        _requestCount--;
        if (_requestCount == 0) {
          state = false;
        }
      }
    });
  }
}
