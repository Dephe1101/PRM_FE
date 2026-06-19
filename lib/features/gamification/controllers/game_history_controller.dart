import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';
import 'package:mobile/features/gamification/models/game_history_item_model.dart';
import 'package:mobile/features/gamification/repositories/game_repository.dart';
import 'package:mobile/core/network/global_loading_provider.dart';

class GameHistoryFilterState {
  final List<String> topicIds;

  const GameHistoryFilterState({this.topicIds = const []});

  GameHistoryFilterState copyWith({List<String>? topicIds}) {
    return GameHistoryFilterState(topicIds: topicIds ?? this.topicIds);
  }
}

class GameHistoryFilterNotifier extends Notifier<GameHistoryFilterState> {
  @override
  GameHistoryFilterState build() => const GameHistoryFilterState();

  void setTopicIds(List<String> topicIds) {
    state = state.copyWith(topicIds: topicIds);
  }
}

final gameHistoryFilterProvider =
    NotifierProvider<GameHistoryFilterNotifier, GameHistoryFilterState>(
      GameHistoryFilterNotifier.new,
    );

final gameHistoryControllerProvider =
    AsyncNotifierProvider.autoDispose<
      GameHistoryController,
      GameHistoryPaginatedModel
    >(GameHistoryController.new);

class GameHistoryController extends AsyncNotifier<GameHistoryPaginatedModel> {
  GameRepository get _repository => ref.read(gameRepositoryProvider);
  int _currentPage = 1;
  final int _limit = 5;

  @override
  FutureOr<GameHistoryPaginatedModel> build() async {
    final filter = ref.watch(gameHistoryFilterProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.isLoggedIn == true && next.isLoggedIn == false) {
        ref.invalidateSelf();
      }
    });

    if (filter.topicIds.isEmpty) {
      return GameHistoryPaginatedModel(
        docs: const [],
        totalDocs: 0,
        page: 1,
        hasNextPage: false,
      );
    }

    _currentPage = 1;
    return _repository.getHistory(
      page: _currentPage,
      limit: _limit,
      topicIds: filter.topicIds,
    );
  }

  Future<void> goToPage(int page) async {
    if (state.isLoading) return;

    final filter = ref.read(gameHistoryFilterProvider);
    if (filter.topicIds.isEmpty) return;

    _currentPage = page;
    
    try {
      final newData = await _repository.getHistory(
        page: _currentPage,
        limit: _limit,
        topicIds: filter.topicIds,
      );
      state = AsyncData(newData);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshHistory() async {
    final filter = ref.read(gameHistoryFilterProvider);
    if (filter.topicIds.isEmpty) {
      state = AsyncData(GameHistoryPaginatedModel(
        docs: const [],
        totalDocs: 0,
        page: 1,
        hasNextPage: false,
      ));
      return;
    }

    _currentPage = 1;
    try {
      final newData = await _repository.getHistory(
        page: _currentPage,
        limit: _limit,
        topicIds: filter.topicIds,
      );
      state = AsyncData(newData);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
