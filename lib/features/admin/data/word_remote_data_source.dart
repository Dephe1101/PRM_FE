import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/dio_client.dart';

final wordRemoteDataSourceProvider = Provider<WordRemoteDataSource>((ref) {
  return WordRemoteDataSource(ref.watch(dioProvider));
});

class WordRemoteDataSource {
  final Dio dio;

  WordRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> getAllWords({
    String? levelId,
    String? topicId,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (levelId != null) queryParams['levelId'] = levelId;
    if (topicId != null) queryParams['topicId'] = topicId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await dio.get(ApiConstants.words, queryParameters: queryParams);
    return response.data;
  }

  Future<Map<String, dynamic>> createWord(Map<String, dynamic> payload) async {
    final response = await dio.post(ApiConstants.words, data: payload);
    return response.data;
  }

  Future<Map<String, dynamic>> updateWord(String id, Map<String, dynamic> payload) async {
    final response = await dio.put('${ApiConstants.words}/$id', data: payload);
    return response.data;
  }

  Future<void> deleteWord(String id) async {
    await dio.delete('${ApiConstants.words}/$id');
  }
}
