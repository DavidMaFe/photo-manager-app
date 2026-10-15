import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/jpeg_xl/domain/jpeg_xl_codec.dart';
import 'package:photo_manager_app/core/jpeg_xl/domain/jpeg_xl_format.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/repositories/encrypted_media_repository.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/file_key_unwrapper.dart';

/// The decrypted thumbnail, 2048 px version or original of a file, in memory only. The 2048 px version and the
/// original are decrypted in another isolate so the interface keeps animating. An original stored in JPEG XL comes
/// back as its exact JPEG, which every decoder shows (throws [JpegXlUnavailableFailure] if this device cannot rebuild
/// it).
class LoadMediaUseCase {
  final EncryptedMediaRepository _repository;
  final FileKeyUnwrapper _keyUnwrapper;
  final CryptoEngine _cryptoEngine;
  final JpegXlCodec _jpegXlCodec;

  LoadMediaUseCase(this._repository, this._keyUnwrapper, this._cryptoEngine, this._jpegXlCodec);

  Future<Uint8List> call(String fileId, MediaVariant variant) async {
    final key = await _keyUnwrapper.keyFor(fileId);
    final encrypted = await _repository.object(fileId, variant);
    if (variant == MediaVariant.thumbnail) {
      return _cryptoEngine.decryptBytes(key, encrypted);
    }
    final bytes = await _cryptoEngine.decryptBytesInBackground(key, encrypted);
    if (variant == MediaVariant.original && JpegXlFormat.isJpegXl(bytes)) {
      return _jpegXlCodec.jxlToJpeg(bytes);
    }
    return bytes;
  }
}
