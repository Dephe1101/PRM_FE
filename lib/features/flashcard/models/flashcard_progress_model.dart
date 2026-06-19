class FlashcardProgressModel {
  final int srsStage;
  final DateTime? nextReviewAt;
  final DateTime? updatedAt;
  final int correctCount;
  final int wrongCount;
  final bool isBookmarked;

  FlashcardProgressModel({
    required this.srsStage,
    this.nextReviewAt,
    this.updatedAt,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.isBookmarked = false,
  });

  factory FlashcardProgressModel.fromJson(Map<String, dynamic> json) {
    return FlashcardProgressModel(
      srsStage: json['srsStage'] as int? ?? 0,
      nextReviewAt: json['nextReviewAt'] != null
          ? DateTime.tryParse(json['nextReviewAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      correctCount: json['correctCount'] as int? ?? 0,
      wrongCount: json['wrongCount'] as int? ?? 0,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'srsStage': srsStage,
      if (nextReviewAt != null) 'nextReviewAt': nextReviewAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'isBookmarked': isBookmarked,
    };
  }

  FlashcardProgressModel copyWith({
    int? srsStage,
    DateTime? nextReviewAt,
    int? correctCount,
    int? wrongCount,
    bool? isBookmarked,
  }) {
    return FlashcardProgressModel(
      srsStage: srsStage ?? this.srsStage,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
