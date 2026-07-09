class FlashcardStatsModel {
  final String? status;
  final String? message;
  final int totalLearning;
  final int totalMastered;

  FlashcardStatsModel({
    this.status,
    this.message,
    required this.totalLearning,
    required this.totalMastered,
  });

  factory FlashcardStatsModel.fromJson(Map<String, dynamic> json) {
    return FlashcardStatsModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      totalLearning: json['totalLearning'] as int? ?? 0,
      totalMastered: json['totalMastered'] as int? ?? 0,
    );
  }
}
