import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_failures.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_plan.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/device_gallery_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/file_mapping_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/share_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/services/original_content_reader.dart';

/// Shares the originals of some files with another app (WhatsApp, mail…). A file that is in the gallery of this
/// device is shared from there; any other is decrypted into a temporary file of the private cache of the app, removed
/// when the app comes back (ROADMAP-downloads-and-account-deletion.md, Phase 0). At most [maxFiles] at once.
class ShareFilesUseCase {
  static const int maxFiles = 50;

  final FileMappingRepository _mappings;
  final DeviceGalleryRepository _gallery;
  final OriginalContentReader _reader;
  final ShareRepository _share;

  ShareFilesUseCase(this._mappings, this._gallery, this._reader, this._share);

  /// [onPrepared] is called after each file is ready, with how many are.
  Future<void> call(List<RemoteMediaFile> files, {void Function(int prepared, int total)? onPrepared}) async {
    if (files.isEmpty) return;
    if (files.length > maxFiles) {
      throw const TooManyFilesToShareFailure(messageParams: {'max': maxFiles});
    }

    final (mappings, galleryIds) = await (_mappings.all(), _galleryIdsOrEmpty()).wait;
    String? localIdOf(RemoteMediaFile file) {
      final localId = mappings[file.id];
      return localId != null && galleryIds.contains(localId) ? localId : null;
    }

    final toDecrypt = files.where((file) => localIdOf(file) == null).toList();
    final neededBytes = toDecrypt.fold(0, (total, file) => total + file.sizeBytes);
    final freeBytes = await _share.temporaryFreeBytes();
    if (toDecrypt.isNotEmpty && neededBytes + DownloadPlan.reservedBytes > freeBytes) {
      throw NotEnoughSpaceFailure(messageParams: {'needed': neededBytes + DownloadPlan.reservedBytes, 'free': freeBytes});
    }

    final paths = <String>[];
    try {
      for (final file in files) {
        final localId = localIdOf(file);
        if (localId != null) {
          paths.add(await _share.galleryFilePath(localId));
        } else {
          final content = await _reader.read(file.id, isVideo: file.type == FileType.video);
          paths.add(await _share.writeTemporary(content.fileName, content.bytes));
        }
        onPrepared?.call(paths.length, files.length);
      }
    } catch (_) {
      await _share.clearTemporary();
      rethrow;
    }
    await _share.share(paths);
  }

  Future<Set<String>> _galleryIdsOrEmpty() async {
    try {
      return await _gallery.isSupported() ? await _gallery.galleryIds() : <String>{};
    } catch (_) {
      return <String>{};
    }
  }
}
