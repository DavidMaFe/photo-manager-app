import 'package:photo_manager_app/features/devices/domain/repositories/device_repository.dart';

class UnlinkDeviceUseCase {
  final DeviceRepository _repository;

  UnlinkDeviceUseCase(this._repository);

  Future<void> call({required String deviceId}) async {
    return await _repository.unlinkDevice(deviceId: deviceId);
  }
}
