
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/sync_device_local_data_source.dart';

import '../../domain/entities/user.dart';


class AuthDataRepository implements AuthRepository {

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ProfileLocalDataSource profileLocalDataSource;
  final SyncDeviceLocalDataSource syncDeviceLocalDataSource;

  AuthDataRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.profileLocalDataSource,
    required this.syncDeviceLocalDataSource,
  });

  @override
  Future<User> login({required String email, required String password}) async {

    final deviceUuid = await syncDeviceLocalDataSource.getDeviceUuid();
    final authResponse = await remoteDataSource.login(email, password, deviceUuid);

    await localDataSource.cacheToken(authResponse.token);
    await localDataSource.cacheRefreshToken(authResponse.refreshToken!);
    await localDataSource.cacheLoginTimestamp(DateTime.now());
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
    final deviceUuid = await syncDeviceLocalDataSource.getDeviceUuid();
    final authResponse = await remoteDataSource.register(email, password, name, surname, deviceUuid);

    await localDataSource.cacheToken(authResponse.token);
    await localDataSource.cacheRefreshToken(authResponse.refreshToken!);
    await localDataSource.cacheLoginTimestamp(DateTime.now());
    await localDataSource.cacheUser(authResponse.user);
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

  @override
  Future<void> refreshToken() async {
    final storedRefreshToken = await localDataSource.getRefreshToken();

    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    final deviceUuid = await syncDeviceLocalDataSource.getDeviceUuid();
    final refreshResponse = await remoteDataSource.refreshToken(storedRefreshToken, deviceUuid);

    await localDataSource.cacheToken(refreshResponse.accessToken);
    await localDataSource.cacheRefreshToken(refreshResponse.refreshToken);
    // Note: We don't update login timestamp on refresh, only on new login
  }

  Future<bool> isRefreshTokenExpired() async {
    final loginTimestamp = await localDataSource.getLoginTimestamp();

    if (loginTimestamp == null) {
      return true; // No login timestamp means expired
    }

    final now = DateTime.now();
    final daysSinceLogin = now.difference(loginTimestamp).inDays;

    return daysSinceLogin >= 30;
  }
}