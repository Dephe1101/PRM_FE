import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/dio_client.dart';

final learningRemoteDataSourceProvider = Provider<LearningRemoteDataSource>((
  ref,
) {
  return LearningRemoteDataSource(ref.watch(dioProvider));
});

class LearningRemoteDataSource {
  final Dio dio;

  LearningRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> getTopicDetail(String topicId) async {
    final response = await dio.get('${ApiConstants.topics}/$topicId');
    return response.data;
  }
}
