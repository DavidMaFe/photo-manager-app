import 'package:photo_manager_app/features/sync_config/data/data_sources/sync_config_local_data_source.dart';
import 'package:photo_manager_app/features/sync_config/data/models/sync_config_model.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';

class SyncConfigDataRepository implements SyncConfigRepository {
  final SyncConfigLocalDataSource localDataSource;

  SyncConfigDataRepository({required this.localDataSource});

  @override
  Future<SyncConfig?> getSyncConfig() async {
    return await localDataSource.getSyncConfig();
  }

  @override
  Future<void> saveSyncConfig(SyncConfig config) async {
    final model = SyncConfigModel.fromEntity(config);
    await localDataSource.cacheSyncConfig(model);
  }

  @override
  Future<void> clearSyncConfig() async {
    await localDataSource.clearSyncConfig();
  }

  @override
  Future<bool> hasSyncConfig() async {
    return await localDataSource.hasSyncConfig();
  }
}
