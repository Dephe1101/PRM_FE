import 'package:mobile/features/admin/models/topic_model.dart';

class GameHistoryDetailModel {
  final String sessionId;
  final String gameType;
  final int score;
  final int maxCombo;
  final int coinsEarned;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;
  final List<TopicModel> includedTopics;

  GameHistoryDetailModel({
    required this.sessionId,
    required this.gameType,
    required this.score,
    required this.maxCombo,
    required this.coinsEarned,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.includedTopics,
  });

  factory GameHistoryDetailModel.fromJson(Map<String, dynamic> json) {
    return GameHistoryDetailModel(
      sessionId: json['_id'] as String,
      gameType: json['gameType'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      maxCombo: json['maxCombo'] as int? ?? 0,
      coinsEarned: json['coinsEarned'] as int? ?? 0,
      status: json['status'] as String? ?? 'completed',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      includedTopics: (json['includedTopics'] as List? ?? [])
          .map((e) => TopicModel.fromJson(e))
          .toList(),
    );
  }
}
