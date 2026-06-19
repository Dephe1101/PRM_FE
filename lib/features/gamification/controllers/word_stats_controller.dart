import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/flashcard/models/flashcard_stats_model.dart';
import 'package:mobile/features/flashcard/repositories/flashcard_repository.dart';
import 'package:mobile/features/home/repositories/home_repository.dart';

class WordStatsState {
  final List<LevelModel> levels;
  final List<TopicModel> topics;
  final String? selectedLevelId;
  final String? selectedTopicId;
  final FlashcardStatsModel? stats;
  final String? error;

  const WordStatsState({
    this.levels = const [],
    this.topics = const [],
    this.selectedLevelId,
    this.selectedTopicId,
    this.stats,
    this.error,
  });

  WordStatsState copyWith({
    List<LevelModel>? levels,
    List<TopicModel>? topics,
    String? selectedLevelId,
    String? selectedTopicId,
    FlashcardStatsModel? stats,
    String? error,
  }) {
    return WordStatsState(
      levels: levels ?? this.levels,
      topics: topics ?? this.topics,
      selectedLevelId: selectedLevelId ?? this.selectedLevelId,
      selectedTopicId: selectedTopicId ?? this.selectedTopicId,
      stats: stats ?? this.stats,
      error: error,
    );
  }
}

class WordStatsController extends Notifier<WordStatsState> {
  @override
  WordStatsState build() {
    Future.microtask(() => fetchLevels());
    return const WordStatsState();
  }

  Future<void> fetchLevels() async {
    state = state.copyWith(error: null);
    try {
      final repo = ref.read(homeRepositoryProvider);
      final levels = await repo.getAllLevels();

      String? newSelectedId = state.selectedLevelId;
      if (levels.isNotEmpty && newSelectedId == null) {
        newSelectedId = levels.first.id;
      }

      state = state.copyWith(
        levels: levels,
        selectedLevelId: newSelectedId,
      );

      if (newSelectedId != null) {
        await fetchTopics(newSelectedId);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchTopics(String levelId) async {
    state = state.copyWith(error: null);
    try {
      final repo = ref.read(homeRepositoryProvider);
      final topics = await repo.getTopicsByLevel(levelId);

      String? newSelectedTopicId;
      if (topics.isNotEmpty) {
        newSelectedTopicId = topics.first.id;
      }

      state = state.copyWith(
        topics: topics,
        selectedTopicId: newSelectedTopicId,
      );

      if (newSelectedTopicId != null) {
        await fetchStats(newSelectedTopicId);
      } else {
        state = state.copyWith(stats: null);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchStats(String topicId) async {
    state = state.copyWith(error: null);
    try {
      final repo = ref.read(flashcardRepositoryProvider);
      final stats = await repo.getProgress(topicId: topicId);
      
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setLevel(String levelId) {
    if (state.selectedLevelId == levelId) return;
    state = state.copyWith(
      selectedLevelId: levelId,
      selectedTopicId: null, // Clear topic
      topics: [], // Clear topics
      stats: null, // Clear stats
    );
    fetchTopics(levelId);
  }

  void setTopic(String topicId) {
    if (state.selectedTopicId == topicId) return;
    state = state.copyWith(selectedTopicId: topicId);
    fetchStats(topicId);
  }
}

final wordStatsControllerProvider = NotifierProvider<WordStatsController, WordStatsState>(() {
  return WordStatsController();
});
