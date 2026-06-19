import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/admin/repositories/level_repository.dart';

final levelControllerProvider =
    AsyncNotifierProvider<LevelController, List<LevelModel>>(() {
      return LevelController();
    });

class LevelController extends AsyncNotifier<List<LevelModel>> {
  late final LevelRepository _repository;

  @override
  Future<List<LevelModel>> build() async {
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.isLoggedIn == true && next.isLoggedIn == false) {
        ref.invalidateSelf();
      }
    });
    _repository = ref.read(levelRepositoryProvider);
    return _fetchLevels();
  }

  Future<List<LevelModel>> _fetchLevels() async {
    return await _repository.getAllLevels();
  }

  Future<void> createLevel(Map<String, dynamic> payload) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      await _repository.createLevel(payload);
      state = AsyncValue.data(await _fetchLevels());
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> updateLevel(String id, Map<String, dynamic> payload) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      await _repository.updateLevel(id, payload);
      state = AsyncValue.data(await _fetchLevels());
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> toggleActiveStatus(String id, bool currentStatus) async {
    // Optimistic update
    final previousState = state;
    if (state.hasValue) {
      final updatedList = state.value!.map((e) {
        if (e.id == id) return e.copyWith(isActive: !currentStatus);
        return e;
      }).toList();
      state = AsyncValue.data(updatedList);
    }

    try {
      await _repository.updateLevel(id, {'isActive': !currentStatus});
    } catch (e, st) {
      // Revert if failed
      state = previousState;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteLevel(String id) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      await _repository.deleteLevel(id);
      final newData = await _fetchLevels();
      state = AsyncValue.data(newData);
    } catch (e) {
      state = previousState; // Revert to old list instead of breaking UI
      rethrow; // Let UI catch it to show Snackbar
    }
  }
}
