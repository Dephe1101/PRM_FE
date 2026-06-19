import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/flashcard/models/flashcard_model.dart';
import 'package:mobile/features/flashcard/repositories/flashcard_repository.dart';
import 'package:mobile/features/learning/repositories/learning_repository.dart';

final topicDetailControllerProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, topicId) async {
  final repository = ref.watch(learningRepositoryProvider);
  return repository.getTopicDetail(topicId);
});

final topicBookmarkedFlashcardsProvider = FutureProvider.autoDispose
    .family<List<FlashcardModel>, String>((ref, topicId) async {
  final repository = ref.watch(flashcardRepositoryProvider);
  return repository.getBookmarkedFlashcardsByTopic(topicId);
});
