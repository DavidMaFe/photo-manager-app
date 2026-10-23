import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/current_master_key.dart';
import 'package:photo_manager_app/core/crypto/domain/master_key_store.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/encrypted_upload.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/dedup_hasher.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/media_thumbnail_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/original_recompressor.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/storage_budget.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/temporary_files.dart';

import '../entities/upload_result.dart';


/// Encrypts a file of the device and uploads it (docs/e2ee-spec.md, sections 6 and 7):
/// a new key for the file encrypts the content (to a temporary file, chunk by chunk), the thumbnail, the 2048 px
/// version of images bigger than that (ROADMAP-media-compression.md) and the metadata; the key travels wrapped with
/// the current master key. A JPEG is uploaded recompressed into JPEG XL without loss when it can be (`enc: jxl` in the
/// metadata, docs/e2ee-spec.md section 7.1); the duplicate hash is still the one of the JPEG of the device.
class UploadFileUseCase {

  /// The server rejects a bigger 2048 px version (INVALID_FILE_PREVIEW): the file is uploaded without it.
  static const int maxEncryptedPreviewBytes = 4 * 1024 * 1024;

  final SyncSessionRepository _syncSessionRepository;
  final CryptoEngine _cryptoEngine;
  final MasterKeyStore _masterKeyStore;
  final MediaThumbnailSource _thumbnailSource;
  final TemporaryFiles _temporaryFiles;
  final OriginalRecompressor _recompressor;

  UploadFileUseCase(this._syncSessionRepository, this._cryptoEngine, this._masterKeyStore, this._thumbnailSource,
      this._temporaryFiles, this._recompressor);

  /// Throws MissingCurrentKeyFailure if this device has no current master key.
  /// With a [budget], a file that does not fit in the free space of the plan is not sent: it throws
  /// [FileDoesNotFitFailure]. A video is checked before it is encrypted (encrypted it never takes less); an image
  /// after (as JPEG XL it can take less than its original). What is sent is spent from the budget.
  Future<UploadResult> call({required String sessionId, required SyncFile file, StorageBudget? budget}) async {
    if (sessionId.trim().isEmpty) {
      throw Exception("Invalid Sync Session ID");
    }
    if (budget != null && file.isVideo && !budget.fits(file.sizeBytes)) {
      throw FileDoesNotFitFailure(file.sizeBytes);
    }

    final masterKey = await CurrentMasterKey.of(_masterKeyStore);
    final fileKey = _cryptoEngine.generateKey();
    final dedupKey = _cryptoEngine.dedupKey(masterKey.key);
    final encryptedFile = await _temporaryFiles.create('.pmef');
    try {
      final jpegXl = await _recompressor.jpegXlOf(file);
      if (jpegXl != null) {
        await encryptedFile.writeAsBytes(_cryptoEngine.encryptBytes(fileKey, jpegXl), flush: true);
      } else {
        await _cryptoEngine.encryptFile(fileKey, file.file, encryptedFile);
      }
      final thumbnail = await _thumbnailSource.thumbnail(file);
      final preview = file.isImage ? await _thumbnailSource.preview(file) : null;
      final encryptedPreview = preview == null ? null : _cryptoEngine.encryptBytes(fileKey, preview);

      final upload = EncryptedUpload(
        encryptedFile: encryptedFile,
        encryptedThumbnail: thumbnail == null ? null : _cryptoEngine.encryptBytes(fileKey, thumbnail),
        encryptedPreview: encryptedPreview != null && encryptedPreview.length <= maxEncryptedPreviewBytes
            ? encryptedPreview
            : null,
        dedupHash: _cryptoEngine.dedupHash(dedupKey, DedupHasher.hexToBytes(file.hash)),
        isVideo: file.isVideo,
        capturedAt: file.capturedAt,
        width: file.width,
        height: file.height,
        durationSeconds: file.durationSeconds,
        keyVersion: masterKey.version,
        encryptedFileKey: _cryptoEngine.wrapKey(masterKey.key, fileKey.bytes, WrapPurpose.fileKey),
        encryptedMetadata: _cryptoEngine.encryptMetadata(fileKey, {
          'v': jpegXl != null ? 2 : 1,
          'name': file.fileName,
          'mime': file.mimeType,
          if (jpegXl != null) 'enc': 'jxl',
        }),
        localAlbumId: file.localAlbumId,
      );

      // What the server counts in the quota: the three objects (File#storedBytes of the backend)
      final storedBytes = await encryptedFile.length() +
          (upload.encryptedThumbnail?.length ?? 0) +
          (upload.encryptedPreview?.length ?? 0);
      if (budget != null && !budget.fits(storedBytes)) {
        throw FileDoesNotFitFailure(storedBytes);
      }

      final serverId = await _syncSessionRepository.uploadFile(sessionId: sessionId, upload: upload);
      budget?.spend(storedBytes);
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
