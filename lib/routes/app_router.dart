import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/core/constants/route_constants.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';
import 'package:mobile/features/auth/views/login_screen.dart';
import 'package:mobile/features/auth/views/register_screen.dart';
import 'package:mobile/features/home/views/main_scaffold.dart';
import 'package:mobile/features/splash/views/splash_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: RouteConstants.splash,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoggedIn = authState.isLoggedIn;
      final isLoading = authState.isLoading;
      final isGoingToAuth = state.matchedLocation == RouteConstants.login || state.matchedLocation == RouteConstants.register;

      // 1. App đang khởi tạo (getMe), giữ nguyên ở màn hình Splash
      if (isLoading && state.matchedLocation == RouteConstants.splash) {
        return null;
      }

      // 2. App đã khởi tạo xong, nếu đang ở Splash thì đẩy về Home hoặc Login
      if (state.matchedLocation == RouteConstants.splash && !isLoading) {
        return isLoggedIn ? RouteConstants.home : RouteConstants.login;
      }

      // 3. Chưa đăng nhập mà vào trang yêu cầu quyền (Home) -> Bắt về Login
      if (!isLoggedIn && !isGoingToAuth && state.matchedLocation != RouteConstants.splash) {
        return RouteConstants.login;
      }

      // 4. Đã đăng nhập mà cố vào lại Login/Register -> Đẩy vào Home
      if (isLoggedIn && isGoingToAuth) {
        return RouteConstants.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteConstants.home,
        builder: (context, state) => const MainScaffold(),
      ),
      GoRoute(
        path: RouteConstants.topics,
        builder: (context, state) => Scaffold(body: Center(child: Text('Topics Screen Stub: ${state.pathParameters['levelId']}'))),
      ),
      GoRoute(
        path: RouteConstants.flashcard,
        builder: (context, state) => Scaffold(body: Center(child: Text('Flashcard Screen Stub: ${state.pathParameters['topicId']}'))),
      ),
      GoRoute(
        path: RouteConstants.game,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Game Screen Stub'))),
      ),
    ],
  );

  // Lắng nghe sự thay đổi của AuthController để kích hoạt redirect
  ref.listen(
    authControllerProvider,
    (previous, next) {
      // Nếu vừa load xong (isLoading: true -> false)
      if (previous?.isLoading == true && next.isLoading == false) {
        router.refresh();
      } 
      // Hoặc nếu trạng thái đăng nhập thay đổi (Login/Logout)
      else if (previous?.isLoggedIn != next.isLoggedIn) {
        router.refresh();
      }
    },
  );

  return router;
});