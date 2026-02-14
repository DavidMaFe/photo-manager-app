import 'dart:developer' as developer;

import 'package:photo_manager_app/core/injection_container.dart' as di;
import 'package:photo_manager_app/core/services/background_sync_service.dart';
import 'package:photo_manager_app/core/services/sync_scheduler_service.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';
import 'package:workmanager/workmanager.dart';

/// Top-level callback function for WorkManager background tasks
///
/// This function is called by WorkManager when a scheduled task needs to run.
/// It must be a top-level function (not a method) to work with WorkManager.
///
/// IMPORTANT: This function runs in an isolate separate from the main app,
/// so it needs to initialize its own dependency injection container.
@pragma('vm:entry-point')
void backgroundTaskHandler() {
  Workmanager().executeTask((task, inputData) async {
    developer.log(
      '🚀 Background task started: $task',
      name: 'BackgroundTaskHandler',
    );

    try {
      // Initialize dependency injection
      await di.init();

      // Get services from DI container
      final backgroundSyncService = di.sl<BackgroundSyncService>();
      final syncSchedulerService = di.sl<SyncSchedulerService>();
      final syncConfigRepository = di.sl<SyncConfigRepository>();

      // Execute sync
      final success = await backgroundSyncService.execute();

      if (success) {
        developer.log(
          '✅ Background task completed successfully',
          name: 'BackgroundTaskHandler',
        );
        return Future.value(true);
      } else {
        developer.log(
          '⚠️ Background task completed with issues',
          name: 'BackgroundTaskHandler',
        );

        // Schedule retry on failure
        final syncConfig = await syncConfigRepository.getSyncConfig();
        if (syncConfig != null && syncConfig.autoSyncEnabled) {
          await syncSchedulerService.scheduleRetry(syncConfig);
        }

        // Return true to prevent WorkManager from retrying immediately
        // We handle our own retry logic with scheduleRetry()
        return Future.value(true);
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Background task failed',
        name: 'BackgroundTaskHandler',
        error: e,
        stackTrace: stackTrace,
      );

      // Schedule retry on error
      try {
        await di.init();
        final syncSchedulerService = di.sl<SyncSchedulerService>();
        final syncConfigRepository = di.sl<SyncConfigRepository>();
        final syncConfig = await syncConfigRepository.getSyncConfig();

        if (syncConfig != null && syncConfig.autoSyncEnabled) {
          await syncSchedulerService.scheduleRetry(syncConfig);
        }
      } catch (retryError) {
        developer.log(
          '❌ Failed to schedule retry',
          name: 'BackgroundTaskHandler',
          error: retryError,
        );
      }

      // Return true to prevent WorkManager from retrying immediately
      return Future.value(true);
    }
  });
}
