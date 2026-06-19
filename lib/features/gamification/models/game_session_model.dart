class GameOptionModel {
  final String text;
  final bool isCorrect;

  GameOptionModel({
    required this.text,
    required this.isCorrect,
  });

  factory GameOptionModel.fromJson(Map<String, dynamic> json) {
    return GameOptionModel(
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool,
    );
  }
}

class GameWordModel {
  final String wordId;
  final String kanji;
  final String? hiragana;
  final String? romaji;
  final String? correctMeaning;
  final List<GameOptionModel>? options;
  final double? speed;

  GameWordModel({
    required this.wordId,
    required this.kanji,
    this.hiragana,
    this.romaji,
    this.correctMeaning,
    this.options,
    this.speed,
  });

  factory GameWordModel.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List?;
    return GameWordModel(
      wordId: json['wordId'] as String,
      kanji: json['kanji'] as String,
      hiragana: json['hiragana'] as String?,
      romaji: json['romaji'] as String?,
      correctMeaning: json['correctMeaning'] as String?,
      options: optionsList?.map((e) => GameOptionModel.fromJson(e)).toList(),
      speed: (json['speed'] as num?)?.toDouble(),
    );
  }
}

class GameSessionModel {
  final String sessionId;
  final String gameType;
  final int totalWords;
  final List<GameWordModel> words;

  GameSessionModel({
    required this.sessionId,
    required this.gameType,
    required this.totalWords,
    required this.words,
  });

  factory GameSessionModel.fromJson(Map<String, dynamic> json) {
    var wordsList = json['words'] as List;
    return GameSessionModel(
      sessionId: json['sessionId'] as String,
      gameType: json['gameType'] as String,
      totalWords: json['totalWords'] as int,
      words: wordsList.map((e) => GameWordModel.fromJson(e)).toList(),
    );
  }
}
