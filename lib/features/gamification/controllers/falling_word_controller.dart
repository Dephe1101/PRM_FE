import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/gamification/models/game_session_model.dart';
import 'package:mobile/features/gamification/repositories/game_repository.dart';

enum GameDifficulty { easy, hell }

class FallingWordState {
  final bool isLoading;
  final String? error;
  final GameSessionModel? session;
  
  final int currentIndex;
  final int score;
  final int currentCombo;
  final int maxCombo;
  
  final List<String> wordsHit;
  final List<String> wordsMissed;
  
  final bool isGameFinished;
  final Map<String, dynamic>? submitResult;

  final int? selectedOptionIndex;
  final bool? isLastAnswerCorrect;
  final bool isAnswering;

  final int hintCount;
  final int totalPoints;
  final bool isHintUsed;
  final GameDifficulty difficulty;

  const FallingWordState({
    this.isLoading = false,
    this.error,
    this.session,
    this.currentIndex = 0,
    this.score = 0,
    this.currentCombo = 0,
    this.maxCombo = 0,
    this.wordsHit = const [],
    this.wordsMissed = const [],
    this.isGameFinished = false,
    this.submitResult,
    this.selectedOptionIndex,
    this.isLastAnswerCorrect,
    this.isAnswering = false,
    this.hintCount = 0,
    this.totalPoints = 0,
    this.isHintUsed = false,
    this.difficulty = GameDifficulty.easy,
  });

  FallingWordState copyWith({
    bool? isLoading,
    String? error,
    GameSessionModel? session,
    int? currentIndex,
    int? score,
    int? currentCombo,
    int? maxCombo,
    List<String>? wordsHit,
    List<String>? wordsMissed,
    bool? isGameFinished,
    Map<String, dynamic>? submitResult,
    int? selectedOptionIndex,
    bool? isLastAnswerCorrect,
    bool? isAnswering,
    int? hintCount,
    int? totalPoints,
    bool? isHintUsed,
    GameDifficulty? difficulty,
  }) {
    return FallingWordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      session: session ?? this.session,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      currentCombo: currentCombo ?? this.currentCombo,
      maxCombo: maxCombo ?? this.maxCombo,
      wordsHit: wordsHit ?? this.wordsHit,
      wordsMissed: wordsMissed ?? this.wordsMissed,
      isGameFinished: isGameFinished ?? this.isGameFinished,
      submitResult: submitResult ?? this.submitResult,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
      isLastAnswerCorrect: isLastAnswerCorrect ?? this.isLastAnswerCorrect,
      isAnswering: isAnswering ?? this.isAnswering,
      hintCount: hintCount ?? this.hintCount,
      totalPoints: totalPoints ?? this.totalPoints,
      isHintUsed: isHintUsed ?? this.isHintUsed,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

class FallingWordController extends Notifier<FallingWordState> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  static const _totalPointsKey = 'game_total_points';
  static const _hintCountKey = 'game_hint_count';

  @override
  FallingWordState build() {
    final totalPoints = _prefs.getInt(_totalPointsKey) ?? 0;
    final hintCount = _prefs.getInt(_hintCountKey) ?? 0;
    return FallingWordState(totalPoints: totalPoints, hintCount: hintCount);
  }

  Future<void> startGame(List<String> topicIds, {GameDifficulty difficulty = GameDifficulty.easy}) async {
    state = state.copyWith(isLoading: true, error: null, difficulty: difficulty);
    try {
      final repo = ref.read(gameRepositoryProvider);
      final session = await repo.startGame(topicIds, 'FALLING_WORDS');
      
      state = state.copyWith(
        isLoading: false,
        session: session,
        currentIndex: 0,
        score: 0,
        currentCombo: 0,
        maxCombo: 0,
        wordsHit: [],
        wordsMissed: [],
        isGameFinished: false,
        isHintUsed: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void buyHints() {
    if (state.totalPoints >= 700) {
      final newTotal = state.totalPoints - 700;
      final newHints = state.hintCount + 2;
      
      _prefs.setInt(_totalPointsKey, newTotal);
      _prefs.setInt(_hintCountKey, newHints);
      
      state = state.copyWith(totalPoints: newTotal, hintCount: newHints);
    }
  }

  void useHint() {
    if (state.hintCount > 0 && !state.isHintUsed && !state.isGameFinished) {
      final newHints = state.hintCount - 1;
      _prefs.setInt(_hintCountKey, newHints);
      state = state.copyWith(hintCount: newHints, isHintUsed: true);
    }
  }

  void handleAnswer(bool isCorrect, String wordId, {int? optionIndex}) async {
    if (state.isGameFinished || state.session == null || state.isAnswering) {
      return;
    }

    // Hiển thị feedback
    state = state.copyWith(
      isAnswering: true,
      selectedOptionIndex: optionIndex,
      isLastAnswerCorrect: isCorrect,
    );

    // Chờ 500ms để người dùng thấy feedback
    await Future.delayed(const Duration(milliseconds: 500));

    final newWordsHit = List<String>.from(state.wordsHit);
    final newWordsMissed = List<String>.from(state.wordsMissed);
    int newScore = state.score;
    int newCombo = state.currentCombo;
    int newMaxCombo = state.maxCombo;
    int newTotalPoints = state.totalPoints;

    if (isCorrect) {
      // Mỗi combo 5 thì câu tiếp theo x2 điểm (ví dụ: combo 5, 10, 15...)
      int pointsToAdd = 100;
      if (newCombo > 0 && newCombo % 5 == 0) {
        pointsToAdd = 200;
      }
      
      newScore += pointsToAdd;
      newTotalPoints += pointsToAdd;
      newCombo += 1;
      if (newCombo > newMaxCombo) {
        newMaxCombo = newCombo;
      }
      newWordsHit.add(wordId);
      
      _prefs.setInt(_totalPointsKey, newTotalPoints);
    } else {
      newCombo = 0;
      newWordsMissed.add(wordId);
    }

    int nextIndex = state.currentIndex + 1;
    bool finished = nextIndex >= state.session!.totalWords;

    state = state.copyWith(
      score: newScore,
      totalPoints: newTotalPoints,
      currentCombo: newCombo,
      maxCombo: newMaxCombo,
      wordsHit: newWordsHit,
      wordsMissed: newWordsMissed,
      currentIndex: nextIndex,
      isGameFinished: finished,
      isAnswering: false,
      selectedOptionIndex: null,
      isLastAnswerCorrect: null,
      isHintUsed: false,
    );

    if (finished) {
      _submitGameResult();
    }
  }

  void handleTimeout(String wordId) {
    handleAnswer(false, wordId);
  }

  Future<void> _submitGameResult() async {
    if (state.session == null) return;
    
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(gameRepositoryProvider);
      final result = await repo.submitGame(
        sessionId: state.session!.sessionId,
        score: state.score,
        maxCombo: state.maxCombo,
        wordsHit: state.wordsHit,
        wordsMissed: state.wordsMissed,
      );
      
      state = state.copyWith(isLoading: false, submitResult: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final fallingWordControllerProvider = NotifierProvider<FallingWordController, FallingWordState>(
  FallingWordController.new,
);
