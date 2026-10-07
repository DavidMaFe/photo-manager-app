import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/features/account_security/data/data_sources/account_security_remote_data_source.dart';
import 'package:photo_manager_app/features/account_security/data/repositories/account_security_data_repository.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/auth/data/models/user_model.dart';

import '../../../../fixtures/e2ee_test_data.dart';

class MockAccountSecurityRemoteDataSource extends Mock implements AccountSecurityRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AccountSecurityDataRepository repository;
  late MockAccountSecurityRemoteDataSource remote;
  late MockAuthLocalDataSource authLocal;

  setUpAll(() {
    registerFallbackValue(E2eeTestData.kdfParams());
  });

  setUp(() {
    remote = MockAccountSecurityRemoteDataSource();
    authLocal = MockAuthLocalDataSource();
    repository = AccountSecurityDataRepository(remoteDataSource: remote, authLocalDataSource: authLocal);
  });

  group('AccountSecurityDataRepository', () {
    test('should ask the kdf parameters of the logged-in user', () async {
      final params = E2eeTestData.kdfParams();
      when(() => authLocal.getCachedUser())
          .thenAnswer((_) async => UserModel(id: '1', email: 'ana@example.com', name: 'Ana'));
      when(() => remote.getKdfParams('ana@example.com')).thenAnswer((_) async => params);

      expect(await repository.getKdfParams(), params);
    });

    test('should fail without a logged-in user', () async {
      when(() => authLocal.getCachedUser()).thenAnswer((_) async => null);

      await expectLater(repository.getKdfParams(), throwsException);
      verifyNever(() => remote.getKdfParams(any()));
    });

    test('should delegate the key versions and the new keys', () async {
      final keys = AccountKeys(accountLocked: false, versions: [E2eeTestData.keyVersion()]);
      final material = E2eeTestData.newKeyMaterial();
      when(() => remote.getAccountKeys()).thenAnswer((_) async => keys);
      when(() => remote.createKeyVersion(material)).thenAnswer((_) async => 2);

      expect(await repository.getAccountKeys(), keys);
      expect(await repository.createKeyVersion(material), 2);
    });

    test('should send the authKeys of a password change as Base64', () async {
      when(() => remote.changePassword(
            currentAuthKey: any(named: 'currentAuthKey'),
            newAuthKey: any(named: 'newAuthKey'),
            kdfParams: any(named: 'kdfParams'),
            keys: any(named: 'keys'),
          )).thenAnswer((_) async {});
      final params = E2eeTestData.kdfParams();

      await repository.changePassword(currentAuthKey: E2eeTestData.key(1), newAuthKey: E2eeTestData.key(2),
          kdfParams: params, keys: const []);

      verify(() => remote.changePassword(
            currentAuthKey: base64Encode(E2eeTestData.key(1).bytes),
            newAuthKey: base64Encode(E2eeTestData.key(2).bytes),
            kdfParams: params,
            keys: const [],
          )).called(1);
    });

    test('should send the new authKey of a device reset as Base64', () async {
      when(() => remote.resetPasswordFromDevice(
            newAuthKey: any(named: 'newAuthKey'),
            kdfParams: any(named: 'kdfParams'),
            keys: any(named: 'keys'),
          )).thenAnswer((_) async {});
      final keys = [DeviceRewrappedKey(version: 1, masterKeyAuth: E2eeTestData.bytes(32, 1),
          encryptedMasterKey: E2eeTestData.bytes(72, 2))];

      await repository.resetPasswordFromDevice(newAuthKey: E2eeTestData.key(3), kdfParams: E2eeTestData.kdfParams(),
          keys: keys);

      verify(() => remote.resetPasswordFromDevice(
            newAuthKey: base64Encode(E2eeTestData.key(3).bytes),
            kdfParams: any(named: 'kdfParams'),
            keys: keys,
          )).called(1);
    });

    test('should send the unlock proofs as Base64', () async {
      when(() => remote.unlockKeyVersion(
            version: any(named: 'version'),
            recoveryAuthKey: any(named: 'recoveryAuthKey'),
            masterKeyAuth: any(named: 'masterKeyAuth'),
            encryptedMasterKey: any(named: 'encryptedMasterKey'),
          )).thenAnswer((_) async {});

      await repository.unlockKeyVersion(version: 1, recoveryAuthKey: E2eeTestData.key(4),
          encryptedMasterKey: E2eeTestData.bytes(72, 5));
      await repository.unlockKeyVersion(version: 2, masterKeyAuth: E2eeTestData.bytes(32, 6),
          encryptedMasterKey: E2eeTestData.bytes(72, 7));

      verify(() => remote.unlockKeyVersion(
            version: 1,
            recoveryAuthKey: base64Encode(E2eeTestData.key(4).bytes),
            masterKeyAuth: null,
            encryptedMasterKey: base64Encode(E2eeTestData.bytes(72, 5)),
          )).called(1);
      verify(() => remote.unlockKeyVersion(
            version: 2,
            recoveryAuthKey: null,
            masterKeyAuth: base64Encode(E2eeTestData.bytes(32, 6)),
            encryptedMasterKey: base64Encode(E2eeTestData.bytes(72, 7)),
          )).called(1);
    });
  });
}
