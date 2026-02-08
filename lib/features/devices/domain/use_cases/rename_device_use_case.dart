import 'package:photo_manager_app/features/devices/domain/repositories/device_repository.dart';

class RenameDeviceUseCase {
  final DeviceRepository _repository;

  RenameDeviceUseCase(this._repository);

  Future<void> call({
    required String deviceId,
    required String newName,
  }) async {
    if (newName.trim().isEmpty) {
      throw Exception('Device name cannot be empty');
    }

    return await _repository.renameDevice(
      deviceId: deviceId,
      newName: newName.trim(),
    );
  }
}
