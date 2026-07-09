import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';
import 'package:mobile/features/flashcard/models/flashcard_stats_model.dart';
import 'package:mobile/features/flashcard/repositories/flashcard_repository.dart';
import 'package:mobile/features/flashcard/controllers/progress_filter_controller.dart';

final progressControllerProvider =
    AsyncNotifierProvider.autoDispose<ProgressController, FlashcardStatsModel>(
      ProgressController.new,
    );

class ProgressController extends AsyncNotifier<FlashcardStatsModel> {
  late FlashcardRepository _repository;

  @override
  FutureOr<FlashcardStatsModel> build() async {
    _repository = ref.watch(flashcardRepositoryProvider);
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.isLoggedIn == true && next.isLoggedIn == false) {
        ref.invalidateSelf();
      }
    });

    // Sử dụng ref.read thay vì ref.watch để tránh bị rebuild liên tục
    // mỗi khi ProgressFilterController cập nhật trạng thái isLoading hay danh sách levels.
    // UI đã tự xử lý gọi refreshProgress() khi người dùng thay đổi dropdown.
    final filter = ref.read(progressFilterControllerProvider);
    return _fetchProgress(filter.selectedLevelId, filter.selectedTopicId);
  }

  Future<FlashcardStatsModel> _fetchProgress(
    String levelId,
    String topicId,
  ) async {
    return _repository.getProgress(levelId: levelId, topicId: topicId);
  }

  Future<void> refreshProgress() async {
    state = const AsyncValue.loading();
    final filter = ref.read(progressFilterControllerProvider);
    state = await AsyncValue.guard(
      () => _fetchProgress(filter.selectedLevelId, filter.selectedTopicId),
    );
  }
}
