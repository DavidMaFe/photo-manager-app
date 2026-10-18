import 'package:photo_manager_app/features/downloads/domain/entities/downloadable_file.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/device_gallery_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/file_mapping_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/services/original_content_reader.dart';

/// Saves the exact original of a file into the gallery of this device and remembers which file of the gallery it is,
/// so a sync never uploads it again. Photos go to `Pictures/PhotoManager[/<album>]`, videos to `Movies/...`, dated
/// when they were taken. Returns the id in the gallery.
class SaveOriginalToGalleryUseCase {
  static const String galleryFolder = 'PhotoManager';

  final OriginalContentReader _reader;
  final DeviceGalleryRepository _gallery;
  final FileMappingRepository _mappings;

  SaveOriginalToGalleryUseCase(this._reader, this._gallery, this._mappings);

  Future<String> call(DownloadableFile file, {String? album}) async {
    final content = await _reader.read(file.id, isVideo: file.isVideo);
    final relativePath = relativePathFor(isVideo: content.isVideo, album: album);
    final localId = await _gallery.save(
      relativePath: relativePath,
      fileName: content.fileName,
      mimeType: content.mimeType,
      takenAt: file.capturedAt,
      bytes: content.bytes,
    );
    await _mappings.save(serverId: file.id, localId: localId, localPath: '$relativePath/${content.fileName}');
    return localId;
  }

  /// Folder of the gallery for a file; [album] without the characters a folder name cannot have.
  static String relativePathFor({required bool isVideo, String? album}) {
    final base = '${isVideo ? 'Movies' : 'Pictures'}/$galleryFolder';
    final folder = album?.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_').trim();
    return folder == null || folder.isEmpty || folder == '.' || folder == '..' ? base : '$base/$folder';
  }
}
