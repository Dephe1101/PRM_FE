import 'package:mobile/features/admin/models/word_model.dart';
import 'package:mobile/features/flashcard/models/flashcard_progress_model.dart';

class FlashcardModel {
  final WordModel word;
  final FlashcardProgressModel progress;

  FlashcardModel({
    required this.word,
    required this.progress,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    // API getFlashcardsByTopic trả về { word: {...}, progress: {...} }
    if (json.containsKey('word') && json.containsKey('progress')) {
      return FlashcardModel(
        word: WordModel.fromJson(json['word'] as Map<String, dynamic>),
        progress: FlashcardProgressModel.fromJson(json['progress'] as Map<String, dynamic>),
      );
    }
    
    // API getReviewWords / getBookmarks trả về { ...progress_fields, word: {...} }
    if (json.containsKey('word') && json['word'] is Map<String, dynamic>) {
      return FlashcardModel(
        word: WordModel.fromJson(json['word'] as Map<String, dynamic>),
        progress: FlashcardProgressModel.fromJson(json),
      );
    }

    // Fallback an toàn
    return FlashcardModel(
      word: WordModel.fromJson(json),
      progress: FlashcardProgressModel.fromJson(json),
    );
  }

  FlashcardModel copyWith({
    WordModel? word,
    FlashcardProgressModel? progress,
  }) {
    return FlashcardModel(
      word: word ?? this.word,
      progress: progress ?? this.progress,
    );
  }
}
