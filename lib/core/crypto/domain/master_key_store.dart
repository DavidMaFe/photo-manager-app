import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';

/// Keys of the logged-in user kept on this device (secure storage).
abstract class MasterKeyStore {
  Future<void> saveMasterKey(int version, CryptoKey masterKey);

  Future<CryptoKey?> getMasterKey(int version);

  Future<List<int>> getVersions();

  Future<void> saveCurrentVersion(int version);

  Future<int?> getCurrentVersion();

  /// Local copy of the recovery key of a version (decision of 7 Oct 2026): lets the user see the 24 words again and
  /// lets the reminders ask for only 3 words.
  Future<void> saveRecoveryKey(int version, CryptoKey recoveryKey);

  Future<CryptoKey?> getRecoveryKey(int version);

  /// Removes every key of this device (logout).
  Future<void> clear();
}
