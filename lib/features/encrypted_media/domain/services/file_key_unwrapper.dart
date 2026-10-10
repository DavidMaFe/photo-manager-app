import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/master_key_store.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_failures.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/repositories/file_key_repository.dart';

/// Opens the key of a file with the master key of its version. The keys stay in memory only, and are forgotten at
/// logout.
class FileKeyUnwrapper {
  final CryptoEngine _cryptoEngine;
  final MasterKeyStore _masterKeyStore;
  final FileKeyRepository _fileKeyRepository;
  final Map<String, CryptoKey> _keys = {};

  FileKeyUnwrapper(this._cryptoEngine, this._masterKeyStore, this._fileKeyRepository);

  /// Throws LockedFileFailure if this device does not hold the master key of the file, and UnencryptedFileFailure if
  /// the file has no key.
  Future<CryptoKey> keyFor(String fileId) async {
    final cached = _keys[fileId];
    if (cached != null) {
      return cached;
    }
    final ref = await _fileKeyRepository.refFor(fileId);
    final masterKey = await _masterKeyStore.getMasterKey(ref.keyVersion);
    if (masterKey == null) {
      throw const LockedFileFailure();
    }
    final key = CryptoKey(_cryptoEngine.unwrapKey(masterKey, ref.encryptedFileKey, WrapPurpose.fileKey));
    return _keys[fileId] = key;
  }

  void clear() {
    for (final key in _keys.values) {
      key.dispose();
    }
    _keys.clear();
  }
}
