import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/crypto/domain/keyring_service.dart';
import 'package:photo_manager_app/core/crypto/domain/master_key_store.dart';
import 'package:photo_manager_app/features/account_security/domain/repositories/account_security_repository.dart';

/// Whether the keys of this device are the current ones of the account. Each device only refreshes its keys when it
/// logs in, so a password reset or a new key version made on another device leaves it behind.
enum KeySyncStatus {
  /// This device holds the current key version.
  upToDate,

  /// The current version is wrapped with a password this device has not used yet: it must be typed again.
  passwordRequired,

  /// No version can be opened with the current password: the locked account flow.
  accountLocked,
}

class CheckKeysUpToDateUseCase {
  final AccountSecurityRepository _repository;
  final MasterKeyStore _store;

  CheckKeysUpToDateUseCase(this._repository, this._store);

  Future<KeySyncStatus> call() async {
    final keys = await _repository.getAccountKeys();
    if (keys.accountLocked) {
      return KeySyncStatus.accountLocked;
    }
    final current = keys.versions.where((version) => version.state == KeyState.current).firstOrNull;
    if (current == null) {
      return KeySyncStatus.accountLocked;
    }
    if (await _store.getMasterKey(current.version) == null) {
      return KeySyncStatus.passwordRequired;
    }
    // Held but not marked as current (e.g. an older version was unlocked meanwhile)
    if (await _store.getCurrentVersion() != current.version) {
      await _store.saveCurrentVersion(current.version);
    }
    return KeySyncStatus.upToDate;
  }
}

/// Opens again every available key version with the current password, as a login does, without logging in again.
/// Throws KeyUnlockFailure when the password is not the current one.
class RefreshKeysWithPasswordUseCase {
  final AccountSecurityRepository _repository;
  final CryptoEngine _cryptoEngine;
  final KeyringService _keyringService;

  RefreshKeysWithPasswordUseCase(this._repository, this._cryptoEngine, this._keyringService);

  Future<void> call({required String password}) async {
    if (password.isEmpty) {
      throw Exception('Password is required');
    }
    final params = await _repository.getKdfParams();
    final passwordKeys = await _cryptoEngine.deriveFromPassword(password, params);
    try {
      await _keyringService.unlockAndStore(await _repository.getAccountKeys(), passwordKeys.kek);
    } finally {
      passwordKeys.dispose();
    }
  }
}
