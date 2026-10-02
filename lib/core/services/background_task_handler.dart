import 'dart:developer' as developer;

import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_app/core/injection_container.dart' as di;
import 'package:photo_manager_app/core/services/background_sync_service.dart';
import 'package:photo_manager_app/core/services/sync_log_service.dart';
import 'package:photo_manager_app/core/services/sync_notification_service.dart';
import 'package:photo_manager_app/core/services/sync_scheduler_service.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';
import 'package:workmanager/workmanager.dart';

/// Top-level callback function for WorkManager background tasks.
///
/// Runs in a separate isolate — initialises its own DI container, writes
/// every key checkpoint to [SyncLogService] (persisted to SharedPreferences
/// so the result is visible in the UI without USB-connected logcat).
@pragma('vm:entry-point')
void backgroundTaskHandler() {
  Workmanager().executeTask((task, inputData) async {
    SyncLogService? log;

    try {
      // ── Step 1: DI ──────────────────────────────────────────────────────
      if (!GetIt.instance.isRegistered<BackgroundSyncService>()) {
        await di.init();
      }

      log = di.sl<SyncLogService>();
      log.write('▶ WorkManager disparó tarea: $task');

      // ── Step 2: photo_manager — skip Activity-based permission dialog ────
      // In a WorkManager background isolate there is no foreground Activity.
      // Calling PhotoManager.requestPermissionExtend() would crash with
      // NullPointerException inside ActivityResultLauncher. The OS-level
      // permission is already granted by the main app process, so we tell
      // photo_manager to skip the runtime permission check entirely.
      PhotoManager.setIgnorePermissionCheck(true);
      log.write('✓ photo_manager: ignore permission check activado');

      // ── Step 4: Notification service ─────────────────────────────────────
      try {
        final notificationService = di.sl<SyncNotificationService>();
        await notificationService.initializeForBackground();
        log.write('✓ Servicio de notificaciones listo');
      } catch (e) {
        log.write('⚠ Notificaciones: error de inicio ($e) — continúa sin notificación');
      }

      // ── Step 5: Execute sync ─────────────────────────────────────────────
      final backgroundSyncService = di.sl<BackgroundSyncService>();
      final syncSchedulerService = di.sl<SyncSchedulerService>();
      final syncConfigRepository = di.sl<SyncConfigRepository>();

      final success = await backgroundSyncService.execute();

      // Always read the config once for scheduling decisions below.
      final syncConfig = await syncConfigRepository.getSyncConfig();

      if (success) {
        log.write('✓ Tarea completada con éxito — programando siguiente ejecución');

        // Chain the next occurrence. Because scheduleSync uses one-off tasks
        // (not periodic), we must explicitly re-register after each run.
        if (syncConfig != null && syncConfig.autoSyncEnabled) {
          await syncSchedulerService.scheduleNextRecurrence(syncConfig);
          log.write('📅 Siguiente ejecución programada');
        }
      } else {
        // Check whether the failure was auth-related (expired/revoked tokens).
        // Retrying in 1 hour makes no sense for auth failures — the server will
        // reject the request again for the same reason. Instead, maintain the
        // scheduling chain so tomorrow's run still fires at the right time.
        // The user must open the app to re-authenticate.
        final isAuthFailure = backgroundSyncService.wasLastFailureAuthRelated();

        if (isAuthFailure) {
          log.write(
            '✗ Fallo de autenticación — no se programa reintento. '
            'Abre la app para renovar las credenciales.',
          );
          // Still schedule the next recurrence so the chain is not broken.
          if (syncConfig != null && syncConfig.autoSyncEnabled) {
            await syncSchedulerService.scheduleNextRecurrence(syncConfig);
            log.write('📅 Siguiente ejecución mantenida (sin reintento)');
          }
        } else {
          log.write('⚠ Tarea fallida — programando reintento en 1 hora');
          if (syncConfig != null && syncConfig.autoSyncEnabled) {
            await syncSchedulerService.scheduleRetry(syncConfig);
            log.write('↩ Reintento programado en 1 hora');
            // Note: scheduleRetry registers a one-off task with unique name
            // '${syncTaskName}_retry'. When that retry task fires and succeeds,
            // scheduleNextRecurrence will be called, restoring the normal chain.
          }
        }
      }

      log.write('■ WorkManager tarea terminada (retorna true)');
      return Future.value(true);
    } catch (e, stackTrace) {
      developer.log(
        '❌ Background task failed',
        name: 'BackgroundTaskHandler',
        error: e,
        stackTrace: stackTrace,
      );

      log?.write('💥 EXCEPCIÓN NO CAPTURADA: $e');

      // Scheduling after uncaught exception — re-use the already-initialised
      // DI container. For auth errors, schedule the next recurrence instead
      // of a retry (a retry will fail for the same auth reason).
      try {
        if (GetIt.instance.isRegistered<SyncSchedulerService>()) {
          final syncSchedulerService = di.sl<SyncSchedulerService>();
          final syncConfigRepository = di.sl<SyncConfigRepository>();
          final backgroundSyncService = di.sl<BackgroundSyncService>();
          final syncConfig = await syncConfigRepository.getSyncConfig();

          if (syncConfig != null && syncConfig.autoSyncEnabled) {
            final isAuthFailure =
                backgroundSyncService.wasLastFailureAuthRelated();
            if (isAuthFailure) {
              await syncSchedulerService.scheduleNextRecurrence(syncConfig);
              log?.write('📅 Siguiente ejecución programada tras excepción de auth');
            } else {
              await syncSchedulerService.scheduleRetry(syncConfig);
              log?.write('↩ Reintento programado tras excepción');
            }
          }
        }
      } catch (retryError) {
        log?.write('✗ No se pudo programar siguiente ejecución: $retryError');
      }

      return Future.value(true);
    }
  });
}
