import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';

abstract class SyncConfigRepository {
  /// Get the current sync configuration
  /// Returns null if no configuration exists
  Future<SyncConfig?> getSyncConfig();

  /// Save sync configuration
  Future<void> saveSyncConfig(SyncConfig config);

  /// Clear sync configuration
  Future<void> clearSyncConfig();

  /// Check if sync configuration exists
  Future<bool> hasSyncConfig();

  /// When the last automatic backup of this device completed, or null.
  Future<DateTime?> lastAutomaticBackupAt();

  Future<void> recordAutomaticBackup(DateTime completedAt);
}
