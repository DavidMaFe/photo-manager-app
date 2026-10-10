import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/current_master_key.dart';
import 'package:photo_manager_app/core/crypto/domain/master_key_store.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/encrypted_upload.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/dedup_hasher.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/media_thumbnail_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/temporary_files.dart';

import '../entities/upload_result.dart';


/// Encrypts a file of the device and uploads it (docs/e2ee-spec.md, sections 6 and 7):
/// a new key for the file encrypts the content (to a temporary file, chunk by chunk), the thumbnail and the metadata;
/// the key travels wrapped with the current master key.
class UploadFileUseCase {

  final SyncSessionRepository _syncSessionRepository;
  final CryptoEngine _cryptoEngine;
  final MasterKeyStore _masterKeyStore;
  final MediaThumbnailSource _thumbnailSource;
  final TemporaryFiles _temporaryFiles;

  UploadFileUseCase(this._syncSessionRepository, this._cryptoEngine, this._masterKeyStore, this._thumbnailSource,
      this._temporaryFiles);

  /// Throws MissingCurrentKeyFailure if this device has no current master key.
  Future<UploadResult> call({required String sessionId, required SyncFile file}) async {
    if (sessionId.trim().isEmpty) {
      throw Exception("Invalid Sync Session ID");
    }

    final masterKey = await CurrentMasterKey.of(_masterKeyStore);
    final fileKey = _cryptoEngine.generateKey();
    final dedupKey = _cryptoEngine.dedupKey(masterKey.key);
    final encryptedFile = await _temporaryFiles.create('.pmef');
    try {
      await _cryptoEngine.encryptFile(fileKey, file.file, encryptedFile);
      final thumbnail = await _thumbnailSource.thumbnail(file);

      final upload = EncryptedUpload(
        encryptedFile: encryptedFile,
        encryptedThumbnail: thumbnail == null ? null : _cryptoEngine.encryptBytes(fileKey, thumbnail),
        dedupHash: _cryptoEngine.dedupHash(dedupKey, DedupHasher.hexToBytes(file.hash)),
        isVideo: file.isVideo,
        capturedAt: file.capturedAt,
        width: file.width,
        height: file.height,
        durationSeconds: file.durationSeconds,
        keyVersion: masterKey.version,
        encryptedFileKey: _cryptoEngine.wrapKey(masterKey.key, fileKey.bytes, WrapPurpose.fileKey),
        encryptedMetadata: _cryptoEngine.encryptMetadata(fileKey, {'v': 1, 'name': file.fileName, 'mime': file.mimeType}),
      );

      final serverId = await _syncSessionRepository.uploadFile(sessionId: sessionId, upload: upload);
      return UploadResult(serverFileId: serverId);
    } finally {
      fileKey.dispose();
      dedupKey.dispose();
      if (await encryptedFile.exists()) {
        await encryptedFile.delete();
      }
    }
  }
}
