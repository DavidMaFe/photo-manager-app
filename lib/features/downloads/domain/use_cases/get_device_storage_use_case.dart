import 'package:photo_manager_app/features/downloads/domain/entities/device_storage.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/device_gallery_repository.dart';

/// Free and total space of this device, or null where the app cannot save into the gallery.
class GetDeviceStorageUseCase {
  final DeviceGalleryRepository _gallery;

  GetDeviceStorageUseCase(this._gallery);

  Future<DeviceStorage?> call() async {
    if (!await _gallery.isSupported()) return null;
    return _gallery.storage();
  }
}
