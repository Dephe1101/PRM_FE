import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/dio_client.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(ref.watch(dioProvider));
});

class UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> getAllUsers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final response = await _dio.get(
      ApiConstants.users,
      queryParameters: queryParams,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> toggleUserStatus(
    String id, {
    required bool isActive,
  }) async {
    final response = await _dio.patch(
      ApiConstants.userStatus(id),
      data: {'isActive': isActive},
    );
    return response.data;
  }
}
