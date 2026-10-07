import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/change_password_use_case.dart';

import '../../../../helpers/e2ee_test_kit.dart';
import '../../helpers/fake_account_security_server.dart';

void main() {
  late E2eeTestKit kit;
  late FakeAccountSecurityServer server;
  late ChangePasswordUseCase useCase;
  late NewKeyMaterial current;
  late NewKeyMaterial old;

  const password = 'the current password';
  const newPassword = 'the brand new password';
  final params = E2eeTestKit.cheapParams();

  setUp(() async {
    kit = await E2eeTestKit.create();
    server = FakeAccountSecurityServer(kdfParams: params);
    useCase = ChangePasswordUseCase(server, kit.engine, kit.keyring);

    // An account with an older unlocked version, both held by this device
    old = await kit.material(password, params);
    current = await kit.material(password, params);
    server
      ..addVersion(old, version: 1, state: KeyState.unlocked)
      ..addVersion(current, version: 2);
    await kit.keyring.storeNewKey(1, old);
    await kit.keyring.storeNewKey(2, current);
  });

  group('ChangePasswordUseCase', () {
    // ==================== HAPPY PATH TESTS ====================

    test('should change the password and wrap every available key with the new one', () async {
      // Act
      await useCase(currentPassword: password, newPassword: newPassword);

      // Assert: the old password proves the user, the new one opens every key
      final currentKeys = await kit.passwordKeys(password, params);
      expect(server.receivedCurrentAuthKey, base64Encode(currentKeys.authKey.bytes));

      expect(server.kdfParams.ops, KdfParams.defaultOps);
      final newKeys = await kit.passwordKeys(newPassword, server.kdfParams);
      expect(server.receivedNewAuthKey, base64Encode(newKeys.authKey.bytes));
      expect(kit.unwrapWithPassword(newKeys.kek, server.version(1).encryptedMasterKey), old.masterKey.bytes);
      expect(kit.unwrapWithPassword(newKeys.kek, server.version(2).encryptedMasterKey), current.masterKey.bytes);
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    test('should not change anything when this device does not hold one of the keys', () async {
      // Arrange: a version created on another device
      server.addVersion(await kit.material(password, params), version: 3, state: KeyState.unlocked);

      // Act / Assert
      await expectLater(useCase(currentPassword: password, newPassword: newPassword),
          throwsA(isA<MissingDeviceKeyFailure>()));
      expect(server.passwordChanges, 0);
    });

    // ==================== VALIDATION ERROR TESTS ====================

    test('should throw WeakPasswordFailure when the new password has fewer than 10 characters', () async {
      await expectLater(useCase(currentPassword: password, newPassword: 'short'), throwsA(isA<WeakPasswordFailure>()));
      expect(server.passwordChanges, 0);
    });

    test('should require the current password', () async {
      await expectLater(useCase(currentPassword: '  ', newPassword: newPassword), throwsException);
      expect(server.passwordChanges, 0);
    });
  });
}
