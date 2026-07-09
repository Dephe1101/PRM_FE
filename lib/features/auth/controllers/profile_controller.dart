import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/features/auth/repositories/auth_repository.dart';

final profileControllerProvider =
    AsyncNotifierProvider.autoDispose<ProfileController, UserModel>(
  ProfileController.new,
);

class ProfileController extends AsyncNotifier<UserModel> {
  @override
  FutureOr<UserModel> build() async {
    final repo = ref.watch(authRepositoryProvider);
    final result = await repo.getMe();
    
    return result.fold(
      (failure) => throw failure,
      (user) => user,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.getMe();
      return result.fold(
        (failure) => throw failure,
        (user) => user,
      );
    });
  }
}
