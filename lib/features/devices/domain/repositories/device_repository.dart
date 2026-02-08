import 'package:photo_manager_app/features/devices/domain/entities/device.dart';

abstract class DeviceRepository {
  Future<List<Device>> getUserDevices();

  Future<void> renameDevice({
    required String deviceId,
    required String newName,
  });

  Future<void> toggleAutoSync({
    required String deviceId,
    required bool enabled,
  });

  Future<void> unlinkDevice({required String deviceId});
}
