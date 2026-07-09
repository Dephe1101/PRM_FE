import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/flashcard/models/progress_word_page_model.dart';
import 'package:mobile/features/flashcard/repositories/flashcard_repository.dart';

class ProgressWordsState {
  final ProgressWordPageModel data;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final String type; // 'mastered' | 'learning'
  final String? levelId;
  final String? topicId;

  const ProgressWordsState({
    this.data = const ProgressWordPageModel(),
    this.isLoading = true,
    this.error,
    this.currentPage = 1,
    this.type = 'mastered',
    this.levelId,
    this.topicId,
  });

  ProgressWordsState copyWith({
    ProgressWordPageModel? data,
    bool? isLoading,
    String? error,
    int? currentPage,
    String? type,
    String? levelId,
    String? topicId,
  }) {
    return ProgressWordsState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      type: type ?? this.type,
      levelId: levelId ?? this.levelId,
      topicId: topicId ?? this.topicId,
    );
  }
}

class ProgressWordsController extends Notifier<ProgressWordsState> {
  @override
  ProgressWordsState build() => const ProgressWordsState();

  Future<void> load({
    required String type,
    String? levelId,
    String? topicId,
    int page = 1,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      type: type,
      levelId: levelId,
      topicId: topicId,
      currentPage: page,
    );
    try {
      final repo = ref.read(flashcardRepositoryProvider);
      final data = await repo.getProgressWords(
        type: type,
        levelId: levelId,
        topicId: topicId,
        page: page,
        limit: 10,
      );
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> goToPage(int page) => load(
    type: state.type,
    levelId: state.levelId,
    topicId: state.topicId,
    page: page,
  );
}

final progressWordsControllerProvider =
    NotifierProvider<ProgressWordsController, ProgressWordsState>(
      ProgressWordsController.new,
    );
