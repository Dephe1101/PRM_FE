import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_error_handler.dart';
import 'package:mobile/features/admin/models/word_model.dart';
import 'package:mobile/core/models/paginated_response.dart';
import 'package:mobile/features/admin/repositories/word_repository.dart';

class WordFilterState {
  final String? levelId;
  final String? topicId;
  final String? search;
  final int page;
  final int limit;
  WordFilterState({
    this.levelId,
    this.topicId,
    this.search,
    this.page = 1,
    this.limit = 5,
  });
}

final wordFilterProvider =
    NotifierProvider.autoDispose<WordFilterNotifier, WordFilterState>(() {
      return WordFilterNotifier();
    });

class WordFilterNotifier extends Notifier<WordFilterState> {
  @override
  WordFilterState build() => WordFilterState();

  void setLevel(String? levelId) {
    state = WordFilterState(
      levelId: levelId,
      topicId: null,
      search: state.search,
      page: 1,
      limit: state.limit,
    ); // Reset topic and page when level changes
  }

  void setTopic(String? topicId) {
    state = WordFilterState(
      levelId: state.levelId,
      topicId: topicId,
      search: state.search,
      page: 1,
      limit: state.limit,
    );
  }

  void setSearch(String? search) {
    state = WordFilterState(
      levelId: state.levelId,
      topicId: state.topicId,
      search: search,
      page: 1,
      limit: state.limit,
    );
  }

  void setPage(int page) {
    state = WordFilterState(
      levelId: state.levelId,
      topicId: state.topicId,
      search: state.search,
      page: page,
      limit: state.limit,
    );
  }
}

// Word Controller
final wordControllerProvider =
    AsyncNotifierProvider.autoDispose<
      WordController,
      PaginatedResponse<WordModel>
    >(() {
      return WordController();
    });

class WordController extends AsyncNotifier<PaginatedResponse<WordModel>> {
  WordRepository get _repository => ref.read(wordRepositoryProvider);

  @override
  FutureOr<PaginatedResponse<WordModel>> build() async {
    final filter = ref.watch(wordFilterProvider);
    return _fetchWords(
      levelId: filter.levelId,
      topicId: filter.topicId,
      search: filter.search,
      page: filter.page,
      limit: filter.limit,
    );
  }

  Future<PaginatedResponse<WordModel>> _fetchWords({
    String? levelId,
    String? topicId,
    String? search,
    int page = 1,
    int limit = 5,
  }) async {
    return _repository.getAllWords(
      levelId: levelId,
      topicId: topicId,
      search: search,
      page: page,
      limit: limit,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final filter = ref.read(wordFilterProvider);
    state = await AsyncValue.guard(
      () => _fetchWords(
        levelId: filter.levelId,
        topicId: filter.topicId,
        search: filter.search,
        page: filter.page,
        limit: filter.limit,
      ),
    );
  }

  Future<void> createWord(Map<String, dynamic> payload) async {
    try {
      final newWord = await _repository.createWord(payload);

      // Check if the new word belongs to the current filter
      final currentFilter = ref.read(wordFilterProvider);

      // We can just refresh to ensure correctness, or blindly append.
      // Since words have topicId, we could check if currentFilter.topicId matches, but let's just refresh.
      // However, appending is faster.
      if (currentFilter.topicId == null ||
          currentFilter.topicId == newWord.topicId) {
        state = state.whenData(
          (response) => PaginatedResponse(
            docs: [newWord, ...response.docs],
            totalDocs: response.totalDocs + 1,
            limit: response.limit,
            totalPages: response.totalPages,
            page: response.page,
            hasNextPage: response.hasNextPage,
            hasPrevPage: response.hasPrevPage,
          ),
        );
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> updateWord(String id, Map<String, dynamic> payload) async {
    try {
      final updatedWord = await _repository.updateWord(id, payload);

      state = state.whenData((response) {
        return PaginatedResponse(
          docs: response.docs.map((w) => w.id == id ? updatedWord : w).toList(),
          totalDocs: response.totalDocs,
          limit: response.limit,
          totalPages: response.totalPages,
          page: response.page,
          hasNextPage: response.hasNextPage,
          hasPrevPage: response.hasPrevPage,
        );
      });
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> deleteWord(String id) async {
    try {
      await _repository.deleteWord(id);
      state = state.whenData((response) {
        return PaginatedResponse(
          docs: response.docs.where((w) => w.id != id).toList(),
          totalDocs: response.totalDocs - 1,
          limit: response.limit,
          totalPages: response.totalPages,
          page: response.page,
          hasNextPage: response.hasNextPage,
          hasPrevPage: response.hasPrevPage,
        );
      });
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
