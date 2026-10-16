import 'package:photo_manager_app/features/downloads/domain/entities/missing_on_device.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/device_gallery_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/file_mapping_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/server_files_repository.dart';

/// Which files of the server this device is missing: those without a mapping to its gallery, or whose mapped file is
/// no longer in the gallery (deleted outside the app). It compares three lists of ids, without opening any file
/// (25 ms for 10,000 files on the S23, ROADMAP-downloads-and-account-deletion.md, Phase 0).
class ComputeMissingOnDeviceUseCase {
  final ServerFilesRepository _serverFiles;
  final FileMappingRepository _mappings;
  final DeviceGalleryRepository _gallery;

  ComputeMissingOnDeviceUseCase(this._serverFiles, this._mappings, this._gallery);

  Future<MissingOnDevice> call({String? folderId, bool includeSubfolders = false}) async {
    final (files, mappings, galleryIds) = await (
      _serverFiles.files(folderId: folderId, includeSubfolders: includeSubfolders),
      _mappings.all(),
      _gallery.galleryIds(),
    ).wait;

    final missing = <RemoteMediaFile>[];
    final onDevice = <RemoteMediaFile>[];
    for (final file in files) {
      final localId = mappings[file.id];
      (localId != null && galleryIds.contains(localId) ? onDevice : missing).add(file);
    }
    return MissingOnDevice(missing: missing, onDevice: onDevice);
  }
}
