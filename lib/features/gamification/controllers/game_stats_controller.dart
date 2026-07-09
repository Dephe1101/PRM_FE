import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/gamification/models/game_stats_model.dart';
import 'package:mobile/features/gamification/repositories/game_repository.dart';
import 'package:mobile/features/home/repositories/home_repository.dart';

class GameStatsState {
  final List<LevelModel> levels;
  final List<TopicModel> topics;
  final String? selectedLevelId;
  final List<String> selectedTopicIds;
  final GameStatsModel? stats;
  final String? error;

  const GameStatsState({
    this.levels = const [],
    this.topics = const [],
    this.selectedLevelId,
    this.selectedTopicIds = const [],
    this.stats,
    this.error,
  });

  GameStatsState copyWith({
    List<LevelModel>? levels,
    List<TopicModel>? topics,
    String? selectedLevelId,
    List<String>? selectedTopicIds,
    GameStatsModel? stats,
    String? error,
  }) {
    return GameStatsState(
      levels: levels ?? this.levels,
      topics: topics ?? this.topics,
      selectedLevelId: selectedLevelId ?? this.selectedLevelId,
      selectedTopicIds: selectedTopicIds ?? this.selectedTopicIds,
      stats: stats ?? this.stats,
      error: error,
    );
  }
}

class GameStatsController extends Notifier<GameStatsState> {
  @override
  GameStatsState build() {
    Future.microtask(() => fetchLevels());
    return const GameStatsState();
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

      state = state.copyWith(
        topics: topics,
        selectedTopicIds: [],
        stats: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchStats(List<String> topicIds) async {
    if (topicIds.isEmpty) {
      state = state.copyWith(stats: null);
      return;
    }
    state = state.copyWith(error: null);
    try {
      final repo = ref.read(gameRepositoryProvider);
      final stats = await repo.getStats(topicIds: topicIds);
      
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setLevel(String levelId) {
    if (state.selectedLevelId == levelId) return;
    state = state.copyWith(
      selectedLevelId: levelId,
      selectedTopicIds: [], // Clear topics
      topics: [], // Clear topics
      stats: null, // Clear stats
    );
    fetchTopics(levelId);
  }

  void clearTopics() {
    state = state.copyWith(selectedTopicIds: []);
    fetchStats([]);
  }

  void toggleTopic(String topicId) {
    final currentIds = List<String>.from(state.selectedTopicIds);
    if (currentIds.contains(topicId)) {
      currentIds.remove(topicId);
    } else {
      if (currentIds.length < 5) {
        currentIds.add(topicId);
      } else {
        // Can't add more than 5, silently ignore or handle error if needed
        return;
      }
    }
    state = state.copyWith(selectedTopicIds: currentIds);
    fetchStats(currentIds);
  }
}

final gameStatsControllerProvider = NotifierProvider<GameStatsController, GameStatsState>(() {
  return GameStatsController();
});
