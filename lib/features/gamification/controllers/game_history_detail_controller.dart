import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/gamification/models/game_history_detail_model.dart';
import 'package:mobile/features/gamification/repositories/game_repository.dart';

final gameHistoryDetailControllerProvider = FutureProvider.family<GameHistoryDetailModel, String>((ref, sessionId) async {
  final repository = ref.watch(gameRepositoryProvider);
  return repository.getHistoryDetail(sessionId);
});
