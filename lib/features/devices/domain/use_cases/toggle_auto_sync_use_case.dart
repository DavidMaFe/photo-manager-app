import 'package:photo_manager_app/features/devices/domain/repositories/device_repository.dart';

class ToggleAutoSyncUseCase {
  final DeviceRepository _repository;

  ToggleAutoSyncUseCase(this._repository);

  Future<void> call({
    required String deviceId,
    required bool enabled,
  }) async {
    return await _repository.toggleAutoSync(
      deviceId: deviceId,
      enabled: enabled,
    );
  }
}
