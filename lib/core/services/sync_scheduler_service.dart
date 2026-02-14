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

  /// Schedule background sync based on configuration
  ///
  /// This will schedule a periodic task that runs at the time specified
  /// in the sync configuration (daily or weekly)
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
        '📅 Scheduling sync: ${config.syncFrequency.name} at ${config.syncHour}:${config.syncMinute.toString().padLeft(2, '0')}, initial delay: ${initialDelay.inMinutes} minutes',
        name: 'SyncSchedulerService',
      );

      // Cancel any existing tasks first
      await cancelSync();

      // Schedule periodic task
      await Workmanager().registerPeriodicTask(
        syncTaskName,
        syncTaskName,
        frequency: config.isWeeklySync
            ? const Duration(days: 7)
            : const Duration(days: 1),
        initialDelay: initialDelay,
        constraints: Constraints(
          networkType: config.requiresWifiOnly
              ? NetworkType.unmetered  // WiFi or unlimited data
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
        '✅ Sync scheduled successfully',
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

  /// Reschedule sync when configuration changes
  ///
  /// This cancels existing tasks and schedules new ones based on updated config
  Future<void> rescheduleSync(SyncConfig config) async {
    developer.log('🔄 Rescheduling sync with new configuration', name: 'SyncSchedulerService');

    if (config.autoSyncEnabled) {
      await scheduleSync(config);
    } else {
      await cancelSync();
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
