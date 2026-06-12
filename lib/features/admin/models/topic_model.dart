class TopicModel {
  final String id;
  final String title;
  final dynamic levelIdRaw;
  final int orderIndex;
  final int totalWords;

  TopicModel({
    required this.id,
    required this.title,
    required this.levelIdRaw,
    required this.orderIndex,
    this.totalWords = 0,
  });

  // Helpers to get levelId string or name depending on populated or not
  String get levelId {
    if (levelIdRaw is Map) {
      return levelIdRaw['_id']?.toString() ?? '';
    }
    return levelIdRaw?.toString() ?? '';
  }

  String? get levelName {
    if (levelIdRaw is Map) {
      return levelIdRaw['name']?.toString();
    }
    return null;
  }

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      levelIdRaw: json['levelId'],
      orderIndex: json['orderIndex'] ?? 0,
      totalWords: json['totalWords'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'levelId': levelIdRaw,
      'orderIndex': orderIndex,
      'totalWords': totalWords,
    };
  }
}
