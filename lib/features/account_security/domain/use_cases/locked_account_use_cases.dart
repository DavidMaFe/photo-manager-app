import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/crypto/domain/keyring_service.dart';
import 'package:photo_manager_app/core/crypto/domain/password_keys.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/features/account_security/domain/repositories/account_security_repository.dart';

/// State of a locked account as the locked account page needs it.
class LockedAccountStatus {
  final AccountKeys keys;

  /// Locked versions this device still holds: it can unlock them with the password.
  final List<int> versionsHeldOnDevice;

  const LockedAccountStatus({required this.keys, required this.versionsHeldOnDevice});

  bool get hasLockedVersions => keys.locked.isNotEmpty;
}

/// Shared by the locked account use cases: the KEK of the current password, needed to wrap the unlocked keys.
Future<PasswordKeys> _currentPasswordKeys(
    AccountSecurityRepository repository, CryptoEngine cryptoEngine, String password) async {
  if (password.trim().isEmpty) {
    throw Exception('Password is required');
  }
  final params = await repository.getKdfParams();
  return cryptoEngine.deriveFromPassword(password, params);
}

Future<void> _storeAvailableVersions(
    AccountSecurityRepository repository, KeyringService keyringService, PasswordKeys passwordKeys) async {
  final refreshed = await repository.getAccountKeys();
  await keyringService.unlockAndStore(refreshed, passwordKeys.kek);
}

class GetLockedAccountStatusUseCase {
  final AccountSecurityRepository _repository;
  final KeyringService _keyringService;

  GetLockedAccountStatusUseCase(this._repository, this._keyringService);

  Future<LockedAccountStatus> call() async {
    final keys = await _repository.getAccountKeys();
    return LockedAccountStatus(keys: keys, versionsHeldOnDevice: await _keyringService.lockedVersionsHeldOnDevice(keys));
  }
}

/// Unlocks the locked versions opened by the old 24 words (docs/e2ee-spec.md, section 8.6).
class UnlockWithRecoveryPhraseUseCase {
  final AccountSecurityRepository _repository;
  final CryptoEngine _cryptoEngine;
  final KeyringService _keyringService;

  UnlockWithRecoveryPhraseUseCase(this._repository, this._cryptoEngine, this._keyringService);

  /// Returns the unlocked versions.
  Future<List<int>> call({required String password, required List<String> words}) async {
    final recoveryKey = _keyringService.recoveryKeyFromWords(words);
    final passwordKeys = await _currentPasswordKeys(_repository, _cryptoEngine, password);
    try {
      final keys = await _repository.getAccountKeys();
      final wraps = keys.locked
          .map((version) => RecoveryWrap(version: version.version, masterKeyByRecovery: version.masterKeyByRecovery))
          .toList();
      final recovered = _keyringService.recover(wraps, recoveryKey, passwordKeys.kek);

      for (final key in recovered) {
        await _repository.unlockKeyVersion(
          version: key.version,
          recoveryAuthKey: CryptoKey(key.recoveryAuthKey),
          encryptedMasterKey: key.encryptedMasterKey,
        );
        await _keyringService.store.saveRecoveryKey(key.version, recoveryKey);
      }
      await _storeAvailableVersions(_repository, _keyringService, passwordKeys);
      return recovered.map((key) => key.version).toList();
    } finally {
      passwordKeys.dispose();
      recoveryKey.dispose();
    }
  }
}

/// Unlocks the locked versions this device still holds (it proves it has them), after a reset with only the email.
class UnlockWithDeviceKeysUseCase {
  final AccountSecurityRepository _repository;
  final CryptoEngine _cryptoEngine;
  final KeyringService _keyringService;

  UnlockWithDeviceKeysUseCase(this._repository, this._cryptoEngine, this._keyringService);

  /// Returns the unlocked versions.
  Future<List<int>> call({required String password}) async {
    final passwordKeys = await _currentPasswordKeys(_repository, _cryptoEngine, password);
    try {
      final keys = await _repository.getAccountKeys();
      final versions = await _keyringService.lockedVersionsHeldOnDevice(keys);
      for (final version in versions) {
        final unlock = await _keyringService.deviceUnlock(version, passwordKeys.kek);
        await _repository.unlockKeyVersion(
          version: version,
          masterKeyAuth: unlock.masterKeyAuth,
          encryptedMasterKey: unlock.encryptedMasterKey,
        );
      }
      await _storeAvailableVersions(_repository, _keyringService, passwordKeys);
      return versions;
    } finally {
      passwordKeys.dispose();
    }
  }
}

/// New master key for a locked account (docs/e2ee-spec.md, section 8.6). The old versions stay locked, never deleted.
/// Returns the 24 words of the new recovery key.
class CreateNewKeyVersionUseCase {
  final AccountSecurityRepository _repository;
  final CryptoEngine _cryptoEngine;
  final KeyringService _keyringService;

  CreateNewKeyVersionUseCase(this._repository, this._cryptoEngine, this._keyringService);

  Future<List<String>> call({required String password, required RecoveryPhraseLanguage language}) async {
    final passwordKeys = await _currentPasswordKeys(_repository, _cryptoEngine, password);
    try {
      final material = _keyringService.createKeyMaterial(passwordKeys.kek);
      final version = await _repository.createKeyVersion(material);
      await _keyringService.storeNewKey(version, material);
      return RecoveryPhrase.encode(material.recoveryKey.bytes, language);
    } finally {
      passwordKeys.dispose();
    }
  }
}
