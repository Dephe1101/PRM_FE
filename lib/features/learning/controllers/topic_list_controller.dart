import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/home/repositories/home_repository.dart';

class TopicListState {
  final List<LevelModel> levels;
  final List<TopicModel> topics;
  final String? selectedLevelId;
  final bool isLoadingLevels;
  final bool isLoadingTopics;
  final String? error;

  const TopicListState({
    this.levels = const [],
    this.topics = const [],
    this.selectedLevelId,
    this.isLoadingLevels = true,
    this.isLoadingTopics = false,
    this.error,
  });

  TopicListState copyWith({
    List<LevelModel>? levels,
    List<TopicModel>? topics,
    String? selectedLevelId,
    bool? isLoadingLevels,
    bool? isLoadingTopics,
    String? error,
  }) {
    return TopicListState(
      levels: levels ?? this.levels,
      topics: topics ?? this.topics,
      selectedLevelId: selectedLevelId ?? this.selectedLevelId,
      isLoadingLevels: isLoadingLevels ?? this.isLoadingLevels,
      isLoadingTopics: isLoadingTopics ?? this.isLoadingTopics,
      error: error ?? this.error,
    );
  }
}

class TopicListController extends Notifier<TopicListState> {
  @override
  TopicListState build() {
    Future.microtask(() => fetchLevels());
    return const TopicListState();
  }

  Future<void> fetchLevels() async {
    state = state.copyWith(isLoadingLevels: true, error: null);
    try {
      final repo = ref.read(homeRepositoryProvider);
      final levels = await repo.getAllLevels();

      String? newSelectedId = state.selectedLevelId;
      if (levels.isNotEmpty && newSelectedId == null) {
        newSelectedId = levels.first.id;
      }

      state = state.copyWith(
        levels: levels,
        isLoadingLevels: false,
        selectedLevelId: newSelectedId,
      );

      if (newSelectedId != null) {
        fetchTopics(newSelectedId);
      }
    } catch (e) {
      state = state.copyWith(isLoadingLevels: false, error: e.toString());
    }
  }

  Future<void> fetchTopics(String levelId) async {
    state = state.copyWith(isLoadingTopics: true, error: null);
    try {
      final repo = ref.read(homeRepositoryProvider);
      final topics = await repo.getTopicsByLevel(levelId);
      // Chỉ cập nhật nếu user chưa chuyển sang level khác
      if (state.selectedLevelId == levelId) {
        state = state.copyWith(topics: topics, isLoadingTopics: false);
      }
    } catch (e, st) {
      print('fetchTopics error: $e');
      print(st);
      if (state.selectedLevelId == levelId) {
        state = state.copyWith(isLoadingTopics: false, error: e.toString());
      }
    }
  }

  void setLevel(String levelId) {
    if (state.selectedLevelId == levelId) return;
    state = state.copyWith(selectedLevelId: levelId, topics: []);
    fetchTopics(levelId);
  }
}

final topicListControllerProvider =
    NotifierProvider.autoDispose<TopicListController, TopicListState>(() {
      return TopicListController();
    });

// Giữ lại các provider cũ để mapping tạm thời nếu UI chưa sửa hết, hoặc xoá và sửa UI
