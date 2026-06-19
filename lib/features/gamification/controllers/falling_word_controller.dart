import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/gamification/models/game_session_model.dart';
import 'package:mobile/features/gamification/repositories/game_repository.dart';

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
  }) {
    return FallingWordState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Clear error when not explicitly passed, or adjust as needed
      session: session ?? this.session,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      currentCombo: currentCombo ?? this.currentCombo,
      maxCombo: maxCombo ?? this.maxCombo,
      wordsHit: wordsHit ?? this.wordsHit,
      wordsMissed: wordsMissed ?? this.wordsMissed,
      isGameFinished: isGameFinished ?? this.isGameFinished,
      submitResult: submitResult ?? this.submitResult,
    );
  }
}

class FallingWordController extends Notifier<FallingWordState> {
  @override
  FallingWordState build() {
    return const FallingWordState();
  }

  Future<void> startGame(List<String> topicIds) async {
    state = state.copyWith(isLoading: true, error: null);
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
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void handleAnswer(bool isCorrect, String wordId) {
    if (state.isGameFinished || state.session == null) return;

    final newWordsHit = List<String>.from(state.wordsHit);
    final newWordsMissed = List<String>.from(state.wordsMissed);
    int newScore = state.score;
    int newCombo = state.currentCombo;
    int newMaxCombo = state.maxCombo;

    if (isCorrect) {
      newScore += 100;
      newCombo += 1;
      if (newCombo > newMaxCombo) {
        newMaxCombo = newCombo;
      }
      newWordsHit.add(wordId);
    } else {
      newCombo = 0;
      newWordsMissed.add(wordId);
    }

    int nextIndex = state.currentIndex + 1;
    bool finished = nextIndex >= state.session!.totalWords;

    state = state.copyWith(
      score: newScore,
      currentCombo: newCombo,
      maxCombo: newMaxCombo,
      wordsHit: newWordsHit,
      wordsMissed: newWordsMissed,
      currentIndex: nextIndex,
      isGameFinished: finished,
    );

    if (finished) {
      _submitGameResult();
    }
  }

  void handleTimeout(String wordId) {
    // Rơi chạm đáy coi như sai
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
