
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_device.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';

class RegisterSyncDeviceUseCase {

  final SyncDeviceRepository _syncDeviceRepository;
  RegisterSyncDeviceUseCase(this._syncDeviceRepository);

  Future<SyncDevice> call({
    required String uuid,
    required String name,
    required String model,
    required String osType,
    required String osVersion,
    required String appVersion,
    String? pushToken
  }) async {

    if (uuid.trim().isEmpty) {
      throw Exception("Invalid or empty device UUID");
    }

    if (name.trim().isEmpty) {
      throw Exception("Invalid or empty device name");
    }

    if (model.trim().isEmpty) {
      throw Exception("Invalid or empty device model");
    }

    final validOsTypes = ['Android', 'iOS', 'android', 'ios'];
    if (!validOsTypes.contains(osType.trim())) {
      throw Exception('Invalid OS type: $osType');
    }

    if (osVersion.trim().isEmpty) {
      throw Exception("Invalid or empty OS version");
    }

    if (appVersion.trim().isEmpty) {
      throw Exception("Invalid or empty APP version");
    }

    final normalizedOsType = osType.trim().toLowerCase() == 'android'
        ? 'ANDROID'
        : 'IOS';

    return await _syncDeviceRepository.registerDevice(
        uuid: uuid.trim(), name: name.trim(), model: model.trim(), osType: normalizedOsType,
        osVersion: osVersion.trim(), appVersion: appVersion.trim(), pushToken: pushToken?.trim()
    );
  }
}