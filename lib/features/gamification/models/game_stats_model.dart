class GameStatsModel {
  final int totalGames;
  final int avgScore;
  final int bestScore;

  GameStatsModel({
    required this.totalGames,
    required this.avgScore,
    required this.bestScore,
  });

  factory GameStatsModel.fromJson(Map<String, dynamic> json) {
    return GameStatsModel(
      totalGames: json['totalGames'] as int? ?? 0,
      avgScore: json['avgScore'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
    );
  }
}
