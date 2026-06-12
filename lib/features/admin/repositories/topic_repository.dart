import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_error_handler.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/admin/data/topic_remote_data_source.dart';

final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  final dataSource = ref.watch(topicRemoteDataSourceProvider);
  return TopicRepository(dataSource);
});

class TopicRepository {
  final TopicRemoteDataSource _dataSource;

  TopicRepository(this._dataSource);

  Future<List<TopicModel>> getAllTopics() async {
    try {
      final response = await _dataSource.getAllTopics();
      // The backend returns paginated data inside "data" -> "docs"
      final data = response['data']['docs'] as List;
      return data.map((e) => TopicModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<TopicModel>> getTopicsByLevel(String levelId) async {
    try {
      final response = await _dataSource.getTopicsByLevel(levelId);
      final data = response['data']['docs'] as List;
      return data.map((e) => TopicModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<TopicModel> createTopic(Map<String, dynamic> payload) async {
    try {
      final response = await _dataSource.createTopic(payload);
      return TopicModel.fromJson(response['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> importTopic(Map<String, dynamic> payload) async {
    try {
      await _dataSource.importTopic(payload);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<TopicModel> updateTopic(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dataSource.updateTopic(id, payload);
      return TopicModel.fromJson(response['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> deleteTopic(String id) async {
    try {
      await _dataSource.deleteTopic(id);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
