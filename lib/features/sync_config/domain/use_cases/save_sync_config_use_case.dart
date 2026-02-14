import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';

class SaveSyncConfigUseCase {
  final SyncConfigRepository _repository;

  SaveSyncConfigUseCase(this._repository);

  Future<void> call(SyncConfig config) async {
    // Validate sync time
    if (config.syncHour < 0 || config.syncHour > 23) {
      throw Exception('Sync hour must be between 0 and 23');
    }

    if (config.syncMinute < 0 || config.syncMinute > 59) {
      throw Exception('Sync minute must be between 0 and 59');
    }

    // Validate day of week for weekly sync
    if (config.isWeeklySync) {
      if (config.syncDayOfWeek == null) {
        throw Exception('Day of week is required for weekly sync');
      }
      if (config.syncDayOfWeek! < 1 || config.syncDayOfWeek! > 7) {
        throw Exception('Day of week must be between 1 (Monday) and 7 (Sunday)');
      }
    }

    await _repository.saveSyncConfig(config);
  }
}
