import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/exceptions/app_exception.dart';
import 'package:mobile/core/network/api_error_handler.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/auth/data/auth_remote_data_source.dart';
import 'package:mobile/features/auth/models/user_model.dart';
import 'package:mobile/features/auth/models/session_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageProvider),
  );
});

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepository(this._remoteDataSource, this._secureStorage);

  Future<Either<Failure, UserModel>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final data = await _remoteDataSource.register(
        username: username,
        email: email,
        password: password,
      );
      final user = UserModel.fromJson(data['user']);
      await _secureStorage.write(key: 'accessToken', value: data['accessToken']);
      return right(user);
    } catch (e) {
      return left(Failure.fromException(ApiErrorHandler.handle(e)));
    }
  }

  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      final user = UserModel.fromJson(data['user']);
      await _secureStorage.write(key: 'accessToken', value: data['accessToken']);
      return right(user);
    } catch (e) {
      return left(Failure.fromException(ApiErrorHandler.handle(e)));
    }
  }

  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _secureStorage.delete(key: 'accessToken');
      return right(null);
    } catch (e) {
      return left(Failure.fromException(ApiErrorHandler.handle(e)));
    }
  }

  Future<Either<Failure, void>> logoutAll() async {
    try {
      await _remoteDataSource.logoutAll();
      await _secureStorage.delete(key: 'accessToken');
      return right(null);
    } catch (e) {
      return left(Failure.fromException(ApiErrorHandler.handle(e)));
    }
  }

  Future<Either<Failure, UserModel>> getMe() async {
    try {
      final user = await _remoteDataSource.getMe();
      return right(user);
    } catch (e) {
      return left(Failure.fromException(ApiErrorHandler.handle(e)));
    }
  }

  Future<Either<Failure, List<SessionModel>>> getSessions() async {
    try {
      final sessions = await _remoteDataSource.getSessions();
      return right(sessions);
    } catch (e) {
      return left(Failure.fromException(ApiErrorHandler.handle(e)));
    }
  }

  Future<Either<Failure, void>> deleteSession(String id) async {
    try {
      await _remoteDataSource.deleteSession(id);
      return right(null);
    } catch (e) {
      return left(Failure.fromException(ApiErrorHandler.handle(e)));
    }
  }
}
