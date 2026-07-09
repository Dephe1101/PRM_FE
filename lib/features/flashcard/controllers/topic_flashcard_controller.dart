import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';
import 'package:mobile/features/flashcard/models/flashcard_model.dart';
import 'package:mobile/features/flashcard/repositories/flashcard_repository.dart';
import 'package:mobile/features/flashcard/views/widgets/swipeable_card_stack.dart';
import 'package:mobile/features/flashcard/controllers/progress_controller.dart';
import 'package:mobile/features/gamification/controllers/game_filter_controller.dart';
import 'package:mobile/features/learning/controllers/topic_list_controller.dart';
import 'package:mobile/features/flashcard/controllers/progress_words_controller.dart';

final topicFlashcardControllerProvider = FutureProvider.autoDispose
    .family<List<FlashcardModel>, String>((ref, topicId) async {
      final repository = ref.watch(flashcardRepositoryProvider);

      ref.listen(authControllerProvider, (previous, next) {
        if (previous?.isLoggedIn == true && next.isLoggedIn == false) {
          // Invalidate if logged out
        }
      });

      if (topicId.startsWith('bookmarks')) {
        String? filterTopicId;
        String? filterLevelId;
        
        final parts = topicId.split('_');
        for (var i = 1; i < parts.length; i++) {
          if (parts[i].startsWith('level:')) {
            filterLevelId = parts[i].substring(6);
          } else if (parts[i].startsWith('topic:')) {
            filterTopicId = parts[i].substring(6);
          } else {
            // backward compatibility
            filterTopicId = parts[i];
          }
        }
        return repository.getBookmarksStudy(topicId: filterTopicId, levelId: filterLevelId);
      }

      return repository.getFlashcardsByTopic(topicId);
    });

final batchFlashcardActionProvider =
    NotifierProvider.autoDispose<
      BatchFlashcardActionNotifier,
      List<Map<String, dynamic>>
    >(BatchFlashcardActionNotifier.new);

class BatchFlashcardActionNotifier
    extends Notifier<List<Map<String, dynamic>>> {
  late FlashcardRepository _repository;

  @override
  List<Map<String, dynamic>> build() {
    _repository = ref.watch(flashcardRepositoryProvider);
    return []; // Khởi tạo mảng rỗng chứa kết quả
  }

  void recordSwipe(String wordId, SwipeDirection direction) {
    final isCorrect = direction == SwipeDirection.right;
    final newResult = {'wordId': wordId, 'isCorrect': isCorrect};
    state = [...state, newResult];
  }

  Future<bool> submitBatch() async {
    if (state.isEmpty) return true;

    try {
      await _repository.submitBatchFlashcards(state);
      // Xoá state sau khi gửi thành công
      state = [];

      // Invalidate các provider liên quan để UI (Game, Progress, Topics) cập nhật
      ref.invalidate(topicListControllerProvider);
      ref.invalidate(gameFilterControllerProvider);
      ref.invalidate(progressControllerProvider);
      ref.invalidate(progressWordsControllerProvider);

      return true;
    } catch (e) {
      return false;
    }
  }
}
