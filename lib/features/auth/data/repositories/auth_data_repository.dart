
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_local_data_source.dart';

import '../../domain/entities/user.dart';


class AuthDataRepository implements AuthRepository {

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ProfileLocalDataSource profileLocalDataSource;

  AuthDataRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.profileLocalDataSource
  });

  @override
  Future<User> login({required String email, required String password}) async {

    final authResponse = await remoteDataSource.login(email, password);

    await localDataSource.cacheToken(authResponse.token);
    await localDataSource.cacheUser(authResponse.user);

    return authResponse.user;
  }

  @override
  Future<void> logout() async {

    try {
      final token = await localDataSource.getToken();

      if (token != null && token.isNotEmpty) {
        await remoteDataSource.logout(token);
        await localDataSource.clearCache();
        await profileLocalDataSource.clearProfileCache();
      }
    } catch (e) {
      await localDataSource.clearCache();
      await profileLocalDataSource.clearProfileCache();
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? surname
  }) async {
    await remoteDataSource.register(email, password, name, surname);
  }

  @override
  Future<User?> getCurrentUser() async {

    final cachedUser = await localDataSource.getCachedUser();

    if (cachedUser != null && await localDataSource.hasValidToken()) {
      return cachedUser;
    } else {
      await localDataSource.clearCache();
      return null;
    }
  }

  @override
  Future<bool> hasToken() async {
    return await localDataSource.hasValidToken();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await remoteDataSource.requestPasswordReset(email);
  }

  @override
  Future<void> validateResetCode(String email, String code) async {
    await remoteDataSource.validateResetCode(email, code);
  }

  @override
  Future<void> resetPassword(String email, String code, String newPassword) async {
    await remoteDataSource.resetPassword(email, code, newPassword);
  }
}