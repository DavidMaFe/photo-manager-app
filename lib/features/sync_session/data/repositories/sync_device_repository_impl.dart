import 'package:photo_manager_app/features/sync_session/data/data_sources/local/sync_device_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/remote/sync_device_remote_data_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_device.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';


class SyncDeviceRepositoryImpl implements SyncDeviceRepository {

  final SyncDeviceRemoteDataSource remoteDataSource;
  final SyncDeviceLocalDataSource localDataSource;

  SyncDeviceRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<SyncDevice> registerDevice({
    required String uuid,
    required String name,
    required String model,
    required String osType,
    required String osVersion,
    required String appVersion,
    String? pushToken
  }) async {

    return await remoteDataSource.registerDevice(
        uuid: uuid,
        name: name,
        model: model,
        osType: osType,
        osVersion: osVersion,
        appVersion: appVersion,
        pushToken: pushToken);
  }

  @override
  Future<SyncDevice> getCurrentDeviceInfo() async {
    return await localDataSource.getCurrentDeviceInfo();
  }

  @override
  Future<String> getDeviceUuid() async {
    return await localDataSource.getDeviceUuid();
  }
}