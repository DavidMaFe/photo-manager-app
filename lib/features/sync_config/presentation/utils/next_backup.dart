import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';

/// Next scheduled backup after [now], or `null` when automatic backup is off.
DateTime? nextBackupAt(SyncConfig config, DateTime now) {
  if (!config.autoSyncEnabled) return null;

  var candidate = DateTime(now.year, now.month, now.day, config.syncHour, config.syncMinute);

  if (config.isWeeklySync && config.syncDayOfWeek != null) {
    final daysAhead = (config.syncDayOfWeek! - candidate.weekday) % 7;
    candidate = DateTime(candidate.year, candidate.month, candidate.day + daysAhead, config.syncHour, config.syncMinute);
    if (!candidate.isAfter(now)) {
      candidate = DateTime(candidate.year, candidate.month, candidate.day + 7, config.syncHour, config.syncMinute);
    }
    return candidate;
  }

  if (!candidate.isAfter(now)) {
    candidate = DateTime(candidate.year, candidate.month, candidate.day + 1, config.syncHour, config.syncMinute);
  }
  return candidate;
}
