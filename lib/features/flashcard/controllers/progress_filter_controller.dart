import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/home/repositories/home_repository.dart';

class ProgressFilterState {
  final List<LevelModel> levels;
  final List<TopicModel> topics;
  final String selectedLevelId;
  final String selectedTopicId;
  final bool isLoading;
  final String? error;

  const ProgressFilterState({
    this.levels = const [],
    this.topics = const [],
    this.selectedLevelId = 'All',
    this.selectedTopicId = 'All',
    this.isLoading = true,
    this.error,
  });

  ProgressFilterState copyWith({
    List<LevelModel>? levels,
    List<TopicModel>? topics,
    String? selectedLevelId,
    String? selectedTopicId,
    bool? isLoading,
    String? error,
  }) {
    return ProgressFilterState(
      levels: levels ?? this.levels,
      topics: topics ?? this.topics,
      selectedLevelId: selectedLevelId ?? this.selectedLevelId,
      selectedTopicId: selectedTopicId ?? this.selectedTopicId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProgressFilterController extends Notifier<ProgressFilterState> {
  @override
  ProgressFilterState build() {
    Future.microtask(() => initFilters());
    return const ProgressFilterState();
  }

  Future<void> initFilters() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final homeRepo = ref.read(homeRepositoryProvider);
      final levels = await homeRepo.getAllLevels();
      
      state = state.copyWith(
        levels: levels,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setLevel(String levelId) async {
    if (state.selectedLevelId == levelId) return;

    state = state.copyWith(
      selectedLevelId: levelId,
      selectedTopicId: 'All',
      topics: [],
    );

    if (levelId == 'All') return;

    try {
      final homeRepo = ref.read(homeRepositoryProvider);
      final topics = await homeRepo.getTopicsByLevel(levelId);
      
      state = state.copyWith(topics: topics);
    } catch (e) {
      // Ignored error
    }
  }

  void setTopic(String topicId) {
    if (state.selectedTopicId == topicId) return;
    state = state.copyWith(selectedTopicId: topicId);
  }
}

final progressFilterControllerProvider = NotifierProvider<ProgressFilterController, ProgressFilterState>(
  ProgressFilterController.new,
);
