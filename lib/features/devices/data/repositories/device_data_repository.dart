import 'package:photo_manager_app/features/devices/data/data_sources/device_remote_data_source.dart';
import 'package:photo_manager_app/features/devices/domain/entities/device.dart';
import 'package:photo_manager_app/features/devices/domain/repositories/device_repository.dart';

class DeviceDataRepository implements DeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;

  DeviceDataRepository({required this.remoteDataSource});

  @override
  Future<List<Device>> getUserDevices() async {
    return await remoteDataSource.getUserDevices();
  }

  @override
  Future<void> renameDevice({
    required String deviceId,
    required String newName,
  }) async {
    return await remoteDataSource.renameDevice(
      deviceId: deviceId,
      newName: newName,
    );
  }

  @override
  Future<void> toggleAutoSync({
    required String deviceId,
    required bool enabled,
  }) async {
    return await remoteDataSource.toggleAutoSync(
      deviceId: deviceId,
      enabled: enabled,
    );
  }

  @override
  Future<void> unlinkDevice({required String deviceId}) async {
    return await remoteDataSource.unlinkDevice(deviceId: deviceId);
  }
}
