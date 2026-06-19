import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/gamification/models/leaderboard_entry_model.dart';
import 'package:mobile/features/gamification/repositories/game_repository.dart';

class LeaderboardFilterState {
  final List<String> topicIds;

  const LeaderboardFilterState({
    this.topicIds = const [],
  });

  LeaderboardFilterState copyWith({
    List<String>? topicIds,
  }) {
    return LeaderboardFilterState(
      topicIds: topicIds ?? this.topicIds,
    );
  }
}

class LeaderboardFilterNotifier extends Notifier<LeaderboardFilterState> {
  @override
  LeaderboardFilterState build() => const LeaderboardFilterState();

  void setTopicIds(List<String> topicIds) {
    state = state.copyWith(topicIds: topicIds);
  }
}

final leaderboardFilterProvider = NotifierProvider<LeaderboardFilterNotifier, LeaderboardFilterState>(
  LeaderboardFilterNotifier.new,
);

final gameLeaderboardControllerProvider = AsyncNotifierProvider.autoDispose<GameLeaderboardController, List<LeaderboardEntryModel>>(
  GameLeaderboardController.new,
);

class GameLeaderboardController extends AsyncNotifier<List<LeaderboardEntryModel>> {
  GameRepository get _repository => ref.read(gameRepositoryProvider);

  @override
  FutureOr<List<LeaderboardEntryModel>> build() async {
    final filter = ref.watch(leaderboardFilterProvider);
    if (filter.topicIds.isEmpty) return [];
    return _repository.getLeaderboard(gameType: 'FALLING_WORDS', topicIds: filter.topicIds);
  }

  Future<void> refreshLeaderboard() async {
    final filter = ref.read(leaderboardFilterProvider);
    if (filter.topicIds.isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = await AsyncValue.guard(() => _repository.getLeaderboard(gameType: 'FALLING_WORDS', topicIds: filter.topicIds));
  }
}
