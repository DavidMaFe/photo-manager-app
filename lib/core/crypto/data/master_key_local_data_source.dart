import 'dart:convert';
import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/storage/secure_store.dart';

/// Master keys of the logged-in user, one per key version, kept in the secure storage of the device
/// (docs/e2ee-spec.md, section 8.2). Background sync reads them without asking for the password.
abstract class MasterKeyLocalDataSource {
  Future<void> saveMasterKey(int version, CryptoKey masterKey);

  Future<CryptoKey?> getMasterKey(int version);

  /// Versions stored on this device.
  Future<List<int>> getVersions();

  /// Version used for new uploads.
  Future<void> saveCurrentVersion(int version);

  Future<int?> getCurrentVersion();

  /// Removes every master key (logout).
  Future<void> clear();
}

class MasterKeyLocalDataSourceImpl implements MasterKeyLocalDataSource {
  static const String _masterKeyPrefix = 'E2EE_MASTER_KEY_V';
  static const String _currentVersionKey = 'E2EE_CURRENT_KEY_VERSION';

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
  Future<void> clear() async {
    for (final version in await getVersions()) {
      await secureStore.delete('$_masterKeyPrefix$version');
    }
    await secureStore.delete(_currentVersionKey);
  }
}
