import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/locked_account_use_cases.dart';

import '../../../../helpers/e2ee_test_kit.dart';
import '../../helpers/fake_account_security_server.dart';

void main() {
  late E2eeTestKit kit;
  late FakeAccountSecurityServer server;
  late NewKeyMaterial lockedKey;

  // The password was reset without the 24 words: version 1 is wrapped with the forgotten one
  const password = 'the new password';
  final params = E2eeTestKit.cheapParams();

  setUp(() async {
    kit = await E2eeTestKit.create();
    server = FakeAccountSecurityServer(kdfParams: params);
    lockedKey = await kit.material('the forgotten password', params);
    server.addVersion(lockedKey, version: 1, state: KeyState.locked);
  });

  List<String> wordsOf(NewKeyMaterial material) =>
      RecoveryPhrase.encode(material.recoveryKey.bytes, RecoveryPhraseLanguage.english);

  group('GetLockedAccountStatusUseCase', () {
    test('should tell which locked versions this device still holds', () async {
      // Arrange: a second locked version that this device never had
      server.addVersion(await kit.material('older password', params), version: 2, state: KeyState.locked);
      await kit.keyring.storeNewKey(1, lockedKey);

      // Act
      final status = await GetLockedAccountStatusUseCase(server, kit.keyring)();

      // Assert
      expect(status.keys.accountLocked, isTrue);
      expect(status.hasLockedVersions, isTrue);
      expect(status.versionsHeldOnDevice, [1]);
    });

    test('should have no locked versions in a usable account', () async {
      final usable = FakeAccountSecurityServer(kdfParams: params)
        ..addVersion(await kit.material(password, params), version: 1);

      final status = await GetLockedAccountStatusUseCase(usable, kit.keyring)();

      expect(status.hasLockedVersions, isFalse);
      expect(status.versionsHeldOnDevice, isEmpty);
    });
  });

  group('UnlockWithRecoveryPhraseUseCase', () {
    late UnlockWithRecoveryPhraseUseCase useCase;

    setUp(() => useCase = UnlockWithRecoveryPhraseUseCase(server, kit.engine, kit.keyring));

    test('should unlock the versions opened by the words and keep them on the device', () async {
      // Act
      final unlocked = await useCase(password: password, words: wordsOf(lockedKey));

      // Assert: the server accepted the proof and the new password opens the key
      expect(unlocked, [1]);
      expect(server.version(1).state, KeyState.current);
      final keys = await kit.passwordKeys(password, params);
      expect(kit.unwrapWithPassword(keys.kek, server.version(1).encryptedMasterKey), lockedKey.masterKey.bytes);
      expect((await kit.store.getMasterKey(1))!.bytes, lockedKey.masterKey.bytes);
      expect((await kit.store.getRecoveryKey(1))!.bytes, lockedKey.recoveryKey.bytes);
      expect(await kit.store.getCurrentVersion(), 1);
    });

    test('should throw RecoveryPhraseMismatchFailure with the words of another key', () async {
      final other = await kit.material(password, params);

      await expectLater(useCase(password: password, words: wordsOf(other)),
          throwsA(isA<RecoveryPhraseMismatchFailure>()));
      expect(server.version(1).state, KeyState.locked);
    });

    test('should throw InvalidRecoveryPhraseFailure on a typo', () async {
      final words = wordsOf(lockedKey)..[3] = 'notaword';

      await expectLater(useCase(password: password, words: words), throwsA(isA<InvalidRecoveryPhraseFailure>()));
    });

    test('should require the password', () async {
      await expectLater(useCase(password: ' ', words: wordsOf(lockedKey)), throwsException);
      expect(server.version(1).state, KeyState.locked);
    });
  });

  group('UnlockWithDeviceKeysUseCase', () {
    late UnlockWithDeviceKeysUseCase useCase;

    setUp(() => useCase = UnlockWithDeviceKeysUseCase(server, kit.engine, kit.keyring));

    test('should unlock the versions this device still holds with its proof', () async {
      // Arrange
      await kit.keyring.storeNewKey(1, lockedKey);

      // Act
      final unlocked = await useCase(password: password);

      // Assert
      expect(unlocked, [1]);
      expect(server.version(1).state, KeyState.current);
      final keys = await kit.passwordKeys(password, params);
      expect(kit.unwrapWithPassword(keys.kek, server.version(1).encryptedMasterKey), lockedKey.masterKey.bytes);
    });

    test('should unlock nothing when this device does not hold any locked version', () async {
      final unlocked = await useCase(password: password);

      expect(unlocked, isEmpty);
      expect(server.version(1).state, KeyState.locked);
    });
  });

  group('CreateNewKeyVersionUseCase', () {
    test('should create a new current key, keep the old one locked and return its 24 words', () async {
      // Act
      final words = await CreateNewKeyVersionUseCase(server, kit.engine, kit.keyring)(
          password: password, language: RecoveryPhraseLanguage.spanish);

      // Assert: the photos of version 1 are never deleted
      expect(server.versions, hasLength(2));
      expect(server.version(1).state, KeyState.locked);
      expect(server.version(2).state, KeyState.current);
      expect(await kit.store.getCurrentVersion(), 2);
      expect(RecoveryPhrase.decode(words), (await kit.store.getRecoveryKey(2))!.bytes);

      final keys = await kit.passwordKeys(password, params);
      expect(kit.unwrapWithPassword(keys.kek, server.version(2).encryptedMasterKey),
          (await kit.store.getMasterKey(2))!.bytes);
    });

    test('should require the password', () async {
      await expectLater(CreateNewKeyVersionUseCase(server, kit.engine, kit.keyring)(
          password: '', language: RecoveryPhraseLanguage.english), throwsException);
      expect(server.versions, hasLength(1));
    });
  });
}
