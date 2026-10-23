import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';

/// When the next automatic backup runs (ROADMAP-local-albums.md, Phase 6).
///
/// A weekly backup runs at most once per calendar week (Monday to Sunday): when an automatic backup already completed
/// in the week of the next chosen day, it moves to the same day of the next week. Otherwise changing the day after a
/// backup (Monday → Tuesday) would give the free plan a daily backup. A backup that failed does not count, so its
/// retry still runs. Manual backups do not count either.
class NextAutomaticBackup {
  const NextAutomaticBackup._();

  /// The next automatic backup after [now], or null when the automatic backup is off. [lastCompleted]: when the last
  /// automatic backup completed.
  static DateTime? of(SyncConfig config, DateTime now, {DateTime? lastCompleted}) {
    if (!config.autoSyncEnabled) return null;

    var candidate = DateTime(now.year, now.month, now.day, config.syncHour, config.syncMinute);

    if (config.isWeeklySync) {
      final daysAhead = ((config.syncDayOfWeek ?? DateTime.monday) - candidate.weekday) % 7;
      candidate = _plusDays(candidate, daysAhead, config);
      if (!candidate.isAfter(now)) {
        candidate = _plusDays(candidate, 7, config);
      }
      if (lastCompleted != null && _sameWeek(candidate, lastCompleted)) {
        candidate = _plusDays(candidate, 7, config);
      }
      return candidate;
    }

    if (!candidate.isAfter(now)) {
      candidate = _plusDays(candidate, 1, config);
    }
    return candidate;
  }

  /// Whether a weekly automatic backup already completed in the week of [now]: a task scheduled before the day was
  /// changed must not back up again.
  static bool alreadyDoneThisWeek(SyncConfig config, DateTime now, DateTime? lastCompleted) =>
      config.isWeeklySync && lastCompleted != null && _sameWeek(now, lastCompleted);

  /// Monday 00:00 of the week of [date].
  static DateTime weekStart(DateTime date) => DateTime(date.year, date.month, date.day - (date.weekday - 1));

  static bool _sameWeek(DateTime a, DateTime b) => weekStart(a) == weekStart(b.toLocal());

  // Day by day in local time, so a change of the summer time does not move the hour
  static DateTime _plusDays(DateTime date, int days, SyncConfig config) =>
      DateTime(date.year, date.month, date.day + days, config.syncHour, config.syncMinute);
}
