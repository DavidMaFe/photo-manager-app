import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/file_metadata.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/repositories/file_key_repository.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/file_key_unwrapper.dart';

/// Original name and real MIME type of a file, decrypted on this device.
class GetFileMetadataUseCase {
  final FileKeyRepository _fileKeyRepository;
  final FileKeyUnwrapper _keyUnwrapper;
  final CryptoEngine _cryptoEngine;

  GetFileMetadataUseCase(this._fileKeyRepository, this._keyUnwrapper, this._cryptoEngine);

  /// Empty metadata if the file has none.
  Future<FileMetadata> call(String fileId) async {
    final ref = await _fileKeyRepository.refFor(fileId);
    final encrypted = ref.encryptedMetadata;
    if (encrypted == null) {
      return const FileMetadata();
    }
    final key = await _keyUnwrapper.keyFor(fileId);
    return FileMetadata.fromDecrypted(_cryptoEngine.decryptMetadata(key, encrypted));
  }
}
