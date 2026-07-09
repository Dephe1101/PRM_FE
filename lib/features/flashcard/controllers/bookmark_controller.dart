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
      // Nếu có trong list, toggle sẽ làm mất nó khỏi list Bookmark.
      // Nếu muốn giữ trong list nhưng tắt tim, ta cần cập nhật trạng thái isBookmarked.
      // Thường màn hình My Words, nếu bỏ tim thì nó sẽ biến mất khỏi danh sách.
      final newList = currentList.where((f) => f.word.id != wordId).toList();
      state = AsyncValue.data(newList);
    }

    try {
      final isBookmarked = await _repository.toggleBookmark(wordId);
      // Nếu API trả về true (nghĩa là bookmarked), nhưng ta lại vừa xoá khỏi list,
      // thì phải rollback hoặc fetch lại.
      // Thường ở màn hình Bookmark, toggle là xoá, nên isBookmarked sẽ là false.
      if (isBookmarked) {
        // Rollback nếu có lỗi logic
        state = previousState;
        ref.invalidateSelf();
      }
    } catch (e) {
      // Revert
      state = previousState;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getBookmarks());
  }
}
