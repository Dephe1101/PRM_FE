import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/home/repositories/home_repository.dart';

class BookmarkFilterState {
  final List<LevelModel> levels;
  final List<TopicModel> topics;
  final String? selectedLevelId;
  final String? selectedTopicId;
  final bool isLoading;
  final String? error;

  BookmarkFilterState({
    this.levels = const [],
    this.topics = const [],
    this.selectedLevelId,
    this.selectedTopicId,
    this.isLoading = false,
    this.error,
  });

  BookmarkFilterState copyWith({
    List<LevelModel>? levels,
    List<TopicModel>? topics,
    String? selectedLevelId,
    String? selectedTopicId,
    bool? isLoading,
    String? error,
    bool clearLevelId = false,
    bool clearTopicId = false,
  }) {
    return BookmarkFilterState(
      levels: levels ?? this.levels,
      topics: topics ?? this.topics,
      selectedLevelId: clearLevelId ? null : (selectedLevelId ?? this.selectedLevelId),
      selectedTopicId: clearTopicId ? null : (selectedTopicId ?? this.selectedTopicId),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class BookmarkFilterNotifier extends Notifier<BookmarkFilterState> {
  @override
  BookmarkFilterState build() {
    Future.microtask(() => initFilters());
    return BookmarkFilterState();
  }

  Future<void> initFilters() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(homeRepositoryProvider);
      final levels = await repo.getAllLevels();

      state = state.copyWith(
        levels: levels,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectLevel(String? levelId) async {
    if (levelId == state.selectedLevelId) return;

    if (levelId == null) {
      state = state.copyWith(clearLevelId: true, topics: [], clearTopicId: true);
      return;
    }

    state = state.copyWith(selectedLevelId: levelId, topics: [], clearTopicId: true, isLoading: true);
    
    try {
      final repo = ref.read(homeRepositoryProvider);
      final topics = await repo.getTopicsByLevel(levelId);
      
      state = state.copyWith(
        topics: topics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectTopic(String? topicId) {
    state = state.copyWith(
      selectedTopicId: topicId,
      clearTopicId: topicId == null,
    );
  }
}

final bookmarkFilterProvider = NotifierProvider.autoDispose<BookmarkFilterNotifier, BookmarkFilterState>(() {
  return BookmarkFilterNotifier();
});
