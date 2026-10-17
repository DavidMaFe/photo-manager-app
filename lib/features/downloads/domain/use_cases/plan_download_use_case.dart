import 'package:photo_manager_app/features/downloads/domain/entities/download_failures.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_plan.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/missing_on_device.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/device_gallery_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/compute_missing_on_device_use_case.dart';

/// What a download would save, before starting it: of the chosen files (or of an album, with or without its
/// subalbums), the ones this device is missing, the ones it already has and the free space.
class PlanDownloadUseCase {
  final ComputeMissingOnDeviceUseCase _computeMissing;
  final DeviceGalleryRepository _gallery;

  PlanDownloadUseCase(this._computeMissing, this._gallery);

  /// Throws [DeviceMediaUnsupportedFailure] if this device cannot save into its gallery.
  Future<DownloadPlan> call({Set<String>? fileIds, String? folderId, bool includeSubfolders = false}) async {
    if (!await _gallery.isSupported()) {
      throw const DeviceMediaUnsupportedFailure();
    }
    final (missingOnDevice, storage) = await (
      _computeMissing(folderId: folderId, includeSubfolders: includeSubfolders),
      _gallery.storage(),
    ).wait;

    final MissingOnDevice chosen = fileIds == null
        ? missingOnDevice
        : MissingOnDevice(
            missing: missingOnDevice.missing.where((file) => fileIds.contains(file.id)).toList(),
            onDevice: missingOnDevice.onDevice.where((file) => fileIds.contains(file.id)).toList(),
          );
    return DownloadPlan(toDownload: chosen.missing, alreadyOnDevice: chosen.onDevice.length, storage: storage);
  }
}
