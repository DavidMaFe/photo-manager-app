import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';

/// The free plan backs up weekly (ROADMAP-subscriptions.md in the backend): when the plan does not include the daily
/// backup, a daily automatic backup becomes weekly, at the same time (on Mondays unless a day was chosen before), and
/// is scheduled again. The server does not keep the backup schedule, so the app applies it.
class ApplyPlanToSyncConfigUseCase {
  final SyncConfigRepository _repository;
  final Future<void> Function(SyncConfig config) _reschedule;

  ApplyPlanToSyncConfigUseCase(this._repository, {required Future<void> Function(SyncConfig config) reschedule})
      : _reschedule = reschedule;

  /// Whether the backup changed to weekly.
  Future<bool> call({required bool dailyBackup}) async {
    if (dailyBackup) return false;
    final config = await _repository.getSyncConfig();
    if (config == null || !config.isDailySync) return false;

    final weekly = config.copyWith(
      syncFrequency: SyncFrequency.weekly,
      syncDayOfWeek: config.syncDayOfWeek ?? DateTime.monday,
    );
    await _repository.saveSyncConfig(weekly);
    if (weekly.autoSyncEnabled) {
      await _reschedule(weekly);
    }
    return true;
  }
}
