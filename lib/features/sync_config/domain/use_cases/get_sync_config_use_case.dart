import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';

class GetSyncConfigUseCase {
  final SyncConfigRepository _repository;

  GetSyncConfigUseCase(this._repository);

  Future<SyncConfig> call() async {
    final config = await _repository.getSyncConfig();

    // Return disabled config if no configuration exists
    return config ?? SyncConfig.disabled();
  }
}
