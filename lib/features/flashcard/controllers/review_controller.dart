import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';
import 'package:mobile/features/flashcard/models/flashcard_model.dart';
import 'package:mobile/features/flashcard/repositories/flashcard_repository.dart';
import 'package:mobile/features/flashcard/views/widgets/swipeable_card_stack.dart';

final reviewControllerProvider = AsyncNotifierProvider.autoDispose<
    ReviewController, List<FlashcardModel>>(ReviewController.new);

class ReviewController extends AsyncNotifier<List<FlashcardModel>> {
  late final FlashcardRepository _repository;

  @override
  Future<List<FlashcardModel>> build() async {
    _repository = ref.read(flashcardRepositoryProvider);
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.isLoggedIn == true && next.isLoggedIn == false) {
        ref.invalidateSelf();
      }
    });

    return _repository.getReviewWords();
  }

  Future<void> submitSwipe(String wordId, SwipeDirection direction) async {
    final isCorrect = direction == SwipeDirection.right;

    try {
      final updatedFlashcard = await _repository.submitFlashcard(
        wordId: wordId,
        isCorrect: isCorrect,
      );

      if (state.hasValue) {
        final currentList = state.value!;
        final newList = currentList.map((f) {
          if (f.word.id == wordId) {
            return updatedFlashcard;
          }
          return f;
        }).toList();
        state = AsyncValue.data(newList);
      }
    } catch (e) {
      print('Lỗi submit flashcard (review): $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getReviewWords());
  }
}
