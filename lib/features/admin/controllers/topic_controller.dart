import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/controllers/auth_controller.dart';
import 'package:mobile/core/network/api_error_handler.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/admin/repositories/topic_repository.dart';

import 'package:mobile/features/admin/views/topics_tab.dart'; // for selectedLevelFilterProvider

final topicControllerProvider =
    AsyncNotifierProvider<TopicController, List<TopicModel>>(() {
      return TopicController();
    });

class TopicController extends AsyncNotifier<List<TopicModel>> {
  TopicRepository get _repository => ref.read(topicRepositoryProvider);

  @override
  FutureOr<List<TopicModel>> build() async {
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.isLoggedIn == true && next.isLoggedIn == false) {
        ref.invalidateSelf();
      }
    });
    final levelId = ref.read(selectedLevelFilterProvider);
    return _fetchTopics(levelId);
  }

  Future<List<TopicModel>> _fetchTopics(String? levelId) async {
    if (levelId == null) {
      return _repository.getAllTopics();
    } else {
      return _repository.getTopicsByLevel(levelId);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final levelId = ref.read(selectedLevelFilterProvider);
    state = await AsyncValue.guard(() => _fetchTopics(levelId));
  }

  Future<void> createTopic({
    required String levelId,
    required String title,
    int? orderIndex,
  }) async {
    try {
      final payload = {
        'levelId': levelId,
        'title': title,
        'orderIndex': ?orderIndex,
      };

      final newTopic = await _repository.createTopic(payload);

      // Update local state if the current filter matches or is "All Levels"
      final currentFilter = ref.read(selectedLevelFilterProvider);
      if (currentFilter == null || currentFilter == levelId) {
        state = state.whenData(
          (topics) =>
              [...topics, newTopic]
                ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
        );
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> importTopic({
    required String topicId,
    required String levelId,
    required String title,
    required List<Map<String, dynamic>> words,
  }) async {
    try {
      final payload = <String, dynamic>{
        'levelId': levelId,
        'title': title,
        'words': words,
      };

      if (topicId.isNotEmpty) {
        payload['topicId'] = topicId;
      }

      await _repository.importTopic(payload);

      // Auto-refresh to fetch updated and potentially new topics (spillover)
      await refresh();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> updateTopic({
    required String id,
    required String title,
    required int orderIndex,
  }) async {
    try {
      final payload = {'title': title, 'orderIndex': orderIndex};

      final updatedTopic = await _repository.updateTopic(id, payload);

      state = state.whenData((topics) {
        return topics.map((t) => t.id == id ? updatedTopic : t).toList()
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      });
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> deleteTopic(String id) async {
    try {
      await _repository.deleteTopic(id);
      state = state.whenData(
        (topics) => topics.where((t) => t.id != id).toList(),
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
