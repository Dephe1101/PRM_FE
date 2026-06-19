import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_error_handler.dart';
import 'package:mobile/features/admin/data/user_remote_data_source.dart';
import 'package:mobile/features/auth/models/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepository(dataSource);
});

class UserRepository {
  final UserRemoteDataSource _dataSource;

  UserRepository(this._dataSource);

  Future<List<UserModel>> getAllUsers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final response = await _dataSource.getAllUsers(
        page: page,
        limit: limit,
        search: search,
      );
      final data = response['data']['docs'] as List;
      return data.map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<UserModel> toggleUserStatus(
    String id, {
    required bool isActive,
  }) async {
    try {
      final response = await _dataSource.toggleUserStatus(id, isActive: isActive);
      return UserModel.fromJson(response['data']);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
