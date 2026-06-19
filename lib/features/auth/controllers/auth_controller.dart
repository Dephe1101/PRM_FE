import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/core/error/error_codes.dart';
import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/features/auth/models/session_model.dart';
import 'package:mobile/features/auth/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/exceptions/app_exception.dart';

part 'auth_controller.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isLoggedIn,
    UserModel? user,
    List<SessionModel>? sessions,
    String? errorMessage,
  }) = _AuthState;
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Tự động lấy thông tin user (nếu có cookie) ngay khi app khởi động
    Future.microtask(() => getMe());
    // Trả về trạng thái đang Loading ban đầu để chờ getMe
    return const AuthState(isLoading: true);
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.login(email: email, password: password);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (user) {
        state = state.copyWith(isLoading: false, isLoggedIn: true, user: user);
      },
    );
  }

  Future<void> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.register(
      username: username,
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (user) {
        state = state.copyWith(isLoading: false, isLoggedIn: true, user: user);
      },
    );
  }

  Future<void> getMe() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    // Đảm bảo Splash Screen hiển thị ít nhất 1.5s để chạy hết animation
    final results = await Future.wait([
      _repository.getMe(),
      Future.delayed(const Duration(milliseconds: 1500)),
    ]);

    final result = results[0] as Either<Failure, UserModel>;

    result.fold(
      (failure) {
        // Nếu lỗi do hết hạn token hoặc không có quyền -> Đăng xuất
        final isAuthError = failure.code == ErrorCodes.unauthorized || 
                            failure.code == ErrorCodes.tokenExpired ||
                            failure.code == ErrorCodes.accountDisabled;
        
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: false,
          user: null,
          errorMessage: isAuthError ? null : failure.message,
        );
      },
      (user) {
        state = state.copyWith(isLoading: false, isLoggedIn: true, user: user);
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.logout();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        state = const AuthState();
      },
    );
  }

  Future<void> logoutAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.logoutAll();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        state = const AuthState();
      },
    );
  }

  Future<void> getSessions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getSessions();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (sessions) {
        state = state.copyWith(isLoading: false, sessions: sessions);
      },
    );
  }

  Future<void> deleteSession(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.deleteSession(id);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        // Sau khi xoá thành công 1 session, ta nên cập nhật lại list session
        if (state.sessions != null) {
          final updatedSessions = state.sessions!
              .where((s) => s.id != id)
              .toList();
          state = state.copyWith(isLoading: false, sessions: updatedSessions);
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
    );
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
