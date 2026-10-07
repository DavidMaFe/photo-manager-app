import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/decryption_failure.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/crypto/domain/master_key_store.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';

/// Key logic shared by login, registration, recovery and password changes (docs/e2ee-spec.md, sections 4 and 8).
/// It never talks to the network: the use cases send what it produces.
class KeyringService {
  final CryptoEngine engine;
  final MasterKeyStore store;

  const KeyringService({required this.engine, required this.store});

  /// New master key, recovery key and identity key pair, wrapped for the server.
  NewKeyMaterial createKeyMaterial(CryptoKey kek) {
    final masterKey = engine.generateKey();
    final recoveryKey = engine.generateKey();
    final identity = engine.generateIdentityKeyPair();
    final recoveryWrapKey = engine.recoveryWrapKey(recoveryKey);
    final recoveryAuthKey = engine.recoveryAuthKey(recoveryKey);
    final masterKeyAuth = engine.masterKeyAuth(masterKey);
    try {
      return NewKeyMaterial(
        masterKey: masterKey,
        recoveryKey: recoveryKey,
        encryptedMasterKey: engine.wrapKey(kek, masterKey.bytes, WrapPurpose.masterKeyByPassword),
        masterKeyByRecovery: engine.wrapKey(recoveryWrapKey, masterKey.bytes, WrapPurpose.masterKeyByRecovery),
        recoveryAuthKey: Uint8List.fromList(recoveryAuthKey.bytes),
        masterKeyAuth: Uint8List.fromList(masterKeyAuth.bytes),
        publicKey: identity.publicKey,
        encryptedPrivateKey: engine.wrapKey(masterKey, identity.secretKey.bytes, WrapPurpose.identitySecretKey),
      );
    } finally {
      recoveryWrapKey.dispose();
      recoveryAuthKey.dispose();
      masterKeyAuth.dispose();
      identity.secretKey.dispose();
    }
  }

  /// Keeps a newly created key version on this device as the current one, with its recovery key.
  Future<void> storeNewKey(int version, NewKeyMaterial material) async {
    await store.saveMasterKey(version, material.masterKey);
    await store.saveRecoveryKey(version, material.recoveryKey);
    await store.saveCurrentVersion(version);
  }

  /// Opens every available version with the KEK of the password and keeps them on this device.
  /// Throws [KeyUnlockFailure] if a key cannot be opened.
  Future<void> unlockAndStore(AccountKeys keys, CryptoKey kek) async {
    for (final version in keys.available) {
      final masterKey = _unwrap(kek, version.encryptedMasterKey, WrapPurpose.masterKeyByPassword);
      await store.saveMasterKey(version.version, masterKey);
      if (version.state == KeyState.current) {
        await store.saveCurrentVersion(version.version);
      }
    }
  }

  /// Every available version this device holds, wrapped with the KEK of a new password.
  /// Throws [MissingDeviceKeyFailure] if the device does not hold one of them.
  Future<List<RewrappedKey>> rewrapAvailable(AccountKeys keys, CryptoKey newKek) async {
    final rewrapped = <RewrappedKey>[];
    for (final version in keys.available) {
      final masterKey = await _storedKey(version.version);
      rewrapped.add(RewrappedKey(
        version: version.version,
        encryptedMasterKey: engine.wrapKey(newKek, masterKey.bytes, WrapPurpose.masterKeyByPassword),
      ));
    }
    return rewrapped;
  }

  /// Same as [rewrapAvailable] with the proof that this device holds each key (password reset from a device).
  Future<List<DeviceRewrappedKey>> rewrapWithDeviceProof(AccountKeys keys, CryptoKey newKek) async {
    final rewrapped = <DeviceRewrappedKey>[];
    for (final version in keys.available) {
      final masterKey = await _storedKey(version.version);
      final proof = engine.masterKeyAuth(masterKey);
      rewrapped.add(DeviceRewrappedKey(
        version: version.version,
        masterKeyAuth: Uint8List.fromList(proof.bytes),
        encryptedMasterKey: engine.wrapKey(newKek, masterKey.bytes, WrapPurpose.masterKeyByPassword),
      ));
      proof.dispose();
    }
    return rewrapped;
  }

  /// Locked versions that this device still holds (it can unlock them with its proof).
  Future<List<int>> lockedVersionsHeldOnDevice(AccountKeys keys) async {
    final held = await store.getVersions();
    return keys.locked.map((version) => version.version).where(held.contains).toList();
  }

  /// Proof that this device holds [version], and the key wrapped with the KEK of the current password.
  Future<DeviceRewrappedKey> deviceUnlock(int version, CryptoKey kek) async {
    final masterKey = await _storedKey(version);
    final proof = engine.masterKeyAuth(masterKey);
    try {
      return DeviceRewrappedKey(
        version: version,
        masterKeyAuth: Uint8List.fromList(proof.bytes),
        encryptedMasterKey: engine.wrapKey(kek, masterKey.bytes, WrapPurpose.masterKeyByPassword),
      );
    } finally {
      proof.dispose();
    }
  }

  /// Turns the 24 words into the recovery key. Throws [InvalidRecoveryPhraseFailure] on a typo.
  CryptoKey recoveryKeyFromWords(List<String> words) {
    try {
      return CryptoKey(RecoveryPhrase.decode(words));
    } on FormatException {
      throw const InvalidRecoveryPhraseFailure();
    }
  }

  /// Opens the versions whose recovery wrap matches [recoveryKey] and wraps them with [newKek].
  /// Throws [RecoveryPhraseMismatchFailure] if the words do not open any version.
  List<RecoveredKey> recover(List<RecoveryWrap> wraps, CryptoKey recoveryKey, CryptoKey newKek) {
    final recoveryWrapKey = engine.recoveryWrapKey(recoveryKey);
    final recoveryAuthKey = engine.recoveryAuthKey(recoveryKey);
    try {
      final recovered = <RecoveredKey>[];
      for (final wrap in wraps) {
        final CryptoKey masterKey;
        try {
          masterKey = CryptoKey(engine.unwrapKey(recoveryWrapKey, wrap.masterKeyByRecovery, WrapPurpose.masterKeyByRecovery));
        } on DecryptionFailure {
          continue; // these words belong to another version
        }
        recovered.add(RecoveredKey(
          version: wrap.version,
          recoveryAuthKey: Uint8List.fromList(recoveryAuthKey.bytes),
          encryptedMasterKey: engine.wrapKey(newKek, masterKey.bytes, WrapPurpose.masterKeyByPassword),
          masterKey: masterKey,
        ));
      }
      if (recovered.isEmpty) {
        throw const RecoveryPhraseMismatchFailure();
      }
      return recovered;
    } finally {
      recoveryWrapKey.dispose();
      recoveryAuthKey.dispose();
    }
  }

  /// The 24 words of the recovery key kept on this device for [version], or null if this device does not have it.
  Future<List<String>?> recoveryWords(int version, RecoveryPhraseLanguage language) async {
    final recoveryKey = await store.getRecoveryKey(version);
    return recoveryKey == null ? null : RecoveryPhrase.encode(recoveryKey.bytes, language);
  }

  CryptoKey _unwrap(CryptoKey key, Uint8List wrapped, WrapPurpose purpose) {
    try {
      return CryptoKey(engine.unwrapKey(key, wrapped, purpose));
    } on DecryptionFailure {
      throw const KeyUnlockFailure();
    }
  }

  Future<CryptoKey> _storedKey(int version) async {
    final masterKey = await store.getMasterKey(version);
    if (masterKey == null) {
      throw const MissingDeviceKeyFailure();
    }
    return masterKey;
  }
}
