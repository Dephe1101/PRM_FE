import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/role_constants.dart';
import 'package:mobile/core/constants/route_constants.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';
import 'package:mobile/features/auth/views/login_screen.dart';
import 'package:mobile/features/auth/views/register_screen.dart';
import 'package:mobile/features/home/views/main_scaffold.dart';
import 'package:mobile/features/splash/views/splash_screen.dart';
import 'package:mobile/features/admin/views/main_admin_scaffold.dart';
import 'package:mobile/core/widgets/placeholder_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: RouteConstants.splash,
    refreshListenable: RouterNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoggedIn = authState.isLoggedIn;
      final isLoading = authState.isLoading;
      final isAdmin = authState.user?.role == RoleConstants.admin;

      final isGoingToAuth =
          state.uri.path == RouteConstants.login ||
          state.uri.path == RouteConstants.register;
      final isGoingToAdmin = state.uri.path.startsWith('/admin');

      // 1. App đang khởi tạo (getMe), giữ nguyên ở màn hình Splash
      if (isLoading && state.uri.path == RouteConstants.splash) {
        return null;
      }

      // 2. App đã khởi tạo xong, nếu đang ở Splash thì đẩy về trang chủ tương ứng
      if (state.uri.path == RouteConstants.splash && !isLoading) {
        // Lỗi mạng hoặc server -> Kẹt ở Splash để hiện nút Retry (không đẩy ra Login)
        if (authState.errorMessage != null && !isLoggedIn) {
          return null;
        }
        if (!isLoggedIn) return RouteConstants.login;
        return isAdmin ? RouteConstants.admin : RouteConstants.home;
      }

      // 3. Chưa đăng nhập mà vào trang yêu cầu quyền -> Bắt về Login
      if (!isLoggedIn &&
          !isGoingToAuth &&
          state.uri.path != RouteConstants.splash) {
        return RouteConstants.login;
      }

      // 4. Đã đăng nhập mà cố vào lại Login/Register -> Đẩy vào trang chủ tương ứng
      if (isLoggedIn && isGoingToAuth) {
        return isAdmin ? RouteConstants.admin : RouteConstants.home;
      }

      // 5. Phân quyền Admin vs User
      if (isLoggedIn) {
        if (isAdmin && !isGoingToAdmin) {
          // Admin đi lạc vào khu vực User -> Bắt về Admin Dashboard
          return RouteConstants.admin;
        } else if (!isAdmin && isGoingToAdmin) {
          // User đi lạc vào khu vực Admin -> Bắt về Home
          return RouteConstants.home;
        }
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
        builder: (context, state) => PlaceholderScreen(
          title: 'Topics',
          message: 'Topics Screen Stub: ${state.pathParameters['levelId']}',
        ),
      ),
      GoRoute(
        path: RouteConstants.flashcard,
        builder: (context, state) => PlaceholderScreen(
          title: 'Flashcard',
          message: 'Flashcard Screen Stub: ${state.pathParameters['topicId']}',
        ),
      ),
      GoRoute(
        path: RouteConstants.game,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Game',
          message: 'Game Screen Stub',
        ),
      ),
      // --- Admin Routes ---
      GoRoute(
        path: RouteConstants.admin,
        builder: (context, state) => const MainAdminScaffold(),
      ),
    ],
  );

  return router;
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) {
        if (previous?.isLoading == true && next.isLoading == false) {
          notifyListeners();
        } else if (previous?.isLoggedIn != next.isLoggedIn) {
          notifyListeners();
        }
      },
    );
  }
}
