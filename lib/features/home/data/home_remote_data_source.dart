import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/dio_client.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return HomeRemoteDataSource(ref.watch(dioProvider));
});

class HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> getAllLevels() async {
    final response = await dio.get(ApiConstants.levels);
    return response.data;
  }

  Future<Map<String, dynamic>> getTopicsByLevel(String levelId) async {
    final response = await dio.get(
      '${ApiConstants.flashcards}/levels/$levelId/topics',
    );
    return response.data;
  }
}
