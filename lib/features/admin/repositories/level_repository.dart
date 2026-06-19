import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_error_handler.dart';
import 'package:mobile/features/admin/models/level_model.dart';
import 'package:mobile/features/admin/data/level_remote_data_source.dart';

final levelRepositoryProvider = Provider<LevelRepository>((ref) {
  final dataSource = ref.watch(levelRemoteDataSourceProvider);
  return LevelRepository(dataSource);
});

class LevelRepository {
  final LevelRemoteDataSource _dataSource;

  LevelRepository(this._dataSource);

  Future<List<LevelModel>> getAllLevels() async {
    try {
      final response = await _dataSource.getAllLevels();
      final data = response['data'] as List;
      return data.map((e) => LevelModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<LevelModel> createLevel(Map<String, dynamic> payload) async {
    try {
      final response = await _dataSource.createLevel(payload);
      return LevelModel.fromJson(response['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<LevelModel> updateLevel(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dataSource.updateLevel(id, payload);
      return LevelModel.fromJson(response['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> deleteLevel(String id) async {
    try {
      await _dataSource.deleteLevel(id);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
