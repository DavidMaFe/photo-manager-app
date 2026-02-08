import 'package:photo_manager_app/features/devices/domain/entities/device.dart';
import 'package:photo_manager_app/features/devices/domain/repositories/device_repository.dart';

class GetUserDevicesUseCase {
  final DeviceRepository _repository;

  GetUserDevicesUseCase(this._repository);

  Future<List<Device>> call() async {
    return await _repository.getUserDevices();
  }
}
