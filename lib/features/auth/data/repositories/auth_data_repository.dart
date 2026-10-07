
import 'dart:convert';

import 'package:photo_manager_app/core/crypto/data/master_key_local_data_source.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/auth/data/models/auth_response_model.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:photo_manager_app/features/auth/domain/entities/login_result.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/sync_device_local_data_source.dart';

import '../../domain/entities/user.dart';


class AuthDataRepository implements AuthRepository {

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ProfileLocalDataSource profileLocalDataSource;
  final SyncDeviceLocalDataSource syncDeviceLocalDataSource;
  final MasterKeyLocalDataSource masterKeyLocalDataSource;

  AuthDataRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.profileLocalDataSource,
    required this.syncDeviceLocalDataSource,
    required this.masterKeyLocalDataSource,
  });

  @override
  Future<KdfParams> getKdfParams(String email) => remoteDataSource.getKdfParams(email);

  @override
  Future<LoginResult> login({required String email, required CryptoKey authKey}) async {

    final deviceUuid = await syncDeviceLocalDataSource.getDeviceUuid();
    final authResponse = await remoteDataSource.login(email, base64Encode(authKey.bytes), deviceUuid);

    await _cacheSession(authResponse);
    return LoginResult(user: authResponse.user, keys: authResponse.keys!,
        legalAcceptanceRequired: authResponse.legalAcceptanceRequired);
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
    } finally {
      // The master keys never stay on a device without a session (docs/e2ee-spec.md, section 8.7)
      await masterKeyLocalDataSource.clear();
    }
  }

  @override
  Future<LoginResult> register({
    required String email,
    required CryptoKey authKey,
    required String name,
    String? surname,
    required KdfParams kdfParams,
    required NewKeyMaterial key,
    required String acceptedTermsVersion,
    required String acceptedPrivacyVersion,
  }) async {
    final deviceUuid = await syncDeviceLocalDataSource.getDeviceUuid();
    final authResponse = await remoteDataSource.register(
      email: email,
      authKey: base64Encode(authKey.bytes),
      name: name,
      surname: surname,
      deviceUuid: deviceUuid,
      kdfParams: kdfParams,
      key: key,
      acceptedTermsVersion: acceptedTermsVersion,
      acceptedPrivacyVersion: acceptedPrivacyVersion,
    );

    await _cacheSession(authResponse);
    return LoginResult(user: authResponse.user, keys: authResponse.keys!,
        legalAcceptanceRequired: authResponse.legalAcceptanceRequired);
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
  Future<List<RecoveryWrap>> getRecoveryWraps(String email, String code) {
    return remoteDataSource.getRecoveryWraps(email, code);
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String code,
    required CryptoKey newAuthKey,
    required KdfParams kdfParams,
    required List<RecoveredKey> recoveredKeys,
  }) {
    return remoteDataSource.resetPassword(
      email: email,
      code: code,
      newAuthKey: base64Encode(newAuthKey.bytes),
      kdfParams: kdfParams,
      recoveredKeys: recoveredKeys,
    );
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

  Future<void> _cacheSession(AuthResponseModel authResponse) async {
    await localDataSource.cacheToken(authResponse.token);
    await localDataSource.cacheRefreshToken(authResponse.refreshToken!);
    await localDataSource.cacheLoginTimestamp(DateTime.now());
    await localDataSource.cacheUser(authResponse.user);
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