import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_error_handler.dart';
import 'package:mobile/features/admin/models/word_model.dart';
import 'package:mobile/core/models/paginated_response.dart';
import 'package:mobile/features/admin/data/word_remote_data_source.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final dataSource = ref.watch(wordRemoteDataSourceProvider);
  return WordRepository(dataSource);
});

class WordRepository {
  final WordRemoteDataSource _dataSource;

  WordRepository(this._dataSource);

  Future<PaginatedResponse<WordModel>> getAllWords({
    String? levelId,
    String? topicId,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dataSource.getAllWords(
        levelId: levelId,
        topicId: topicId,
        search: search,
        page: page,
        limit: limit,
      );
      return PaginatedResponse<WordModel>.fromJson(
        response['data'],
        (json) => WordModel.fromJson(json),
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<WordModel> createWord(Map<String, dynamic> payload) async {
    try {
      final response = await _dataSource.createWord(payload);
      return WordModel.fromJson(response['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<WordModel> updateWord(String id, Map<String, dynamic> payload) async {
    try {
      final response = await _dataSource.updateWord(id, payload);
      return WordModel.fromJson(response['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> deleteWord(String id) async {
    try {
      await _dataSource.deleteWord(id);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
