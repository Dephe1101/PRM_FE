class GameHistoryItemModel {
  final String sessionId;
  final String gameType;
  final int score;
  final int maxCombo;
  final int coinsEarned;
  final DateTime? endTime;

  GameHistoryItemModel({
    required this.sessionId,
    required this.gameType,
    required this.score,
    required this.maxCombo,
    required this.coinsEarned,
    this.endTime,
  });

  factory GameHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return GameHistoryItemModel(
      sessionId: json['_id'] as String,
      gameType: json['gameType'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      maxCombo: json['maxCombo'] as int? ?? 0,
      coinsEarned: json['coinsEarned'] as int? ?? 0,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
}

class GameHistoryPaginatedModel {
  final List<GameHistoryItemModel> docs;
  final int totalDocs;
  final bool hasNextPage;
  final int page;

  GameHistoryPaginatedModel({
    required this.docs,
    required this.totalDocs,
    required this.hasNextPage,
    required this.page,
  });

  factory GameHistoryPaginatedModel.fromJson(Map<String, dynamic> json) {
    final docsList = json['docs'] as List? ?? [];
    return GameHistoryPaginatedModel(
      docs: docsList.map((e) => GameHistoryItemModel.fromJson(e)).toList(),
      totalDocs: json['totalDocs'] as int? ?? 0,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      page: json['page'] as int? ?? 1,
    );
  }
}
