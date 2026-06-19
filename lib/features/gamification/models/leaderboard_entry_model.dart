class LeaderboardEntryModel {
  final String sessionId;
  final String userId;
  final String username;
  final int score;
  final String gameType;
  final DateTime? endTime;

  LeaderboardEntryModel({
    required this.sessionId,
    required this.userId,
    required this.username,
    required this.score,
    required this.gameType,
    this.endTime,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['userId'];
    final userId = userJson is Map ? userJson['_id'] : userJson;
    final username = userJson is Map ? userJson['username'] : 'Unknown User';

    return LeaderboardEntryModel(
      sessionId: json['_id'] as String,
      userId: userId as String? ?? '',
      username: username as String? ?? 'Unknown User',
      score: json['score'] as int? ?? 0,
      gameType: json['gameType'] as String? ?? '',
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
}
