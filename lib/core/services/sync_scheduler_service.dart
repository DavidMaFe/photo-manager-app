import 'dart:developer' as developer;

import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:workmanager/workmanager.dart';

/// Service for scheduling background sync tasks
///
/// This service handles:
/// - Calculating next sync execution time based on sync configuration
/// - Scheduling periodic background tasks with WorkManager
/// - Applying constraints (network, battery, storage)
/// - Canceling scheduled tasks
/// - Rescheduling on configuration changes
/// - Retry scheduling after failures
class SyncSchedulerService {
  // WorkManager task identifier
  static const String syncTaskName = 'background_sync_task';
  static const String syncTaskTag = 'sync';

  // Retry configuration
  static const Duration retryDelay = Duration(hours: 1);

  /// Schedule background sync based on configuration.
  ///
  /// Registers a **one-off** WorkManager task with the exact initial delay
  /// until the user-configured time (e.g. tonight at 2:00 AM).
  ///
  /// After the task executes, [scheduleNextRecurrence] is called from
  /// [backgroundTaskHandler] to register the next occurrence — maintaining
  /// the correct time across days without drift.
  ///
  /// NOTE: [registerPeriodicTask] is intentionally NOT used because Android's
  /// WorkManager silently ignores the [initialDelay] parameter on periodic
  /// tasks, causing the task to fire at an OS-determined time instead of the
  /// user-configured time. Chained one-off tasks are the only reliable way to
  /// hit a specific clock time on Android.
  Future<void> scheduleSync(SyncConfig config) async {
    if (!config.autoSyncEnabled) {
      developer.log(
        '⚠️ Auto-sync disabled, not scheduling',
        name: 'SyncSchedulerService',
      );
      return;
    }

    try {
      // Calculate initial delay until next scheduled time
      final initialDelay = _calculateInitialDelay(config);

      developer.log(
        '📅 Scheduling one-off sync task: ${config.syncFrequency.name} '
        'at ${config.syncHour}:${config.syncMinute.toString().padLeft(2, '0')}, '
        'initial delay: ${initialDelay.inMinutes} min',
        name: 'SyncSchedulerService',
      );

      // Cancel any existing tasks first
      await cancelSync();

      // Schedule as a one-off task with the exact delay to the configured
      // time. backgroundTaskHandler calls scheduleNextRecurrence() after
      // each execution to chain the following occurrence.
      await Workmanager().registerOneOffTask(
        syncTaskName,
        syncTaskName,
        initialDelay: initialDelay,
        constraints: Constraints(
          networkType: config.requiresWifiOnly
              ? NetworkType.unmetered // WiFi or unlimited data
              : NetworkType.connected,
          requiresCharging: false, // We handle battery in BackgroundSyncService
          requiresDeviceIdle: false,
          requiresBatteryNotLow: false, // We handle battery level ourselves
          requiresStorageNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        tag: syncTaskTag,
      );

      developer.log(
        '✅ One-off sync task scheduled (fires in ${initialDelay.inMinutes} min)',
        name: 'SyncSchedulerService',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to schedule sync',
        name: 'SyncSchedulerService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Schedule the next recurrence after a sync task has been executed.
  ///
  /// Called by [backgroundTaskHandler] after each successful run. Computes
  /// the next future occurrence of the configured hour/minute using
  /// [_calculateInitialDelay] and registers a new one-off task.
  ///
  /// Because [_calculateInitialDelay] always finds the **next** future
  /// occurrence, calling this right after a run naturally advances to the
  /// next day (daily) or next week (weekly) with no cumulative drift.
  Future<void> scheduleNextRecurrence(SyncConfig config) async {
    if (!config.autoSyncEnabled) {
      developer.log(
        '⚠️ Auto-sync disabled, skipping next recurrence',
        name: 'SyncSchedulerService',
      );
      return;
    }

    try {
      final nextDelay = _calculateInitialDelay(config);

      developer.log(
        '📅 Scheduling next recurrence: '
        '${config.syncHour}:${config.syncMinute.toString().padLeft(2, '0')} '
        '(in ${nextDelay.inMinutes} min)',
        name: 'SyncSchedulerService',
      );

      await Workmanager().registerOneOffTask(
        syncTaskName,
        syncTaskName,
        initialDelay: nextDelay,
        constraints: Constraints(
          networkType: config.requiresWifiOnly
              ? NetworkType.unmetered
              : NetworkType.connected,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresBatteryNotLow: false,
          requiresStorageNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        tag: syncTaskTag,
      );

      developer.log(
        '✅ Next recurrence scheduled (fires in ${nextDelay.inMinutes} min)',
        name: 'SyncSchedulerService',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to schedule next recurrence — sync chain broken',
        name: 'SyncSchedulerService',
        error: e,
        stackTrace: stackTrace,
      );
      // Do not rethrow: failure here must not affect the current task's
      // return value, and the sync chain can be restored by the user
      // opening the app (rescheduleSync is called on launch).
    }
  }

  /// Schedule a retry sync after a failure
  ///
  /// This schedules a one-time task to run after [retryDelay] (1 hour)
  Future<void> scheduleRetry(SyncConfig config) async {
    try {
      developer.log(
        '🔄 Scheduling retry sync in ${retryDelay.inMinutes} minutes',
        name: 'SyncSchedulerService',
      );

      await Workmanager().registerOneOffTask(
        '${syncTaskName}_retry',
        syncTaskName,
        initialDelay: retryDelay,
        constraints: Constraints(
          networkType: config.requiresWifiOnly
              ? NetworkType.unmetered
              : NetworkType.connected,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresBatteryNotLow: false,
          requiresStorageNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.keep, // Don't replace if already scheduled
        tag: '${syncTaskTag}_retry',
      );

      developer.log(
        '✅ Retry sync scheduled',
        name: 'SyncSchedulerService',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to schedule retry',
        name: 'SyncSchedulerService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Cancel all scheduled sync tasks
  Future<void> cancelSync() async {
    try {
      developer.log('🚫 Canceling scheduled sync tasks', name: 'SyncSchedulerService');

      await Workmanager().cancelByUniqueName(syncTaskName);
      await Workmanager().cancelByTag(syncTaskTag);
      await Workmanager().cancelByTag('${syncTaskTag}_retry');

      developer.log('✅ Sync tasks cancelled', name: 'SyncSchedulerService');
    } catch (e) {
      developer.log(
        '❌ Failed to cancel sync tasks',
        name: 'SyncSchedulerService',
        error: e,
      );
    }
  }

  /// Reschedule sync when the user **explicitly changes** their configuration.
  ///
  /// Cancels existing tasks and registers a fresh one based on the new config.
  /// Use [restoreSyncIfNeeded] for the app-launch scenario instead.
  Future<void> rescheduleSync(SyncConfig config) async {
    developer.log('🔄 Rescheduling sync with new configuration', name: 'SyncSchedulerService');

    if (config.autoSyncEnabled) {
      await scheduleSync(config);
    } else {
      await cancelSync();
    }
  }

  /// Restores the sync schedule on app launch **without disrupting a pending task**.
  ///
  /// Unlike [rescheduleSync] (which cancels then replaces), this method uses
  /// [ExistingWorkPolicy.keep]: if a task with the same unique name is already
  /// pending in WorkManager, it is preserved untouched. A new task is only
  /// registered when none exists (broken chain restoration).
  ///
  /// **Why this matters:** calling [rescheduleSync] on every app launch
  /// cancels the pending 2 AM task and re-registers it from the current
  /// moment — meaning opening the app at 9 AM would permanently shift a 2 AM
  /// schedule to start from 9 AM every day.
  Future<void> restoreSyncIfNeeded(SyncConfig config) async {
    if (!config.autoSyncEnabled) {
      developer.log(
        '⚠️ Auto-sync disabled, skipping restore',
        name: 'SyncSchedulerService',
      );
      return;
    }

    try {
      final nextDelay = _calculateInitialDelay(config);

      developer.log(
        '🔁 Restoring sync schedule if needed '
        '(delay: ${nextDelay.inMinutes} min, policy: keep)',
        name: 'SyncSchedulerService',
      );

      await Workmanager().registerOneOffTask(
        syncTaskName,
        syncTaskName,
        initialDelay: nextDelay,
        constraints: Constraints(
          networkType: config.requiresWifiOnly
              ? NetworkType.unmetered
              : NetworkType.connected,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresBatteryNotLow: false,
          requiresStorageNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        tag: syncTaskTag,
      );

      developer.log(
        '✅ Sync schedule verified (existing task preserved or new task created)',
        name: 'SyncSchedulerService',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Failed to restore sync schedule on launch',
        name: 'SyncSchedulerService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Calculate initial delay until next scheduled sync time
  Duration _calculateInitialDelay(SyncConfig config) {
    final now = DateTime.now();
    DateTime nextSync;

    if (config.isDailySync) {
      // Calculate next daily sync
      nextSync = DateTime(
        now.year,
        now.month,
        now.day,
        config.syncHour,
        config.syncMinute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (nextSync.isBefore(now)) {
        nextSync = nextSync.add(const Duration(days: 1));
      }
    } else {
      // Weekly sync
      final targetDayOfWeek = config.syncDayOfWeek ?? DateTime.monday;

      // Calculate next occurrence of target day
      nextSync = DateTime(
        now.year,
        now.month,
        now.day,
        config.syncHour,
        config.syncMinute,
      );

      // Find next occurrence of the target day
      int daysUntilTarget = (targetDayOfWeek - now.weekday) % 7;

      if (daysUntilTarget == 0) {
        // Today is the target day
        if (nextSync.isBefore(now)) {
          // Time has passed, schedule for next week
          daysUntilTarget = 7;
        }
      }

      nextSync = nextSync.add(Duration(days: daysUntilTarget));
    }

    final delay = nextSync.difference(now);

    developer.log(
      '⏰ Next sync scheduled for: ${nextSync.toLocal()}',
      name: 'SyncSchedulerService',
    );

    return delay;
  }

  /// Calculate time until next sync for display purposes
  Duration? getTimeUntilNextSync(SyncConfig config) {
    if (!config.autoSyncEnabled) {
      return null;
    }

    return _calculateInitialDelay(config);
  }
}
