import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/data/master_key_local_data_source.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:photo_manager_app/features/auth/data/models/auth_response_model.dart';
import 'package:photo_manager_app/features/auth/data/models/refresh_token_response_model.dart';
import 'package:photo_manager_app/features/auth/data/models/user_model.dart';
import 'package:photo_manager_app/features/auth/data/repositories/auth_data_repository.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/sync_device_local_data_source.dart';

import '../../../../fixtures/e2ee_test_data.dart';
import '../../../../helpers/in_memory_secure_store.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockProfileLocalDataSource extends Mock implements ProfileLocalDataSource {}

class MockSyncDeviceLocalDataSource extends Mock implements SyncDeviceLocalDataSource {}

class FakeUserModel extends Fake implements UserModel {}

class FakeKdfParams extends Fake implements KdfParams {}

class FakeNewKeyMaterial extends Fake implements NewKeyMaterial {}

void main() {
  late AuthDataRepository repository;
  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late MockProfileLocalDataSource profileLocal;
  late MockSyncDeviceLocalDataSource syncDeviceLocal;
  late MasterKeyLocalDataSourceImpl masterKeys;

  const email = 'test@example.com';
  const deviceUuid = 'uuid_123';
  final user = UserModel(id: '1', email: email, name: 'John', surname: 'Doe');
  final keys = AccountKeys(accountLocked: false, versions: [E2eeTestData.keyVersion()]);
  final authResponse = AuthResponseModel(token: 'access', refreshToken: 'refresh', user: user, keys: keys);

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
    registerFallbackValue(FakeKdfParams());
    registerFallbackValue(FakeNewKeyMaterial());
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    profileLocal = MockProfileLocalDataSource();
    syncDeviceLocal = MockSyncDeviceLocalDataSource();
    masterKeys = MasterKeyLocalDataSourceImpl(secureStore: InMemorySecureStore());
    repository = AuthDataRepository(
      remoteDataSource: remote,
      localDataSource: local,
      profileLocalDataSource: profileLocal,
      syncDeviceLocalDataSource: syncDeviceLocal,
      masterKeyLocalDataSource: masterKeys,
    );

    when(() => syncDeviceLocal.getDeviceUuid()).thenAnswer((_) async => deviceUuid);
    when(() => local.cacheToken(any())).thenAnswer((_) async {});
    when(() => local.cacheRefreshToken(any())).thenAnswer((_) async {});
    when(() => local.cacheLoginTimestamp(any())).thenAnswer((_) async {});
    when(() => local.cacheUser(any())).thenAnswer((_) async {});
    when(() => local.clearCache()).thenAnswer((_) async {});
    when(() => profileLocal.clearProfileCache()).thenAnswer((_) async {});
  });

  group('AuthDataRepository', () {
    group('getKdfParams', () {
      test('should delegate to the remote data source', () async {
        final params = E2eeTestData.kdfParams();
        when(() => remote.getKdfParams(email)).thenAnswer((_) async => params);

        expect(await repository.getKdfParams(email), params);
      });
    });

    group('login', () {
      test('should send the authKey as Base64 with the device and return user and keys', () async {
        // Arrange
        final authKey = E2eeTestData.key(7);
        when(() => remote.login(any(), any(), any())).thenAnswer((_) async => authResponse);

        // Act
        final result = await repository.login(email: email, authKey: authKey);

        // Assert
        verify(() => remote.login(email, base64Encode(authKey.bytes), deviceUuid)).called(1);
        expect(result.user, user);
        expect(result.keys, keys);
      });

      test('should cache the session after a successful login', () async {
        when(() => remote.login(any(), any(), any())).thenAnswer((_) async => authResponse);

        await repository.login(email: email, authKey: E2eeTestData.key(7));

        verify(() => local.cacheToken('access')).called(1);
        verify(() => local.cacheRefreshToken('refresh')).called(1);
        verify(() => local.cacheUser(user)).called(1);
        verify(() => local.cacheLoginTimestamp(any())).called(1);
      });

      test('should not cache anything when the login fails', () async {
        when(() => remote.login(any(), any(), any())).thenThrow(Exception('401'));

        await expectLater(repository.login(email: email, authKey: E2eeTestData.key(7)), throwsException);

        verifyNever(() => local.cacheToken(any()));
      });
    });

    group('register', () {
      test('should send the registration with the key material and cache the session', () async {
        // Arrange
        final material = E2eeTestData.newKeyMaterial();
        final params = E2eeTestData.kdfParams();
        when(() => remote.register(
              email: any(named: 'email'),
              authKey: any(named: 'authKey'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              deviceUuid: any(named: 'deviceUuid'),
              kdfParams: any(named: 'kdfParams'),
              key: any(named: 'key'),
            )).thenAnswer((_) async => authResponse);

        // Act
        final result = await repository.register(email: email, authKey: E2eeTestData.key(7), name: 'John',
            surname: 'Doe', kdfParams: params, key: material);

        // Assert
        verify(() => remote.register(email: email, authKey: base64Encode(E2eeTestData.key(7).bytes), name: 'John',
            surname: 'Doe', deviceUuid: deviceUuid, kdfParams: params, key: material)).called(1);
        verify(() => local.cacheToken('access')).called(1);
        expect(result.keys.versions.single.version, 1);
      });
    });

    group('logout', () {
      test('should log out remotely, clear the caches and remove the keys of this device', () async {
        // Arrange
        when(() => local.getToken()).thenAnswer((_) async => 'access');
        when(() => remote.logout('access')).thenAnswer((_) async {});
        await masterKeys.saveMasterKey(1, E2eeTestData.key(1));
        await masterKeys.saveRecoveryKey(1, E2eeTestData.key(2));

        // Act
        await repository.logout();

        // Assert
        verify(() => remote.logout('access')).called(1);
        verify(() => local.clearCache()).called(1);
        verify(() => profileLocal.clearProfileCache()).called(1);
        expect(await masterKeys.getVersions(), isEmpty);
        expect(await masterKeys.getRecoveryKey(1), isNull);
      });

      test('should remove the keys even when the remote logout fails', () async {
        when(() => local.getToken()).thenThrow(Exception('storage error'));
        await masterKeys.saveMasterKey(1, E2eeTestData.key(1));

        await repository.logout();

        verify(() => local.clearCache()).called(1);
        expect(await masterKeys.getVersions(), isEmpty);
      });

      test('should not call the remote logout without a token, but still remove the keys', () async {
        when(() => local.getToken()).thenAnswer((_) async => null);
        await masterKeys.saveMasterKey(1, E2eeTestData.key(1));

        await repository.logout();

        verifyNever(() => remote.logout(any()));
        expect(await masterKeys.getVersions(), isEmpty);
      });
    });

    group('getCurrentUser', () {
      test('should return the cached user when there is a valid token', () async {
        when(() => local.getCachedUser()).thenAnswer((_) async => user);
        when(() => local.hasValidToken()).thenAnswer((_) async => true);

        expect(await repository.getCurrentUser(), user);
      });

      test('should clear the cache and return null without a valid token', () async {
        when(() => local.getCachedUser()).thenAnswer((_) async => user);
        when(() => local.hasValidToken()).thenAnswer((_) async => false);

        expect(await repository.getCurrentUser(), isNull);
        verify(() => local.clearCache()).called(1);
      });
    });

    group('hasToken', () {
      test('should delegate to the local data source', () async {
        when(() => local.hasValidToken()).thenAnswer((_) async => true);

        expect(await repository.hasToken(), isTrue);
      });
    });

    group('password reset', () {
      test('should delegate the request and the code validation', () async {
        when(() => remote.requestPasswordReset(email)).thenAnswer((_) async {});
        when(() => remote.validateResetCode(email, '123456')).thenAnswer((_) async {});

        await repository.requestPasswordReset(email);
        await repository.validateResetCode(email, '123456');

        verify(() => remote.requestPasswordReset(email)).called(1);
        verify(() => remote.validateResetCode(email, '123456')).called(1);
      });

      test('should get the recovery wraps with the code', () async {
        final wraps = [RecoveryWrap(version: 1, masterKeyByRecovery: E2eeTestData.bytes(72, 1))];
        when(() => remote.getRecoveryWraps(email, '123456')).thenAnswer((_) async => wraps);

        expect(await repository.getRecoveryWraps(email, '123456'), wraps);
      });

      test('should reset with the new authKey as Base64 and return whether the account is locked', () async {
        when(() => remote.resetPassword(
              email: any(named: 'email'),
              code: any(named: 'code'),
              newAuthKey: any(named: 'newAuthKey'),
              kdfParams: any(named: 'kdfParams'),
              recoveredKeys: any(named: 'recoveredKeys'),
            )).thenAnswer((_) async => true);
        final params = E2eeTestData.kdfParams();

        final locked = await repository.resetPassword(email: email, code: '123456', newAuthKey: E2eeTestData.key(9),
            kdfParams: params, recoveredKeys: const []);

        expect(locked, isTrue);
        verify(() => remote.resetPassword(email: email, code: '123456',
            newAuthKey: base64Encode(E2eeTestData.key(9).bytes), kdfParams: params, recoveredKeys: const [])).called(1);
      });
    });

    group('refreshToken', () {
      test('should refresh with the stored refresh token and cache the new tokens', () async {
        when(() => local.getRefreshToken()).thenAnswer((_) async => 'refresh');
        when(() => remote.refreshToken('refresh', deviceUuid)).thenAnswer(
            (_) async => RefreshTokenResponseModel(accessToken: 'new_access', refreshToken: 'new_refresh'));

        await repository.refreshToken();

        verify(() => local.cacheToken('new_access')).called(1);
        verify(() => local.cacheRefreshToken('new_refresh')).called(1);
      });

      test('should throw without a stored refresh token', () async {
        when(() => local.getRefreshToken()).thenAnswer((_) async => null);

        expect(() => repository.refreshToken(), throwsException);
      });
    });
  });
}
