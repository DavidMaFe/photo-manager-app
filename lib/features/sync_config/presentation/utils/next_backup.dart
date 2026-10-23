import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/services/next_automatic_backup.dart';

/// Next scheduled backup after [now], or `null` when automatic backup is off. [lastAutomaticBackup]: when the last
/// automatic backup completed (a weekly backup runs at most once per calendar week).
DateTime? nextBackupAt(SyncConfig config, DateTime now, {DateTime? lastAutomaticBackup}) =>
    NextAutomaticBackup.of(config, now, lastCompleted: lastAutomaticBackup);
