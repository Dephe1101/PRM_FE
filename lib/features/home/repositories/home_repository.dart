import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_error_handler.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/home/data/home_remote_data_source.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final dataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepository(dataSource);
});

class HomeRepository {
  final HomeRemoteDataSource _dataSource;

  HomeRepository(this._dataSource);

  Future<List<LevelModel>> getAllLevels() async {
    try {
      final response = await _dataSource.getAllLevels();
      final data = response['data'] as List;
      // Lọc ra các level đang active nếu cần (mặc định BE có thể trả về tất cả)
      final levels = data.map((e) => LevelModel.fromJson(e)).toList();
      return levels.where((level) => level.isActive).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<TopicModel>> getTopicsByLevel(String levelId) async {
    try {
      final response = await _dataSource.getTopicsByLevel(levelId);
      final data = response['data'] as List;
      return data
          .map((e) => TopicModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
