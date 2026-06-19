class WordModel {
  final String id;
  final dynamic topicIdRaw; // can be string or populated object
  final String kanji;
  final String hiragana;
  final String romaji;
  final String meaning;
  final String example;
  final String audioUrl;

  WordModel({
    required this.id,
    required this.topicIdRaw,
    required this.kanji,
    required this.hiragana,
    required this.romaji,
    required this.meaning,
    required this.example,
    required this.audioUrl,
  });

  String get topicId {
    if (topicIdRaw is Map) {
      return topicIdRaw['_id']?.toString() ?? '';
    }
    return topicIdRaw?.toString() ?? '';
  }

  String? get topicName {
    if (topicIdRaw is Map) {
      return topicIdRaw['title']?.toString();
    }
    return null;
  }

  String? get levelId {
    if (topicIdRaw is Map) {
      final lId = topicIdRaw['levelId'];
      if (lId is Map) {
        return lId['_id']?.toString();
      }
      return lId?.toString();
    }
    return null;
  }

  String? get levelName {
    if (topicIdRaw is Map) {
      final lId = topicIdRaw['levelId'];
      if (lId is Map) {
        return lId['name']?.toString();
      }
    }
    return null;
  }

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['_id'] ?? '',
      topicIdRaw: json['topicId'],
      kanji: json['kanji'] ?? '',
      hiragana: json['hiragana'] ?? '',
      romaji: json['romaji'] ?? '',
      meaning: json['meaning'] ?? '',
      example: json['example'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'topicId': topicIdRaw,
      'kanji': kanji,
      'hiragana': hiragana,
      'romaji': romaji,
      'meaning': meaning,
      'example': example,
      'audioUrl': audioUrl,
    };
  }
}
