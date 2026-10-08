import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/repositories/encrypted_media_repository.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/file_key_unwrapper.dart';

/// The decrypted thumbnail or original of a file, in memory only. Originals are decrypted in another isolate so the
/// interface keeps animating.
class LoadMediaUseCase {
  final EncryptedMediaRepository _repository;
  final FileKeyUnwrapper _keyUnwrapper;
  final CryptoEngine _cryptoEngine;

  LoadMediaUseCase(this._repository, this._keyUnwrapper, this._cryptoEngine);

  Future<Uint8List> call(String fileId, MediaVariant variant) async {
    final key = await _keyUnwrapper.keyFor(fileId);
    final encrypted = await _repository.object(fileId, variant);
    if (variant == MediaVariant.thumbnail) {
      return _cryptoEngine.decryptBytes(key, encrypted);
    }
    return _cryptoEngine.decryptBytesInBackground(key, encrypted);
  }
}
