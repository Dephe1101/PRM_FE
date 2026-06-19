import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/learning/data/learning_remote_data_source.dart';

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return LearningRepository(ref.watch(learningRemoteDataSourceProvider));
});

class LearningRepository {
  final LearningRemoteDataSource _remoteDataSource;

  LearningRepository(this._remoteDataSource);

  Future<Map<String, dynamic>> getTopicDetail(String topicId) async {
    return _remoteDataSource.getTopicDetail(topicId);
  }
}
