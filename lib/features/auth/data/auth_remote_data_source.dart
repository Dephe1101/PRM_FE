import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/features/auth/models/session_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      ApiConstants.register,
      data: {'username': username, 'email': email, 'password': password},
    );
    return response.data['data']; // Trả về { user, accessToken }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return response.data['data']; // Trả về { user, accessToken }
  }

  Future<void> logout() async {
    await dio.post(ApiConstants.logout);
  }

  Future<void> logoutAll() async {
    await dio.post(ApiConstants.logoutAll);
  }

  Future<UserModel> getMe() async {
    // Không hiện vòng loading đen đè lên màn hình Splash lúc khởi động
    final response = await dio.get(
      ApiConstants.getMe,
      options: Options(extra: {'showLoading': false}),
    );
    return UserModel.fromJson(response.data['data']);
  }

  Future<UserModel> updateProfile({required String username}) async {
    final response = await dio.patch(
      ApiConstants.getMe,
      data: {'username': username},
    );
    return UserModel.fromJson(response.data['data']);
  }

  Future<List<SessionModel>> getSessions() async {
    final response = await dio.get(ApiConstants.getSessions);
    final List<dynamic> data = response.data['data'];
    return data.map((e) => SessionModel.fromJson(e)).toList();
  }

  Future<void> deleteSession(String id) async {
    await dio.delete(ApiConstants.deleteSession(id));
  }
}
