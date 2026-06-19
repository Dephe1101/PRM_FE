import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_error_handler.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/admin/models/topic_model.dart';
import 'package:mobile/features/gamification/models/game_session_model.dart';
import 'package:mobile/features/gamification/models/game_stats_model.dart';
import 'package:mobile/features/gamification/models/leaderboard_entry_model.dart';
import 'package:mobile/features/gamification/models/game_history_item_model.dart';
import 'package:mobile/features/gamification/models/game_history_detail_model.dart';

class GameRepository {
  final Dio _dio;

  GameRepository(this._dio);

  Future<List<TopicModel>> getEligibleTopics({String? levelId}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (levelId != null && levelId.isNotEmpty && levelId != 'All') {
        queryParameters['levelId'] = levelId;
      }
      final response = await _dio.get('/games/eligible-topics', queryParameters: queryParameters);
      final data = response.data['data'] as List;
      return data.map((json) => TopicModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<GameSessionModel> startGame(List<String> topicIds, String gameType) async {
    try {
      final response = await _dio.post('/games/start', data: {
        'topicIds': topicIds,
        'gameType': gameType,
      });
      return GameSessionModel.fromJson(response.data['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Map<String, dynamic>> submitGame({
    required String sessionId,
    required int score,
    required int maxCombo,
    required List<String> wordsHit,
    required List<String> wordsMissed,
  }) async {
    try {
      final response = await _dio.post('/games/submit', data: {
        'sessionId': sessionId,
        'score': score,
        'maxCombo': maxCombo,
        'wordsHit': wordsHit,
        'wordsMissed': wordsMissed,
      });
      return response.data['data'];
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<GameStatsModel> getStats({List<String>? topicIds}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (topicIds != null && topicIds.isNotEmpty) {
        queryParameters['topicIds'] = topicIds.join(',');
      }
      final response = await _dio.get('/games/stats', queryParameters: queryParameters);
      return GameStatsModel.fromJson(response.data['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<LeaderboardEntryModel>> getLeaderboard({String? gameType, List<String>? topicIds, int limit = 10}) async {
    try {
      final queryParameters = <String, dynamic>{'limit': limit};
      if (gameType != null) {
        queryParameters['gameType'] = gameType;
      }
      if (topicIds != null && topicIds.isNotEmpty) {
        queryParameters['topicIds'] = topicIds.join(',');
      }
      final response = await _dio.get('/games/leaderboard', queryParameters: queryParameters);
      final data = response.data['data'] as List;
      return data.map((json) => LeaderboardEntryModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<GameHistoryPaginatedModel> getHistory({int page = 1, int limit = 10, List<String>? topicIds}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (topicIds != null && topicIds.isNotEmpty) {
        queryParams['topicIds'] = topicIds.join(',');
      }
      
      final response = await _dio.get('/games/history', queryParameters: queryParams);
      return GameHistoryPaginatedModel.fromJson(response.data['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<GameHistoryDetailModel> getHistoryDetail(String id) async {
    try {
      final response = await _dio.get('/games/history/$id');
      return GameHistoryDetailModel.fromJson(response.data['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository(ref.read(dioProvider));
});
