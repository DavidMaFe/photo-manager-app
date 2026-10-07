import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/crypto/domain/password_keys.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';

import '../../../helpers/e2ee_test_kit.dart';

void main() {
  late E2eeTestKit kit;
  late PasswordKeys password;
  late PasswordKeys newPassword;

  setUpAll(() async {
    final setup = await E2eeTestKit.create();
    password = await setup.passwordKeys('the password', E2eeTestKit.cheapParams(seed: 1));
    newPassword = await setup.passwordKeys('the new password', E2eeTestKit.cheapParams(seed: 2));
  });

  setUp(() async {
    kit = await E2eeTestKit.create();
  });

  AccountKeys accountOf(List<KeyVersion> versions) =>
      AccountKeys(accountLocked: versions.every((version) => !version.state.isAvailable), versions: versions);

  group('KeyringService', () {
    group('createKeyMaterial', () {
      test('should wrap the master key with the password, with the recovery key and give the proofs', () {
        // Act
        final material = kit.keyring.createKeyMaterial(password.kek);

        // Assert
        final engine = kit.engine;
        expect(kit.unwrapWithPassword(password.kek, material.encryptedMasterKey), material.masterKey.bytes);
        expect(engine.unwrapKey(engine.recoveryWrapKey(material.recoveryKey), material.masterKeyByRecovery,
            WrapPurpose.masterKeyByRecovery), material.masterKey.bytes);
        expect(material.recoveryAuthKey, engine.recoveryAuthKey(material.recoveryKey).bytes);
        expect(material.masterKeyAuth, engine.masterKeyAuth(material.masterKey).bytes);
        expect(engine.unwrapKey(material.masterKey, material.encryptedPrivateKey, WrapPurpose.identitySecretKey),
            hasLength(32));
        expect(material.publicKey, hasLength(32));
      });

      test('should generate different keys every time', () {
        final first = kit.keyring.createKeyMaterial(password.kek);
        final second = kit.keyring.createKeyMaterial(password.kek);

        expect(first.masterKey.bytes, isNot(second.masterKey.bytes));
        expect(first.recoveryKey.bytes, isNot(second.recoveryKey.bytes));
      });
    });

    group('storeNewKey', () {
      test('should keep the master key and the recovery key as the current version', () async {
        final material = kit.keyring.createKeyMaterial(password.kek);

        await kit.keyring.storeNewKey(3, material);

        expect(await kit.store.getCurrentVersion(), 3);
        expect((await kit.store.getMasterKey(3))!.bytes, material.masterKey.bytes);
        expect((await kit.store.getRecoveryKey(3))!.bytes, material.recoveryKey.bytes);
      });
    });

    group('unlockAndStore', () {
      test('should keep the available versions and skip the locked ones', () async {
        // Arrange
        final locked = await kit.material('a forgotten password', E2eeTestKit.cheapParams(seed: 3));
        final old = kit.keyring.createKeyMaterial(password.kek);
        final current = kit.keyring.createKeyMaterial(password.kek);

        // Act
        await kit.keyring.unlockAndStore(accountOf([
          E2eeTestKit.serverVersion(locked, version: 1, state: KeyState.locked),
          E2eeTestKit.serverVersion(old, version: 2, state: KeyState.unlocked),
          E2eeTestKit.serverVersion(current, version: 3),
        ]), password.kek);

        // Assert
        expect(await kit.store.getVersions(), unorderedEquals([2, 3]));
        expect(await kit.store.getCurrentVersion(), 3);
        expect((await kit.store.getMasterKey(2))!.bytes, old.masterKey.bytes);
      });

      test('should throw KeyUnlockFailure when the KEK does not open a version', () async {
        final other = kit.keyring.createKeyMaterial(newPassword.kek);

        expect(() => kit.keyring.unlockAndStore(accountOf([E2eeTestKit.serverVersion(other)]), password.kek),
            throwsA(isA<KeyUnlockFailure>()));
      });
    });

    group('rewrapAvailable', () {
      test('should wrap every available version held on the device with the new password', () async {
        // Arrange
        final material = kit.keyring.createKeyMaterial(password.kek);
        await kit.keyring.storeNewKey(1, material);

        // Act
        final rewrapped = await kit.keyring.rewrapAvailable(accountOf([E2eeTestKit.serverVersion(material)]),
            newPassword.kek);

        // Assert
        expect(rewrapped.single.version, 1);
        expect(kit.unwrapWithPassword(newPassword.kek, rewrapped.single.encryptedMasterKey), material.masterKey.bytes);
      });

      test('should throw MissingDeviceKeyFailure when the device does not hold a version', () async {
        final material = kit.keyring.createKeyMaterial(password.kek);

        expect(() => kit.keyring.rewrapAvailable(accountOf([E2eeTestKit.serverVersion(material)]), newPassword.kek),
            throwsA(isA<MissingDeviceKeyFailure>()));
      });
    });

    group('rewrapWithDeviceProof', () {
      test('should add the proof that the device holds each key', () async {
        final material = kit.keyring.createKeyMaterial(password.kek);
        await kit.keyring.storeNewKey(1, material);

        final rewrapped = await kit.keyring.rewrapWithDeviceProof(accountOf([E2eeTestKit.serverVersion(material)]),
            newPassword.kek);

        expect(rewrapped.single.masterKeyAuth, material.masterKeyAuth);
        expect(kit.unwrapWithPassword(newPassword.kek, rewrapped.single.encryptedMasterKey), material.masterKey.bytes);
      });
    });

    group('locked versions held on the device', () {
      test('should list only the locked versions this device still holds', () async {
        // Arrange: versions 1 and 2 are locked, the device only kept version 1
        final first = kit.keyring.createKeyMaterial(password.kek);
        final second = kit.keyring.createKeyMaterial(password.kek);
        await kit.keyring.storeNewKey(1, first);

        // Act
        final held = await kit.keyring.lockedVersionsHeldOnDevice(accountOf([
          E2eeTestKit.serverVersion(first, version: 1, state: KeyState.locked),
          E2eeTestKit.serverVersion(second, version: 2, state: KeyState.locked),
        ]));

        // Assert
        expect(held, [1]);
      });

      test('should unlock a held version with its proof, wrapped with the current password', () async {
        final material = kit.keyring.createKeyMaterial(password.kek);
        await kit.keyring.storeNewKey(1, material);

        final unlocked = await kit.keyring.deviceUnlock(1, newPassword.kek);

        expect(unlocked.version, 1);
        expect(unlocked.masterKeyAuth, material.masterKeyAuth);
        expect(kit.unwrapWithPassword(newPassword.kek, unlocked.encryptedMasterKey), material.masterKey.bytes);
      });

      test('should throw MissingDeviceKeyFailure when unlocking a version the device does not hold', () async {
        expect(() => kit.keyring.deviceUnlock(1, newPassword.kek), throwsA(isA<MissingDeviceKeyFailure>()));
      });
    });

    group('recovery', () {
      test('should turn the 24 words back into the recovery key', () {
        final material = kit.keyring.createKeyMaterial(password.kek);
        final words = RecoveryPhrase.encode(material.recoveryKey.bytes, RecoveryPhraseLanguage.spanish);

        expect(kit.keyring.recoveryKeyFromWords(words).bytes, material.recoveryKey.bytes);
      });

      test('should throw InvalidRecoveryPhraseFailure on a typo or a missing word', () {
        final words = RecoveryPhrase.encode(kit.engine.generateKey().bytes, RecoveryPhraseLanguage.english);

        expect(() => kit.keyring.recoveryKeyFromWords([...words]..[0] = 'notaword'),
            throwsA(isA<InvalidRecoveryPhraseFailure>()));
        expect(() => kit.keyring.recoveryKeyFromWords(words.sublist(1)), throwsA(isA<InvalidRecoveryPhraseFailure>()));
      });

      test('should recover only the versions the words open, wrapped with the new password', () {
        // Arrange: version 1 belongs to other words
        final other = kit.keyring.createKeyMaterial(password.kek);
        final mine = kit.keyring.createKeyMaterial(password.kek);
        final wraps = [
          RecoveryWrap(version: 1, masterKeyByRecovery: other.masterKeyByRecovery),
          RecoveryWrap(version: 2, masterKeyByRecovery: mine.masterKeyByRecovery),
        ];

        // Act
        final recovered = kit.keyring.recover(wraps, mine.recoveryKey, newPassword.kek);

        // Assert
        expect(recovered.single.version, 2);
        expect(recovered.single.recoveryAuthKey, mine.recoveryAuthKey);
        expect(recovered.single.masterKey.bytes, mine.masterKey.bytes);
        expect(kit.unwrapWithPassword(newPassword.kek, recovered.single.encryptedMasterKey), mine.masterKey.bytes);
      });

      test('should throw RecoveryPhraseMismatchFailure when the words open no version', () {
        final material = kit.keyring.createKeyMaterial(password.kek);
        final wraps = [RecoveryWrap(version: 1, masterKeyByRecovery: material.masterKeyByRecovery)];

        expect(() => kit.keyring.recover(wraps, kit.engine.generateKey(), newPassword.kek),
            throwsA(isA<RecoveryPhraseMismatchFailure>()));
      });

      test('should give the words of the recovery key kept on the device, or null without it', () async {
        final material = kit.keyring.createKeyMaterial(password.kek);
        await kit.keyring.storeNewKey(1, material);

        final words = await kit.keyring.recoveryWords(1, RecoveryPhraseLanguage.english);

        expect(RecoveryPhrase.decode(words!), material.recoveryKey.bytes);
        expect(await kit.keyring.recoveryWords(2, RecoveryPhraseLanguage.english), isNull);
      });
    });
  });
}
