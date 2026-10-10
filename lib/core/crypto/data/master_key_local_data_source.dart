import 'dart:convert';
import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/master_key_store.dart';
import 'package:photo_manager_app/core/storage/secure_store.dart';

/// Master keys of the logged-in user, one per key version, kept in the secure storage of the device
/// (docs/e2ee-spec.md, section 8.2). Background sync reads them without asking for the password.
abstract class MasterKeyLocalDataSource implements MasterKeyStore {}

class MasterKeyLocalDataSourceImpl implements MasterKeyLocalDataSource {
  static const String _masterKeyPrefix = 'E2EE_MASTER_KEY_V';
  static const String _currentVersionKey = 'E2EE_CURRENT_KEY_VERSION';
  static const String _recoveryKeyPrefix = 'E2EE_RECOVERY_KEY_V';

  final SecureStore secureStore;

  MasterKeyLocalDataSourceImpl({required this.secureStore});

  @override
  Future<void> saveMasterKey(int version, CryptoKey masterKey) {
    return secureStore.write('$_masterKeyPrefix$version', base64Encode(masterKey.bytes));
  }

  @override
  Future<CryptoKey?> getMasterKey(int version) async {
    final stored = await secureStore.read('$_masterKeyPrefix$version');
    return stored == null ? null : CryptoKey(Uint8List.fromList(base64Decode(stored)));
  }

  @override
  Future<List<int>> getVersions() async {
    final all = await secureStore.readAll();
    final versions = all.keys
        .where((key) => key.startsWith(_masterKeyPrefix))
        .map((key) => int.tryParse(key.substring(_masterKeyPrefix.length)))
        .whereType<int>()
        .toList()
      ..sort();
    return versions;
  }

  @override
  Future<void> saveCurrentVersion(int version) => secureStore.write(_currentVersionKey, version.toString());

  @override
  Future<int?> getCurrentVersion() async {
    final stored = await secureStore.read(_currentVersionKey);
    return stored == null ? null : int.tryParse(stored);
  }

  @override
  Future<void> saveRecoveryKey(int version, CryptoKey recoveryKey) {
    return secureStore.write('$_recoveryKeyPrefix$version', base64Encode(recoveryKey.bytes));
  }

  @override
  Future<CryptoKey?> getRecoveryKey(int version) async {
    final stored = await secureStore.read('$_recoveryKeyPrefix$version');
    return stored == null ? null : CryptoKey(Uint8List.fromList(base64Decode(stored)));
  }

  @override
  Future<void> clear() async {
    final all = await secureStore.readAll();
    for (final key in all.keys) {
      if (key.startsWith(_masterKeyPrefix) || key.startsWith(_recoveryKeyPrefix)) {
        await secureStore.delete(key);
      }
    }
    await secureStore.delete(_currentVersionKey);
  }
}
