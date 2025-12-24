import 'package:photo_manager_app/features/sync_session/domain/entities/sync_device.dart';


abstract class SyncDeviceRepository {

  Future<SyncDevice> registerDevice({
    required String uuid,
    required String name,
    required String model,
    required String osType,
    required String osVersion,
    required String appVersion,
    String? pushToken
  });

  Future<String> getDeviceUuid();
  Future<SyncDevice> getCurrentDeviceInfo();
}