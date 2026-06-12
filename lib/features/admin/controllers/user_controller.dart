import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/features/admin/repositories/user_repository.dart';

final userControllerProvider =
    AsyncNotifierProvider.autoDispose<UserController, List<UserModel>>(() {
      return UserController();
    });

class UserController extends AsyncNotifier<List<UserModel>> {
  UserRepository get _repository => ref.read(userRepositoryProvider);

  @override
  FutureOr<List<UserModel>> build() async {
    return _fetchUsers();
  }

  Future<List<UserModel>> _fetchUsers() async {
    return _repository.getAllUsers();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUsers());
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.getAllUsers(search: query.isNotEmpty ? query : null),
    );
  }

  Future<void> toggleUserStatus(String userId, bool currentStatus) async {
    try {
      final updatedUser = await _repository.toggleUserStatus(
        userId,
        isActive: !currentStatus,
      );

      state = state.whenData((users) {
        return users.map((u) => u.id == userId ? updatedUser : u).toList();
      });
    } catch (e) {
      throw Exception('Không thể thay đổi trạng thái user: $e');
    }
  }
}
