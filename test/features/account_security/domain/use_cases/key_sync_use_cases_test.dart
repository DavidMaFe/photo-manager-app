import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/key_sync_use_cases.dart';

import '../../../../helpers/e2ee_test_kit.dart';
import '../../helpers/fake_account_security_server.dart';

void main() {
  late E2eeTestKit kit;
  late FakeAccountSecurityServer server;
  late NewKeyMaterial first;

  // The user reset the password on another device and created a new key there
  const oldPassword = 'the old password';
  const newPassword = 'the new password';
  final oldParams = E2eeTestKit.cheapParams(seed: 1);
  final newParams = E2eeTestKit.cheapParams(seed: 2);

  setUp(() async {
    kit = await E2eeTestKit.create();
    server = FakeAccountSecurityServer(kdfParams: oldParams);
    first = await kit.material(oldPassword, oldParams);
    server.addVersion(first, version: 1);
    // This device logged in before the change: it holds version 1 as the current one
    await kit.keyring.storeNewKey(1, first);
  });

  group('CheckKeysUpToDateUseCase', () {
    test('should be up to date when this device holds the current version', () async {
      expect(await CheckKeysUpToDateUseCase(server, kit.store)(), KeySyncStatus.upToDate);
    });

    test('should ask for the password when the current version was created on another device', () async {
      server.versions[0] = E2eeTestKit.serverVersion(first, version: 1, state: KeyState.locked);
      server.addVersion(await kit.material(newPassword, newParams), version: 2);

      expect(await CheckKeysUpToDateUseCase(server, kit.store)(), KeySyncStatus.passwordRequired);
    });

    test('should detect a locked account (password reset without the 24 words)', () async {
      server.versions[0] = E2eeTestKit.serverVersion(first, version: 1, state: KeyState.locked);

      expect(await CheckKeysUpToDateUseCase(server, kit.store)(), KeySyncStatus.accountLocked);
    });

    test('should mark as current a version this device already holds', () async {
      // Version 2 was created here, then version 1 was unlocked and became the current one elsewhere
      final second = await kit.material(oldPassword, oldParams);
      await kit.keyring.storeNewKey(2, second);
      server.addVersion(second, version: 2, state: KeyState.unlocked);

      expect(await CheckKeysUpToDateUseCase(server, kit.store)(), KeySyncStatus.upToDate);
      expect(await kit.store.getCurrentVersion(), 1);
    });
  });

  group('RefreshKeysWithPasswordUseCase', () {
    late NewKeyMaterial second;

    setUp(() async {
      server.versions[0] = E2eeTestKit.serverVersion(first, version: 1, state: KeyState.locked);
      second = await kit.material(newPassword, newParams);
      server.addVersion(second, version: 2);
      server.kdfParams = newParams;
    });

    test('should open the new current version with the current password', () async {
      await RefreshKeysWithPasswordUseCase(server, kit.engine, kit.keyring)(password: newPassword);

      expect(await kit.store.getCurrentVersion(), 2);
      expect((await kit.store.getMasterKey(2))!.bytes, second.masterKey.bytes);
      // The locked version is kept: this device can still unlock it with its proof
      expect((await kit.store.getMasterKey(1))!.bytes, first.masterKey.bytes);
      expect(await CheckKeysUpToDateUseCase(server, kit.store)(), KeySyncStatus.upToDate);
    });

    test('should throw KeyUnlockFailure with a password that is not the current one', () async {
      await expectLater(RefreshKeysWithPasswordUseCase(server, kit.engine, kit.keyring)(password: oldPassword),
          throwsA(isA<KeyUnlockFailure>()));
      expect(await kit.store.getMasterKey(2), isNull);
    });

    test('should require the password', () async {
      await expectLater(RefreshKeysWithPasswordUseCase(server, kit.engine, kit.keyring)(password: ''), throwsException);
    });
  });
}
