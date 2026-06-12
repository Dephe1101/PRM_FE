import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/dio_client.dart';

final levelRemoteDataSourceProvider = Provider<LevelRemoteDataSource>((ref) {
  return LevelRemoteDataSource(ref.watch(dioProvider));
});

class LevelRemoteDataSource {
  final Dio dio;

  LevelRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> getAllLevels() async {
    final response = await dio.get(ApiConstants.levels);
    return response.data;
  }

  Future<Map<String, dynamic>> createLevel(Map<String, dynamic> payload) async {
    final response = await dio.post(ApiConstants.levels, data: payload);
    return response.data;
  }

  Future<Map<String, dynamic>> updateLevel(String id, Map<String, dynamic> payload) async {
    final response = await dio.put('${ApiConstants.levels}/$id', data: payload);
    return response.data;
  }

  Future<void> deleteLevel(String id) async {
    await dio.delete('${ApiConstants.levels}/$id');
  }
}
