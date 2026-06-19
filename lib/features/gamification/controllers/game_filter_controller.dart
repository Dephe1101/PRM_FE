import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/gamification/repositories/game_repository.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/home/repositories/home_repository.dart';

class GameFilterState {
  final List<LevelModel> levels;
  final String? selectedLevelId;
  final List<TopicModel> topics;
  final List<String> selectedTopicIds;
  final bool isLoading;
  final String? error;

  const GameFilterState({
    this.levels = const [],
    this.selectedLevelId,
    this.topics = const [],
    this.selectedTopicIds = const [],
    this.isLoading = true,
    this.error,
  });

  GameFilterState copyWith({
    List<LevelModel>? levels,
    String? selectedLevelId,
    List<TopicModel>? topics,
    List<String>? selectedTopicIds,
    bool? isLoading,
    String? error,
  }) {
    return GameFilterState(
      levels: levels ?? this.levels,
      selectedLevelId: selectedLevelId ?? this.selectedLevelId,
      topics: topics ?? this.topics,
      selectedTopicIds: selectedTopicIds ?? this.selectedTopicIds,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class GameFilterController extends Notifier<GameFilterState> {
  @override
  GameFilterState build() {
    Future.microtask(() => initFilters());
    return const GameFilterState();
  }

  Future<void> initFilters() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final homeRepo = ref.read(homeRepositoryProvider);
      final levels = await homeRepo.getAllLevels();

      final repo = ref.read(gameRepositoryProvider);
      final topics = await repo.getEligibleTopics(
        levelId: state.selectedLevelId,
      );

      state = state.copyWith(levels: levels, topics: topics, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setLevel(String? levelId) async {
    state = state.copyWith(selectedLevelId: levelId, selectedTopicIds: []);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(gameRepositoryProvider);
      final topics = await repo.getEligibleTopics(levelId: levelId);
      state = state.copyWith(topics: topics, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearTopics() {
    state = state.copyWith(selectedTopicIds: []);
  }

  void toggleTopic(String topicId) {
    final currentSelected = List<String>.from(state.selectedTopicIds);
    if (currentSelected.contains(topicId)) {
      currentSelected.remove(topicId);
    } else {
      if (currentSelected.length < 5) {
        currentSelected.add(topicId);
      } else {
        return;
      }
    }
    state = state.copyWith(selectedTopicIds: currentSelected);
  }
}

final gameFilterControllerProvider =
    NotifierProvider<GameFilterController, GameFilterState>(
      GameFilterController.new,
    );
