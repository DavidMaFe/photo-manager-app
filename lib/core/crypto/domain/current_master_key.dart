import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/master_key_store.dart';

/// The master key new files are encrypted with: the current version kept on this device (docs/e2ee-spec.md, 4.2).
class CurrentMasterKey {
  final int version;
  final CryptoKey key;

  const CurrentMasterKey({required this.version, required this.key});

  /// Throws [MissingCurrentKeyFailure] if this device has no current version.
  static Future<CurrentMasterKey> of(MasterKeyStore store) async {
    final version = await store.getCurrentVersion();
    final key = version == null ? null : await store.getMasterKey(version);
    if (version == null || key == null) {
      throw const MissingCurrentKeyFailure();
    }
    return CurrentMasterKey(version: version, key: key);
  }
}
