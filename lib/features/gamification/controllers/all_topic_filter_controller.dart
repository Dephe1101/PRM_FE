import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/home/repositories/home_repository.dart';

/// Manages levels + all topics by level (for History & Leaderboard screens).
/// Uses getTopicsByLevel() — returns ALL topics regardless of learning status.
class AllTopicFilterState {
  final List<LevelModel> levels;
  final String? selectedLevelId;
  final List<TopicModel> topics;
  final bool isLoading;
  final String? error;

  const AllTopicFilterState({
    this.levels = const [],
    this.selectedLevelId,
    this.topics = const [],
    this.isLoading = true,
    this.error,
  });

  AllTopicFilterState copyWith({
    List<LevelModel>? levels,
    String? selectedLevelId,
    List<TopicModel>? topics,
    bool? isLoading,
    String? error,
  }) {
    return AllTopicFilterState(
      levels: levels ?? this.levels,
      selectedLevelId: selectedLevelId ?? this.selectedLevelId,
      topics: topics ?? this.topics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AllTopicFilterController extends Notifier<AllTopicFilterState> {
  @override
  AllTopicFilterState build() {
    Future.microtask(() => init());
    return const AllTopicFilterState();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(homeRepositoryProvider);
      final levels = await repo.getAllLevels();

      List<TopicModel> topics = [];
      String? selectedId = state.selectedLevelId;
      if (selectedId == null && levels.isNotEmpty) {
        selectedId = levels.first.id;
      }
      if (selectedId != null) {
        topics = await repo.getTopicsByLevel(selectedId);
      }

      state = state.copyWith(
        levels: levels,
        selectedLevelId: selectedId,
        topics: topics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setLevel(String levelId) async {
    state = state.copyWith(selectedLevelId: levelId, isLoading: true, error: null);
    try {
      final repo = ref.read(homeRepositoryProvider);
      final topics = await repo.getTopicsByLevel(levelId);
      state = state.copyWith(topics: topics, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final allTopicFilterProvider =
    NotifierProvider<AllTopicFilterController, AllTopicFilterState>(
      AllTopicFilterController.new,
    );
