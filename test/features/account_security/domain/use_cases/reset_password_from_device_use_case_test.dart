import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/features/account_security/domain/services/device_authenticator.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/reset_password_from_device_use_case.dart';

import '../../../../helpers/e2ee_test_kit.dart';
import '../../helpers/fake_account_security_server.dart';

class MockDeviceAuthenticator extends Mock implements DeviceAuthenticator {}

void main() {
  late E2eeTestKit kit;
  late FakeAccountSecurityServer server;
  late MockDeviceAuthenticator deviceAuthenticator;
  late ResetPasswordFromDeviceUseCase useCase;
  late NewKeyMaterial material;

  const newPassword = 'the brand new password';
  const reason = 'Confirm it is you';
  final params = E2eeTestKit.cheapParams();

  setUp(() async {
    kit = await E2eeTestKit.create();
    server = FakeAccountSecurityServer(kdfParams: params);
    deviceAuthenticator = MockDeviceAuthenticator();
    useCase = ResetPasswordFromDeviceUseCase(server, kit.engine, kit.keyring, deviceAuthenticator);

    material = await kit.material('the forgotten password', params);
    server.addVersion(material, version: 1);
    await kit.keyring.storeNewKey(1, material);

    when(() => deviceAuthenticator.isAvailable()).thenAnswer((_) async => true);
    when(() => deviceAuthenticator.authenticate(any())).thenAnswer((_) async => true);
  });

  group('ResetPasswordFromDeviceUseCase', () {
    // ==================== HAPPY PATH TESTS ====================

    test('should set the new password with the proof that this device holds the keys', () async {
      // Act
      await useCase(newPassword: newPassword, reason: reason);

      // Assert: the fake server rejects a wrong proof, and the new password opens the key
      verify(() => deviceAuthenticator.authenticate(reason)).called(1);
      final newKeys = await kit.passwordKeys(newPassword, server.kdfParams);
      expect(server.receivedNewAuthKey, base64Encode(newKeys.authKey.bytes));
      expect(kit.unwrapWithPassword(newKeys.kek, server.version(1).encryptedMasterKey), material.masterKey.bytes);
    });

    // ==================== AUTHENTICATION & AUTHORIZATION TESTS ====================

    test('should throw DeviceAuthenticationFailure when the user cancels the fingerprint or PIN', () async {
      when(() => deviceAuthenticator.authenticate(any())).thenAnswer((_) async => false);

      await expectLater(useCase(newPassword: newPassword, reason: reason),
          throwsA(isA<DeviceAuthenticationFailure>()));
      expect(server.passwordChanges, 0);
    });

    test('should throw DeviceAuthenticationFailure when the device has no screen lock', () async {
      when(() => deviceAuthenticator.isAvailable()).thenAnswer((_) async => false);

      await expectLater(useCase(newPassword: newPassword, reason: reason),
          throwsA(isA<DeviceAuthenticationFailure>()));
      verifyNever(() => deviceAuthenticator.authenticate(any()));
      expect(server.passwordChanges, 0);
    });

    // ==================== VALIDATION ERROR TESTS ====================

    test('should check the new password before asking for the device lock', () async {
      await expectLater(useCase(newPassword: 'short', reason: reason), throwsA(isA<WeakPasswordFailure>()));

      verifyNever(() => deviceAuthenticator.authenticate(any()));
    });

    // ==================== EDGE CASE TESTS ====================

    test('should not reset when this device lost the keys', () async {
      await kit.store.clear();

      await expectLater(useCase(newPassword: newPassword, reason: reason), throwsA(isA<MissingDeviceKeyFailure>()));
      expect(server.passwordChanges, 0);
    });
  });
}
