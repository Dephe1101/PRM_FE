import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/dio_client.dart';

final topicRemoteDataSourceProvider = Provider<TopicRemoteDataSource>((ref) {
  return TopicRemoteDataSource(ref.watch(dioProvider));
});

class TopicRemoteDataSource {
  final Dio dio;

  TopicRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> getAllTopics() async {
    // using pagination defaults
    final response = await dio.get('${ApiConstants.topics}?limit=100');
    return response.data;
  }

  Future<Map<String, dynamic>> getTopicsByLevel(String levelId) async {
    final response = await dio.get('${ApiConstants.topics}/level/$levelId?limit=100');
    return response.data;
  }

  Future<Map<String, dynamic>> createTopic(Map<String, dynamic> payload) async {
    final response = await dio.post(ApiConstants.topics, data: payload);
    return response.data;
  }

  Future<Map<String, dynamic>> importTopic(Map<String, dynamic> payload) async {
    final response = await dio.post('${ApiConstants.topics}/import', data: payload);
    return response.data;
  }

  Future<Map<String, dynamic>> updateTopic(String id, Map<String, dynamic> payload) async {
    final response = await dio.put('${ApiConstants.topics}/$id', data: payload);
    return response.data;
  }

  Future<void> deleteTopic(String id) async {
    await dio.delete('${ApiConstants.topics}/$id');
  }
}
