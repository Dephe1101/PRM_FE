import 'package:mobile/features/flashcard/models/flashcard_model.dart';

class FlashcardStatsModel {
  final String? status;
  final String? message;
  final int totalLearning;
  final int totalMastered;
  final List<FlashcardModel> learningWords;
  final List<FlashcardModel> masteredWords;

  FlashcardStatsModel({
    this.status,
    this.message,
    required this.totalLearning,
    required this.totalMastered,
    this.learningWords = const [],
    this.masteredWords = const [],
  });

  factory FlashcardStatsModel.fromJson(Map<String, dynamic> json) {
    return FlashcardStatsModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      totalLearning: json['totalLearning'] as int? ?? 0,
      totalMastered: json['totalMastered'] as int? ?? 0,
      learningWords:
          (json['learningWords'] as List<dynamic>?)
              ?.map((e) => FlashcardModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      masteredWords:
          (json['masteredWords'] as List<dynamic>?)
              ?.map((e) => FlashcardModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
