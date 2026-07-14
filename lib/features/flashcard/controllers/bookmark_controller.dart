import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';
import 'package:mobile/features/flashcard/models/flashcard_model.dart';
import 'package:mobile/features/flashcard/repositories/flashcard_repository.dart';

import 'package:mobile/features/flashcard/controllers/bookmark_filter_controller.dart';

final bookmarkControllerProvider = AsyncNotifierProvider.autoDispose<
    BookmarkController, List<FlashcardModel>>(BookmarkController.new);

class BookmarkController extends AsyncNotifier<List<FlashcardModel>> {
  FlashcardRepository get _repository => ref.read(flashcardRepositoryProvider);

  @override
  Future<List<FlashcardModel>> build() async {
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.isLoggedIn == true && next.isLoggedIn == false) {
        ref.invalidateSelf();
      }
    });

    final filterState = ref.watch(bookmarkFilterProvider);
    return _repository.getBookmarks(
      levelId: filterState.selectedLevelId,
      topicId: filterState.selectedTopicId,
    );
  }

  Future<void> toggleBookmark(String wordId) async {
    // Optimistic Update
    final previousState = state;
    if (state.hasValue) {
      final currentList = state.value!;
      final newList = currentList.where((f) => f.word.id != wordId).toList();
      state = AsyncValue.data(newList);
    }

    try {
      final isBookmarked = await _repository.toggleBookmark(wordId);
      if (isBookmarked) {
        // Rollback if it was supposed to be removed
        state = previousState;
        ref.invalidateSelf();
      }
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> unsaveAll() async {
    if (!state.hasValue) return;
    final currentList = state.value!;
    if (currentList.isEmpty) return;

    final previousState = state;
    state = const AsyncValue.data([]);

    try {
      await Future.wait(
        currentList.map((f) => _repository.toggleBookmark(f.word.id)),
      );
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> unsaveTopic(List<FlashcardModel> flashcards) async {
    final previousState = state;
    if (state.hasValue) {
      final idsToRemove = flashcards.map((f) => f.word.id).toSet();
      final newList =
          state.value!.where((f) => !idsToRemove.contains(f.word.id)).toList();
      state = AsyncValue.data(newList);
    }

    try {
      await Future.wait(
        flashcards.map((f) => _repository.toggleBookmark(f.word.id)),
      );
      ref.invalidateSelf();
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> saveAll(String topicId) async {
    final previousState = state;
    state = const AsyncValue.loading();

    try {
      final allWordsInTopic = await _repository.getFlashcardsByTopic(topicId);
      final List<Future> futures = [];
      for (var f in allWordsInTopic) {
        if (!f.progress.isBookmarked) {
          futures.add(_repository.toggleBookmark(f.word.id));
        }
      }

      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
      ref.invalidateSelf();
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getBookmarks());
  }
}
