import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/network/api_error_handler.dart';
import 'package:mobile/features/flashcard/models/flashcard_model.dart';
import 'package:mobile/features/flashcard/models/flashcard_stats_model.dart';

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return FlashcardRepository(dio);
});

class FlashcardRepository {
  final Dio _dio;

  FlashcardRepository(this._dio);

  Future<List<FlashcardModel>> getFlashcardsByTopic(String topicId) async {
    try {
      final response = await _dio.get('/flashcards/topics/$topicId');
      final data = response.data['data']['flashcards'] as List;
      return data.map((json) => FlashcardModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<FlashcardModel> submitFlashcard({
    required String wordId,
    required bool isCorrect,
    int? timeSpent,
  }) async {
    try {
      final payload = {
        'wordId': wordId,
        'isCorrect': isCorrect,
        if (timeSpent != null) 'timeSpent': timeSpent,
      };
      final response = await _dio.post('/flashcards/submit', data: payload);
      return FlashcardModel.fromJson(response.data['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> submitBatchFlashcards(List<Map<String, dynamic>> results) async {
    try {
      await _dio.post('/flashcards/submit-batch', data: {'results': results});
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<FlashcardModel>> getReviewWords() async {
    try {
      final response = await _dio.get('/flashcards/review');
      final data = response.data['data'] as List;
      return data.map((json) => FlashcardModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<FlashcardStatsModel> getProgress({String? levelId, String? topicId}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (levelId != null && levelId != 'All') queryParameters['levelId'] = levelId;
      if (topicId != null && topicId != 'All') queryParameters['topicId'] = topicId;

      final response = await _dio.get(
        '/flashcards/progress',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );
      return FlashcardStatsModel.fromJson(response.data['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<FlashcardModel>> getBookmarks() async {
    try {
      final response = await _dio.get('/flashcards/bookmarks');
      final data = response.data['data'] as List;
      return data.map((json) => FlashcardModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<FlashcardModel>> getBookmarksStudy() async {
    try {
      final response = await _dio.get('/flashcards/bookmarks/study');
      final data = response.data['data']['flashcards'] as List;
      return data.map((json) => FlashcardModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<bool> toggleBookmark(String wordId) async {
    try {
      final response = await _dio.patch('/flashcards/bookmark/$wordId');
      return response.data['data']['isBookmarked'] as bool;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<FlashcardModel>> getBookmarkedFlashcardsByTopic(String topicId) async {
    try {
      final response = await _dio.get('/flashcards/topics/$topicId/bookmarks');
      final data = response.data['data']['flashcards'] as List;
      return data.map((json) => FlashcardModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
